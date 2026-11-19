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
