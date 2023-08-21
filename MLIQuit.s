MLIQuit    Start

*          MLI Quit ($65) Call
*
*          Usage       : jmp MLIQuit
*          Requirements: None

MLI        equ  $BF00

           jsr  MLI
           dc   h'65'
           dc   a'Parms'

Parms      anop

           dc   h'04'
           dc   i6'00'

           End
