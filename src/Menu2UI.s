;
; Menu2 user interface
;

Menu2UI:


           ; Expected to scope to Menu2Vars.s

;UpArrow     =   $8B
;DownArrow   =   $8A
;LeftArrow   =   $88
;RightArrow  =   $95
;ReturnKey   =   $8D
;TabKey      =   $89

;AppleKey    =   $C061
;OptionKey   =   $C062

           stz  RC2                     ; Reset return code
           stz  ClearKbd

M2_PollDev:

           jsr  PlotMouse               ; Put mouse cursor on screen

M2_PollDevLoop:

           lda  Keyboard                ; Get keypress
           bpl  @PollMouse              ; No keypress, check mouse
           jmp  M2_KeyDev

@PollMouse:

           jsr  ReadMouse               ; Read mouse
           lsr  MouseX                  ; Put x and y mouse coordinates into
           lsr  MouseY                  ;  0 to 79 and 0 to 23 range.
           lda  MouseStat               ; Mouse status
           bit  #MouseMove              ; Mouse moved?
           bne  M2_MouseDev1            ; Yes, process cursor movement
           bit  #CurrButton             ; Button pressed?
           bne  M2_MouseDev2            ; Yes, process button pressed.
           bit  #PrevButton             ; Button release?
           bne  M2_MouseDev3            ; Yes, process button release.

           bra  M2_PollDevLoop          ; Check keyboard and mouse again.

;
; Process mouse movement
;

M2_MouseDev1:

           jsr  MoveMouse
           jmp  M2_PollDevLoop

;
; Process button pressed
;

M2_MouseDev2:

           jmp  M2_ButtonDown

;
; Process mouse button release
;

M2_MouseDev3:

           jmp  M2_ButtonUp

;
; Process keyboard key press
;

M2_KeyDev:

           stz  ClearKbd                ; Clear keyboard strobe
           sta  M2_KeyPress

; Text for quiting screen

           lda  AppleKey
           bpl  M2_NextKey01
           lda  M2_KeyPress
           cmp  #'Q'+$80
           beq  M2_QuitReq
           cmp  #'q'+$80
           beq  M2_QuitReq
           cmp  #'B'+$80
           beq  M2_QuitReq
           cmp  #'b'+$80
           beq  M2_QuitReq
           bra  M2_NextKey01

M2_QuitReq:

           lda  #SkipBtn                ; Test here to see of Skip is the
           cmp  TabIndex2               ;  current displayed button.
           sta  TabIndex2
           beq  M2_QuitReq0
           jsr  Refresh2Btn             ; Display Skip as current selected.

M2_QuitReq0:

           jsr  M2_AnimateBtn

           lda  #Quit2
           sta  RC2
           jmp  M2_Exit

; Down / right arrow keypress logic

M2_NextKey01:

           lda  M2_KeyPress
           cmp  #DownArrow              ; Down arrow?
           beq  DownReq2
           cmp  #RightArrow             ; ...or right arrow?
           beq  DownReq2
           bra  M2_NextKey02

DownReq2:

           lda  M2_SelLine
           cmp  #5                      ; At bottom of window?
           beq  @AtBottom

           lda  DevEntCnt               ; If total number of devices = our current
           cmp  M2_SelLine              ;  line number then no more entries.
           beq  @AtBottom

;IncSelLine:

           inc  M2_SelLine
           lda  #UpdDevLst
           sta  RC2
           jmp  M2_Exit

@AtBottom:

           lda  Below
           beq  @NoMoreBelow

           inc  M2_SelLine              ; Should make M2_SelLine = 6

@NoMoreBelow:

           lda  #UpdDevLst
           sta  RC2
           jmp  M2_Exit

M2_NextKey02:

; Up / left arrow keypress

           lda  M2_KeyPress
           cmp  #UpArrow
           beq  UpReq2
           cmp  #LeftArrow
           beq  UpReq2
           bra  M2_NextKey03

UpReq2:

           lda  M2_SelLine
           cmp  #1
           beq  @AtTop

           dec  M2_SelLine
           lda  #UpdDevLst
           sta  RC2
           jmp  M2_Exit

@AtTop:

           lda  Above
           beq  @NoMoreAbove

           dec  M2_SelLine              ; Should make M2_SelLine = 0

@NoMoreAbove:

           lda  #UpdDevLst
           sta  RC2
           jmp  M2_Exit

M2_NextKey03:

; About screen request

           lda  AppleKey
           bpl  M2_NextKey04
           lda  M2_KeyPress
           cmp  #'A'+$80
           beq  AboutReq
           cmp  #'a'+$80
           beq  AboutReq
           bra  M2_NextKey04

AboutReq:

           lda  #AboutBtn
           cmp  TabIndex2
           sta  TabIndex2
           beq  AboutReq0

           jsr  Refresh2Btn

AboutReq0:

           jsr  M2_AnimateBtn

AboutReq1:

           lda  #SkipBtn
           sta  TabIndex2

;          lda  #<AboutMsg
;          sta  MsgPtr
;          lda  #>AboutMsg
;          sta  MsgPtr+1
;
;          jsr  MsgOk

           jsr  About

           lda  #Nothing
           sta  RC2
           jmp  M2_Exit

;          Msb  On
AboutMsg:  asccr "       Diskmaker 8"
           ascz  "(c) 2005 by Mark Percival"
;          Msb  Off

M2_NextKey04:

; Make disk request

           lda  AppleKey
           bpl  M2_NextKey05
           lda  M2_KeyPress
           cmp  #'M'+$80
           beq  MakeReq
           cmp  #'m'+$80
           beq  MakeReq
           bra  M2_NextKey05

MakeReq:

           lda  #MakeBtn
           cmp  TabIndex2
           sta  TabIndex2
           beq  MakeReq0

           jsr  Refresh2Btn

MakeReq0:

           jsr  M2_AnimateBtn

           lda  DevEntCnt               ; Check to see if there are devices listed
           bne  MakeReq1                ;  on the screen.

           jsr  Beep                    ; Nope, so beep him and exit.

           lda  #Nothing
           sta  RC2
           jmp  M2_Exit

MakeReq1:

           lda  #SkipBtn
           sta  TabIndex2

           lda  #MakingDisk
           sta  RC2
           jmp  M2_Exit

M2_NextKey05:

; Tab key routine

           lda  M2_KeyPress
           cmp  #TabKey
           beq  M2_TabReq
           bra  M2_NextKey06

M2_TabReq:

           lda  OptionKey
           bmi  M2_TabUp

;TabDown:

           lda  TabIndex2
           inc  a
           cmp  #LoopBack2
           bne  M2_TabReq1

           lda  #0
           bra  M2_TabReq1

M2_TabUp:

           lda  TabIndex2
           dec  a
           bpl  M2_TabReq1

           lda  #LoopBack2-1

M2_TabReq1:

           sta  TabIndex2

           lda  #Nothing
           sta  RC2
           jmp  M2_Exit

M2_NextKey06:

; Process <cr>

           lda   M2_KeyPress
           cmp  #ReturnKey
           beq  M2_EnterReq
           cmp  #' '+$80
           beq  M2_EnterReq
           bra  M2_NextKey07

M2_EnterReq:

           lda  TabIndex2

           cmp  #AboutBtn
           bne  @Enter01
           jmp  AboutReq

@Enter01:

           cmp  #SkipBtn
           bne  @Enter02
           jmp  M2_QuitReq

@Enter02:

           cmp  #MakeBtn
           bne  @Enter03
           jmp  MakeReq

@Enter03:

           cmp  #ImgTypeBox
           bne  @Enter04
           jsr  SelImgType
           jsr  GetImgSize

           lda  blnSize                 ; Is same-size on?
           bne  @Enter03a
           jmp  M2_PollDevLoop          ; No, so just get next keystroke.

@Enter03a:

           lda  #ReloadDevs             ; Same size on and he changed type so
           sta  RC2                     ; refresh device display.
           jmp  M2_Exit

@Enter04:

           cmp  #SameSize
           bne  @Enter05
           jsr  ToggleSize
           lda  #ReloadDevs
           sta  RC2
           jmp  M2_Exit

@Enter05:

M2_NextKey07:

           jsr  Beep
           jmp  M2_PollDevLoop

M2_Exit:

           rts

M2_KeyPress: .res 1

;
; Do button animation on <cr>
;

M2_AnimateBtn:

           lda  #<M2BtnText
           sta  Ptr1
           lda  #>M2BtnText
           sta  Ptr1+1

           ldx  TabIndex2
           beq  M2_AnimBtn02

M2_AnimBtn01:

           clc
           lda  Ptr1
           adc  #12
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           dex
           bne  M2_AnimBtn01

M2_AnimBtn02:

           lda  #Normal
           jsr  cout

           jsr  @PrtButton

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout

           jsr  @PrtButton

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout

           rts

;
; Print button text
;

@PrtButton:

           lda  #51-1
           sta  HTab
           lda  (Ptr1)
           sta  VTab
           jsr  SetVTab

           ldy  #1
           ldx  #11

@PrtButt01:

           lda  (Ptr1),y
           jsr  cout
           iny
           dex
           bne  @PrtButt01

           rts

;
; Process mouse button press
;

M2_ButtonDown:

           lda  MouseStat               ; Button is down but make sure he has also
           bit  #PrevButton             ; released it and is not holding it down.
           beq  BD00

           lda  M2_HoldCnt              ; Check to see how long he's held down the
           cmp  #$FF                    ; mouse button.
           beq  M2_Repeat               ; Long enough so he's repeating.

           inc  M2_HoldCnt              ; Hasn't held it long enough to be
           lda  #$01                    ; considered repeating so count the hold
           jsr  Wait

           jmp  M2_PollDevLoop

M2_HoldCnt:    .res 1                   ; Count how long he's holding the button

BD00:

           stz  M2_HoldCnt              ; Zero out counter on first button press.

M2_Repeat:

; Test for About button click

           lda  MouseY
           cmp  #11-1
           bne  BD01

           lda  MouseX
           cmp  #50-1
           bcc  BD01

           cmp  #62
           bcs  BD01

           lda  #AboutBtn
           sta  TabIndex2

           lda  #Nothing
           sta  RC2
           rts

BD01:

; Test for Skip button click

           lda  MouseY
           cmp  #13-1
           bne  BD02

           lda  MouseX
           cmp  #50-1
           bcc  BD02

           cmp  #62
           bcs  BD02

           lda  #SkipBtn
           sta  TabIndex2

           lda  #Nothing
           sta  RC2
           rts

BD02:

; Test for Make Disks button click

           lda  MouseY
           cmp  #15-1
           bne  BD03

           lda  MouseX
           cmp  #50-1
           bcc  BD03

           cmp  #62
           bcs  BD03

           lda  #MakeBtn
           sta  TabIndex2

           lda  #Nothing
           sta  RC2
           rts

BD03:

; Test for Image Type box click

           lda  MouseY
           cmp  #17-1
           bne  BD04

           lda  MouseX
           cmp  #19-1
           bcc  BD04

           cmp  #38
           bcs  BD04

           lda  #ImgTypeBox
           sta  TabIndex2

           jsr  Refresh2Btn
           jsr  SelImgType
           jsr  GetImgSize

           lda  blnSize                 ; Is same-size on?
           bne  BD03a
           jmp  M2_PollDevLoop             ; No, so just get next keystroke.

BD03a:

           lda  #ReloadDevs             ; Same size on and he changed type so
           sta  RC2                     ; refresh device display.
           rts

BD04:

; Test for Same-size disks checkbox click

           lda  MouseY
           cmp  #17-1
           bne  BD05

           lda  MouseX
           cmp  #42-1
           bcc  BD05

           cmp  #63
           bcs  BD05

           lda  #SameSize
           sta  TabIndex2

           lda  #Nothing
           sta  RC2
           rts

BD05:

; Text for scroll list box up

           lda  MouseY
           cmp  #11-1
           bne  BD06

           lda  MouseX
           cmp  #46-1
           bne  BD06

           jmp  UpReq2

BD06:

; Test for scroll list box down

           lda  MouseY
           cmp  #15-1
           bne  BD07

           lda  MouseX
           cmp  #46-1
           bne  BD07

           jmp  DownReq2

BD07:

; Look for a click on a device inside of list box

           lda  MouseY
           cmp  #11-1
           bcc  BD09

           cmp  #15
           bcs  BD09

           lda  MouseX
           cmp  #19-1
           bcc  BD09

           cmp  #44
           bcs  BD09

           sec
           lda  MouseY
           sbc  #9
           cmp  M2_SelLine              ; Did he click the same line twice?
           beq  BD08                    ; Yes so execute double click logic

           sta  M2_SelLine              ; No so change selected line pointer.

           lda  #UpdDevLst
           sta  RC2
           rts

BD08:                         ; Double clicked line

           lda  #MakeBtn                ; Change command to Make Disks
           sta  TabIndex2

           jmp  M2_EnterReq             ; Pretend that he pressed Enter key

BD09:

           jsr  Beep
           jmp  M2_PollDevLoop

           rts
;
; Process mouse button release
;

M2_ButtonUp:

; Test for About button click

           lda  MouseY
           cmp  #11-1
           bne  BU01

           lda  MouseX
           cmp  #50-1
           bcc  BU01

           cmp  #62
           bcs  BU01

           lda  TabIndex2
           cmp  #AboutBtn
           bne  BU01

           jmp  M2_EnterReq

BU01:

; Test for Skip button click

           lda  MouseY
           cmp  #13-1
           bne  BU02

           lda  MouseX
           cmp  #50-1
           bcc  BU02

           cmp  #62
           bcs  BU02

           lda  TabIndex2
           cmp  #SkipBtn
           bne  BU02

           jmp  M2_EnterReq

BU02:

; Test for Make Disks button click

           lda  MouseY
           cmp  #15-1
           bne  BU03

           lda  MouseX
           cmp  #50-1
           bcc  BU03

           cmp  #62
           bcs  BU03

           lda  TabIndex2
           cmp  #MakeBtn
           bne  BU03

           jmp  M2_EnterReq

BU03:

; Test for Same-size disks checkbox click

           lda  MouseY
           cmp  #17-1
           bne  BU04

           lda  MouseX
           cmp  #42-1
           bcc  BU04

           cmp  #63
           bcs  BU04

           lda  TabIndex2
           cmp  #SameSize
           bne  BU04

           jmp  M2_EnterReq

BU04:

           jmp  M2_PollDevLoop


