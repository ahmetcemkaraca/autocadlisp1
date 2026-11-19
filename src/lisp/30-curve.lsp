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
