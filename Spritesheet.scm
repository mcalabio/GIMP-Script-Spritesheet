(define (script-fu-spritesheet theImage)
  (let*
    (
      ; define some local variables
      (getLayers (gimp-image-get-layers theImage))
      (numFrames (car getLayers))     ;number of layers
      (theLayers (cadr getLayers))    ;(vector of layer ids)
      (theSpritesheet 
                (car
                    (gimp-image-new
                      (car (gimp-image-width theImage))
                      (* (car (gimp-image-height theImage)) numFrames) ;height of frame by num of frames
                      RGB
                    )
                )
      )
      (thisLayerName)
      (thisLayer)
      (thisFrame)
      (thisPaste)
      (i (- numFrames 1))     ;going to iterate for each layer starting with bottom layer (first layer of animation)
    )

    ; perform actions for each layer
    (for-each (lambda (x)
                  
                  ;gain access to thisLayer using layer name
                  (set! thisLayerName (car (gimp-item-get-name x))) ; get a layer name
                  (set! thisLayer (car (gimp-image-get-layer-by-name theImage thisLayerName)))

                  ; set thisLayer as active, select it all, and copy it
                  (gimp-image-set-active-layer theImage thisLayer)
                  (gimp-selection-all theImage)
                  (gimp-edit-copy thisLayer)

                  ; create new layer to use as a frame on spritesheet
                  (set! thisFrame
                            (car
                                (gimp-layer-new
                                  theSpritesheet
                                  (car (gimp-image-width theImage))
                                  (car (gimp-image-height theImage))
                                  RGB-IMAGE
                                  "layer 1"
                                  100
                                  NORMAL
                                )
                            )
                  )

                  ; add thisFrame to the Spritesheet
                  (gimp-image-add-layer theSpritesheet thisFrame 0)

                  ; paste current layer and anchor it onto this frame on spritesheet
                  (set! thisPaste (car (gimp-edit-paste thisFrame TRUE)))
                  (gimp-floating-sel-anchor thisPaste)

                  ; align it on spritesheet (height of frame by frame number i)
                  (gimp-layer-translate thisFrame 0 (* (car (gimp-image-height theImage)) i) )

                  ; move on to next layer
                  (set! i (- i 1))
              )
      (vector->list theLayers)) ; perform above actions for each layer

    ; flatten the spritesheet so it is all just one layer
    (gimp-image-flatten theSpritesheet)

    (gimp-display-new theSpritesheet)
    (gimp-image-clean-all theSpritesheet)
    (gimp-image-clean-all theImage)
  )
)
(script-fu-register
            "script-fu-spritesheet"                        ;func name
            "Generate Spritesheet"                                  ;menu label
            "Creates a vertical spritesheet\
              using each layer of the current\
              image as frames."              ;description
            "Mark Calabio"                             ;author
            "copyright 2016, Mark Calabio;\
              2016, Plunger Games"                ;copyright notice
            "July 28, 2016"                          ;date created
            ""                     ;image type that the script works on
            SF-IMAGE  "Image" 0
)
(script-fu-menu-register "script-fu-spritesheet" "<Image>/Image")