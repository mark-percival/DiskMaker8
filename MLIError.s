MLIError   Start

*
* Print MLI Error
*

cout       equ  $FDED
kbd        equ  $C000
clrkbd     equ  $C010

           pla
           jsr  GetASCII
           lda  ASCII
           sta  ErrorRtn
           lda  ASCII+1
           sta  ErrorRtn+1

           pla
           pha                          Save error code
           jsr  GetASCII
           lda  ASCII
           sta  ErrorCode
           lda  ASCII+1
           sta  ErrorCode+1

           lda  #Message
           sta  MsgPtr
           lda  #>Message
           sta  MsgPtr+1

           jsr  MsgOk

           pla                          Restore error code

           rts

           Msb  On
Message    dc   c'MLI Error $'
ErrorCode  ds   2
           dc   c' from call $'
ErrorRtn   ds   2
           dc   c'.',h'00'
           Msb  Off

GetASCII   anop

           tay
           clc
           ldx  #4

GetASCII1  anop

           lsr  a
           dex
           bne  GetASCII1

           tax
           lda  HexTable,x
           sta  ASCII

           tya
           and  #$0F
           tax
           lda  HexTable,x
           sta  ASCII+1

           rts

ASCII      ds   2

           Msb  On
HexTable   dc   c'0123456789ABCDEF'
           Msb  Off

           End
