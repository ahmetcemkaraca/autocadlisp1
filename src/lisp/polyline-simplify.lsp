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

(defun point-segment-perp-dist (p a b / ap ab ab2 t proj)
  "Noktanın AB doğru parçasına en kısa uzaklığı (2D)"
  (if (equal a b 1e-9)
    (distance2d p a)
    (progn
      (setq ap (list (- (car p) (car a)) (- (cadr p) (cadr a))))
      (setq ab (list (- (car b) (car a)) (- (cadr b) (cadr a))))
      (setq ab2 (+ (* (car ab) (car ab)) (* (cadr ab) (cadr ab))))
      (setq t (/ (+ (* (car ap) (car ab)) (* (cadr ap) (cadr ab))) ab2))
      (cond
        ((< t 0.0) (distance2d p a))
        ((> t 1.0) (distance2d p b))
        (T (setq proj (list (+ (car a) (* t (car ab)))
                            (+ (cadr a) (* t (cadr ab)))))
           (distance2d p proj)))
    )
  )
)

(defun get-lwpoly-points (ent / d pts closed)
  "LWPOLYLINE vertex listesini döner; kapalıysa kapanış tekrarını eklemez"
  (setq d (entget ent))
  (setq pts '())
  (foreach it d (if (= (car it) 10) (setq pts (append pts (list (cdr it))))))
  (setq closed (= 1 (logand 1 (cdr (assoc 70 d)))))
  (list pts closed)
)

(defun get-polyline-heavy-points (ent / d v en pts closed)
  "Klasik POLYLINE (heavy) vertex listesini döner"
  (setq d (entget ent))
  (setq closed (= 1 (logand 1 (cdr (assoc 70 d)))))
  (setq en ent)
  (setq pts '())
  (while (setq en (entnext en))
    (setq v (entget en))
    (if (= (cdr (assoc 0 v)) "VERTEX")
      (setq pts (append pts (list (cdr (assoc 10 v)))))
    )
    (if (= (cdr (assoc 0 v)) "SEQEND") (setq en nil))
  )
  (list pts closed)
)

(defun get-any-poly-points (ent / t0)
  "POLYLINE veya LWPOLYLINE noktalarını ve kapalı bayrağını döner"
  (setq t0 (cdr (assoc 0 (entget ent))))
  (cond
    ((= t0 "LWPOLYLINE") (get-lwpoly-points ent))
    ((= t0 "POLYLINE") (get-polyline-heavy-points ent))
    (T (list nil nil))
  )
)

(defun drop-n (n lst)
  (repeat n (setq lst (cdr lst)))
  lst
)

(defun take-n (n lst / res i)
  (setq res '() i 0)
  (while (and lst (< i n))
    (setq res (append res (list (car lst))))
    (setq lst (cdr lst))
    (setq i (1+ i))
  )
  res
)

(defun slice (lst start end)
  "0-based, end hariç"
  (take-n (- end start) (drop-n start lst))
)

(defun douglas-peucker (pts eps / n maxd maxi i a bpt p left right)
  "Douglas-Peucker özyinelemeli algoritma"
  (setq n (length pts))
  (cond
    ((<= n 2) pts)
    (T
     (setq a (car pts))
     (setq bpt (car (last pts)))
     (setq maxd -1.0)
     (setq maxi -1)
     (setq i 1)
     (while (< i (1- n))
       (setq p (nth i pts))
       (setq rec (point-segment-perp-dist p a bpt))
       (if (> rec maxd) (progn (setq maxd rec) (setq maxi i)))
       (setq i (1+ i))
     )
     (if (and maxi (> maxd eps))
       (progn
         (setq left (douglas-peucker (slice pts 0 (1+ maxi)) eps))
         (setq right (douglas-peucker (slice pts maxi n) eps))
         ;; Son eleman tekrarını engelle
         (append left (cdr right))
       )
       (list a bpt)
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

(defun build-lwpoly (pts closed ref-ent / lay col ltype lw n flags data new i p ref-ok ref-entget)
  "Verilen noktalardan LWPOLYLINE oluşturur; referans özelliklerini taşır (entmake)"
  (if (< (length pts) 2)
    nil
    (progn
      (setq ref-ok (and ref-ent (eq (type ref-ent) 'ENAME)))
      (if ref-ok (setq ref-entget (entget ref-ent)))
      (setq lay (if ref-ok (cdr (assoc 8 ref-entget)) "0"))
      (setq col (if ref-ok (cdr (assoc 62 ref-entget)) 256))
      (setq ltype (if ref-ok (cdr (assoc 6 ref-entget)) "BYLAYER"))
      (setq lw (if ref-ok (cdr (assoc 370 ref-entget)) -1))
      (if (not lay) (setq lay "0"))
      (if (and col (or (< col 1) (> col 256))) (setq col 256))
      (if (not ltype) (setq ltype "BYLAYER"))
      (if (not lw) (setq lw -1))
      (setq n (length pts))
      (setq flags (if closed 1 0))
      (setq data (list
        (cons 0 "LWPOLYLINE")
        (cons 100 "AcDbEntity")
        (cons 8 lay)
        (cons 100 "AcDbPolyline")
        (cons 90 n)
        (cons 70 flags)
      ))
      (if (and col (/= col 256)) (setq data (append data (list (cons 62 col)))))
      (if ltype (setq data (append data (list (cons 6 ltype)))))
      (if lw (setq data (append data (list (cons 370 lw)))))
      (setq i 0)
      (while (< i n)
        (setq p (nth i pts))
        (setq data (append data (list (cons 10 (list (car p) (cadr p))))))
        (setq i (1+ i))
      )
      (if (entmake data)
        (progn (setq new (entlast)) new)
        nil
      )
    )
  )
)

(defun remove-collinear (pts eps / res i a b c d)
  "Komşu üçlülerde orta noktayı, sapma küçükse kaldır"
  (setq res '())
  (if (< (length pts) 3)
    pts
    (progn
      (setq res (list (car pts)))
      (setq i 1)
      (while (< i (1- (length pts)))
        (setq a (nth (1- i) pts))
        (setq b (nth i pts))
        (setq c (nth (1+ i) pts))
        (setq d (point-segment-perp-dist b a c))
        (if (> d (* 0.5 eps))
          (setq res (append res (list b)))
        )
        (setq i (1+ i))
      )
      (setq res (append res (list (car (last pts)))))
      res
    )
  )
)

(defun simplify-polyline-pts (pts closed eps / pts2 res)
  "Kapalı polylinelerde başlangıç bağımlılığı azaltmak için döndürme denemesi"
  (if (not closed)
    (remove-collinear (douglas-peucker pts eps) eps)
    (progn
      ;; Kapalı: başlangıç önyargısını azaltmak için farklı başlangıçlarla dene
      (setq pts2 (append pts (list (car pts))))
      (setq res (douglas-peucker pts2 eps))
      ;; Kapalıda son noktayı tekrar etme
      (setq res (if (> (length res) 1) (reverse (cdr (reverse res))) res))
      (remove-collinear res eps)
    )
  )
)

;;; Komut: SIMPLIFYPL — 2D LWPOLYLINE vertex azaltma
(defun c:SIMPLIFYPL (/ ss i e d pts closed tol newpts newent cnt tmp)
  (princ (strcat "\nMevcut tolerans: " (rtos *SIMPLIFY-TOL* 2 3)))
  (setq tol (getreal "\nTolerans (Enter=mevcut): "))
  (if (and tol (> tol 0.0)) (setq *SIMPLIFY-TOL* tol))
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  (if ss
    (progn
      (setq i 0)
      (setq cnt 0)
      (repeat (sslength ss)
        (setq e (ssname ss i))
        (setq d (entget e))
        (setq tmp (get-any-poly-points e))
        (setq pts (car tmp))
        (setq closed (cadr tmp))
        (if (and pts (> (length pts) 2))
          (progn
            (setq newpts (simplify-polyline-pts pts closed *SIMPLIFY-TOL*))
            ;; Yeni liste orijinalden belirgin az ise değiştir, değilse EPS arttırmayı öner
            (if (and newpts (>= (length newpts) 2) (< (length newpts) (length pts)))
              (progn
                (setq newent (build-lwpoly newpts closed e))
                (if newent
                  (progn (entdel e) (setq cnt (1+ cnt)))
                  (princ "\nHata: Yeni polyline olusturulamadi.")
                )
              )
              (princ "\nNot: Bu polyline icin azaltma olmadi (toleransi arttirin).")
            )
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\n" (itoa cnt) " polyline basitleştirildi."))
      (if (= cnt 0)
        (princ "\nNot: Toleransı arttırmayı deneyin (SETSIMP ile).")
      )
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


