MLIQuit:

;          MLI Quit ($65) Call
;
;          Usage       : jmp MLIQuit
;          Requirements: None

;MLI         =   $BF00

           jsr  MLI
           .byte $65
           .addr @Parms

@Parms:

           .byte $04
           .res 6


