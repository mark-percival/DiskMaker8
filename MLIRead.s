MLIRead    Start

*          MLI Read ($CA) Call
*
*          Usage       : jsr MLIRead
*          Requirements: 'readRef' 1 byte file reference number
*                        'readRequest' 2 byte number of byte to read
*                        'readBuf' destination data buffer
*          Returns     : 'readTrans' 2 byte number of bytes actually read
*                                    0 = EOF

MLICode    equ  $CA
MLI        equ  $BF00

           lda  readRef
           sta  ref_num
           lda  readRequest
           sta  req_count
           lda  readRequest+1
           sta  req_count+1

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'

           bne  CheckError              MLI error

           bra  GoodError

Parms      anop

parm_count dc   h'04'
ref_num    ds   1
data_buf   dc   a'readBuf'
req_count  ds   2
tran_count ds   2

CheckError anop

           cmp  #$4C                    EOF error code
           beq  GoodError

           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

GoodError  anop

           pha                          Save error code
           lda  tran_count              return byte transfer count
           sta  readTrans
           lda  tran_count+1
           sta  readTrans+1
           pla                          Restore error code

           rts

           End
