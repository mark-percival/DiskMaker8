MLIOpen1   Start

*          MLI Open ($C8) Call
*
*          Usage       : jsr MLIOpen
*          Requirements: 'path' location of path to be opened
*                        'openBuf1' a 512 byte buffer
*          Returns     : 'openRef1' 1 byte file reference number

MLICode    equ  $C8
MLI        equ  $BF00

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'

           pha                          Save possible MLI error code
           lda  ref_num                 Get file reference number
           sta  openRef1                Save reference number for user
           pla                          Restore possible MLI error code

           bne  CheckError              MLI error
           rts

Parms      anop

parm_count dc   h'03'
path_name  dc   a'path'
io_buffer  dc   a'openBuf1'
ref_num    ds   1

CheckError anop

           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

           End
