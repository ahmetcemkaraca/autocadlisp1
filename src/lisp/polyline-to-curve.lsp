;;; polyline-to-curve.lsp
;;; AutoCAD LISP kodu - Polyline'ları curved çizgiler haline getirir
;;; Yazar: ArchBuilder.AI
;;; Versiyon: 1.0
;;; Tarih: 2025-09-26

(defun c:pl2curve (/ ss i ent entdata entname newspline pts bulges)
  "Polyline'ları spline eğrilerine dönüştürür"
  
  ;; Kullanıcıdan polyline seçmesini iste
  (princ "\nPolyline'ları seçin (curved çizgiler haline getirilecek): ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  
  (if ss
    (progn
      (setq i 0)
      ;; Seçilen her polyline için işlem yap
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq entdata (entget ent))
        (setq entname (cdr (assoc 0 entdata)))
        
        ;; Polyline noktalarını al
        (setq pts (get-polyline-points ent))
        (setq bulges (get-polyline-bulges ent))
        
        (if pts
          (progn
            ;; Yeni spline oluştur
            (setq newspline (create-curved-polyline pts bulges entdata))
            
            ;; Orijinal polyline'ı sil
            (if newspline
              (progn
                (entdel ent)
                (princ (strcat "\nPolyline " (itoa (1+ i)) " curved çizgiye dönüştürüldü."))
              )
              (princ (strcat "\nHata: Polyline " (itoa (1+ i)) " dönüştürülemedi."))
            )
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nToplam " (itoa (sslength ss)) " polyline işlendi."))
    )
    (princ "\nHiçbir polyline seçilmedi.")
  )
  (princ)
)

(defun get-polyline-points (ent / entdata pt-list vertex-data)
  "Polyline'ın tüm noktalarını liste olarak döner"
  (setq entdata (entget ent))
  (setq pt-list '())
  
  ;; DXF kodlarını kontrol et ve noktaları topla
  (foreach item entdata
    (if (= (car item) 10)  ; Vertex koordinatları
      (setq pt-list (append pt-list (list (cdr item))))
    )
  )
  
  ;; Kapalı polyline kontrolü
  (if (= 1 (logand 1 (cdr (assoc 70 entdata))))
    (setq pt-list (append pt-list (list (car pt-list))))
  )
  
  pt-list
)

(defun get-polyline-bulges (ent / entdata bulge-list)
  "Polyline'ın bulge değerlerini liste olarak döner"
  (setq entdata (entget ent))
  (setq bulge-list '())
  
  ;; Bulge değerlerini topla
  (foreach item entdata
    (if (= (car item) 42)  ; Bulge faktörü
      (setq bulge-list (append bulge-list (list (cdr item))))
    )
  )
  
  bulge-list
)

(defun create-curved-polyline (pts bulges entdata / spline-pts i curve-pts pt1 pt2 bulge mid-pt)
  "Noktalar ve bulge değerlerinden curved polyline oluşturur"
  (setq spline-pts '())
  (setq i 0)
  
  ;; Her segment için eğri noktaları hesapla
  (while (< i (1- (length pts)))
    (setq pt1 (nth i pts))
    (setq pt2 (nth (1+ i) pts))
    (setq bulge (if (< i (length bulges)) (nth i bulges) 0.0))
    
    ;; Spline noktalarına başlangıç noktasını ekle
    (setq spline-pts (append spline-pts (list pt1)))
    
    ;; Eğer bulge varsa, ara nokta hesapla
    (if (not (equal bulge 0.0 0.001))
      (progn
        (setq curve-pts (calculate-arc-points pt1 pt2 bulge))
        (setq spline-pts (append spline-pts curve-pts))
      )
    )
    
    (setq i (1+ i))
  )
  
  ;; Son noktayı ekle
  (setq spline-pts (append spline-pts (list (last pts))))
  
  ;; Spline oluştur
  (if (> (length spline-pts) 2)
    (progn
      (command "_SPLINE")
      (foreach pt spline-pts
        (command pt)
      )
      (command "" "" "")
      (entlast)
    )
    nil
  )
)

(defun calculate-arc-points (pt1 pt2 bulge / center radius start-angle end-angle num-pts angle-step i angle pt)
  "İki nokta ve bulge değerinden arc noktaları hesaplar"
  (setq num-pts 10)  ; Ara nokta sayısı
  (setq angle-step (/ (* 4.0 (atan bulge)) num-pts))
  
  ;; Merkez ve yarıçapı hesapla
  (setq center (calculate-arc-center pt1 pt2 bulge))
  (setq radius (distance center pt1))
  (setq start-angle (angle center pt1))
  
  ;; Ara noktaları hesapla
  (setq i 1)
  (setq arc-points '())
  (repeat (1- num-pts)
    (setq angle (+ start-angle (* i angle-step)))
    (setq pt (polar center angle radius))
    (setq arc-points (append arc-points (list pt)))
    (setq i (1+ i))
  )
  
  arc-points
)

(defun calculate-arc-center (pt1 pt2 bulge / mid-pt perp-angle dist center-dist)
  "İki nokta ve bulge değerinden arc merkezini hesaplar"
  (setq mid-pt (list (/ (+ (car pt1) (car pt2)) 2.0)
                     (/ (+ (cadr pt1) (cadr pt2)) 2.0)))
  
  (setq perp-angle (+ (angle pt1 pt2) (/ pi 2)))
  (setq dist (distance pt1 pt2))
  (setq center-dist (/ (* dist bulge) 2.0))
  
  (polar mid-pt perp-angle center-dist)
)

;;; Yardımcı komut - Smooth polyline oluşturur
(defun c:smoothpl (/ ss)
  "Seçilen polyline'ları smooth hale getirir"
  (princ "\nSmooth yapılacak polyline'ları seçin: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  
  (if ss
    (progn
      (command "_PEDIT" "_M" ss "" "_S" "")
      (princ "\nPolyline'lar smooth yapıldı.")
    )
    (princ "\nHiçbir polyline seçilmedi.")
  )
  (princ)
)

;;; Fit curve komutu
(defun c:fitcurve (/ ss)
  "Seçilen polyline'ları fit curve yapar"
  (princ "\nFit curve yapılacak polyline'ları seçin: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  
  (if ss
    (progn
      (command "_PEDIT" "_M" ss "" "_F" "")
      (princ "\nPolyline'lar fit curve yapıldı.")
    )
    (princ "\nHiçbir polyline seçilmedi.")
  )
  (princ)
)

;;; Global tolerans değişkeni
(if (not *JOIN-TOLERANCE*) (setq *JOIN-TOLERANCE* 0.001))

;;; Tolerans ayarlama komutu
(defun c:settol (/ new-tol)
  "Polyline birleştirme toleransını ayarlar"
  (princ (strcat "\nMevcut tolerans: " (rtos *JOIN-TOLERANCE* 2 6)))
  (setq new-tol (getreal "\nYeni tolerans değeri: "))
  (if (and new-tol (> new-tol 0))
    (progn
      (setq *JOIN-TOLERANCE* new-tol)
      (princ (strcat "\nTolerans " (rtos *JOIN-TOLERANCE* 2 6) " olarak ayarlandı."))
    )
    (princ "\nGeçersiz tolerans değeri.")
  )
  (princ)
)

;;; Polyline birleştirme komutu
(defun c:joinpl (/ ss ent1 ent2 pts1 pts2 end1 start2 end2 start1 tolerance merged-pts new-pl)
  "Uç uca gelmiş iki polyline'ı birleştirir"
  (setq tolerance *JOIN-TOLERANCE*) ; Global tolerans değeri
  
  (princ "\nBirleştirilecek ilk polyline'ı seçin: ")
  (setq ent1 (car (entsel)))
  
  (if ent1
    (progn
      (princ "\nBirleştirilecek ikinci polyline'ı seçin: ")
      (setq ent2 (car (entsel)))
      
      (if ent2
        (progn
          ;; Her iki polyline'ın noktalarını al
          (setq pts1 (get-polyline-points ent1))
          (setq pts2 (get-polyline-points ent2))
          
          (if (and pts1 pts2)
            (progn
              ;; Uç noktaları kontrol et
              (setq end1 (last pts1))
              (setq start1 (car pts1))
              (setq start2 (car pts2))
              (setq end2 (last pts2))
              
              ;; Hangi uçların birleşeceğini belirle
              (cond
                ;; end1 - start2 birleşimi
                ((< (distance end1 start2) tolerance)
                 (setq merged-pts (append pts1 (cdr pts2)))
                 (princ "\nPolyline'lar birleştirildi (end1->start2).")
                )
                ;; end1 - end2 birleşimi (ikinci polyline'ı ters çevir)
                ((< (distance end1 end2) tolerance)
                 (setq merged-pts (append pts1 (reverse (cdr (reverse pts2)))))
                 (princ "\nPolyline'lar birleştirildi (end1->end2).")
                )
                ;; start1 - start2 birleşimi (ilk polyline'ı ters çevir)
                ((< (distance start1 start2) tolerance)
                 (setq merged-pts (append (reverse pts1) (cdr pts2)))
                 (princ "\nPolyline'lar birleştirildi (start1->start2).")
                )
                ;; start1 - end2 birleşimi
                ((< (distance start1 end2) tolerance)
                 (setq merged-pts (append pts2 (cdr pts1)))
                 (princ "\nPolyline'lar birleştirildi (start1->end2).")
                )
                ;; Uçlar birleşmiyor
                (t
                 (princ "\nHata: Polyline'ların uçları birleşmiyor!")
                 (setq merged-pts nil)
                )
              )
              
              ;; Yeni polyline oluştur
              (if merged-pts
                (progn
                  (setq new-pl (create-joined-polyline merged-pts ent1))
                  (if new-pl
                    (progn
                      ;; Orijinal polyline'ları sil
                      (entdel ent1)
                      (entdel ent2)
                      (princ "\nBirleştirme işlemi tamamlandı.")
                    )
                    (princ "\nHata: Yeni polyline oluşturulamadı.")
                  )
                )
              )
            )
            (princ "\nHata: Polyline noktaları alınamadı.")
          )
        )
        (princ "\nİkinci polyline seçilmedi.")
      )
    )
    (princ "\nİlk polyline seçilmedi.")
  )
  (princ)
)

;;; Otomatik polyline birleştirme komutu
(defun c:autojoinpl (/ ss i j ent1 ent2 pts1 pts2 end1 start2 end2 start1 tolerance processed merged-count answer)
  "Seçilen polyline'lar arasında uç uca gelenleri otomatik birleştirir"
  (setq tolerance *JOIN-TOLERANCE*) ; Global tolerans değeri
  (setq processed '())   ; İşlenmiş polyline'lar
  (setq merged-count 0)  ; Birleştirilen çift sayısı
  
  (princ "\nBirleştirilecek polyline'ları seçin: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  
  (if ss
    (progn
      ;; Çok fazla polyline seçilmişse uyarı ver
      (if (> (sslength ss) 50)
        (progn
          (princ (strcat "\nUyarı: " (itoa (sslength ss)) " polyline seçtiniz. İşlem uzun sürebilir."))
          (princ "\nDevam etmek istiyor musunuz? (E/H): ")
          (setq answer (getstring))
          (if (or (= answer "H") (= answer "h") (= answer "N") (= answer "n"))
            (progn
              (princ "\nİşlem iptal edildi.")
              (setq ss nil)
            )
          )
        )
      )
      
      (if ss
        (progn
          (setq i 0)
          ;; Her polyline için
      (while (< i (sslength ss))
        (setq ent1 (ssname ss i))
        
        ;; Eğer bu polyline işlenmediyse
        (if (not (member ent1 processed))
          (progn
            (setq j (1+ i))
            ;; Diğer polyline'larla karşılaştır
            (while (< j (sslength ss))
              (setq ent2 (ssname ss j))
              
              ;; Eğer ikinci polyline de işlenmediyse
              (if (not (member ent2 processed))
                (progn
                  ;; Noktaları al
                  (setq pts1 (get-polyline-points ent1))
                  (setq pts2 (get-polyline-points ent2))
                  
                  (if (and pts1 pts2)
                    (progn
                      ;; Uç noktaları kontrol et
                      (setq end1 (last pts1))
                      (setq start1 (car pts1))
                      (setq start2 (car pts2))
                      (setq end2 (last pts2))
                      
                      ;; Birleşme kontrolü
                      (cond
                        ;; Uçlar birleşiyorsa
                        ((or (< (distance end1 start2) tolerance)
                             (< (distance end1 end2) tolerance)
                             (< (distance start1 start2) tolerance)
                             (< (distance start1 end2) tolerance))
                         ;; Birleştirme işlemini yap
                         (if (join-two-polylines ent1 ent2 tolerance)
                           (progn
                             (setq processed (append processed (list ent1 ent2)))
                             (setq merged-count (1+ merged-count))
                             (princ (strcat "\nPolyline çifti " (itoa merged-count) " birleştirildi."))
                           )
                         )
                        )
                      )
                    )
                  )
                )
              )
              (setq j (1+ j))
            )
          )
        )
        (setq i (1+ i))
      )
          (princ (strcat "\nToplam " (itoa merged-count) " polyline çifti birleştirildi."))
        )
      )
    )
    (princ "\nHiçbir polyline seçilmedi.")
  )
  (princ)
)

(defun create-joined-polyline (pts reference-ent / entdata new-ent layer color)
  "Verilen noktalardan yeni polyline oluşturur"
  ;; Referans polyline'ın özelliklerini al
  (setq entdata (entget reference-ent))
  (setq layer (cdr (assoc 8 entdata)))
  (setq color (cdr (assoc 62 entdata)))
  
  ;; Varsayılan değerleri ayarla
  (if (not layer) (setq layer "0"))
  (if (not color) (setq color 256))
  
  ;; Geçersiz renk değerlerini düzelt
  (if (or (< color 1) (> color 256))
    (setq color 256)  ; BYLAYER
  )
  
  ;; Yeni polyline oluştur
  (command "_PLINE")
  (foreach pt pts
    (command pt)
  )
  (command "")
  
  ;; Oluşturulan polyline'ın özelliklerini ayarla
  (setq new-ent (entlast))
  (if new-ent
    (progn
      ;; Entity data ile güvenli özellik ayarlama
      (setq new-entdata (entget new-ent))
      
      ;; Layer ayarla
      (setq new-entdata (subst (cons 8 layer) (assoc 8 new-entdata) new-entdata))
      
      ;; Renk ayarla - sadece geçerli değerler için
      (if (and color (>= color 1) (<= color 256))
        (if (= color 256)
          ;; BYLAYER için renk association'ını kaldır
          (if (assoc 62 new-entdata)
            (setq new-entdata (vl-remove (assoc 62 new-entdata) new-entdata))
          )
          ;; Spesifik renk ayarla
          (setq new-entdata (subst (cons 62 color) (assoc 62 new-entdata) new-entdata))
        )
      )
      
      ;; Değişiklikleri uygula
      (entmod new-entdata)
      (entupd new-ent)
      new-ent
    )
    nil
  )
)

(defun join-two-polylines (ent1 ent2 tolerance / pts1 pts2 end1 start1 start2 end2 merged-pts new-pl)
  "İki polyline'ı birleştirir ve başarı durumunu döner"
  (setq pts1 (get-polyline-points ent1))
  (setq pts2 (get-polyline-points ent2))
  
  (if (and pts1 pts2)
    (progn
      ;; Uç noktaları kontrol et
      (setq end1 (last pts1))
      (setq start1 (car pts1))
      (setq start2 (car pts2))
      (setq end2 (last pts2))
      
      ;; Hangi uçların birleşeceğini belirle
      (cond
        ;; end1 - start2 birleşimi
        ((< (distance end1 start2) tolerance)
         (setq merged-pts (append pts1 (cdr pts2)))
        )
        ;; end1 - end2 birleşimi (ikinci polyline'ı ters çevir)
        ((< (distance end1 end2) tolerance)
         (setq merged-pts (append pts1 (reverse (cdr (reverse pts2)))))
        )
        ;; start1 - start2 birleşimi (ilk polyline'ı ters çevir)
        ((< (distance start1 start2) tolerance)
         (setq merged-pts (append (reverse pts1) (cdr pts2)))
        )
        ;; start1 - end2 birleşimi
        ((< (distance start1 end2) tolerance)
         (setq merged-pts (append pts2 (cdr pts1)))
        )
        ;; Uçlar birleşmiyor
        (t
         (setq merged-pts nil)
        )
      )
      
      ;; Yeni polyline oluştur
      (if merged-pts
        (progn
          (setq new-pl (create-joined-polyline merged-pts ent1))
          (if new-pl
            (progn
              ;; Orijinal polyline'ları sil
              (entdel ent1)
              (entdel ent2)
              t ; Başarılı
            )
            nil ; Başarısız
          )
        )
        nil ; Uçlar birleşmiyor
      )
    )
    nil ; Noktalar alınamadı
  )
)

(princ "\nPolyline to Curve LISP yüklendi!")
(princ "\nKomutlar:")
(princ "\n  PL2CURVE - Polyline'ları spline eğrilerine dönüştürür")
(princ "\n  SMOOTHPL - Polyline'ları smooth yapar")  
(princ "\n  FITCURVE - Polyline'ları fit curve yapar")
(princ "\n  JOINPL - İki polyline'ı uç uca birleştirir")
(princ "\n  AUTOJOINPL - Seçilen polyline'lar arasında uç uca gelenleri otomatik birleştirir")
(princ "\n  SETTOL - Birleştirme toleransını ayarlar")
(princ "\nKullanım için komut satırında istediğiniz komutu yazın.")
(princ (strcat "\nMevcut birleştirme toleransı: " (rtos *JOIN-TOLERANCE* 2 6)))
(princ)