
(define (layerScan img rootFolder) ; recursive function
  (let*
    (
      (children     0)
      (layerList    0)
      (i            0)
      (layer        0)
      (allLayerList ())
    )

    (if (= rootFolder 0)
        (set! children (gimp-image-get-layers img))
        ;; else 
        (if (equal? (car (gimp-item-is-group rootFolder)) 1)
            (set! children (gimp-item-get-children rootFolder))
            (set! children (list 1 (list->vector (list rootFolder)))))
        )

    (set! layerList (car children))

    (while (< i (vector-length layerList))
      (set! layer (vector-ref layerList i))
      (set! allLayerList (append allLayerList (list layer)))

      (if (equal? (car (gimp-item-is-group layer)) 1)
        (set! allLayerList (append allLayerList (layerScan img layer)))
      )
      (set! i (+ i 1))
    )

    allLayerList
  )
)

;; set-hari-color ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (set-hair-color layer color)
  (gimp-layer-set-lock-alpha layer TRUE)
  (gimp-context-set-foreground color)
  (gimp-drawable-edit-fill layer FILL-FOREGROUND)
  (gimp-layer-set-lock-alpha layer FALSE)
  )
;; rotate-hair-color ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script-fu-rotate-hair-color img)
  (let loop ((layers (layerScan img 0)))
    (unless (null? layers)
      (define layer (car layers))
      (if (= FALSE (car (gimp-item-is-group layer)))
          (begin
           (define layer-name (car (gimp-item-get-name layer)))
           (cond
            ((re-match "^h00" layer-name) (set-hair-color layer "#eaf4f5"))
            ((re-match "^h01" layer-name) (set-hair-color layer "#add7db"))
            ((re-match "^h02" layer-name) (set-hair-color layer "#7c9b9e"))
            ((re-match "^h0G" layer-name)
             (gimp-drawable-hue-saturation
              layer
              HUE-RANGE-ALL
              -99.5  ; hue-offset
              0.0 ; lightness
              0.0  ; saturation
              0    ; overlap
              ))
            ((re-match "^h0L" layer-name) (set-hair-color layer "#eaf4f5"))
            ((re-match "^s00" layer-name) (set-hair-color layer "#fef9eb"))
            ((re-match "^e00" layer-name) (set-hair-color layer "#94bae0"))
            ((re-match "^e01" layer-name) (set-hair-color layer "#23486e"))
            ((re-match "^e02" layer-name) (set-hair-color layer "#0b233c"))
            ((re-match "^e0L" layer-name)
             (gimp-drawable-hue-saturation
              layer HUE-RANGE-ALL -123.0 0.0 0.0 0))
            ((re-match "^e0G" layer-name)
             (gimp-drawable-hue-saturation
              layer HUE-RANGE-ALL -123.0 0.0 0.0 0))
             )
           )
          ;; else ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          (display "this item is group")(newline)
          )
    (loop (cdr layers))))
 ) 


;; register ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(script-fu-register-filter
    "script-fu-rotate-hair-color" ; procecdure name
    "rotate hair color" ; menu label
    "rotate hair color" ; tool tip description
    "kam1610"           ; author
    ""                  ; License
    "2023-12-02"        ; date created
    "*"                 ; require image
    SF-ONE-DRAWABLE
)
(script-fu-menu-register 
  "script-fu-rotate-hair-color"
  "<Image>/Plug-in")

