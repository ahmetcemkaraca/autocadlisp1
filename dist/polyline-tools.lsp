;;; polyline-tools.lsp - PolylineTools 2.1.0
;;; GENERATED FILE - do not edit. Edit src/lisp/*.lsp and run scripts/build.ps1.
;;; https://github.com/ahmetcemkaraca/autocadlisp  (GPL-3.0)

;;; ===== 00-core.lsp =====

;;; ---------------------------------------------------------------------------
;;; 00-core.lsp - shared infrastructure: settings, messages, environment guard
;;; ---------------------------------------------------------------------------

(vl-load-com)

(setq *plx-version* "2.1.0")

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
    (help-simplifypl ("en" . "Reduce polyline vertices (Douglas-Peucker), arcs are kept")
                     ("tr" . "Polyline k\U+00F6\U+015Fe say\U+0131s\U+0131n\U+0131 azalt\U+0131r (Douglas-Peucker), yaylar korunur"))
    (help-ctile70   ("en" . "Cut contours into clipped tile blocks and lay them out in a grid")
                    ("tr" . "Konturlar\U+0131 XCLIP'li karo bloklar\U+0131na b\U+00F6ler ve \U+0131zgara olarak dizer"))    (help-number    ("en" . "Place consecutive numbers as text at picked points")
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
    (simp-tol       ("en" . "Simplification tolerance <%1>: ")
                    ("tr" . "Basitle\U+015Ftirme tolerans\U+0131 <%1>: "))
    (simp-done      ("en" . "Simplified %1 polyline(s); %2 vertex(es) removed.")
                    ("tr" . "%1 polyline basitle\U+015Ftirildi; %2 k\U+00F6\U+015Fe kald\U+0131r\U+0131ld\U+0131."))
    (simp-nochange  ("en" . "No polyline could be reduced. Try a larger tolerance.")
                    ("tr" . "Hi\U+00E7bir polyline azalt\U+0131lamad\U+0131. Daha b\U+00FCy\U+00FCk bir tolerans deneyin."))
    (simp-skipped   ("en" . "Skipped %1 object(s) (3D polylines and meshes are not supported).")
                    ("tr" . "%1 nesne atland\U+0131 (3B polyline ve a\U+011Flar desteklenmez)."))
    (tile-select    ("en" . "Select contour objects (LWPOLYLINE, POLYLINE, SPLINE, LINE, ARC): ")
                    ("tr" . "Kontur nesnelerini se\U+00E7in (LWPOLYLINE, POLYLINE, SPLINE, LINE, ARC): "))
    (tile-width     ("en" . "Tile width <%1>: ")
                    ("tr" . "Karo geni\U+015Fli\U+011Fi <%1>: "))
    (tile-height    ("en" . "Tile height <%1>: ")
                    ("tr" . "Karo y\U+00FCksekli\U+011Fi <%1>: "))
    (tile-gap       ("en" . "Gap between tiles in the layout <%1>: ")
                    ("tr" . "D\U+00FCzendeki karolar aras\U+0131 bo\U+015Fluk <%1>: "))
    (tile-cols      ("en" . "Tiles per row in the layout <%1>: ")
                    ("tr" . "D\U+00FCzende sat\U+0131r ba\U+015F\U+0131na karo <%1>: "))
    (tile-nobox     ("en" . "Could not determine the extents of the selection.")
                    ("tr" . "Se\U+00E7imin s\U+0131n\U+0131rlar\U+0131 belirlenemedi."))
    (tile-too-many  ("en" . "That would create %1 tiles. Use a larger tile size.")
                    ("tr" . "Bu i\U+015Flem %1 karo olu\U+015Fturur. Daha b\U+00FCy\U+00FCk bir karo boyutu kullan\U+0131n."))
    (tile-block-fail ("en" . "Could not create the source block.")
                     ("tr" . "Kaynak blok olu\U+015Fturulamad\U+0131."))
    (tile-none      ("en" . "No tile contains any of the selected objects.")
                    ("tr" . "Hi\U+00E7bir karo se\U+00E7ilen nesnelerden birini i\U+00E7ermiyor."))
    (tile-done      ("en" . "%1 tile(s) created in block %2.")
                    ("tr" . "%2 blo\U+011Funda %1 karo olu\U+015Fturuldu."))    (lang-set       ("en" . "Language: English")
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
      (if *plx-ucs-pushed*
        (progn (command "_.UCS" "_P")
               (setq *plx-ucs-pushed* nil)))
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

;; Switch to the World UCS for the rest of the command; plx:end restores the
;; previous UCS.
(defun plx:world-ucs ()
  (command "_.UCS" "_W")
  (setq *plx-ucs-pushed* T))

;;; ---------------------------------------------------------------------------
;;; Input and drawing helpers
;;; ---------------------------------------------------------------------------

;; Ask for a real number > 0; Enter (or an invalid value) returns DEFAULT.
(defun plx:ask-real (key default / value)
  (setq value (getreal (strcat "\n" (plx:fmt key (list default)))))
  (if (and value (> value 0.0)) value default))

;; Smallest integer that is >= X (X >= 0), at least 1.
(defun plx:ceil (x / n)
  (setq n (fix x))
  (if (> (- x n) 1e-9) (setq n (1+ n)))
  (max n 1))

;; Create a TEXT object.  PT is expressed in the OCS defined by NORMAL.
;; HALIGN/VALIGN are the DXF justification codes (72/73), e.g. 1/2 = middle centre.
(defun plx:make-text (pt text height normal rotation halign valign)
  (if (entmake
        (list '(0 . "TEXT")
              (cons 10 pt)
              (cons 40 height)
              (cons 1 text)
              (cons 50 rotation)
              (cons 7 (getvar "TEXTSTYLE"))
              (cons 72 halign)
              (cons 11 pt)
              (cons 210 normal)
              (cons 73 valign)))
    T))

;;; ===== 10-polyline.lsp =====

;;; ---------------------------------------------------------------------------
;;; 10-polyline.lsp - reading, building and joining polyline geometry
;;;
;;; A polyline is modelled as a list of vertices (POINT . BULGE).  The bulge
;;; of a vertex describes the segment that starts at that vertex and ends at
;;; the next one (for a closed polyline the last vertex describes the closing
;;; segment).  Points are 3D and expressed in the polyline's OCS.
;;; ---------------------------------------------------------------------------

;;; --- Classification --------------------------------------------------------

(defun plx:flags (ename / flags)
  (setq flags (cdr (assoc 70 (entget ename))))
  (if flags flags 0))

(defun plx:kind (ename)
  (cdr (assoc 0 (entget ename))))

(defun plx:polyline-p (ename)
  (and ename (member (plx:kind ename) '("LWPOLYLINE" "POLYLINE")) T))

;; Heavy POLYLINE that is a 3D polygon mesh or a polyface mesh.
(defun plx:mesh-p (ename)
  (and (= (plx:kind ename) "POLYLINE")
       (/= 0 (logand 80 (plx:flags ename)))))

;; Heavy POLYLINE that is a 3D polyline (vertices are WCS points).
(defun plx:3d-p (ename)
  (and (= (plx:kind ename) "POLYLINE")
       (/= 0 (logand 8 (plx:flags ename)))))

(defun plx:closed-p (ename)
  (/= 0 (logand 1 (plx:flags ename))))

;; Polyline whose vertices live in one plane (LWPOLYLINE or 2D POLYLINE).
(defun plx:flat-p (ename)
  (and (plx:polyline-p ename)
       (not (plx:mesh-p ename))
       (not (plx:3d-p ename))))

;; Open, flat polyline - the only kind that can be joined end to end.
(defun plx:joinable-p (ename)
  (and (plx:flat-p ename)
       (not (plx:closed-p ename))))

(defun plx:normal (ename / normal)
  (setq normal (cdr (assoc 210 (entget ename))))
  (if normal normal '(0.0 0.0 1.0)))

;; Coordinate system the vertex points of ENAME are expressed in, suitable as
;; the "from" argument of TRANS: the entity itself (OCS) or 0 (WCS).
(defun plx:space (ename)
  (if (plx:3d-p ename) 0 ename))

(defun plx:comparable-p (a b)
  (equal (plx:normal a) (plx:normal b) 1e-8))

;;; --- Reading ---------------------------------------------------------------

(defun plx:lw-vertices (data / elev verts item)
  (setq elev (cdr (assoc 38 data)))
  (if (not elev) (setq elev 0.0))
  (foreach item data
    (cond
      ((= (car item) 10)
       (setq verts (cons (cons (list (cadr item) (caddr item) elev) 0.0) verts)))
      ((and (= (car item) 42) verts)
       (setq verts (cons (cons (car (car verts)) (cdr item)) (cdr verts))))))
  (reverse verts))

(defun plx:heavy-vertices (ename data / flat elev vert vdata pt bulge verts)
  (setq flat (zerop (logand 8 (plx:flags ename)))
        elev (caddr (cdr (assoc 10 data)))
        vert (entnext ename))
  (if (not elev) (setq elev 0.0))
  (while (and vert
              (= (cdr (assoc 0 (setq vdata (entget vert)))) "VERTEX"))
    ;; Skip spline frame control points (vertex flag 16).
    (if (zerop (logand 16 (plx:flags vert)))
      (progn
        (setq pt    (cdr (assoc 10 vdata))
              bulge (cdr (assoc 42 vdata)))
        (if flat (setq pt (list (car pt) (cadr pt) elev)))
        (setq verts (cons (cons pt (if bulge bulge 0.0)) verts))))
    (setq vert (entnext vert)))
  (reverse verts))

;; Vertex list of an LWPOLYLINE or POLYLINE; nil for anything else.
(defun plx:vertices (ename / data kind)
  (setq data (entget ename)
        kind (cdr (assoc 0 data)))
  (cond
    ((= kind "LWPOLYLINE") (plx:lw-vertices data))
    ((and (= kind "POLYLINE") (not (plx:mesh-p ename)))
     (plx:heavy-vertices ename data))))

;;; --- Writing ---------------------------------------------------------------

;; Create an LWPOLYLINE from VERTS, taking layer, color, linetype, linetype
;; scale and lineweight from the entity REF.  Returns the new entity or nil.
(defun plx:make-lwpolyline (verts closed ref / rdata code props elev)
  (setq rdata (entget ref)
        elev  (caddr (car (car verts))))
  (foreach code '(6 62 48 370)
    (if (assoc code rdata)
      (setq props (append props (list (assoc code rdata))))))
  (if (entmake
        (append
          (list '(0 . "LWPOLYLINE")
                '(100 . "AcDbEntity")
                (cons 8 (cdr (assoc 8 rdata))))
          props
          (list '(100 . "AcDbPolyline")
                (cons 90 (length verts))
                (cons 70 (if closed 1 0))
                (cons 38 elev))
          (apply 'append
                 (mapcar '(lambda (v)
                            (list (cons 10 (list (car (car v)) (cadr (car v))))
                                  (cons 42 (cdr v))))
                         verts))
          (list (cons 210 (plx:normal ref)))))
    (entlast)))

;; Copy layer, color, linetype, linetype scale and lineweight from SRC to DST.
(defun plx:copy-props (src dst / sdata ddata code new old)
  (setq sdata (entget src)
        ddata (entget dst))
  (foreach code '(8 6 62 48 370)
    (setq new (assoc code sdata)
          old (assoc code ddata))
    (cond
      ((and new old) (setq ddata (subst new old ddata)))
      (new           (setq ddata (append ddata (list new))))
      (old           (setq ddata (vl-remove old ddata)))))
  (entmod ddata)
  (entupd dst)
  dst)

;;; --- Joining ---------------------------------------------------------------

;; Reverse the direction of a vertex list.  Bulges are negated and shifted to
;; the vertex that now starts the segment.
(defun plx:reverse-verts (verts)
  (mapcar 'cons
          (reverse (mapcar 'car verts))
          (append (mapcar '- (reverse (mapcar 'cdr (plx:butlast verts))))
                  (list 0.0))))

;; Append B to A; the end of A and the start of B are assumed to coincide.
(defun plx:concat-verts (a b)
  (append (plx:butlast a)
          (list (cons (car (last a)) (cdr (car b))))
          (cdr b)))

;; Join two open vertex lists end to end, reversing either one if needed.
;; Returns the joined list or nil when no pair of endpoints is within TOL.
(defun plx:join-verts (a b tol / a-start a-end b-start b-end)
  (setq a-start (car (car a))
        a-end   (car (last a))
        b-start (car (car b))
        b-end   (car (last b)))
  (cond
    ((plx:near a-end b-start tol)   (plx:concat-verts a b))
    ((plx:near a-end b-end tol)     (plx:concat-verts a (plx:reverse-verts b)))
    ((plx:near a-start b-start tol) (plx:concat-verts (plx:reverse-verts a) b))
    ((plx:near a-start b-end tol)   (plx:concat-verts b a))))

;; If the first and last vertex coincide, drop the duplicate and report the
;; polyline as closed.  Returns (VERTS . CLOSED).
(defun plx:close-ring (verts tol)
  (if (and (>= (length verts) 4)
           (plx:near (car (car verts)) (car (last verts)) tol))
    (cons (plx:butlast verts) T)
    (cons verts nil)))

;; Repeatedly merge touching chains.  A chain is (VERTS SOURCES) where SOURCES
;; lists the original entities it was built from.  Returns the final chains.
(defun plx:merge-chains (chains tol / changed i j a b joined)
  (setq changed T)
  (while changed
    (setq changed nil
          i       0)
    (while (and (not changed) (< i (length chains)))
      (setq a (nth i chains)
            j (1+ i))
      (while (and (not changed) (< j (length chains)))
        (setq b (nth j chains))
        (if (and (plx:comparable-p (car (cadr a)) (car (cadr b)))
                 (setq joined (plx:join-verts (car a) (car b) tol)))
          (setq chains  (append (plx:remove-nth i (plx:remove-nth j chains))
                                (list (list joined (append (cadr a) (cadr b)))))
                changed T))
        (setq j (1+ j)))
      (setq i (1+ i))))
  chains)

;;; ===== 20-geometry.lsp =====

;;; ---------------------------------------------------------------------------
;;; 20-geometry.lsp - bulge arc math and point sampling
;;; ---------------------------------------------------------------------------

;; Angular resolution used when an arc segment is approximated by points.
(setq *plx-arc-step* (/ pi 18.0)) ; 10 degrees

;; Interior points of the arc that a bulge describes between P1 and P2.
;; Bulge = tan(sweep / 4); positive bulges run counter-clockwise.
(defun plx:arc-points (p1 p2 bulge / chord sweep steps middle center radius start k pts)
  (setq chord (distance p1 p2))
  (if (and (> chord 1e-9) (> (abs bulge) 1e-9))
    (progn
      (setq sweep  (* 4.0 (atan bulge))
            steps  (max 2 (1+ (fix (/ (abs sweep) *plx-arc-step*))))
            middle (mapcar '(lambda (a b) (/ (+ a b) 2.0)) p1 p2)
            ;; The centre lies on the chord's perpendicular bisector, at a
            ;; signed distance of chord * (1 - bulge^2) / (4 * bulge).
            center (polar middle
                          (+ (angle p1 p2) (/ pi 2.0))
                          (/ (* chord (- 1.0 (* bulge bulge))) (* 4.0 bulge)))
            radius (distance center p1)
            start  (angle center p1)
            k      1)
      (repeat (1- steps)
        (setq pts (cons (polar center
                               (+ start (* sweep (/ k (float steps))))
                               radius)
                        pts)
              k   (1+ k)))
      (reverse pts))))

;; Drop consecutive duplicate points (a closed list also drops a final point
;; that repeats the first one).
(defun plx:dedupe (pts closed / out p)
  (foreach p pts
    (if (or (null out) (not (plx:near p (car out) 1e-9)))
      (setq out (cons p out))))
  (if (and closed
           (> (length out) 1)
           (plx:near (car out) (last out) 1e-9))
    (setq out (cdr out)))
  (reverse out))

;; Flatten a vertex list to a point list in which arc segments are replaced by
;; a series of points.  Closed polylines do not repeat the first point.
(defun plx:sample-points (verts closed / n i v w pts p)
  (setq n (length verts)
        i 0)
  (repeat (if closed n (1- n))
    (setq v   (nth i verts)
          w   (nth (rem (1+ i) n) verts)
          pts (cons (car v) pts))
    (foreach p (plx:arc-points (car v) (car w) (cdr v))
      (setq pts (cons p pts)))
    (setq i (1+ i)))
  (if (not closed)
    (setq pts (cons (car (last verts)) pts)))
  (plx:dedupe (reverse pts) closed))

;;; ===== 30-curve.lsp =====

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

;;; ===== 40-join.lsp =====

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

;;; ===== 50-number.lsp =====

;;; ---------------------------------------------------------------------------
;;; 50-number.lsp - NUMBER: place consecutive numbers as text
;;; ---------------------------------------------------------------------------

(if (not *plx-text-height*) (setq *plx-text-height* 2.5))

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
           (if (plx:make-text (trans pt 1 normal)
                                     (itoa n)
                                     height
                                     normal
                                     rotation
                                     1
                                     2)
             (setq n     (1+ n)
                   count (1+ count))
             (plx:say 'num-failed nil)))
         (plx:say 'num-done (list count))))))
  (plx:end))

;;; ===== 60-simplify.lsp =====

;;; ---------------------------------------------------------------------------
;;; 60-simplify.lsp - SIMPLIFYPL: reduce polyline vertices (Douglas-Peucker)
;;;
;;; Arc segments are never touched.  Each run of straight segments between
;;; arcs (or between the ends of the polyline) is simplified on its own with
;;; its end points fixed.
;;; ---------------------------------------------------------------------------

(if (not *plx-simplify-tol*) (setq *plx-simplify-tol* 0.5))

(defun plx:dist2d (p q)
  (distance (list (car p) (cadr p)) (list (car q) (cadr q))))

;; Distance in the XY plane from P to the segment A-B.
(defun plx:point-segment-distance (p a b / dx dy len2 u)
  (setq dx   (- (car b) (car a))
        dy   (- (cadr b) (cadr a))
        len2 (+ (* dx dx) (* dy dy)))
  (if (< len2 1e-18)
    (plx:dist2d p a)
    (progn
      (setq u (/ (+ (* (- (car p) (car a)) dx)
                    (* (- (cadr p) (cadr a)) dy))
                 len2))
      (cond
        ((< u 0.0) (plx:dist2d p a))
        ((> u 1.0) (plx:dist2d p b))
        (T (plx:dist2d p (list (+ (car a) (* u dx))
                               (+ (cadr a) (* u dy)))))))))

(defun plx:take (n lst / out)
  (repeat n
    (setq out (cons (car lst) out)
          lst (cdr lst)))
  (reverse out))

(defun plx:drop (n lst)
  (repeat n
    (setq lst (cdr lst)))
  lst)

;; Douglas-Peucker on a list of points; the first and last point are kept.
(defun plx:douglas-peucker (pts eps / a b worst worst-i i d p)
  (if (<= (length pts) 2)
    pts
    (progn
      (setq a       (car pts)
            b       (last pts)
            worst   -1.0
            worst-i 0
            i       1)
      (foreach p (cdr (plx:butlast pts))
        (setq d (plx:point-segment-distance p a b))
        (if (> d worst)
          (setq worst   d
                worst-i i))
        (setq i (1+ i)))
      (if (> worst eps)
        (append (plx:douglas-peucker (plx:take (1+ worst-i) pts) eps)
                (cdr (plx:douglas-peucker (plx:drop worst-i pts) eps)))
        (list a b)))))

;; Simplify the points of one straight run.  Every returned vertex has a zero
;; bulge except the last one, which gets LAST-BULGE (the arc that follows).
(defun plx:simplify-run (pts last-bulge eps / simple out p)
  (setq simple (plx:douglas-peucker pts eps))
  (foreach p (plx:butlast simple)
    (setq out (cons (cons p 0.0) out)))
  (reverse (cons (cons (last simple) last-bulge) out)))

;; Simplify an OPEN vertex list.  Returns a new vertex list.
(defun plx:simplify-open (verts eps / n i v run out)
  (setq n (1- (length verts))
        i 0)
  (repeat n
    (setq v   (nth i verts)
          run (cons (car v) run))
    (if (/= 0.0 (cdr v))
      (setq out (append out (plx:simplify-run (reverse run) (cdr v) eps))
            run nil))
    (setq i (1+ i)))
  (setq run (cons (car (last verts)) run))
  (append out (plx:simplify-run (reverse run) 0.0 eps)))

;; Index of the first vertex that starts an arc segment, or nil.
(defun plx:first-arc-index (verts / i found v)
  (setq i 0)
  (foreach v verts
    (if (and (not found) (/= 0.0 (cdr v)))
      (setq found i))
    (setq i (1+ i)))
  found)

;; Simplify a vertex list.  Returns (VERTS . CLOSED).  Closed polylines are
;; rotated to start at an arc (when there is one), simplified as an open
;; polyline that returns to its start, and closed again.
(defun plx:simplify-verts (verts closed eps / k rotated result)
  (if (not closed)
    (cons (plx:simplify-open verts eps) nil)
    (progn
      (setq k       (plx:first-arc-index verts)
            rotated (if (and k (> k 0))
                      (append (plx:drop k verts) (plx:take k verts))
                      verts)
            result  (plx:simplify-open
                      (append rotated (list (cons (car (car rotated)) 0.0)))
                      eps))
      (cons (plx:butlast result) T))))

;;; SIMPLIFYPL - reduce the vertex count of polylines within a tolerance.
(defun c:simplifypl (/ tol enames done removed skipped ename verts closed result new)
  (plx:begin nil)
  (setq tol (plx:ask-real 'simp-tol *plx-simplify-tol*)
        *plx-simplify-tol* tol
        done 0 removed 0 skipped 0)
  (if (setq enames (plx:select-polylines))
    (progn
      (foreach ename enames
        (if (not (plx:flat-p ename))
          (setq skipped (1+ skipped))
          (progn
            (setq verts  (plx:vertices ename)
                  closed (plx:closed-p ename)
                  result (plx:simplify-verts verts closed tol))
            (if (and (< (length (car result)) (length verts))
                     (>= (length (car result)) (if closed 3 2))
                     (setq new (plx:make-lwpolyline (car result) (cdr result) ename)))
              (progn
                (entdel ename)
                (setq done    (1+ done)
                      removed (+ removed (- (length verts) (length (car result))))))))))
      (if (> skipped 0) (plx:say 'simp-skipped (list skipped)))
      (if (> done 0)
        (plx:say 'simp-done (list done removed))
        (plx:say 'simp-nochange nil)))
    (plx:say 'nothing nil))
  (plx:end))

;;; ===== 70-tile.lsp =====

;;; ---------------------------------------------------------------------------
;;; 70-tile.lsp - CTILE70: cut contours into clipped tile blocks
;;;
;;; The selection is wrapped in one block.  For every grid cell that touches
;;; the selection, the block is inserted, clipped to the cell with XCLIP and
;;; moved into a compact layout to the right of the original drawing.  This is
;;; handy for cutting large contour models in pieces (for example 70 x 70).
;;; ---------------------------------------------------------------------------

(if (not *plx-tile-width*)  (setq *plx-tile-width* 70.0))
(if (not *plx-tile-height*) (setq *plx-tile-height* 70.0))
(if (not *plx-tile-gap*)    (setq *plx-tile-gap* 10.0))
(if (not *plx-tile-cols*)   (setq *plx-tile-cols* 5))

(setq *plx-tile-filter* '((0 . "LWPOLYLINE,POLYLINE,SPLINE,LINE,ARC")))

;; Bounding box of a selection set as ((minx miny) (maxx maxy)), or nil.
(defun plx:bbox (ss / i obj pmin pmax lo hi minx miny maxx maxy)
  (repeat (setq i (sslength ss))
    (setq i   (1- i)
          obj (vlax-ename->vla-object (ssname ss i)))
    (if (not (vl-catch-all-error-p
               (vl-catch-all-apply 'vla-getboundingbox (list obj 'pmin 'pmax))))
      (progn
        (setq lo   (vlax-safearray->list pmin)
              hi   (vlax-safearray->list pmax)
              minx (if minx (min minx (car lo)) (car lo))
              miny (if miny (min miny (cadr lo)) (cadr lo))
              maxx (if maxx (max maxx (car hi)) (car hi))
              maxy (if maxy (max maxy (cadr hi)) (cadr hi))))))
  (if minx (list (list minx miny) (list maxx maxy))))

;; Wrap the selection in a new block with a unique name and keep the original
;; objects (-BLOCK erases them, OOPS brings them back).  Returns the name or nil.
(defun plx:make-block (ss / n name)
  (setq n 1)
  (while (tblsearch "BLOCK" (setq name (strcat "PLX_TILES_" (itoa n))))
    (setq n (1+ n)))
  (command "_.-BLOCK" name '(0.0 0.0 0.0) ss "")
  (command "_.OOPS")
  (if (tblsearch "BLOCK" name) name))

;; True when a member of SS crosses or lies inside the rectangle P1-P2.
(defun plx:tile-hit-p (ss p1 p2 / hits i hit)
  (if (setq hits (ssget "_C" p1 p2 *plx-tile-filter*))
    (repeat (setq i (sslength hits))
      (setq i (1- i))
      (if (ssmemb (ssname hits i) ss) (setq hit T))))
  hit)

;; Insert BLK so that the tile whose lower-left corner is TILE-MIN lands at
;; DEST, and clip it to the DEST rectangle (W x H).  Returns the INSERT or nil.
(defun plx:place-tile (blk tile-min dest w h / offset ins)
  (setq offset (list (- (car dest) (car tile-min))
                     (- (cadr dest) (cadr tile-min))
                     0.0))
  (if (entmake (list '(0 . "INSERT") (cons 2 blk) (cons 10 offset)))
    (progn
      (setq ins (entlast))
      (command "_.XCLIP" ins "" "_N" "_R"
               dest
               (list (+ (car dest) w) (+ (cadr dest) h)))
      ins)))

;;; CTILE70 - cut contours into clipped tile blocks (default 70 x 70).
(defun c:ctile70 (/ ss box lo hi w h gap cols nx ny blk origin i j k count
                    tile-min dest label-h)
  (plx:begin T)
  (plx:world-ucs)
  (plx:say 'tile-select nil)
  (cond
    ((not (setq ss (ssget *plx-tile-filter*)))
     (plx:say 'nothing nil))
    ((not (setq box (plx:bbox ss)))
     (plx:say 'tile-nobox nil))
    (T
     (setq lo   (car box)
           hi   (cadr box)
           w    (plx:ask-real 'tile-width *plx-tile-width*)
           h    (plx:ask-real 'tile-height *plx-tile-height*)
           gap  (plx:ask-real 'tile-gap *plx-tile-gap*)
           cols (max 1 (fix (plx:ask-real 'tile-cols *plx-tile-cols*)))
           *plx-tile-width*  w
           *plx-tile-height* h
           *plx-tile-gap*    gap
           *plx-tile-cols*   cols
           nx   (plx:ceil (/ (- (car hi) (car lo)) w))
           ny   (plx:ceil (/ (- (cadr hi) (cadr lo)) h)))
     (cond
       ((> (* nx ny) 2000)
        (plx:say 'tile-too-many (list (* nx ny))))
       ((not (setq blk (plx:make-block ss)))
        (plx:say 'tile-block-fail nil))
       (T
        (setq origin  (list (+ (car hi) (* 2.0 gap)) (cadr lo))
              label-h (/ (min w h) 14.0)
              k       0
              count   0
              i       0)
        (repeat nx
          (setq j 0)
          (repeat ny
            (setq tile-min (list (+ (car lo) (* i w)) (+ (cadr lo) (* j h))))
            (if (plx:tile-hit-p ss
                                tile-min
                                (list (+ (car tile-min) w) (+ (cadr tile-min) h)))
              (progn
                (setq dest (list (+ (car origin) (* (rem k cols) (+ w gap)))
                                 (+ (cadr origin) (* (/ k cols) (+ h gap)))
                                 0.0))
                (if (plx:place-tile blk tile-min dest w h)
                  (progn
                    (plx:make-text (list (+ (car dest) (* 0.03 w))
                                         (+ (cadr dest) (* 0.03 h))
                                         0.0)
                                   (strcat "T" (itoa i) "-" (itoa j))
                                   label-h
                                   '(0.0 0.0 1.0)
                                   0.0
                                   0
                                   0)
                    (setq count (1+ count))))
                (setq k (1+ k))))
            (setq j (1+ j)))
          (setq i (1+ i)))
        (if (> count 0)
          (plx:say 'tile-done (list count blk))
          (plx:say 'tile-none nil))))))
  (plx:end))

;;; ===== 90-help.lsp =====

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
