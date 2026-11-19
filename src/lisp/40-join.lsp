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
