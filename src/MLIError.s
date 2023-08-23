MLIError:

;
; Print MLI Error
;

           pla
           jsr  GetASCII
           lda  ASCII
           sta  ErrorRtn
           lda  ASCII+1
           sta  ErrorRtn+1

           pla
           pha                        ; Save error code
           jsr  GetASCII
           lda  ASCII
           sta  ErrorCode
           lda  ASCII+1
           sta  ErrorCode+1

           lda  #<Message
           sta  MsgPtr
           lda  #>Message
           sta  MsgPtr+1

           jsr  MBMsgOk

           pla                        ; Restore error code

           rts

Message:   asc "MLI Error $"
ErrorCode: .res   2
           asc " from call $"
ErrorRtn:  .res   2
           ascz "."

GetASCII:

           tay
           clc
           ldx  #4

GetASCII1:

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

ASCII:      .res   2

HexTable:  .byte "0123456789ABCDEF"
