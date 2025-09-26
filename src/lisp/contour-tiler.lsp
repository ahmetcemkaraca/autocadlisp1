;;; contour-tiler.lsp
;;; Kontur (eğim) çizgilerini 70x70 cm (veya verilen) karelere böler,
;;; her kareyi ayrı bir blok yerleşimi olarak XCLIP ile düzenler.
;;; Author: ArchBuilder.AI
;;; Version: 1.0.0
;;; Date: 2025-09-26

(vl-load-com)

(defun safe-real (v def)
  (if (and v (numberp v) (> v 0.0)) v def)
)

(defun get-ss-bbox (ss / i n e v minx miny maxx maxy pmin pmax)
  "Seçim kümesinin global bounding box'ını döner"
  (setq n (if ss (sslength ss) 0))
  (if (= n 0)
    nil
    (progn
      (setq i 0)
      (while (< i n)
        (setq e (ssname ss i))
        (if e
          (vl-catch-all-apply
            '(lambda ()
               (setq v (vlax-ename->vla-object e))
               (vla-getboundingbox v 'pmin 'pmax)
               (setq pmin (vlax-safearray->list pmin))
               (setq pmax (vlax-safearray->list pmax))
               (if (not minx) (setq minx (car pmin) miny (cadr pmin) maxx (car pmax) maxy (cadr pmax)))
               (setq minx (min minx (car pmin))
                     miny (min miny (cadr pmin))
                     maxx (max maxx (car pmax))
                     maxy (max maxy (cadr pmax)))
             )
          )
        )
        (setq i (1+ i))
      )
      (list (list minx miny) (list maxx maxy))
    )
  )
)

(defun make-source-block (ss blkname / res)
  "Seçimden blok üretir, orijinali korur (Retain)"
  (setq res (vl-catch-all-apply
    '(lambda ()
       (command "_.-BLOCK" blkname "0,0" ss "" "R")
     )
  ))
  (if (vl-catch-all-error-p res) nil blkname)
)

(defun insert-and-xclip (blkname rectMin rectMax dispPt / insName)
  "Bloğu 0,0'a insert et, dünya koordinatlı dikdörtgenle XCLIP yap, sonra taşı"
  (command "_.-INSERT" blkname '(0 0) 1 1 0)
  (setq insName (entlast))
  (if insName
    (progn
      (command "_.XCLIP" insName "" "N" "R" rectMin rectMax)
      (command "_.MOVE" insName "" "0,0" dispPt)
      insName
    )
    nil
  )
)

(defun label-tile (text insBase / h txtpt)
  "Karo etiketini ekler"
  (setq h 5.0)
  (setq txtpt (list (+ (car insBase) 2.0) (+ (cadr insBase) 2.0)))
  (command "_.TEXT" "J" "BL" txtpt h 0 text)
)

;;; Komut: CTILE70 — Konturları karo bloklara böler
(defun c:CTILE70 (/ ss bbox minpt maxpt w h margin cols dx dy nx ny i j blkname ok rectMin rectMax dispPt k count)
  (princ "\nKonturları seçin (LWPOLYLINE/POLYLINE/SPLINE/LINE/ARC): ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE,SPLINE,LINE,ARC"))))
  (if (not ss) (progn (princ "\nSeçim yapılmadı.") (princ))
    (progn
      (setq bbox (get-ss-bbox ss))
      (if (not bbox) (progn (princ "\nGeçerli bounding box bulunamadı.") (princ))
        (progn
          (setq minpt (car bbox) maxpt (cadr bbox))
          (setq w (safe-real (getreal "\nKaro genişliği (varsayılan 70): ") 70.0))
          (setq h (safe-real (getreal "\nKaro yüksekliği (varsayılan 70): ") 70.0))
          (setq margin (safe-real (getreal "\nKaro arası boşluk (varsayılan 10): ") 10.0))
          (setq cols (fix (safe-real (getreal "\nDizilim sütun sayısı (varsayılan 5): ") 5.0)))
          (if (< cols 1) (setq cols 1))

          (setq blkname (strcat "CT_SRC_" (itoa (fix (getvar "DATE")))))
          (setq ok (make-source-block ss blkname))
          (if (not ok) (progn (princ "\nHata: Blok oluşturulamadı.") (princ))
            (progn
              (setq dx (- (car maxpt) (car minpt)))
              (setq dy (- (cadr maxpt) (cadr minpt)))
              (setq nx (1+ (fix (/ dx w))))
              (setq ny (1+ (fix (/ dy h))))
              (setq i 0 count 0 k 0)
              (while (< i nx)
                (setq j 0)
                (while (< j ny)
                  (setq rectMin (list (+ (car minpt) (* i w)) (+ (cadr minpt) (* j h))))
                  (setq rectMax (list (+ (car rectMin) w) (+ (cadr rectMin) h)))
                  ;; yerleşim ofseti
                  (setq dispPt (list (+ (* (mod k cols) (+ w margin)) 0.0)
                                     (+ (* (fix (/ k cols)) (+ h margin)) 0.0)))
                  (if (insert-and-xclip blkname rectMin rectMax dispPt)
                    (progn
                      (label-tile (strcat "T" (itoa i) "-" (itoa j)) dispPt)
                      (setq count (1+ count))
                    )
                  )
                  (setq j (1+ j))
                  (setq k (1+ k))
                )
                (setq i (1+ i))
              )
              (princ (strcat "\nToplam " (itoa count) " karo üretildi."))
            )
          )
        )
      )
    )
  )
  (princ)
)

(princ "\nContour Tiler LISP yüklendi!")
(princ "\nKomut: CTILE70 - Konturları 70x70 karelere böler ve XCLIP uygular")
(princ)


