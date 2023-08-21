MLISetMark Start

*          MLI SET_MARK ($CE) Call
*
*          Usage       : jsr MLISetMark
*          Requirements: 'setMarkRef' 1 byte file reference number
*                        'setMarkPos' 3 byte absolute position to move to
*          Returns     : Nothing
*

MLICode    equ  $CE
MLI        equ  $BF00

           lda  setMarkRef
           sta  ref_num

           lda  setMarkPos
           sta  position

           lda  setMarkPos+1
           sta  position+1

           lda  setMarkPos+2
           sta  position+2

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'

           bne  CheckError              MLI error

           bra  GoodError

Parms      anop

parm_count dc   h'02'
ref_num    ds   1
position   ds   3

CheckError anop

           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

GoodError  anop

           rts

           End
