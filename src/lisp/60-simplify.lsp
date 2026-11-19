;;; ---------------------------------------------------------------------------
;;; 60-simplify.lsp - SIMPLIFYPL: reduce polyline vertices (Douglas-Peucker)
;;;
;;; Arc segments are never touched.  Each run of straight segments between
;;; arcs (or between the ends of the polyline) is simplified on its own with
;;; its end points fixed.
;;; ---------------------------------------------------------------------------

(if (not *plx-simplify-tol*) (setq *plx-simplify-tol* 0.5))

(defun plx:dist2d (p q)
  (distance (list (car p) (cadr p)) (list (car q) (cadr q))))

;; Distance in the XY plane from P to the segment A-B.
(defun plx:point-segment-distance (p a b / dx dy len2 u)
  (setq dx   (- (car b) (car a))
        dy   (- (cadr b) (cadr a))
        len2 (+ (* dx dx) (* dy dy)))
  (if (< len2 1e-18)
    (plx:dist2d p a)
    (progn
      (setq u (/ (+ (* (- (car p) (car a)) dx)
                    (* (- (cadr p) (cadr a)) dy))
                 len2))
      (cond
        ((< u 0.0) (plx:dist2d p a))
        ((> u 1.0) (plx:dist2d p b))
        (T (plx:dist2d p (list (+ (car a) (* u dx))
                               (+ (cadr a) (* u dy)))))))))

(defun plx:take (n lst / out)
  (repeat n
    (setq out (cons (car lst) out)
          lst (cdr lst)))
  (reverse out))

(defun plx:drop (n lst)
  (repeat n
    (setq lst (cdr lst)))
  lst)

;; Douglas-Peucker on a list of points; the first and last point are kept.
(defun plx:douglas-peucker (pts eps / a b worst worst-i i d p)
  (if (<= (length pts) 2)
    pts
    (progn
      (setq a       (car pts)
            b       (last pts)
            worst   -1.0
            worst-i 0
            i       1)
      (foreach p (cdr (plx:butlast pts))
        (setq d (plx:point-segment-distance p a b))
        (if (> d worst)
          (setq worst   d
                worst-i i))
        (setq i (1+ i)))
      (if (> worst eps)
        (append (plx:douglas-peucker (plx:take (1+ worst-i) pts) eps)
                (cdr (plx:douglas-peucker (plx:drop worst-i pts) eps)))
        (list a b)))))

;; Simplify the points of one straight run.  Every returned vertex has a zero
;; bulge except the last one, which gets LAST-BULGE (the arc that follows).
(defun plx:simplify-run (pts last-bulge eps / simple out p)
  (setq simple (plx:douglas-peucker pts eps))
  (foreach p (plx:butlast simple)
    (setq out (cons (cons p 0.0) out)))
  (reverse (cons (cons (last simple) last-bulge) out)))

;; Simplify an OPEN vertex list.  Returns a new vertex list.
(defun plx:simplify-open (verts eps / n i v run out)
  (setq n (1- (length verts))
        i 0)
  (repeat n
    (setq v   (nth i verts)
          run (cons (car v) run))
    (if (/= 0.0 (cdr v))
      (setq out (append out (plx:simplify-run (reverse run) (cdr v) eps))
            run nil))
    (setq i (1+ i)))
  (setq run (cons (car (last verts)) run))
  (append out (plx:simplify-run (reverse run) 0.0 eps)))

;; Index of the first vertex that starts an arc segment, or nil.
(defun plx:first-arc-index (verts / i found v)
  (setq i 0)
  (foreach v verts
    (if (and (not found) (/= 0.0 (cdr v)))
      (setq found i))
    (setq i (1+ i)))
  found)

;; Simplify a vertex list.  Returns (VERTS . CLOSED).  Closed polylines are
;; rotated to start at an arc (when there is one), simplified as an open
;; polyline that returns to its start, and closed again.
(defun plx:simplify-verts (verts closed eps / k rotated result)
  (if (not closed)
    (cons (plx:simplify-open verts eps) nil)
    (progn
      (setq k       (plx:first-arc-index verts)
            rotated (if (and k (> k 0))
                      (append (plx:drop k verts) (plx:take k verts))
                      verts)
            result  (plx:simplify-open
                      (append rotated (list (cons (car (car rotated)) 0.0)))
                      eps))
      (cons (plx:butlast result) T))))

;;; SIMPLIFYPL - reduce the vertex count of polylines within a tolerance.
(defun c:simplifypl (/ tol enames done removed skipped ename verts closed result new)
  (plx:begin nil)
  (setq tol (plx:ask-real 'simp-tol *plx-simplify-tol*)
        *plx-simplify-tol* tol
        done 0 removed 0 skipped 0)
  (if (setq enames (plx:select-polylines))
    (progn
      (foreach ename enames
        (if (not (plx:flat-p ename))
          (setq skipped (1+ skipped))
          (progn
            (setq verts  (plx:vertices ename)
                  closed (plx:closed-p ename)
                  result (plx:simplify-verts verts closed tol))
            (if (and (< (length (car result)) (length verts))
                     (>= (length (car result)) (if closed 3 2))
                     (setq new (plx:make-lwpolyline (car result) (cdr result) ename)))
              (progn
                (entdel ename)
                (setq done    (1+ done)
                      removed (+ removed (- (length verts) (length (car result))))))))))
      (if (> skipped 0) (plx:say 'simp-skipped (list skipped)))
      (if (> done 0)
        (plx:say 'simp-done (list done removed))
        (plx:say 'simp-nochange nil)))
    (plx:say 'nothing nil))
  (plx:end))
