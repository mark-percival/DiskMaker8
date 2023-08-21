MLIGetEOF  Start

*          MLI GET_EOF ($D1) Call
*
*          Usage       : jsr MLIGetEOF
*          Requirements: 'geteofRef' 1 byte file reference number
*          Returns     : 'geteofEOF' 3 byte result containing the maximum number
*                                    of bytes that can be read from file

MLICode    equ  $D1
MLI        equ  $BF00

           lda  geteofRef
           sta  ref_num

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'

           bne  CheckError              MLI error

           bra  GoodError

Parms      anop

parm_count dc   h'02'
ref_num    ds   1
eof        ds   3

CheckError anop

           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

GoodError  anop

           pha                          Save error code
           lda  eof
           sta  geteofEOF
           lda  eof+1
           sta  geteofEOF+1
           lda  eof+2
           sta  geteofEOF+2
           pla                          Restore error code

           rts

           End
