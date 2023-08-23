MLIAtlkInfo:

;          MLI Appletalk GetInfo (42) Call
;
;          Usage       : jsr MLIAtlkInfo
;          Requirements: None

ProDOSAtlkInfo    =  $42

           jsr  MLI
           .byte ProDOSAtlkInfo
           .addr @Parms

           rts

@Parms:

@InfoParams .byte $00                 ; Synchronous only
            .byte $02                 ; GetInfo call number
@InfoResult .res 13                   ; Result returned here
