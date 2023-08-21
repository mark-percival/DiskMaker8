MLIClose   Start

*          MLI Close($CC) Call
*
*          Usage       : jsr MLIClose
*          Requirements: 'closeRef' 1 byte file reference number
*          Returns     : None.

MLICode    equ  $CC
MLI        equ  $BF00

           lda  closeRef
           sta  ref_num

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'

           bne  CheckError              MLI error

           rts

Parms      anop

parm_count dc   h'01'
ref_num    ds   1

CheckError anop

           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

           End
