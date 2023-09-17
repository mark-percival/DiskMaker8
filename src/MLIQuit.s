MLIQuit:

;          MLI Quit ($65) Call
;
;          Usage       : jmp MLIQuit
;          Requirements: None

           jsr  MLI
           .byte MLI_QUIT
           .addr @Parms

@Parms:

           .byte $04
           .res 6


