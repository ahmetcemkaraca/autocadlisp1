;;; ---------------------------------------------------------------------------
;;; 10-polyline.lsp - reading, building and joining polyline geometry
;;;
;;; A polyline is modelled as a list of vertices (POINT . BULGE).  The bulge
;;; of a vertex describes the segment that starts at that vertex and ends at
;;; the next one (for a closed polyline the last vertex describes the closing
;;; segment).  Points are 3D and expressed in the polyline's OCS.
;;; ---------------------------------------------------------------------------

;;; --- Classification --------------------------------------------------------

(defun plx:flags (ename / flags)
  (setq flags (cdr (assoc 70 (entget ename))))
  (if flags flags 0))

(defun plx:kind (ename)
  (cdr (assoc 0 (entget ename))))

(defun plx:polyline-p (ename)
  (and ename (member (plx:kind ename) '("LWPOLYLINE" "POLYLINE")) T))

;; Heavy POLYLINE that is a 3D polygon mesh or a polyface mesh.
(defun plx:mesh-p (ename)
  (and (= (plx:kind ename) "POLYLINE")
       (/= 0 (logand 80 (plx:flags ename)))))

;; Heavy POLYLINE that is a 3D polyline (vertices are WCS points).
(defun plx:3d-p (ename)
  (and (= (plx:kind ename) "POLYLINE")
       (/= 0 (logand 8 (plx:flags ename)))))

(defun plx:closed-p (ename)
  (/= 0 (logand 1 (plx:flags ename))))

;; Polyline whose vertices live in one plane (LWPOLYLINE or 2D POLYLINE).
(defun plx:flat-p (ename)
  (and (plx:polyline-p ename)
       (not (plx:mesh-p ename))
       (not (plx:3d-p ename))))

;; Open, flat polyline - the only kind that can be joined end to end.
(defun plx:joinable-p (ename)
  (and (plx:flat-p ename)
       (not (plx:closed-p ename))))

(defun plx:normal (ename / normal)
  (setq normal (cdr (assoc 210 (entget ename))))
  (if normal normal '(0.0 0.0 1.0)))

;; Coordinate system the vertex points of ENAME are expressed in, suitable as
;; the "from" argument of TRANS: the entity itself (OCS) or 0 (WCS).
(defun plx:space (ename)
  (if (plx:3d-p ename) 0 ename))

(defun plx:comparable-p (a b)
  (equal (plx:normal a) (plx:normal b) 1e-8))

;;; --- Reading ---------------------------------------------------------------

(defun plx:lw-vertices (data / elev verts item)
  (setq elev (cdr (assoc 38 data)))
  (if (not elev) (setq elev 0.0))
  (foreach item data
    (cond
      ((= (car item) 10)
       (setq verts (cons (cons (list (cadr item) (caddr item) elev) 0.0) verts)))
      ((and (= (car item) 42) verts)
       (setq verts (cons (cons (car (car verts)) (cdr item)) (cdr verts))))))
  (reverse verts))

(defun plx:heavy-vertices (ename data / flat elev vert vdata pt bulge verts)
  (setq flat (zerop (logand 8 (plx:flags ename)))
        elev (caddr (cdr (assoc 10 data)))
        vert (entnext ename))
  (if (not elev) (setq elev 0.0))
  (while (and vert
              (= (cdr (assoc 0 (setq vdata (entget vert)))) "VERTEX"))
    ;; Skip spline frame control points (vertex flag 16).
    (if (zerop (logand 16 (plx:flags vert)))
      (progn
        (setq pt    (cdr (assoc 10 vdata))
              bulge (cdr (assoc 42 vdata)))
        (if flat (setq pt (list (car pt) (cadr pt) elev)))
        (setq verts (cons (cons pt (if bulge bulge 0.0)) verts))))
    (setq vert (entnext vert)))
  (reverse verts))

;; Vertex list of an LWPOLYLINE or POLYLINE; nil for anything else.
(defun plx:vertices (ename / data kind)
  (setq data (entget ename)
        kind (cdr (assoc 0 data)))
  (cond
    ((= kind "LWPOLYLINE") (plx:lw-vertices data))
    ((and (= kind "POLYLINE") (not (plx:mesh-p ename)))
     (plx:heavy-vertices ename data))))

;;; --- Writing ---------------------------------------------------------------

;; Create an LWPOLYLINE from VERTS, taking layer, color, linetype, linetype
;; scale and lineweight from the entity REF.  Returns the new entity or nil.
(defun plx:make-lwpolyline (verts closed ref / rdata code props elev)
  (setq rdata (entget ref)
        elev  (caddr (car (car verts))))
  (foreach code '(6 62 48 370)
    (if (assoc code rdata)
      (setq props (append props (list (assoc code rdata))))))
  (if (entmake
        (append
          (list '(0 . "LWPOLYLINE")
                '(100 . "AcDbEntity")
                (cons 8 (cdr (assoc 8 rdata))))
          props
          (list '(100 . "AcDbPolyline")
                (cons 90 (length verts))
                (cons 70 (if closed 1 0))
                (cons 38 elev))
          (apply 'append
                 (mapcar '(lambda (v)
                            (list (cons 10 (list (car (car v)) (cadr (car v))))
                                  (cons 42 (cdr v))))
                         verts))
          (list (cons 210 (plx:normal ref)))))
    (entlast)))

;; Copy layer, color, linetype, linetype scale and lineweight from SRC to DST.
(defun plx:copy-props (src dst / sdata ddata code new old)
  (setq sdata (entget src)
        ddata (entget dst))
  (foreach code '(8 6 62 48 370)
    (setq new (assoc code sdata)
          old (assoc code ddata))
    (cond
      ((and new old) (setq ddata (subst new old ddata)))
      (new           (setq ddata (append ddata (list new))))
      (old           (setq ddata (vl-remove old ddata)))))
  (entmod ddata)
  (entupd dst)
  dst)

;;; --- Joining ---------------------------------------------------------------

;; Reverse the direction of a vertex list.  Bulges are negated and shifted to
;; the vertex that now starts the segment.
(defun plx:reverse-verts (verts)
  (mapcar 'cons
          (reverse (mapcar 'car verts))
          (append (mapcar '- (reverse (mapcar 'cdr (plx:butlast verts))))
                  (list 0.0))))

;; Append B to A; the end of A and the start of B are assumed to coincide.
(defun plx:concat-verts (a b)
  (append (plx:butlast a)
          (list (cons (car (last a)) (cdr (car b))))
          (cdr b)))

;; Join two open vertex lists end to end, reversing either one if needed.
;; Returns the joined list or nil when no pair of endpoints is within TOL.
(defun plx:join-verts (a b tol / a-start a-end b-start b-end)
  (setq a-start (car (car a))
        a-end   (car (last a))
        b-start (car (car b))
        b-end   (car (last b)))
  (cond
    ((plx:near a-end b-start tol)   (plx:concat-verts a b))
    ((plx:near a-end b-end tol)     (plx:concat-verts a (plx:reverse-verts b)))
    ((plx:near a-start b-start tol) (plx:concat-verts (plx:reverse-verts a) b))
    ((plx:near a-start b-end tol)   (plx:concat-verts b a))))

;; If the first and last vertex coincide, drop the duplicate and report the
;; polyline as closed.  Returns (VERTS . CLOSED).
(defun plx:close-ring (verts tol)
  (if (and (>= (length verts) 4)
           (plx:near (car (car verts)) (car (last verts)) tol))
    (cons (plx:butlast verts) T)
    (cons verts nil)))

;; Repeatedly merge touching chains.  A chain is (VERTS SOURCES) where SOURCES
;; lists the original entities it was built from.  Returns the final chains.
(defun plx:merge-chains (chains tol / changed i j a b joined)
  (setq changed T)
  (while changed
    (setq changed nil
          i       0)
    (while (and (not changed) (< i (length chains)))
      (setq a (nth i chains)
            j (1+ i))
      (while (and (not changed) (< j (length chains)))
        (setq b (nth j chains))
        (if (and (plx:comparable-p (car (cadr a)) (car (cadr b)))
                 (setq joined (plx:join-verts (car a) (car b) tol)))
          (setq chains  (append (plx:remove-nth i (plx:remove-nth j chains))
                                (list (list joined (append (cadr a) (cadr b)))))
                changed T))
        (setq j (1+ j)))
      (setq i (1+ i))))
  chains)
