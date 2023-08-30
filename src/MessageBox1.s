; Put message box on screen

DisplayBox:

; VTab 10

           lda  #10-1
           sta  VTab
           lda  StartHTab
           sta  HTab
           jsr  SetVTab

           lda  #MouseText
           jsr  cout_mark

           lda  #'Z'
           jsr  cout_mark

           lda  BoxWidth
           dec  a
           dec  a
           tax

           lda  #' '

Line10a:

           jsr  cout_mark
           dex
           bne  Line10a

           lda  #'_'
           jsr  cout_mark

; VTab 11

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  BoxWidth
           dec  a
           dec  a
           tax

           lda  #' '+$80

Line11a:

           jsr  cout_mark
           dex
           bne  Line11a

           lda  #'_'
           jsr  cout_mark

; VTab 12

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'='+$80
           jsr  cout_mark

           lda  #'\'+$80
           jsr  cout_mark

           ldx  #3
           lda  #' '+$80

Line12a:

           jsr  cout_mark
           dex
           bne  Line12a

           ldx  #3
           lda  #'_'+$80

Line12b:

           jsr  cout_mark
           dex
           bne  Line12b

           lda  #' '+$80
           jsr  cout_mark
           jsr  cout_mark

           ldy  #0                    ; Message index
           ldx  #0

Line12c:

           lda  (MsgPtr),y
           beq  Line12d
           cmp  #$0D
           beq  Line12d
           ora  #$80
           jsr  cout_mark
           iny
           inx
           bra  Line12c

Line12d:

           stx  TempSave
           sec
           lda  MsgWidth
           sbc  TempSave

           tax
           inx
           inx
           lda  #' '+$80

Line12e:

           jsr  cout_mark
           dex
           bne  Line12e

           lda  #'_'
           jsr  cout_mark

; VTab 13

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           lda  #'o'+$80
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #'?'+$80
           jsr  cout_mark

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark
           jsr  cout_mark

           ldx  #0
           lda  (MsgPtr),y
           beq  Line13b

           iny

Line13a:

           lda  (MsgPtr),y
           beq  Line13b
           cmp  #$0D
           beq  Line13a1

           ora  #$80
           jsr  cout_mark
           inx

Line13a1:

           iny
           bra  Line13a

Line13b:

           stx  TempSave
           sec
           lda  MsgWidth
           sbc  TempSave

           tax
           inx
           inx
           lda  #' '+$80

Line13c:

           jsr  cout_mark
           dex
           bne  Line13c

           lda  #'_'
           jsr  cout_mark

; VTab 14

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           lda  #'I'
           jsr  cout_mark

           lda  #'Y'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           lda  #'/'+$80
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           lda  #'!'+$80
           jsr  cout_mark

           lda  #'Z'
           jsr  cout_mark

           sec                        ; Setup for subtraction
           lda  MsgWidth              ; A = MsgWidth - MinMsg  (= extra chars)
           sbc  MinMsg
           lsr  a                     ; Divide by 2 to center
           inc  a                     ; Add 2 for extra spaces in layout
           inc  a

Line14a:

           tax                        ; Move to index
           lda  #' '+$80

Line14b:

           jsr  cout_mark
           dex
           bne  Line14b

           ldx  #10
           lda  #'_'+$80

Line14c:

           jsr  cout_mark
           dex
           bne  Line14c

           ldx  Mode
           cpx  #ModeOk
           beq  Line14f

           ldx  #3
           lda  #' '+$80

Line14d:

           jsr  cout_mark
           dex
           bne  Line14d

           ldx  #10
           lda  #'_'+$80

Line14e:

           jsr  cout_mark
           dex
           bne  Line14e

Line14f:

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           bcc  Line14g

           inc  a

Line14g:


Line14h:

           tax
           inx
           inx
           lda  #' '+$80

Line14i:

           jsr  cout_mark
           dex
           bne  Line14i

           lda  #'_'
           jsr  cout_mark

; HTab 15

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           lda  #'M'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark
           jsr  cout_mark

           ldx  #4
           lda  #'L'

Line15a:

           jsr  cout_mark
           dex
           bne  Line15a

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a

           tax

           clc                        ; Calculate HTab positions for buttons.
           adc  StartHTab
           adc  #12
           sta  B1HTabS
           adc  #8
           sta  B1HTabE
           adc  #5
           sta  B2HTabS
           adc  #8
           sta  B2HTabE

           inx
           lda  #' '+$80

Line15b:

           jsr  cout_mark
           dex
           bne  Line15b

           lda  #'Z'
           jsr  cout_mark

           lda  #' '
           jsr  cout_mark

           ldx  #8
           ldy  #0

Line15c:

           lda  B1Text,y
           jsr  cout_mark
           iny
           dex
           bne  Line15c

           lda  #' '
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           ldx  Mode
           cpx  #ModeOk
           beq  Line15d1

           lda  #' '+$80
           jsr  cout_mark

           lda  #'Z'
           jsr  cout_mark

           lda  #' '
           jsr  cout_mark

           ldx  #8
           ldy  #0

Line15d:

           lda  B2Text,y
           jsr  cout_mark
           iny
           dex
           bne  Line15d

           lda  #' '
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

Line15d1:

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           tax
           bcc  Line15e

           inx

Line15e:

           inx
           lda  #' '+$80

Line15f:

           jsr  cout_mark
           dex
           bne  Line15f

           lda  #'_'
           jsr  cout_mark

; HTab 16

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           clc
           adc  #10
           tax
           lda  #'_'+$80

Line16a:

           jsr  cout_mark
           dex
           bne  Line16a

           ldx  #10
           lda  #'\'

Line16b:

           jsr  cout_mark
           dex
           bne  Line16b

           ldx  Mode
           cpx  #ModeOk
           beq  Line16d1

           ldx  #3
           lda  #'_'+$80

Line16c:

           jsr  cout_mark
           dex
           bne  Line16c

           ldx  #10
           lda  #'\'

Line16d:

           jsr  cout_mark
           dex
           bne  Line16d

Line16d1:

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           tax
           bcc  Line16e

           inx

Line16e:

           inx
           inx
           lda  #'_'+$80

Line16f:

           jsr  cout_mark
           dex
           bne  Line16f

           lda  #'_'
           jsr  cout_mark

           rts

TextLineMB:                           ; Text screen line starting addresses

TextLineMB09: .addr $04A8             ; 1st message box line
TextLineMB10: .addr $0528             ; 2nd message box line
TextLineMB11: .addr $05A8             ; 3rd message box line
TextLineMB12: .addr $0628             ; 4th message box line
TextLineMB13: .addr $06A8             ; 5th message box line
TextLineMB14: .addr $0728             ; 6th message box line
TextLineMB15: .addr $07A8             ; 7th message box line

MBEndHTab: .res   1
MBSaveRtn: .res   1

;
; MBSaveScreen - Save screen data under message box.
; MBRestScreen - Restore screen data under message box.
;
; Ptr1 = screen data address : Ptr2 = Save buffer address
;

MBSaveScreen:

           lda  #1
           sta  MBSaveRtn
           bra  MB1StartRtn

MBRestScreen:

           stz  MBSaveRtn

MB1StartRtn:

           sta  On80Store             ; Make sure 80STORE is on.

           clc                        ; Calculate ending HTab
           lda  StartHTab
           adc  BoxWidth
           dec  a
           sta  MBEndHTab

           lda  #<MessageBuf          ; Set save buffer address in Ptr2
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #7                    ; 7 lines to save

@SSLoop1:

           txa                        ; Copy lines to save to accumulator
           dec  a                     ; Subtract one to make it a 0 - 6 number
           asl  a                     ; Multiply by two for address table index
           tay                        ; Move to index
           lda  TextLineMB,y          ;   Get line number starting address and
           sta  Ptr1                  ; put it in Ptr1.
           iny
           lda  TextLineMB,y
           sta  Ptr1+1

           ldy  StartHTab

@SSLoop2:

           phy                        ; Push HTab to stack.
           tya                        ; Put HTab into accumulator
           lsr  a                     ; Divide by 2 for index
           bcs  @FromMain             ; A remainder then get char from main mem.

@FromAux:

           sta  Page2                 ; Set access to aux memory
           bra  @GetChar

@FromMain:

           sta  Page1                 ; Set access to main memory

@GetChar:

           tay                        ; Move index value to y register
           lda  MBSaveRtn             ;   Is this a save or restore?
           beq  @Restore               ; If MBSaveRtn = 0 then we're restoring

           lda  (Ptr1),y              ; Get character from screen
           sta  (Ptr2)                ; Save to buffer area
           bra  @Continue

@Restore:  lda  (Ptr2)                ; Get character from buffer area
           sta  (Ptr1),y              ; Restore back to screen area

@Continue:

           ply                        ; Get HTab from stack

           inc  Ptr2                  ; Bump up save buffer address
           bne  @NoOF                 ; If Ptr2 = 0 then add 1 to Ptr2+1

           inc  Ptr2+1

@NoOF:                                ; No overflow label

           iny                        ; Add 1 to HTab
           cpy  MBEndHTab             ;   Compare to ending HTab
           bcc  @SSLoop2              ; < or
           beq  @SSLoop2              ;   = y register process next character.

           dex                        ; More lines to process?
           bne  @SSLoop1              ; Yes

           lda  Page1                 ; Set back main memory access prior to rts

           rts

;
; MBRefreshBtn - Redraw command buttons with selected button highlighted
;

MBRefreshBtn:

           lda  #15-1
           sta  VTab
           lda  B1HTabS
           sta  HTab
           jsr  SetVTab

           lda  #StdText
           jsr  cout_mark

           lda  TabIndex_M1
           cmp  #Button1
           beq  B1Selected

           lda  #Normal
           jsr  cout_mark
           bra  PrtB1

B1Selected:

           lda  #Inverse
           jsr  cout_mark

PrtB1:

           ldx  #8
           ldy  #0

PrtLoop1:

           lda  B1Text,y
           jsr  cout_mark
           iny
           dex
           bne  PrtLoop1

           lda  Mode
           cmp  #ModeOk
           beq  MB1PrtExit

           lda  B2HTabS
           sta  HTab
           jsr  SetVTab

           lda  TabIndex_M1
           cmp  #Button2
           beq  B2Selected

           lda  #Normal
           jsr  cout_mark
           bra  PrtB2

B2Selected:

           lda  #Inverse
           jsr  cout_mark

PrtB2:

           ldx  #8
           ldy  #0

PrtLoop2:

           lda  B2Text,y
           jsr  cout_mark
           iny
           dex
           bne  PrtLoop2

MB1PrtExit:

           lda  #Normal
           jsr  cout_mark

           rts
