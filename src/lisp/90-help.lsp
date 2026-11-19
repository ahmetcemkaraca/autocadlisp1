;;; ---------------------------------------------------------------------------
;;; 90-help.lsp - PLXHELP, PLXLANG and the load banner
;;; ---------------------------------------------------------------------------

(setq *plx-commands*
  '(("PL2CURVE"   . help-pl2curve)
    ("SMOOTHPL"   . help-smoothpl)
    ("FITCURVE"   . help-fitcurve)
    ("JOINPL"     . help-joinpl)
    ("AUTOJOINPL" . help-autojoinpl)
    ("SETTOL"     . help-settol)
    ("SIMPLIFYPL" . help-simplifypl)
    ("CTILE70"    . help-ctile70)
    ("NUMBER"     . help-number)
    ("PLXLANG"    . help-plxlang)))

(defun plx:pad (text width)
  (while (< (strlen text) width)
    (setq text (strcat text " ")))
  text)

;;; PLXHELP - list the available commands.
(defun c:plxhelp (/ entry)
  (plx:say 'help-title nil)
  (foreach entry *plx-commands*
    (princ (strcat "\n  " (plx:pad (car entry) 12) (plx:msg (cdr entry)))))
  (princ))

;;; PLXLANG - switch the language of messages.
(defun c:plxlang (/ choice)
  (initget "English Turkish")
  (setq choice (getkword (strcat "\nLanguage [English/Turkish] <"
                                 (if (= *plx-lang* "tr") "Turkish" "English")
                                 ">: ")))
  (if choice
    (setq *plx-lang* (if (= choice "Turkish") "tr" "en")))
  (plx:say 'lang-set nil)
  (princ))

(plx:say 'banner (list *plx-version*))
(plx:say 'banner-tip nil)
(princ)
