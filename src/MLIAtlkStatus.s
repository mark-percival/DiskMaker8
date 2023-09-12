MLIAtlkInfo:

;          MLI Appletalk GetInfo (42) Call
;
;          Usage       : jsr MLIAtlkInfo
;          Requirements: None

           jsr  MLI
           .byte MLI_ATALK_GET_INFO
           .addr @Parms

           rts

@Parms:

@InfoParams: .byte $00                  ; Synchronous only
            .byte $02                   ; GetInfo call number
@InfoResult: .res 13                    ; Result returned here


