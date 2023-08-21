MLISetPrefix Start

*          MLI Set Prefix($C6) Call
*
*          Usage       : jsr MLISetPrefix
*          Requirements: buffer named 'prefix' 64 bytes long

MLICode    equ  $C6
MLI        equ  $BF00

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'
           bne  CheckError
           rts

Parms      anop

           dc   h'01'
           dc   a'prefix'

CheckError anop

           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

           End
