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
