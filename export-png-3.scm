;; basename_noext ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (re-re-match re string buffer)
        "Workaround GIMP 2.10 bug https://gitlab.gnome.org/GNOME/gimp/issues/2965"
        (and (re-match re string)
             (re-match re string buffer)))
(define (basename_noext path)
        (let ((buffer (vector "" "" "")))
          (if (re-re-match "/([^/.]+)\\.([^.]+)$" path buffer)
              (substring path
                         (car (vector-ref buffer 1))
                         (cdr (vector-ref buffer 1)))
            "")))
;; debugdispay ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (debugdispay pre body)
  (display pre)(display body)(newline))

;; export png ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script-fu-my-export-png indir expdir topX topY w h resizeW)
  (let* ((flist           ())
         (export-img      ())
         (export-drawable ())
         (export-filename ())
         (drawable-new    ())
         (currentW        ())
         (currentH        ())
         (resizeH         ())
         )
    (display "indir=")(display indir)(newline)
    (set! flist (car (file-glob #:pattern (string-append indir "/*.xcf")
                                #:filename-encoding FALSE ; encoding:UTF-8
                           )))
    (display "flist=")(display flist)(newline)

    ;; show file list (full phth)
    ;; (gimp-message indir)
    ;; (gimp-message (number->string (car flist)))
    ;; (gimp-message  (car (car (cdr flist))) )

    ;;(tracing TRUE)
    (for-each (lambda (file)
                (display "file=")(display file)(newline)
                (set! export-img (gimp-file-load 1 ; RUN-NONINTERACTIVE
                                                   ; 0 ; RUN-INTERACTIVE
                                                 file
                                                 file))
                ;; when export pdf
                (gimp-image-merge-visible-layers (car export-img)
                                                  0 ; EXPAND-AS-NECESSARY
                                                  )
                ;; crop
                (gimp-image-crop (car export-img)
                                 w    ; new-width
                                 h    ; new-height
                                 topX ; offx
                                 topY ; offy
                                 )
                ;; resize
                (set! currentW (car (gimp-image-get-width  (car export-img))))
                (set! currentH (car (gimp-image-get-height (car export-img))))
                (set! resizeH  (* currentH (/ resizeW currentW) ))

                ;; (gimp-message resizeH)

                ;; (gimp-image-resize (car export-img)
                ;;                    resizeW ; width
                ;;                    resizeH ; height
                ;;                    0 ; offx
                ;;                    0 ; offy
                ;;                    )

                ;; INTERPOLATION-NONE    (0)
                ;; INTERPOLATION-LINEAR  (1)
                ;; INTERPOLATION-CUBIC   (2)
                ;; INTERPOLATION-LANCZOS (3)
                (gimp-context-set-interpolation 3)

                (gimp-image-scale (car export-img)
                                  resizeW
                                  resizeH)

                ;; (set! export-drawable
                ;;       (gimp-image-get-active-drawable (car export-img)))
                (set! expdir
                  (if (not (string=? (substring expdir (- (string-length expdir) 1) (string-length expdir)) "/"))
                      (string-append expdir "/")
                      expdir))
                (set! export-filename
                      (string-append
                       expdir (basename_noext file) ".png"))
                (debugdispay "export-filename=" export-filename)

                (file-png-export 1 ; The run mode { RUN-INTERACTIVE (0), RUN-NONINTERACTIVE (1) }
                               (car export-img) ; Input image
                               ;; (car export-drawable) ; Drawable to save
                               export-filename ; filename, The name of the file to save the image in
                               ;; export-filename ; raw-filename, The name of the file to save the image in
                               () ; options
                               FALSE    ; interlace, Use Adam7 interlacing?
                               9        ; Deflate Compression factor (0--9)
                               FALSE    ; Write bKGD chunk?
                               FALSE    ; Write oFFs chunk?
                               TRUE     ; Write pHYs chunk?
                               TRUE     ; Write tIME chunk?
                               TRUE     ; save-transparent
                               FALSE    ; optimize-palette
                               "auto"   ; format
                               FALSE    ; include-exif
                               FALSE    ; include-iptc
                               FALSE    ; include-xmp
                               TRUE     ; include-color-profile
                               FALSE    ; include-thumbnail
                               FALSE    ; include-comment
                               )
                (gimp-image-delete (car export-img)))
              flist)
    ;;(tracing FALSE)

    ))

;; register ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(script-fu-register-procedure
 "script-fu-my-export-png" ; function name
 "export png" ; menu label
 "export png" ; description
 "kam1610" ; author
 "4-26-2015" ; date created
 SF-DIRNAME      "dir"       ""
 SF-DIRNAME      "dir"       ""
 SF-ADJUSTMENT   "topX"        '(  0 0 9999 1 100 0 0)
 SF-ADJUSTMENT   "topY"        '(  0 0 9999 1 100 0 0)
 SF-ADJUSTMENT   "width"       '(  1 0 9999 1 100 0 0)
 SF-ADJUSTMENT   "height"      '(  1 0 9999 1 100 0 0)
 SF-ADJUSTMENT   "resizeWitdh" '(480 0 9999 1 100 0 0)
 )
(script-fu-menu-register 
  "script-fu-my-export-png"
  "<Image>/Plug-in")
