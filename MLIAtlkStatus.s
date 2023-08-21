MLIAtlkInfo Start

*          MLI Appletalk GetInfo (42) Call
*
*          Usage       : jsr MLIAtlkInfo
*          Requirements: None

MLICode    equ  $42
MLI        equ  $BF00

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'

           rts

Parms      anop

InfoParams dc   h'00'                   Synchronous only
           dc   h'02'                   GetInfo call number
InfoResult ds   13                      Result returned here

           End
