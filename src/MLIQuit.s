MLIQuit:

;          MLI Quit ($65) Call
;
;          Usage       : jmp MLIQuit
;          Requirements: None

           jsr  MLI
           .byte $65
           .addr @Parms

@Parms:

           .byte $04
           .byte $00,$00,$00,$00,$00,$00
