;; -*- mode: Gimp; -*-
(define (script-fu-save-layers-to-files-with-tone-ofst
         ; image dont-ask display-images
         inSrcFile
         )
  (gimp-message-set-handler 1 ) ; 1: CONSOLE, 2: ERROR-CONSOLE
  (let* (
         (image
          (car (gimp-file-load 0 inSrcFile )))
         (dont-ask           1)
         (display-images FALSE)
         (basename (car (gimp-image-get-name image)))
         )
    (when (string=? basename "")
          (set! basename  (string-append 
                           (car (gimp-temp-name ""))
                           (car (gimp-image-get-name image)))))

    (let loop ((layers (layerScan image 0)))
      (unless (null? layers)
              (unless (equal? (car (gimp-item-is-group (car layers))) 1)
                (display "(car (layers)) -> ") (display (car layers)) (display "\n")

                ;; fit size
                (gimp-layer-resize-to-image-size (car layers))

                ;; apply mask
                (if (not (= (car (gimp-layer-get-mask (car layers))) -1))
                    (gimp-layer-remove-mask
                     (car layers)
                     0 ;{ MASK-APPLY (0), MASK-DISCARD (1) }
                     ))

                (gimp-edit-copy (vector (car layers)))
                (display "layer is copied\nnewname -> ")
                (display (string-append basename (car (gimp-item-get-name (car layers))) ".png"))
                (display "\n")
                (let ((img  (car (gimp-edit-paste-as-new-image)))
                      (new-name (string-append 
                                 basename
                                 (car (gimp-item-get-name (car layers)))
                                 ".png"))
                      (targetLayer     ())
                      (targetHeight     0)
                      (targetWidth      0))

                  (display "new image is created -> ")(display new-name)(display "\n")

                  (set! targetHeight (car (gimp-image-get-height img)))
                  (set! targetWidth  (car (gimp-image-get-width  img)))
                  (set! targetLayer  (vector-ref (car (gimp-image-get-layers img)) 0))
                  (display "h->")(display targetHeight)
                  (display ", w->")(display targetWidth)
                  (display ", target layer->")(display targetLayer)(display "\n:::: ")
                  (display (gimp-item-get-name targetLayer))(display "\n")

                  ;; offset only if "k015"
                  (if (string=? "k015"
                                (car (gimp-item-get-name (car layers))))
                      (begin
                        (gimp-message "k015\n")(display "k015\n")
                        ;; (gimp-layer-resize
                        ;;  targetLayer          ;; layer
                        ;;  (+ targetWidth 8)    ;; new-width
                        ;;  targetHeight         ;; new-height
                        ;;  4                    ;; offx
                        ;;  0                    ;; offy
                        ;;  )
                        ;;(gimp-drawable-offset targetLayer FALSE 1 "white" -4 0)
                        ;;(gimp-image-resize-to-layers img)
                        (display "img->")(display img)(display "\n")
                        (gimp-image-resize img (+ targetWidth 8) targetHeight 4 0)
                        ;;(gimp-image-crop img targetWidth targetHeight 0 0)
                        )
                      )

                  (display "saving...\n")
                  (file-png-export
                   dont-ask ; The run mode { RUN-INTERACTIVE (0), RUN-NONINTERACTIVE (1) }
                   img      ; Input image
                   new-name ; file
                   ()       ; options
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
                  (display "saved\n")
                  
                  (if (= FALSE display-images)
                      ;; clean up afterwards if we are not going to
                      ;; display the images anyway:
                      (gimp-image-delete img)
                      (gimp-display-new img)))
                )
              (loop (cdr layers))
              ))))
;; register ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(script-fu-register-procedure
 "script-fu-save-layers-to-files-with-tone-ofst" ; function name
 "save layers with offset" ; menu label
 "save layers with offset" ; description
 "kam1610" ; author
 "11-23-2025" ; date created
 ""           ; image type that the script works on
 SF-FILENAME "SrcFile"         ""    ; example pattern: "z:/0.gif"
 )

