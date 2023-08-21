MLIOnLine  Start

*          MLI OnLine($C5) Call
*
*          Usage       : jsr MLIOnLine
*          Requirements: onlineUnit = 1 byte unit number
*                        onlineBuf = 256 byte data buffer

MLICode    equ  $C5
MLI        equ  $BF00

           lda  onlineUnit
           sta  Unit_Num

           jsr  MLI
           dc   i1'MLICode'
           dc   a'Parms'
           bne  CheckError

OkError    anop

           rts

Parms      anop

           dc   h'02'
Unit_Num   dc   i1'0'
DataBuffer dc   a'onlineBuf'

CheckError anop

           cmp  #$27                    I/O Error
           beq  OkError
           cmp  #$28                    No Device Connected
           beq  OkError
           cmp  #$2F                    Device Off-line
           beq  OkError
           cmp  #$52                    Not a ProDOS disk
           beq  OkError
           pha                          Save MLI error
           lda  #MLICode
           pha                          Save calling routine
           jmp  MLIError

           End
