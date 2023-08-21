*
* Standard messagebox UI
*

UI         anop

UpArrow    equ  $8B
DownArrow  equ  $8A
LeftArrow  equ  $88
RightArrow equ  $95
ReturnKey  equ  $8D
TabKey     equ  $89

AppleKey   equ  $C061
OptionKey  equ  $C062

           stz  RC                      Reset return code
           stz  ClearKbd                Clear keyboard strobe

PollDev    anop

           jsr  PlotMouse               Put mouse cursor on screen

PollDevLoop anop

           lda  Keyboard                Get keypress
           bpl  PollMouse               No keypress, check mouse
           jmp  KeyDev

PollMouse  anop

           jsr  ReadMouse               Readmouse
           lsr  MouseX                  Put x and y mouse coordinates into
           lsr  MouseY                   0 to 79 and 0 to 23 range.
           lda  MouseStat               Get mouse status
           bit  #MouseMove              Move moved?
           bne  MouseDev1               Yes, process mouse movement
           bit  #CurrButton             Mouse button pressed?
           bne  MouseDev2               Yes, process mouse button press.
           bit  #PrevButton             Mouse button released?
           bne  MouseDev3               Yes, process mouse button release.

           bra  PollDevLoop             Check keyboard and mouse again.

*
* Process mouse movement
*

MouseDev1  anop

           jsr  MoveMouse
           bra  PollDevLoop

*
* Process mouse button press
*

MouseDev2  anop

           jmp  ButtonPress

*
* Process mouse button release
*

MouseDev3  anop

           jmp  ButtonRelease

*
* Process keyboard key press
*

KeyDev     anop

           stz  ClearKbd                Clear keyboard strobe
           sta  KeyPress                Save keypress

* Tab key routine

           lda  KeyPress
           cmp  #TabKey
           beq  TabReq
           bra  NextKey01

TabReq     anop

           lda  OptionKey
           bmi  TabUp

TabDown    anop

           inc  TabIndex
           lda  TabIndex
           cmp  NumButts
           bcc  TabReq1

           stz  TabIndex
           bra  TabReq1

TabUp      anop

           dec  TabIndex
           bpl  TabReq1

           lda  NumButts
           dec  a
           sta  TabIndex

TabReq1    anop

           lda  #TabOnly
           sta  RC
           jmp  Exit

NextKey01  anop

* Process <cr>

           lda  KeyPress
           cmp  #ReturnKey
           beq  EnterReq
           cmp  #' '+$80
           beq  EnterReq

           bra  InvalidKey

EnterReq   anop

           lda  TabIndex
           cmp  #Button1
           bne  Enter01
           jmp  Button1Req

Enter01    anop

           cmp  #Button2
           bne  Enter02
           jmp  Button2Req

Enter02    anop

           jmp  PollDevLoop

Button1Req anop

           lda  #Button1
           cmp  TabIndex
           sta  TabIndex
           beq  B1Req01

           jsr  RefreshBtn

B1Req01    anop

           jsr  AnimateBtn

           lda  #CROnly
           sta  RC
           jmp  Exit

Button2Req anop

           lda  #Button2
           cmp  TabIndex
           sta  TabIndex
           beq  B2Req01

           jsr  RefreshBtn

B2Req01    anop

           jsr  AnimateBtn

           lda  #CROnly
           sta  RC
           jmp  Exit

InvalidKey anop

           jsr  Beep
           jmp  PollDevLoop

Exit       anop

           rts

*
* Do button animation
*

AnimateBtn anop

           lda  #15-1
           sta  VTab
           jsr  SetVTab

           lda  #StdText
           jsr  cout

           lda  TabIndex
           cmp  #Button1
           beq  AnimateB1

           cmp  #Button2
           beq  AnimateB2

           rts

AnimateB1  anop

           lda  #B1Text
           sta  Ptr1
           lda  #>B1Text
           sta  Ptr1+1

           lda  #Normal
           jsr  cout

           lda  B1HTabS
           sta  HTab

           jsr  PtrButton

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout

           lda  B1HTabS
           sta  HTab

           jsr  PtrButton

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout

           rts

AnimateB2  anop

           lda  #B2Text
           sta  Ptr1
           lda  #>B2Text
           sta  Ptr1+1

           lda  #Normal
           jsr  cout

           lda  B2HTabS
           sta  HTab

           jsr  PtrButton

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout

           lda  B2HTabS
           sta  HTab

           jsr  PtrButton

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout

           rts

PtrButton  anop

           ldx  #8
           ldy  #0

PB01       lda  (Ptr1),y
           jsr  cout
           iny
           dex
           bne  PB01

           rts

*
* Process button press
*

ButtonPress anop

           lda  MouseStat
           bit  #PrevButton
           beq  NotHeld
           jmp  PollDevLoop

NotHeld    anop

           lda  MouseY
           cmp  #15-1
           beq  RightRow
           jmp  BadPress

RightRow   anop

           lda  MouseX
           cmp  B1HTabS
           bcc  TestForB2
           cmp  B1HTabE
           bcs  TestForB2

* Button 1 click

           stz  TabIndex

           lda  #TabOnly
           sta  RC
           jmp  Exit

TestForB2  anop

           lda  Mode
           cmp  #ModeOk
           bne  CheckForB2
           jmp  BadPress

CheckForB2 anop

           lda  MouseX
           cmp  B2HTabS
           bcc  TestForB3
           cmp  B2HTabE
           bcs  TestForB3

* Button 2 click

           lda  #1
           sta  TabIndex

           lda  #TabOnly
           sta  RC
           jmp  Exit

TestForB3  anop

BadPress   anop

           jsr  Beep
           jmp  PollDevLoop

*
* Button Release
*

ButtonRelease anop

           lda  MouseY
           cmp  #15-1
           beq  GoodRow

           jmp  PollDevLoop

GoodRow    anop

           lda  TabIndex
           bne  B2Release

B1Release  anop

           lda  MouseX
           cmp  B1HTabS
           bcc  ButtExit
           cmp  B1HTabE
           bcs  ButtExit
           jmp  EnterReq

B2Release  anop

           lda  MouseX
           cmp  B2HTabS
           bcc  ButtExit
           cmp  B2HTabE
           bcs  ButtExit
           jmp  EnterReq

ButtExit   anop

           jmp  PollDevLoop
