MessageBox Start

           bra  MsgOk

*
* Standard messagebox
*

Mode       ds   1
ModeOk     equ  1
ModeOKCan1 equ  2
ModeOkCan2 equ  3
ModeRetCn1 equ  4
ModeRetCn2 equ  5
ModeFmtCn1 equ  6
ModeFmtCn2 equ  7
ModeBtCan  equ  8

MsgWidth   ds   1
StartHTab  ds   1
BoxWidth   ds   1
TempSave   ds   1
MinMsg     ds   1
B1HTabS    ds   1
B1HTabE    ds   1
B2HTabS    ds   1
B2HTabE    ds   1
NumButts   ds   1

TabIndex   ds   1
Button1    equ  0
Button2    equ  1

           Msb  On
txtOk      dc   c'   Ok   '
txtCancel  dc   c' Cancel '
txtRetry   dc   c' Retry  '
txtFormat  dc   c' Format '
txtBoot    dc   c'  Boot  '
           Msb  Off

B1Text     ds   8
B2Text     ds   8

RC         ds   1                       UI return code
TabOnly    equ  1
CROnly     equ  2

KeyPress   ds   1                       Keypress save area

* Single button "Ok" message box

MsgOk      Entry

           lda  #ModeOk
           sta  Mode
           lda  #10                     Minimum message size
           sta  MinMsg
           lda  #1                      Number of command buttons
           sta  NumButts
           stz  TabIndex
           ldx  #7
txtLoop1   lda  txtOk,x
           sta  B1Text,x
           dex
           bpl  txtLoop1
           jmp  MsgStart

* Dual Ok/Cancel button messagebox, default Ok.

MsgOkCan1  Entry

           lda  #ModeOkCan1
           sta  Mode
           lda  #23                     Minimum message size
           sta  MinMsg
           lda  #2                      Number of command buttons
           sta  NumButts
           stz  TabIndex
           ldx  #7
txtLoop2   lda  txtOk,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop2
           jmp  MsgStart

* Dual Ok/Cancel button messagebox, default Cancel.

MsgOkCan2  Entry

           lda  #ModeOkCan2
           sta  Mode
           lda  #23                     Minimum message size
           sta  MinMsg
           lda  #2                      Number of command buttons
           sta  NumButts
           lda  #1
           sta  TabIndex
           ldx  #7
txtLoop3   lda  txtOk,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop3
           jmp  MsgStart

* Dual Retry/Cancel button messagebox, default Retry.

MsgRetCan1 Entry

           lda  #ModeRetCn1
           sta  Mode
           lda  #23                     Minimum message size
           sta  MinMsg
           lda  #2                      Number of command buttons
           sta  NumButts
           stz  TabIndex
           ldx  #7
txtLoop4   lda  txtRetry,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop4
           jmp  MsgStart

* Dual Retry/Cancel button messagebox, default Cancel.

MsgRetCan2 Entry

           lda  #ModeRetCn2
           sta  Mode
           lda  #23                     Minimum message size
           sta  MinMsg
           lda  #2                      Number of command buttons
           sta  NumButts
           lda  #1
           sta  TabIndex
           ldx  #7
txtLoop5   lda  txtRetry,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop5
           jmp  MsgStart

* Dual Format/Cancel button messagebox, default Format.

MsgFmtCan1 Entry

           lda  #ModeFmtCn1
           sta  Mode
           lda  #23                     Minimum message size
           sta  MinMsg
           lda  #2                      Number of command buttons
           sta  NumButts
           stz  TabIndex
           ldx  #7
txtLoop6   lda  txtFormat,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop6
           jmp  MsgStart

* Dual Format/Cancel button messagebox, default Cancel.

MsgFmtCan2 Entry

           lda  #ModeFmtCn2
           sta  Mode
           lda  #23                     Minimum message size
           sta  MinMsg
           lda  #2                      Number of command buttons
           sta  NumButts
           lda  #1
           sta  TabIndex
           ldx  #7
txtLoop7   lda  txtFormat,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop7
           jmp  MsgStart

* Dual Boot/Cancel button messagebox, default Cancel.

MsgBootCan Entry

           lda  #ModeBtCan
           sta  Mode
           lda  #23                     Minimum message size
           sta  MinMsg
           lda  #2                      Number of command buttons
           sta  NumButts
           lda  #1
           sta  TabIndex
           ldx  #7
txtLoop8   lda  txtBoot,x
           sta  B1Text,x
           lda  txtCancel,x
           sta  B2Text,x
           dex
           bpl  txtLoop8
           jmp  MsgStart

* Main Line

MsgStart   anop

           jsr  Init
           jsr  SaveScreen
           jsr  DisplayBox

Loop1      anop

           jsr  RefreshBtn
           jsr  UI

           lda  RC
           cmp  #TabOnly
           beq  Loop1

           jsr  RestScreen

           lda  TabIndex                Load accumulator with button choice.

           rts

* Setup variables

Init       anop

* Calculate message width

           ldy  #0                      Index through message
           ldx  #0                      Length of current segment
           stz  MsgWidth

NextChar   anop

           lda  (MsgPtr),y              Get character
           and  #$7F                    strip high bit
           beq  MsgEOF                  00 = End of message
           cmp  #$0D
           beq  Part1EOF                0D = End of segment
           iny                          Bump up index
           inx                          Count character
           bra  NextChar                Loop back to get next char

Part1EOF   anop

           lda  MsgWidth
           bne  DupCRs
           stx  MsgWidth                Save first part message length

DupCRs     anop

           ldx  #0                      Reset length counter to 0 for next part
           iny                          Bump index up
           bra  NextChar                Loop back to get next char

MsgEOF     anop

           cpx  MsgWidth                Which part is longer?
           bcc  P1Higher                First part is longer.

           stx  MsgWidth                Second part is longer.

P1Higher   anop

           lda  MsgWidth                Check if it meets minimum msg lenght
           cmp  MinMsg                  Minimum message length
           bcs  Over

           lda  MinMsg                  Change to minimum length
           sta  MsgWidth
           bra  GoodLen

Over       anop

           cmp  #60                     Maximum message length
           bcc  GoodLen

           lda  #59                     Change to maximum msg length
           sta  MsgWidth

GoodLen    anop

* Calculate starting HTab

           clc
           lda  MsgWidth                Get message width
           adc  #14                     Add space for left/right borders
           sta  BoxWidth                Save box width

           sec                          Center box
           lda  #80                     80 columns
           sbc  BoxWidth                less box width

           lsr  a                       Divide by 2
           sta  StartHTab               Save our starting HTab

           rts

           Copy MessageBox1.s
           Copy MessageBox2.s

           End
