;;; polyline-tools.lsp - PolylineTools 2.0.0
;;; GENERATED FILE - do not edit. Edit src/lisp/*.lsp and run scripts/build.ps1.
;;; https://github.com/ahmetcemkaraca/autocadlisp  (GPL-3.0)

;;; ===== 00-core.lsp =====

;;; ---------------------------------------------------------------------------
;;; 00-core.lsp - shared infrastructure: settings, messages, environment guard
;;; ---------------------------------------------------------------------------

(vl-load-com)

(setq *plx-version* "2.0.0")

;; User settings (kept for the lifetime of the drawing session).
(if (not *plx-tolerance*) (setq *plx-tolerance* 0.001))
(if (not *plx-lang*) (setq *plx-lang* "en"))

;;; ---------------------------------------------------------------------------
;;; Messages (English / Turkish)
;;; Turkish text uses \U+XXXX escapes so the file stays pure ASCII and loads
;;; correctly regardless of the code page AutoCAD uses to read it.
;;; ---------------------------------------------------------------------------

(setq *plx-messages*
  '((banner       ("en" . "PolylineTools %1 loaded.")
                  ("tr" . "PolylineTools %1 y\U+00FCklendi."))
    (banner-tip   ("en" . "Type a command name to start. Use PLXHELP to list the commands.")
                  ("tr" . "Ba\U+015Flamak i\U+00E7in bir komut ad\U+0131 yaz\U+0131n. Komutlar i\U+00E7in PLXHELP yaz\U+0131n."))
    (help-title   ("en" . "PolylineTools commands:")
                  ("tr" . "PolylineTools komutlar\U+0131:"))
    (help-pl2curve  ("en" . "Convert polylines (including arc segments) to fit-point splines")
                    ("tr" . "Polyline'lar\U+0131 (yay segmentleri dahil) spline e\U+011Friye d\U+00F6n\U+00FC\U+015Ft\U+00FCr\U+00FCr"))
    (help-smoothpl  ("en" . "Spline-fit polylines with PEDIT (keeps them polylines)")
                    ("tr" . "Polyline'lar\U+0131 PEDIT ile spline-fit yapar (polyline olarak kal\U+0131r)"))
    (help-fitcurve  ("en" . "Curve-fit polylines with PEDIT (passes through every vertex)")
                    ("tr" . "Polyline'lar\U+0131 PEDIT ile curve-fit yapar (t\U+00FCm k\U+00F6\U+015Felerden ge\U+00E7er)"))
    (help-joinpl    ("en" . "Join two polylines end to end")
                    ("tr" . "\U+0130ki polyline'\U+0131 u\U+00E7 u\U+00E7a birle\U+015Ftirir"))
    (help-autojoinpl ("en" . "Join all touching polylines in a selection")
                     ("tr" . "Se\U+00E7imdeki birbirine de\U+011Fen t\U+00FCm polyline'lar\U+0131 birle\U+015Ftirir"))
    (help-settol    ("en" . "Set the join tolerance")
                    ("tr" . "Birle\U+015Ftirme tolerans\U+0131 ayarlar"))
    (help-number    ("en" . "Place consecutive numbers as text at picked points")
                    ("tr" . "Se\U+00E7ilen noktalara ard\U+0131\U+015F\U+0131k say\U+0131lar\U+0131 metin olarak yerle\U+015Ftirir"))
    (help-plxlang   ("en" . "Switch the message language (English / Turkish)")
                    ("tr" . "Mesaj dilini de\U+011Fi\U+015Ftirir (\U+0130ngilizce / T\U+00FCrk\U+00E7e)"))
    (error          ("en" . "Error: %1")
                    ("tr" . "Hata: %1"))
    (select-pl      ("en" . "Select polylines: ")
                    ("tr" . "Polyline'lar\U+0131 se\U+00E7in: "))
    (nothing        ("en" . "Nothing selected.")
                    ("tr" . "Hi\U+00E7bir nesne se\U+00E7ilmedi."))
    (skipped-mesh   ("en" . "Skipped %1 unsupported object(s) (3D meshes).")
                    ("tr" . "Desteklenmeyen %1 nesne atland\U+0131 (3B a\U+011Flar)."))
    (converted      ("en" . "Converted %1 polyline(s) to splines.")
                    ("tr" . "%1 polyline spline'a d\U+00F6n\U+00FC\U+015Ft\U+00FCr\U+00FCld\U+00FC."))
    (convert-failed ("en" . "Could not convert polyline %1.")
                    ("tr" . "Polyline %1 d\U+00F6n\U+00FC\U+015Ft\U+00FCr\U+00FClemedi."))
    (smoothed       ("en" . "Spline-fitted the selected polylines.")
                    ("tr" . "Se\U+00E7ilen polyline'lar spline-fit yap\U+0131ld\U+0131."))
    (fitted         ("en" . "Curve-fitted the selected polylines.")
                    ("tr" . "Se\U+00E7ilen polyline'lar curve-fit yap\U+0131ld\U+0131."))
    (pick-first     ("en" . "Select the first polyline: ")
                    ("tr" . "\U+0130lk polyline'\U+0131 se\U+00E7in: "))
    (pick-second    ("en" . "Select the second polyline: ")
                    ("tr" . "\U+0130kinci polyline'\U+0131 se\U+00E7in: "))
    (not-joinable   ("en" . "The selected object is not an open 2D polyline.")
                    ("tr" . "Se\U+00E7ilen nesne a\U+00E7\U+0131k bir 2B polyline de\U+011Fil."))
    (same-entity    ("en" . "Select two different polylines.")
                    ("tr" . "\U+0130ki farkl\U+0131 polyline se\U+00E7in."))
    (not-coplanar   ("en" . "The polylines do not lie in the same plane.")
                    ("tr" . "Polyline'lar ayn\U+0131 d\U+00FCzlemde de\U+011Fil."))
    (ends-apart     ("en" . "The endpoints do not meet within the tolerance (%1).")
                    ("tr" . "U\U+00E7 noktalar tolerans (%1) i\U+00E7inde bulu\U+015Fmuyor."))
    (joined         ("en" . "Polylines joined.")
                    ("tr" . "Polyline'lar birle\U+015Ftirildi."))
    (join-failed    ("en" . "Could not create the joined polyline.")
                    ("tr" . "Birle\U+015Fik polyline olu\U+015Fturulamad\U+0131."))
    (autojoin-done  ("en" . "%1 polyline(s) merged into %2 new polyline(s).")
                    ("tr" . "%1 polyline, %2 yeni polyline olarak birle\U+015Ftirildi."))
    (autojoin-none  ("en" . "No touching polylines were found.")
                    ("tr" . "Birbirine de\U+011Fen polyline bulunamad\U+0131."))
    (tol-current    ("en" . "Current tolerance: %1")
                    ("tr" . "Mevcut tolerans: %1"))
    (tol-prompt     ("en" . "New tolerance <%1>: ")
                    ("tr" . "Yeni tolerans <%1>: "))
    (tol-set        ("en" . "Tolerance set to %1.")
                    ("tr" . "Tolerans %1 olarak ayarland\U+0131."))
    (tol-invalid    ("en" . "The tolerance must be greater than zero.")
                    ("tr" . "Tolerans s\U+0131f\U+0131rdan b\U+00FCy\U+00FCk olmal\U+0131d\U+0131r."))
    (num-start      ("en" . "Start number <%1>: ")
                    ("tr" . "Ba\U+015Flang\U+0131\U+00E7 say\U+0131s\U+0131 <%1>: "))
    (num-end        ("en" . "End number: ")
                    ("tr" . "Biti\U+015F say\U+0131s\U+0131: "))
    (num-height     ("en" . "Text height <%1>: ")
                    ("tr" . "Metin y\U+00FCksekli\U+011Fi <%1>: "))
    (num-neg        ("en" . "The start number must be 0 or greater.")
                    ("tr" . "Ba\U+015Flang\U+0131\U+00E7 say\U+0131s\U+0131 0 veya daha b\U+00FCy\U+00FCk olmal\U+0131d\U+0131r."))
    (num-order      ("en" . "The end number must not be smaller than the start number.")
                    ("tr" . "Biti\U+015F say\U+0131s\U+0131 ba\U+015Flang\U+0131\U+00E7tan k\U+00FC\U+00E7\U+00FCk olamaz."))
    (num-height-bad ("en" . "The text height must be greater than zero.")
                    ("tr" . "Metin y\U+00FCksekli\U+011Fi s\U+0131f\U+0131rdan b\U+00FCy\U+00FCk olmal\U+0131d\U+0131r."))
    (num-pick       ("en" . "Pick location for %1 (Enter to finish): ")
                    ("tr" . "%1 i\U+00E7in konum se\U+00E7in (bitirmek i\U+00E7in Enter): "))
    (num-failed     ("en" . "Could not create the text object.")
                    ("tr" . "Metin nesnesi olu\U+015Fturulamad\U+0131."))
    (num-done       ("en" . "%1 number(s) placed.")
                    ("tr" . "%1 say\U+0131 yerle\U+015Ftirildi."))
    (lang-set       ("en" . "Language: English")
                    ("tr" . "Dil: T\U+00FCrk\U+00E7e"))))

(defun plx:to-string (value)
  (if (= (type value) 'STR) value (vl-princ-to-string value)))

;; Look up a message; falls back to English, then to the key name.
(defun plx:msg (key / entry text)
  (if (setq entry (cdr (assoc key *plx-messages*)))
    (progn
      (setq text (cdr (assoc *plx-lang* entry)))
      (if text text (cdr (assoc "en" entry))))
    (vl-symbol-name key)))

;; Look up a message and substitute %1, %2, ... with the items of ARGS.
(defun plx:fmt (key args / text n token pos arg)
  (setq text (plx:msg key)
        n    1)
  (foreach arg args
    (setq token (strcat "%" (itoa n)))
    (if (setq pos (vl-string-search token text))
      (setq text (strcat (substr text 1 pos)
                         (plx:to-string arg)
                         (substr text (+ pos (strlen token) 1)))))
    (setq n (1+ n)))
  text)

;; Print a message on its own line.
(defun plx:say (key args)
  (princ (strcat "\n" (plx:fmt key args))))

;;; ---------------------------------------------------------------------------
;;; Environment guard: saves/restores system variables, wraps the command in a
;;; single UNDO group and installs an *error* handler that cleans up.
;;; (plx:begin T) also switches object snaps off for scripted point input.
;;; ---------------------------------------------------------------------------

(defun plx:getvar (name / value)
  (setq value (vl-catch-all-apply 'getvar (list name)))
  (if (vl-catch-all-error-p value) nil value))

(defun plx:setvar (name value)
  (vl-catch-all-apply 'setvar (list name value))
  value)

(defun plx:begin (snap-off / name value)
  (setq *plx-saved-vars* nil)
  (foreach name '("CMDECHO" "OSMODE" "SPLMETHOD")
    (if (setq value (plx:getvar name))
      (setq *plx-saved-vars* (cons (cons name value) *plx-saved-vars*))))
  (plx:setvar "CMDECHO" 0)
  (if snap-off (plx:setvar "OSMODE" 0))
  (plx:setvar "SPLMETHOD" 0) ; fit-point splines (ignored where unsupported)
  (command "_.UNDO" "_BEGIN")
  (setq *plx-old-error* *error*
        *error*         plx:error
        *plx-active*    T)
  (princ))

(defun plx:end (/ item)
  (if *plx-active*
    (progn
      (setq *plx-active* nil)
      (command "_.UNDO" "_END")
      (foreach item *plx-saved-vars*
        (plx:setvar (car item) (cdr item)))
      (setq *error* *plx-old-error*)))
  (princ))

(defun plx:error (msg)
  (while (> (getvar "CMDACTIVE") 0)
    (command))
  (if (and msg
           (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*")))
    (plx:say 'error (list msg)))
  (plx:end)
  (princ))

;;; ---------------------------------------------------------------------------
;;; Small list helpers
;;; ---------------------------------------------------------------------------

(defun plx:butlast (lst)
  (reverse (cdr (reverse lst))))

(defun plx:remove-nth (n lst / i out item)
  (setq i 0)
  (foreach item lst
    (if (/= i n) (setq out (cons item out)))
    (setq i (1+ i)))
  (reverse out))

(defun plx:near (p q tol)
  (< (distance p q) tol))

;;; ===== 10-polyline.lsp =====

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

;;; ===== 20-geometry.lsp =====

;;; ---------------------------------------------------------------------------
;;; 20-geometry.lsp - bulge arc math and point sampling
;;; ---------------------------------------------------------------------------

;; Angular resolution used when an arc segment is approximated by points.
(setq *plx-arc-step* (/ pi 18.0)) ; 10 degrees

;; Interior points of the arc that a bulge describes between P1 and P2.
;; Bulge = tan(sweep / 4); positive bulges run counter-clockwise.
(defun plx:arc-points (p1 p2 bulge / chord sweep steps middle center radius start k pts)
  (setq chord (distance p1 p2))
  (if (and (> chord 1e-9) (> (abs bulge) 1e-9))
    (progn
      (setq sweep  (* 4.0 (atan bulge))
            steps  (max 2 (1+ (fix (/ (abs sweep) *plx-arc-step*))))
            middle (mapcar '(lambda (a b) (/ (+ a b) 2.0)) p1 p2)
            ;; The centre lies on the chord's perpendicular bisector, at a
            ;; signed distance of chord * (1 - bulge^2) / (4 * bulge).
            center (polar middle
                          (+ (angle p1 p2) (/ pi 2.0))
                          (/ (* chord (- 1.0 (* bulge bulge))) (* 4.0 bulge)))
            radius (distance center p1)
            start  (angle center p1)
            k      1)
      (repeat (1- steps)
        (setq pts (cons (polar center
                               (+ start (* sweep (/ k (float steps))))
                               radius)
                        pts)
              k   (1+ k)))
      (reverse pts))))

;; Drop consecutive duplicate points (a closed list also drops a final point
;; that repeats the first one).
(defun plx:dedupe (pts closed / out p)
  (foreach p pts
    (if (or (null out) (not (plx:near p (car out) 1e-9)))
      (setq out (cons p out))))
  (if (and closed
           (> (length out) 1)
           (plx:near (car out) (last out) 1e-9))
    (setq out (cdr out)))
  (reverse out))

;; Flatten a vertex list to a point list in which arc segments are replaced by
;; a series of points.  Closed polylines do not repeat the first point.
(defun plx:sample-points (verts closed / n i v w pts p)
  (setq n (length verts)
        i 0)
  (repeat (if closed n (1- n))
    (setq v   (nth i verts)
          w   (nth (rem (1+ i) n) verts)
          pts (cons (car v) pts))
    (foreach p (plx:arc-points (car v) (car w) (cdr v))
      (setq pts (cons p pts)))
    (setq i (1+ i)))
  (if (not closed)
    (setq pts (cons (car (last verts)) pts)))
  (plx:dedupe (reverse pts) closed))

;;; ===== 30-curve.lsp =====

;;; ---------------------------------------------------------------------------
;;; 30-curve.lsp - PL2CURVE, SMOOTHPL, FITCURVE
;;; ---------------------------------------------------------------------------

;; Prompt for polylines and return them as a list of entity names (or nil).
(defun plx:select-polylines (/ ss i enames)
  (plx:say 'select-pl nil)
  (if (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
    (repeat (setq i (sslength ss))
      (setq i      (1- i)
            enames (cons (ssname ss i) enames))))
  enames)

;; Create a fit-point spline through PTS (points in the coordinate system SPACE).
;; Returns the new entity or nil.
(defun plx:make-spline (pts closed space / before p)
  (setq before (entlast))
  (command "_.SPLINE")
  (foreach p pts
    (command (trans p space 1)))
  (if closed
    (command "_C" "")
    (command "" "" ""))
  (if (/= (entlast) before) (entlast)))

;;; PL2CURVE - replace polylines by splines that follow their vertices and arcs.
(defun c:pl2curve (/ enames n done skipped verts closed pts spline ename)
  (plx:begin T)
  (setq n 0 done 0 skipped 0)
  (if (setq enames (plx:select-polylines))
    (progn
      (foreach ename enames
        (setq n (1+ n))
        (if (plx:mesh-p ename)
          (setq skipped (1+ skipped))
          (progn
            (setq verts  (plx:vertices ename)
                  closed (plx:closed-p ename)
                  pts    (plx:sample-points verts closed))
            (if (and (>= (length pts) 3)
                     (setq spline (plx:make-spline pts closed (plx:space ename))))
              (progn
                (plx:copy-props ename spline)
                (entdel ename)
                (setq done (1+ done)))
              (plx:say 'convert-failed (list n))))))
      (if (> skipped 0) (plx:say 'skipped-mesh (list skipped)))
      (plx:say 'converted (list done)))
    (plx:say 'nothing nil))
  (plx:end))

;; Run PEDIT on a selection of polylines with the given option ("_S" or "_F").
(defun plx:pedit-curve (option done-key / ss)
  (plx:begin nil)
  (plx:say 'select-pl nil)
  (if (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
    (progn
      (command "_.PEDIT" "_M" ss "" option "")
      (plx:say done-key nil))
    (plx:say 'nothing nil))
  (plx:end))

;;; SMOOTHPL - spline-fit polylines, keeping them polylines.
(defun c:smoothpl ()
  (plx:pedit-curve "_S" 'smoothed))

;;; FITCURVE - curve-fit polylines through every vertex.
(defun c:fitcurve ()
  (plx:pedit-curve "_F" 'fitted))

;;; ===== 40-join.lsp =====

;;; ---------------------------------------------------------------------------
;;; 40-join.lsp - JOINPL, AUTOJOINPL, SETTOL
;;; ---------------------------------------------------------------------------

;; Ask the user to pick one object; returns its entity name or nil.
(defun plx:pick-entity (prompt-key / sel)
  (if (setq sel (entsel (strcat "\n" (plx:msg prompt-key))))
    (car sel)))

;; Build one polyline from VERTS (closing it when the ends meet) using the
;; properties of the first source, then erase all SOURCES.  Returns the new
;; entity or nil.
(defun plx:replace-polylines (sources verts / ring new source)
  (setq ring (plx:close-ring verts *plx-tolerance*)
        new  (plx:make-lwpolyline (car ring) (cdr ring) (car sources)))
  (if new
    (foreach source sources
      (entdel source)))
  new)

;;; JOINPL - join two polylines end to end.
(defun c:joinpl (/ a b verts)
  (plx:begin nil)
  (if (setq a (plx:pick-entity 'pick-first))
    (cond
      ((not (plx:joinable-p a))
       (plx:say 'not-joinable nil))
      ((setq b (plx:pick-entity 'pick-second))
       (cond
         ((equal a b)
          (plx:say 'same-entity nil))
         ((not (plx:joinable-p b))
          (plx:say 'not-joinable nil))
         ((not (plx:comparable-p a b))
          (plx:say 'not-coplanar nil))
         ((not (setq verts (plx:join-verts (plx:vertices a)
                                           (plx:vertices b)
                                           *plx-tolerance*)))
          (plx:say 'ends-apart (list (rtos *plx-tolerance* 2 6))))
         ((plx:replace-polylines (list a b) verts)
          (plx:say 'joined nil))
         (T
          (plx:say 'join-failed nil))))))
  (plx:end))

;;; AUTOJOINPL - join every set of touching polylines in a selection.
(defun c:autojoinpl (/ enames chains merged created chain)
  (plx:begin nil)
  (setq enames (vl-remove-if-not 'plx:joinable-p (plx:select-polylines)))
  (if (null enames)
    (plx:say 'nothing nil)
    (progn
      (setq merged  0
            created 0
            chains  (plx:merge-chains
                      (mapcar '(lambda (e) (list (plx:vertices e) (list e)))
                              enames)
                      *plx-tolerance*))
      (foreach chain chains
        (if (cdr (cadr chain)) ; more than one source entity
          (if (plx:replace-polylines (cadr chain) (car chain))
            (setq merged  (+ merged (length (cadr chain)))
                  created (1+ created)))))
      (if (> created 0)
        (plx:say 'autojoin-done (list merged created))
        (plx:say 'autojoin-none nil))))
  (plx:end))

;;; SETTOL - set the distance within which endpoints count as touching.
(defun c:settol (/ value)
  (plx:say 'tol-current (list (rtos *plx-tolerance* 2 6)))
  (setq value (getreal (strcat "\n"
                               (plx:fmt 'tol-prompt
                                        (list (rtos *plx-tolerance* 2 6))))))
  (cond
    ((null value))
    ((> value 0.0)
     (setq *plx-tolerance* value)
     (plx:say 'tol-set (list (rtos *plx-tolerance* 2 6))))
    (T
     (plx:say 'tol-invalid nil)))
  (princ))

;;; ===== 50-number.lsp =====

;;; ---------------------------------------------------------------------------
;;; 50-number.lsp - NUMBER: place consecutive numbers as text
;;; ---------------------------------------------------------------------------

(if (not *plx-text-height*) (setq *plx-text-height* 2.5))

;; Create a centred TEXT object.  PT is expressed in the OCS defined by NORMAL.
(defun plx:make-number-text (pt text height normal rotation)
  (if (entmake
        (list '(0 . "TEXT")
              (cons 10 pt)
              (cons 40 height)
              (cons 1 text)
              (cons 50 rotation)
              (cons 7 (getvar "TEXTSTYLE"))
              '(72 . 1)
              (cons 11 pt)
              (cons 210 normal)
              '(73 . 2)))
    T))

;;; NUMBER - click once per number; Enter or ESC ends the command.
(defun c:number (/ start end height input n count pt normal rotation)
  (plx:begin nil)
  (setq start (getint (strcat "\n" (plx:fmt 'num-start (list 1)))))
  (if (not start) (setq start 1))
  (cond
    ((< start 0)
     (plx:say 'num-neg nil))
    ((not (setq end (getint (strcat "\n" (plx:msg 'num-end)))))
     nil)
    ((< end start)
     (plx:say 'num-order nil))
    (T
     (setq input (getreal (strcat "\n"
                                  (plx:fmt 'num-height
                                           (list *plx-text-height*)))))
     (setq height (if input input *plx-text-height*))
     (if (<= height 0.0)
       (plx:say 'num-height-bad nil)
       (progn
         (setq *plx-text-height* height
               n        start
               count    0
               ;; Draw in the plane of the current UCS.
               normal   (trans '(0.0 0.0 1.0) 1 0 T)
               rotation (angle '(0.0 0.0 0.0)
                               (trans '(1.0 0.0 0.0) 1 normal T)))
         (while (and (<= n end)
                     (setq pt (getpoint
                                (strcat "\n" (plx:fmt 'num-pick (list n))))))
           (if (plx:make-number-text (trans pt 1 normal)
                                     (itoa n)
                                     height
                                     normal
                                     rotation)
             (setq n     (1+ n)
                   count (1+ count))
             (plx:say 'num-failed nil)))
         (plx:say 'num-done (list count))))))
  (plx:end))

;;; ===== 90-help.lsp =====

;;; ---------------------------------------------------------------------------
;;; 90-help.lsp - PLXHELP, PLXLANG and the load banner
;;; ---------------------------------------------------------------------------

(setq *plx-commands*
  '(("PL2CURVE"   . help-pl2curve)
    ("SMOOTHPL"   . help-smoothpl)
    ("FITCURVE"   . help-fitcurve)
    ("JOINPL"     . help-joinpl)
    ("AUTOJOINPL" . help-autojoinpl)
    ("SETTOL"     . help-settol)
    ("NUMBER"     . help-number)
    ("PLXLANG"    . help-plxlang)))

(defun plx:pad (text width)
  (while (< (strlen text) width)
    (setq text (strcat text " ")))
  text)

;;; PLXHELP - list the available commands.
(defun c:plxhelp (/ entry)
  (plx:say 'help-title nil)
  (foreach entry *plx-commands*
    (princ (strcat "\n  " (plx:pad (car entry) 12) (plx:msg (cdr entry)))))
  (princ))

;;; PLXLANG - switch the language of messages.
(defun c:plxlang (/ choice)
  (initget "English Turkish")
  (setq choice (getkword (strcat "\nLanguage [English/Turkish] <"
                                 (if (= *plx-lang* "tr") "Turkish" "English")
                                 ">: ")))
  (if choice
    (setq *plx-lang* (if (= choice "Turkish") "tr" "en")))
  (plx:say 'lang-set nil)
  (princ))

(plx:say 'banner (list *plx-version*))
(plx:say 'banner-tip nil)
(princ)
