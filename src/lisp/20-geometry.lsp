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
