;;; auto-numbered-text.lsp
;;; 1'den istenen sayıya kadar otomatik boyutlu text yazan LISP programı
;;; Author: ArchBuilder.AI
;;; Version: 1.0.0
;;; Date: 2025-01-27

(vl-load-com)

;;; Global ayarlar
(if (not *AUTO-TEXT-HEIGHT*) (setq *AUTO-TEXT-HEIGHT* 2.5))
(if (not *AUTO-TEXT-SPACING*) (setq *AUTO-TEXT-SPACING* 1.0))

;;; Yardımcı fonksiyonlar
(defun get-user-input (/ max-num)
  "Kullanıcıdan maksimum sayıyı al"
  (setq max-num (getint "\nKaça kadar sayı yazılacak (1'den başlayarak): "))
  (if (and max-num (> max-num 0))
    max-num
    (progn
      (princ "\nGeçersiz değer! Pozitif sayı girin.")
      nil
    )
  )
)

(defun get-insertion-point-for-number (num / pt)
  "Belirli bir sayı için text yerleştirme noktasını kullanıcıdan al"
  (setq pt (getpoint (strcat "\n" (itoa num) " sayısının yerleştirileceği noktayı seçin: ")))
  (if pt
    pt
    (progn
      (princ "\nGeçersiz nokta!")
      nil
    )
  )
)

(defun calculate-text-height (max-num / base-height)
  "Sayı büyüklüğüne göre otomatik text yüksekliği hesapla"
  (setq base-height *AUTO-TEXT-HEIGHT*)
  (cond
    ((<= max-num 10) base-height)
    ((<= max-num 50) (* base-height 0.8))
    ((<= max-num 100) (* base-height 0.6))
    ((<= max-num 500) (* base-height 0.4))
    (T (* base-height 0.3))
  )
)


(defun create-single-text (num pt height / data)
  "Tek bir numaralı text objesi oluştur"
  (setq data (list
    (cons 0 "TEXT")
    (cons 100 "AcDbEntity")
    (cons 100 "AcDbText")
    (cons 10 pt)
    (cons 40 height)
    (cons 1 (itoa num))
    (cons 50 0.0)
    (cons 51 0.0)
    (cons 7 "STANDARD")
    (cons 71 0)
    (cons 72 0)
    (cons 11 pt)
    (cons 210 (list 0.0 0.0 1.0))
    (cons 100 "AcDbText")
  ))
  (entmake data)
)

(defun create-numbered-texts (max-num text-height / i pt new-ent count)
  "1'den max-num'a kadar text objeleri oluştur - her sayı için ayrı nokta seçimi"
  (setq i 1)
  (setq count 0)
  
  (while (<= i max-num)
    (setq pt (get-insertion-point-for-number i))
    (if pt
      (progn
        (setq new-ent (create-single-text i pt text-height))
        (if new-ent
          (setq count (1+ count))
          (princ (strcat "\nHata: " (itoa i) " numaralı text oluşturulamadı."))
        )
      )
      (progn
        (princ (strcat "\n" (itoa i) " sayısı atlandı."))
      )
    )
    (setq i (1+ i))
  )
  count
)

(defun validate-input (max-num)
  "Giriş değerini doğrula"
  (and max-num 
       (= (type max-num) 'INT) 
       (> max-num 0) 
       (<= max-num 10000))
)

(defun show-settings (/ msg)
  "Mevcut ayarları göster"
  (setq msg (strcat "\nMevcut Ayarlar:"
                    "\n  Text Yüksekliği: " (rtos *AUTO-TEXT-HEIGHT* 2 2)
                    "\n  Satır Aralığı Çarpanı: " (rtos *AUTO-TEXT-SPACING* 2 2)))
  (princ msg)
)

;;; Ana komut: AUTOTEXT
(defun c:AUTOTEXT (/ max-num text-height count)
  "1'den istenen sayıya kadar otomatik boyutlu text yazar - her sayı için ayrı nokta seçimi"
  (princ "\n=== Otomatik Numaralı Text Yazma (Ayrı Yerleştirme) ===")
  (show-settings)
  
  ;; Kullanıcıdan maksimum sayıyı al
  (setq max-num (get-user-input))
  (if (not max-num)
    (progn
      (princ "\nİşlem iptal edildi.")
      (exit)
    )
  )
  
  ;; Giriş doğrulama
  (if (not (validate-input max-num))
    (progn
      (princ "\nHata: Geçersiz değer! 1-10000 arası pozitif sayı girin.")
      (exit)
    )
  )
  
  ;; Text parametrelerini hesapla
  (setq text-height (calculate-text-height max-num))
  
  (princ (strcat "\nText yüksekliği: " (rtos text-height 2 2)))
  (princ "\nHer sayı için ayrı nokta seçmeniz gerekecek.")
  (princ "\nİptal etmek için ESC tuşuna basın.")
  
  ;; Text objelerini oluştur - her sayı için ayrı nokta seçimi
  (setq count (create-numbered-texts max-num text-height))
  
  ;; Sonuç raporu
  (princ (strcat "\n" (itoa count) " adet text oluşturuldu (1-" (itoa max-num) ")."))
  (princ)
)

;;; Ayarlama komutları
(defun c:SETTEXTHEIGHT (/ new-height)
  "Text yüksekliğini ayarla"
  (princ (strcat "\nMevcut text yüksekliği: " (rtos *AUTO-TEXT-HEIGHT* 2 2)))
  (setq new-height (getreal "\nYeni text yüksekliği: "))
  (if (and new-height (> new-height 0))
    (progn
      (setq *AUTO-TEXT-HEIGHT* new-height)
      (princ "\nText yüksekliği güncellendi.")
    )
    (princ "\nGeçersiz değer!")
  )
  (princ)
)

(defun c:SETTEXTSPACING (/ new-spacing)
  "Satır aralığı çarpanını ayarla"
  (princ (strcat "\nMevcut satır aralığı çarpanı: " (rtos *AUTO-TEXT-SPACING* 2 2)))
  (setq new-spacing (getreal "\nYeni satır aralığı çarpanı (1.0 = normal): "))
  (if (and new-spacing (> new-spacing 0))
    (progn
      (setq *AUTO-TEXT-SPACING* new-spacing)
      (princ "\nSatır aralığı çarpanı güncellendi.")
    )
    (princ "\nGeçersiz değer!")
  )
  (princ)
)

(defun c:SHOWAUTOTEXTSETTINGS ()
  "Mevcut ayarları göster"
  (show-settings)
  (princ)
)

;;; Program yükleme mesajları
(princ "\nOtomatik Numaralı Text LISP yüklendi!")
(princ "\nKomutlar:")
(princ "\n  AUTOTEXT              - 1'den istenen sayıya kadar text yazar")
(princ "\n  SETTEXTHEIGHT         - Text yüksekliğini ayarlar")
(princ "\n  SETTEXTSPACING        - Satır aralığı çarpanını ayarlar")
(princ "\n  SHOWAUTOTEXTSETTINGS  - Mevcut ayarları gösterir")
(princ)
