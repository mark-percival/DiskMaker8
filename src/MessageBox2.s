;
; Standard messagebox UI
;

UI:

UpArrow     =   $8B
DownArrow   =   $8A
LeftArrow   =   $88
RightArrow  =   $95
ReturnKey   =   $8D
TabKey      =   $89

;AppleKey    =   $C061
;OptionKey   =   $C062

           stz  M1_RC                   ; Reset return code
           stz  ClearKbd                ; Clear keyboard strobe

MB2_PollDev:

           jsr  PlotMouse               ; Put mouse cursor on screen

MB2_PollDevLoop:

           lda  Keyboard                ; Get keypress
           bpl  @PollMouse              ; No keypress, check mouse
           jmp  MB2_KeyDev

@PollMouse:

           jsr  ReadMouse               ; Readmouse
           lsr  MouseX                  ; Put x and y mouse coordinates into
           lsr  MouseY                  ;  0 to 79 and 0 to 23 range.
           lda  MouseStat               ; Get mouse status
           bit  #MouseMove              ; Move moved?
           bne  MB2_MouseDev1           ; Yes, process mouse movement
           bit  #CurrButton             ; Mouse button pressed?
           bne  MB2_MouseDev2           ; Yes, process mouse button press.
           bit  #PrevButton             ; Mouse button released?
           bne  MB2_MouseDev3           ; Yes, process mouse button release.

           bra  MB2_PollDevLoop         ; Check keyboard and mouse again.

;
; Process mouse movement
;

MB2_MouseDev1:

           jsr  MoveMouse
           bra  MB2_PollDevLoop

;
; Process mouse button press
;

MB2_MouseDev2:

           jmp  ButtonPress

;
; Process mouse button release
;

MB2_MouseDev3:

           jmp  ButtonRelease

;
; Process keyboard key press
;

MB2_KeyDev:

           stz  ClearKbd                ; Clear keyboard strobe
           sta  MB_KeyPress             ; Save keypress

; Tab key routine

           lda  MB_KeyPress
           cmp  #TabKey
           beq  MB2_TabReq
           bra  MB2_NextKey01

MB2_TabReq:

           lda  OptionKey
           bmi  MB2_TabUp

;TabDown:

           inc  M1_TabIndex
           lda  M1_TabIndex
           cmp  NumButts
           bcc  MB2_TabReq1

           stz  M1_TabIndex
           bra  MB2_TabReq1

MB2_TabUp:

           dec  M1_TabIndex
           bpl  MB2_TabReq1

           lda  NumButts
           dec  a
           sta  M1_TabIndex

MB2_TabReq1:

           lda  #TabOnly
           sta  M1_RC
           jmp  MB2_Exit

MB2_NextKey01:

; Process <cr>

           lda  MB_KeyPress
           cmp  #ReturnKey
           beq  MB2_EnterReq
           cmp  #' '+$80
           beq  MB2_EnterReq

           bra  InvalidKey

MB2_EnterReq:

           lda  M1_TabIndex
           cmp  #Button1
           bne  @Enter01
           jmp  Button1Req

@Enter01:

           cmp  #Button2
           bne  @Enter02
           jmp  Button2Req

@Enter02:

           jmp  MB2_PollDevLoop

Button1Req:

           lda  #Button1
           cmp  M1_TabIndex
           sta  M1_TabIndex
           beq  B1Req01

           jsr  MB1_RefreshBtn

B1Req01:

           jsr  MB2_AnimateBtn

           lda  #MB_CROnly
           sta  M1_RC
           jmp  MB2_Exit

Button2Req:

           lda  #Button2
           cmp  M1_TabIndex
           sta  M1_TabIndex
           beq  B2Req01

           jsr  MB1_RefreshBtn

B2Req01:

           jsr  MB2_AnimateBtn

           lda  #MB_CROnly
           sta  M1_RC
           jmp  MB2_Exit

InvalidKey:

           jsr  Beep
           jmp  MB2_PollDevLoop

MB2_Exit:

           rts

;
; Do button animation
;

MB2_AnimateBtn:

           lda  #15-1
           sta  VTab
           jsr  SetVTab

           lda  #StdText
           jsr  cout

           lda  M1_TabIndex
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

PB01:      lda  (Ptr1),y
           jsr  cout
           iny
           dex
           bne  PB01

           rts

;
; Process button press
;

ButtonPress:

           lda  MouseStat
           bit  #PrevButton
           beq  @NotHeld
           jmp  MB2_PollDevLoop

@NotHeld:

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

           stz  M1_TabIndex

           lda  #TabOnly
           sta  M1_RC
           jmp  MB2_Exit

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
           sta  M1_TabIndex

           lda  #TabOnly
           sta  M1_RC
           jmp  MB2_Exit

TestForB3:

BadPress:

           jsr  Beep
           jmp  MB2_PollDevLoop

;
; Button Release
;

ButtonRelease:

           lda  MouseY
           cmp  #15-1
           beq  GoodRow

           jmp  MB2_PollDevLoop

GoodRow:

           lda  M1_TabIndex
           bne  B2Release

B1Release:

           lda  MouseX
           cmp  B1HTabS
           bcc  ButtExit
           cmp  B1HTabE
           bcs  ButtExit
           jmp  MB2_EnterReq

B2Release:

           lda  MouseX
           cmp  B2HTabS
           bcc  ButtExit
           cmp  B2HTabE
           bcs  ButtExit
           jmp  MB2_EnterReq

ButtExit:

           jmp  MB2_PollDevLoop
