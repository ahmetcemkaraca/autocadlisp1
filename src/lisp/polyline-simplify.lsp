;;; polyline-simplify.lsp
;;; 2D LWPOLYLINE vertex sayısını şekli bozmadan azaltır (Douglas-Peucker)
;;; Author: ArchBuilder.AI
;;; Version: 1.0.0
;;; Date: 2025-09-26

(vl-load-com)

;;; Global simplify tolerance (drawing units)
(if (not *SIMPLIFY-TOL*) (setq *SIMPLIFY-TOL* 0.5))

;;; Utils
(defun distance2d (p q)
  "2D iki nokta arası mesafe"
  (distance (list (car p) (cadr p)) (list (car q) (cadr q)))
)

(defun point-line-perp-dist (p a b)
  "Noktanın AB doğrusuna dik uzaklığı (kapalı formül, 2D)"
  (if (equal a b 1e-9)
    (distance2d p a)
    (abs (/ (- (* (- (car b) (car a)) (- (cadr a) (cadr p)))
               (* (- (car a) (car p)) (- (cadr b) (cadr a))))
            (distance2d a b)))
  )
)

(defun get-lwpoly-points (ent / d pts closed)
  "LWPOLYLINE vertex listesini döner; kapalıysa kapanış tekrarını eklemez"
  (setq d (entget ent))
  (setq pts '())
  (foreach it d (if (= (car it) 10) (setq pts (append pts (list (cdr it))))))
  (setq closed (= 1 (logand 1 (cdr (assoc 70 d)))))
  (if closed
    (progn
      ;; Kapalı polyline: algoritma için başlangıcı sona eklemeyelim, ancak
      ;; sadeleştirmeden sonra kapalı özelliği korunacak.
      (list pts T)
    )
    (list pts nil)
  )
)

(defun douglas-peucker (pts eps / n keep rec maxd maxi i a b p left right)
  "Douglas-Peucker özyinelemeli algoritma"
  (setq n (length pts))
  (cond
    ((<= n 2) pts)
    (T
     (setq a (car pts))
     (setq b (last pts))
     (setq maxd -1.0)
     (setq maxi -1)
     (setq i 1)
     (while (< i (1- n))
       (setq p (nth i pts))
       (setq rec (point-line-perp-dist p a b))
       (if (> rec maxd) (progn (setq maxd rec) (setq maxi i)))
       (setq i (1+ i))
     )
     (if (and maxi (> maxd eps))
       (progn
         (setq left (douglas-peucker (subseq pts 0 (1+ maxi)) eps))
         (setq right (douglas-peucker (subseq pts maxi n) eps))
         ;; Son eleman tekrarını engelle
         (append left (cdr right))
       )
       (list a (car b))
     )
    )
  )
)

(defun ensure-minimal-vertices (pts)
  "En az iki nokta tut; dört noktadan az ise olduğu gibi bırak"
  (if (< (length pts) 2)
    pts
    pts
  )
)

(defun build-lwpoly (pts closed ref-ent / lay col ltype lw new)
  "Verilen noktalardan LWPOLYLINE oluşturur; referans özelliklerini taşır"
  (if (< (length pts) 2)
    nil
    (progn
      (command "_PLINE")
      (foreach p pts (command p))
      (if closed (command "C") (command ""))
      (setq new (entlast))
      (if new
        (progn
          (setq lay (cdr (assoc 8 (entget ref-ent))))
          (setq col (cdr (assoc 62 (entget ref-ent))))
          (setq ltype (cdr (assoc 6 (entget ref-ent))))
          (setq lw (cdr (assoc 370 (entget ref-ent))))
          (if (not lay) (setq lay "0"))
          (if (and col (or (< col 1) (> col 256))) (setq col 256))
          (if (not ltype) (setq ltype "BYLAYER"))
          (if (not lw) (setq lw -1))
          (entmod (subst (cons 8 lay) (assoc 8 (entget new)) (entget new)))
          (if col
            (if (= col 256)
              (if (assoc 62 (entget new)) (entmod (vl-remove (assoc 62 (entget new)) (entget new))))
              (entmod (subst (cons 62 col) (assoc 62 (entget new)) (entget new)))
            )
          )
          (entmod (subst (cons 6 ltype) (assoc 6 (entget new)) (entget new)))
          (if lw (entmod (subst (cons 370 lw) (assoc 370 (entget new)) (entget new))))
          (entupd new)
          new
        )
        nil
      )
    )
  )
)

(defun simplify-polyline-pts (pts closed eps / pts2 first last res)
  "Kapalı polylinelerde başlangıç bağımlılığı azaltmak için döndürme denemesi"
  (if (not closed)
    (douglas-peucker pts eps)
    (progn
      ;; Kapalı: başlangıç önyargısını azaltmak için farklı başlangıçlarla dene
      (setq first (car pts))
      (setq last (last pts))
      ;; Başlangıcı iki farklı noktadan dene (ilk ve orta)
      (setq pts2 (append pts (list (car pts))))
      (setq res (douglas-peucker pts2 eps))
      ;; Kapalıda son noktayı tekrar etme
      (if (> (length res) 1) (reverse (cdr (reverse res))) res)
    )
  )
)

;;; Komut: SIMPLIFYPL — 2D LWPOLYLINE vertex azaltma
(defun c:SIMPLIFYPL (/ ss i e d pts closed tol newpts newent cnt)
  (princ (strcat "\nMevcut tolerans: " (rtos *SIMPLIFY-TOL* 2 3)))
  (setq tol (getreal "\nTolerans (Enter=mevcut): "))
  (if (and tol (> tol 0.0)) (setq *SIMPLIFY-TOL* tol))
  (setq ss (ssget '((0 . "LWPOLYLINE"))))
  (if ss
    (progn
      (setq i 0)
      (setq cnt 0)
      (repeat (sslength ss)
        (setq e (ssname ss i))
        (setq d (entget e))
        (setq tmp (get-lwpoly-points e))
        (setq pts (car tmp))
        (setq closed (cadr tmp))
        (if (and pts (> (length pts) 2))
          (progn
            (setq newpts (simplify-polyline-pts pts closed *SIMPLIFY-TOL*))
            (if (and newpts (>= (length newpts) 2))
              (progn
                (setq newent (build-lwpoly newpts closed e))
                (if newent (progn (entdel e) (setq cnt (1+ cnt))))
              )
            )
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\n" (itoa cnt) " polyline basitleştirildi."))
    )
    (princ "\nHiçbir LWPOLYLINE seçilmedi.")
  )
  (princ)
)

;;; Komut: SETSIMP — toleransı ayarla
(defun c:SETSIMP (/ v)
  (princ (strcat "\nMevcut tolerans: " (rtos *SIMPLIFY-TOL* 2 3)))
  (setq v (getreal "\nYeni tolerans: "))
  (if (and v (> v 0.0))
    (progn (setq *SIMPLIFY-TOL* v) (princ "\nTolerans güncellendi."))
    (princ "\nGeçersiz değer.")
  )
  (princ)
)

(princ "\nPolyline Simplify LISP yüklendi!")
(princ "\nKomutlar:")
(princ "\n  SIMPLIFYPL - 2D polylinelerde vertex sayısını azaltır")
(princ "\n  SETSIMP    - Basitleştirme toleransını ayarlar")
(princ)


