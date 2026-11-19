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
