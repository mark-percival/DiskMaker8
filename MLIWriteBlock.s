MLIWriteBlk Start

*          MLI Write Block ($81) Call
*
*          Usage       : jsr MLIWriteBlock
*          Requirements: 'wrblkUnit' 1 byte unit number.
*                        'wrblkDataBuf' 512 byte buffer to be written.
*                        'wrblkBlockNum' 2 byte block number to write

MLICode    equ  $81
MLI        equ  $BF00

           lda  wrblkUnit
           sta  unit_num
           lda  wrblkBlockNum
           sta  block_num
           lda  wrblkBlockNum+1
           sta  block_num+1

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'

           bne  CheckError              MLI error

           bra  GoodError

Parms      anop

parm_count dc   h'03'
unit_num   ds   1
data_buf   dc   a'wrblkDataBuf'
block_num  ds   2

CheckError anop

           cmp  #$27                    IO Error
           beq  GoodError
           cmp  #$28                    No device connected
           beq  GoodError
           cmp  #$2B                    Disk write protect
           beq  GoodError
           cmp  #$2F                    Device offline
           beq  GoodError

           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

GoodError  anop

           cmp  #$00                    Set status register

           rts

           End
