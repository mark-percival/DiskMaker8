MLIAtlkInfo:

;          MLI Appletalk GetInfo (42) Call
;
;          Usage       : jsr MLIAtlkInfo
;          Requirements: None

MLICode_42  =   $42
;MLI         =   $BF00

           jsr  MLI
           .byte MLICode_42
           .addr @Parms

           rts

@Parms:

@InfoParams: .byte $00                  ; Synchronous only
            .byte $02                   ; GetInfo call number
@InfoResult: .res 13                    ; Result returned here


