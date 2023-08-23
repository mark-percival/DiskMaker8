;
; Standard messagebox UI
;

UI:

           stz  RC                    ; Reset return code
           stz  ClearKbd              ; Clear keyboard strobe

@PollDev:

           jsr  PlotMouse             ; Put mouse cursor on screen

MB2PollDevLoop:

           lda  Keyboard              ; Get keypress
           bpl  @PollMouse            ; No keypress, check mouse
           jmp  @KeyDev

@PollMouse:

           jsr  ReadMouse             ; Readmouse
           lsr  MouseX                ; Put x and y mouse coordinates into
           lsr  MouseY                ;  0 to 79 and 0 to 23 range.
           lda  MouseStat             ; Get mouse status
           bit  #MouseMove            ; Move moved?
           bne  @MouseDev1            ; Yes, process mouse movement
           bit  #CurrButton           ; Mouse button pressed?
           bne  @MouseDev2            ; Yes, process mouse button press.
           bit  #PrevButton           ; Mouse button released?
           bne  @MouseDev3            ; Yes, process mouse button release.

           bra  MB2PollDevLoop        ; Check keyboard and mouse again.

;
; Process mouse movement
;

@MouseDev1:

           jsr  MoveMouse
           bra  MB2PollDevLoop

;
; Process mouse button press
;

@MouseDev2:

           jmp  ButtonPress

;
; Process mouse button release
;

@MouseDev3:

           jmp  ButtonRelease

;
; Process keyboard key press
;

@KeyDev:

           stz  ClearKbd              ; Clear keyboard strobe
           sta  KeyPress              ; Save keypress

; Tab key routine

           lda  KeyPress
           cmp  #TabKey
           beq  @TabReq
           bra  @NextKey01

@TabReq:

           lda  OptionKey
           bmi  @TabUp

@TabDown:

           inc  TabIndex
           lda  TabIndex
           cmp  NumButts
           bcc  @TabReq1

           stz  TabIndex
           bra  @TabReq1

@TabUp:

           dec  TabIndex
           bpl  @TabReq1

           lda  NumButts
           dec  a
           sta  TabIndex

@TabReq1:

           lda  #TabOnly
           sta  RC
           jmp  MB2Exit

@NextKey01:

; Process <cr>

           lda  KeyPress
           cmp  #ReturnKey
           beq  MB2EnterReq
           cmp  #' '+$80
           beq  MB2EnterReq

           bra  InvalidKey

MB2EnterReq:

           lda  TabIndex
           cmp  #Button1
           bne  @Enter01
           jmp  Button1Req

@Enter01:

           cmp  #Button2
           bne  @Enter02
           jmp  Button2Req

@Enter02:

           jmp  MB2PollDevLoop

Button1Req:

           lda  #Button1
           cmp  TabIndex
           sta  TabIndex
           beq  B1Req01

           jsr  MBRefreshBtn

B1Req01:

           jsr  MB2AnimateBtn

           lda  #MBCROnly
           sta  RC
           jmp  Exit

Button2Req:

           lda  #Button2
           cmp  TabIndex
           sta  TabIndex
           beq  B2Req01

           jsr  MBRefreshBtn

B2Req01:

           jsr  MB2AnimateBtn

           lda  #MBCROnly
           sta  RC
           jmp  Exit

InvalidKey:

           jsr  Beep
           jmp  MB2PollDevLoop

MB2Exit:

           rts

;
; Do button animation
;

MB2AnimateBtn:

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

AnimateB1:

           lda  #<B1Text
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

AnimateB2:

           lda  #<B2Text
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

PtrButton:

           ldx  #8
           ldy  #0

@PB01:     lda  (Ptr1),y
           jsr  cout
           iny
           dex
           bne  @PB01

           rts

;
; Process button press
;

ButtonPress:

           lda  MouseStat
           bit  #PrevButton
           beq  NotHeld
           jmp  MB2PollDevLoop

NotHeld:

           lda  MouseY
           cmp  #15-1
           beq  RightRow
           jmp  BadPress

RightRow:

           lda  MouseX
           cmp  B1HTabS
           bcc  TestForB2
           cmp  B1HTabE
           bcs  TestForB2

; Button 1 click

           stz  TabIndex

           lda  #TabOnly
           sta  RC
           jmp  Exit

TestForB2:

           lda  Mode
           cmp  #ModeOk
           bne  CheckForB2
           jmp  BadPress

CheckForB2:

           lda  MouseX
           cmp  B2HTabS
           bcc  TestForB3
           cmp  B2HTabE
           bcs  TestForB3

; Button 2 click

           lda  #1
           sta  TabIndex

           lda  #TabOnly
           sta  RC
           jmp  Exit

TestForB3:

BadPress:

           jsr  Beep
           jmp  MB2PollDevLoop

;
; Button Release
;

ButtonRelease:

           lda  MouseY
           cmp  #15-1
           beq  GoodRow

           jmp  MB2PollDevLoop

GoodRow:

           lda  TabIndex
           bne  B2Release

B1Release:

           lda  MouseX
           cmp  B1HTabS
           bcc  ButtExit
           cmp  B1HTabE
           bcs  ButtExit
           jmp  MB2EnterReq

B2Release:

           lda  MouseX
           cmp  B2HTabS
           bcc  ButtExit
           cmp  B2HTabE
           bcs  ButtExit
           jmp  MB2EnterReq

ButtExit:

           jmp  MB2PollDevLoop
