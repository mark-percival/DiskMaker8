MessageBox:

.export MsgOk
           bra  MsgOk

;
; Standard messagebox
;

Mode:       .res 1
ModeOk      =   1
ModeOkCan1  =   2
ModeOkCan2  =   3
ModeRetCn1  =   4
ModeRetCn2  =   5
ModeFmtCn1  =   6
ModeFmtCn2  =   7
ModeBtCan   =   8

MsgWidth:   .res 1
MB_StartHTab: .res 1
BoxWidth:   .res 1
TempSave:   .res 1
MinMsg:     .res 1
B1HTabS:    .res 1
B1HTabE:    .res 1
B2HTabS:    .res 1
B2HTabE:    .res 1
NumButts:   .res 1

MB_TabIndex:   .res 1
Button1     =   0
Button2     =   1

;          Msb  On
txtOk:     asc "   Ok   "
txtCancel: asc " Cancel "
txtRetry:  asc " Retry  "
txtFormat: asc " Format "
txtBoot:   asc "  Boot  "
;          Msb  Off

B1Text:     .res 8
B2Text:     .res 8

MB_RC:      .res 1                       ; UI return code
MB_TabOnly  =   1
MB_CROnly   =   2

MB_KeyPress: .res 1                      ; Keypress save area

; Single button "Ok" message box

MsgOk:

           lda  #ModeOk
           sta  Mode
           lda  #10                     ; Minimum message size
           sta  MinMsg
           lda  #1                      ; Number of command buttons
           sta  NumButts
           stz  MB_TabIndex
           ldx  #7
txtLoop1:  lda  txtOk,x
           sta  B1Text,x
           dex
           bpl  txtLoop1
           jmp  MsgStart

; Dual Ok/Cancel button messagebox, default Ok.

MsgOkCan1:

           lda  #ModeOkCan1
           sta  Mode
           lda  #23                     ; Minimum message size
           sta  MinMsg
           lda  #2                      ; Number of command buttons
           sta  NumButts
           stz  MB_TabIndex
           ldx  #7
txtLoop2:  lda  txtOk,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop2
           jmp  MsgStart

; Dual Ok/Cancel button messagebox, default Cancel.

MsgOkCan2:

           lda  #ModeOkCan2
           sta  Mode
           lda  #23                     ; Minimum message size
           sta  MinMsg
           lda  #2                      ; Number of command buttons
           sta  NumButts
           lda  #1
           sta  MB_TabIndex
           ldx  #7
txtLoop3:  lda  txtOk,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop3
           jmp  MsgStart

; Dual Retry/Cancel button messagebox, default Retry.

MsgRetCan1:

           lda  #ModeRetCn1
           sta  Mode
           lda  #23                     ; Minimum message size
           sta  MinMsg
           lda  #2                      ; Number of command buttons
           sta  NumButts
           stz  MB_TabIndex
           ldx  #7
txtLoop4:  lda  txtRetry,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop4
           jmp  MsgStart

; Dual Retry/Cancel button messagebox, default Cancel.

MsgRetCan2:

           lda  #ModeRetCn2
           sta  Mode
           lda  #23                     ; Minimum message size
           sta  MinMsg
           lda  #2                      ; Number of command buttons
           sta  NumButts
           lda  #1
           sta  MB_TabIndex
           ldx  #7
txtLoop5:  lda  txtRetry,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop5
           jmp  MsgStart

; Dual Format/Cancel button messagebox, default Format.

MsgFmtCan1:

           lda  #ModeFmtCn1
           sta  Mode
           lda  #23                     ; Minimum message size
           sta  MinMsg
           lda  #2                      ; Number of command buttons
           sta  NumButts
           stz  MB_TabIndex
           ldx  #7
txtLoop6:  lda  txtFormat,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop6
           jmp  MsgStart

; Dual Format/Cancel button messagebox, default Cancel.

MsgFmtCan2:

           lda  #ModeFmtCn2
           sta  Mode
           lda  #23                     ; Minimum message size
           sta  MinMsg
           lda  #2                      ; Number of command buttons
           sta  NumButts
           lda  #1
           sta  MB_TabIndex
           ldx  #7
txtLoop7:  lda  txtFormat,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop7
           jmp  MsgStart

; Dual Boot/Cancel button messagebox, default Cancel.

MsgBootCan:

           lda  #ModeBtCan
           sta  Mode
           lda  #23                     ; Minimum message size
           sta  MinMsg
           lda  #2                      ; Number of command buttons
           sta  NumButts
           lda  #1
           sta  MB_TabIndex
           ldx  #7
txtLoop8:  lda  txtBoot,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop8
           jmp  MsgStart

; Main Line

MsgStart:

           jsr  Init
           jsr  M1_SaveScreen
           jsr  DisplayBox

@Loop1:

           jsr  MB1_RefreshBtn
           jsr  UI

           lda  MB_RC
           cmp  #MB_TabOnly
           beq  @Loop1

           jsr  M1_RestScreen

           lda  MB_TabIndex             ; Load accumulator with button choice.

           rts

; Setup variables

Init:

; Calculate message width

           ldy  #0                      ; Index through message
           ldx  #0                      ; Length of current segment
           stz  MsgWidth

MB_NextChar:

           lda  (MsgPtr),y              ; Get character
           and  #$7F                    ; strip high bit
           beq  MsgEOF                  ; 00 = End of message
           cmp  #$0D
           beq  Part1EOF                ; 0D = End of segment
           iny                          ; Bump up index
           inx                          ; Count character
           bra  MB_NextChar             ; Loop back to get next char

Part1EOF:

           lda  MsgWidth
           bne  DupCRs
           stx  MsgWidth                ; Save first part message length

DupCRs:

           ldx  #0                      ; Reset length counter to 0 for next part
           iny                          ; Bump index up
           bra  MB_NextChar             ; Loop back to get next char

MsgEOF:

           cpx  MsgWidth                ; Which part is longer?
           bcc  P1Higher                ; First part is longer.

           stx  MsgWidth                ; Second part is longer.

P1Higher:

           lda  MsgWidth                ; Check if it meets minimum msg lenght
           cmp  MinMsg                  ; Minimum message length
           bcs  Over

           lda  MinMsg                  ; Change to minimum length
           sta  MsgWidth
           bra  GoodLen

Over:

           cmp  #60                     ; Maximum message length
           bcc  GoodLen

           lda  #59                     ; Change to maximum msg length
           sta  MsgWidth

GoodLen:

; Calculate starting HTab

           clc
           lda  MsgWidth                ; Get message width
           adc  #14                     ; Add space for left/right borders
           sta  BoxWidth                ; Save box width

           sec                          ; Center box
           lda  #80                     ; 80 columns
           sbc  BoxWidth                ; less box width

           lsr  a                       ; Divide by 2
           sta  MB_StartHTab               ; Save our starting HTab

           rts

           .include "MessageBox1.s"
           .include "MessageBox2.s"


