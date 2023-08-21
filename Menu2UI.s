*
* Menu2 user interface
*

Menu2UI    Start
           Using Menu2Vars

UpArrow    equ  $8B
DownArrow  equ  $8A
LeftArrow  equ  $88
RightArrow equ  $95
ReturnKey  equ  $8D
TabKey     equ  $89

AppleKey   equ  $C061
OptionKey  equ  $C062

           stz  RC2                     Reset return code
           stz  ClearKbd

PollDev    anop

           jsr  PlotMouse               Put mouse cursor on screen

PollDevLoop anop

           lda  Keyboard                Get keypress
           bpl  PollMouse               No keypress, check mouse
           jmp  KeyDev

PollMouse  anop

           jsr  ReadMouse               Read mouse
           lsr  MouseX                  Put x and y mouse coordinates into
           lsr  MouseY                   0 to 79 and 0 to 23 range.
           lda  MouseStat               Mouse status
           bit  #MouseMove              Mouse moved?
           bne  MouseDev1               Yes, process cursor movement
           bit  #CurrButton             Button pressed?
           bne  MouseDev2               Yes, process button pressed.
           bit  #PrevButton             Button release?
           bne  MouseDev3               Yes, process button release.

           bra  PollDevLoop             Check keyboard and mouse again.

*
* Process mouse movement
*

MouseDev1  anop

           jsr  MoveMouse
           jmp  PollDevLoop

*
* Process button pressed
*

MouseDev2  anop

           jmp  ButtonDown

*
* Process mouse button release
*

MouseDev3  anop

           jmp  ButtonUp

*
* Process keyboard key press
*

KeyDev     anop

           stz  ClearKbd                Clear keyboard strobe
           sta  KeyPress

* Text for quiting screen

           lda  AppleKey
           bpl  NextKey01
           lda  KeyPress
           cmp  #'Q'+$80
           beq  QuitReq
           cmp  #'q'+$80
           beq  QuitReq
           cmp  #'B'+$80
           beq  QuitReq
           cmp  #'b'+$80
           beq  QuitReq
           bra  NextKey01

QuitReq    anop

           lda  #SkipBtn                Test here to see of Skip is the
           cmp  TabIndex2                current displayed button.
           sta  TabIndex2
           beq  QuitReq0
           jsr  Refresh2Btn             Display Skip as current selected.

QuitReq0   anop

           jsr  AnimateBtn

           lda  #Quit2
           sta  RC2
           jmp  Exit

* Down / right arrow keypress logic

NextKey01  anop

           lda  KeyPress
           cmp  #DownArrow              Down arrow?
           beq  DownReq2
           cmp  #RightArrow             ...or right arrow?
           beq  DownReq2
           bra  NextKey02

DownReq2   anop

           lda  SelLine
           cmp  #5                      At bottom of window?
           beq  AtBottom

           lda  DevEntCnt               If total number of devices = our current
           cmp  SelLine                  line number then no more entries.
           beq  AtBottom

IncSelLine anop

           inc  SelLine
           lda  #UpdDevLst
           sta  RC2
           jmp  Exit

AtBottom   anop

           lda  Below
           beq  NoMoreBelow

           inc  SelLine                 Should make SelLine = 6

NoMoreBelow anop

           lda  #UpdDevLst
           sta  RC2
           jmp  Exit

NextKey02  anop

* Up / left arrow keypress

           lda  KeyPress
           cmp  #UpArrow
           beq  UpReq2
           cmp  #LeftArrow
           beq  UpReq2
           bra  NextKey03

UpReq2     anop

           lda  SelLine
           cmp  #1
           beq  AtTop

           dec  SelLine
           lda  #UpdDevLst
           sta  RC2
           jmp  Exit

AtTop      anop

           lda  Above
           beq  NoMoreAbove

           dec  SelLine                 Should make SelLine = 0

NoMoreAbove anop

           lda  #UpdDevLst
           sta  RC2
           jmp  Exit

NextKey03  anop

* About screen request

           lda  AppleKey
           bpl  NextKey04
           lda  KeyPress
           cmp  #'A'+$80
           beq  AboutReq
           cmp  #'a'+$80
           beq  AboutReq
           bra  NextKey04

AboutReq   anop

           lda  #AboutBtn
           cmp  TabIndex2
           sta  TabIndex2
           beq  AboutReq0

           jsr  Refresh2Btn

AboutReq0  anop

           jsr  AnimateBtn

AboutReq1  anop

           lda  #SkipBtn
           sta  TabIndex2

*          lda  #AboutMsg
*          sta  MsgPtr
*          lda  #>AboutMsg
*          sta  MsgPtr+1
*
*          jsr  MsgOk

           jsr  About

           lda  #Nothing
           sta  RC2
           jmp  Exit

           Msb  On
AboutMsg   dc   c'       Diskmaker 8',h'0D'
           dc   c'(c) 2005 by Mark Percival',h'00'
           Msb  Off

NextKey04  anop

* Make disk request

           lda  AppleKey
           bpl  NextKey05
           lda  KeyPress
           cmp  #'M'+$80
           beq  MakeReq
           cmp  #'m'+$80
           beq  MakeReq
           bra  NextKey05

MakeReq    anop

           lda  #MakeBtn
           cmp  TabIndex2
           sta  TabIndex2
           beq  MakeReq0

           jsr  Refresh2Btn

MakeReq0   anop

           jsr  AnimateBtn

           lda  DevEntCnt               Check to see if there are devices listed
           bne  MakeReq1                 on the screen.

           jsr  Beep                    Nope, so beep him and exit.

           lda  #Nothing
           sta  RC2
           jmp  Exit

MakeReq1   anop

           lda  #SkipBtn
           sta  TabIndex2

           lda  #MakingDisk
           sta  RC2
           jmp  Exit

NextKey05  anop

* Tab key routine

           lda  KeyPress
           cmp  #TabKey
           beq  TabReq
           bra  NextKey06

TabReq     anop

           lda  OptionKey
           bmi  TabUp

TabDown    anop

           lda  TabIndex2
           inc  a
           cmp  #LoopBack2
           bne  TabReq1

           lda  #0
           bra  TabReq1

TabUp      anop

           lda  TabIndex2
           dec  a
           bpl  TabReq1

           lda  #LoopBack2-1

TabReq1    anop

           sta  TabIndex2

           lda  #Nothing
           sta  RC2
           jmp  Exit

NextKey06  anop

* Process <cr>

           lda   KeyPress
           cmp  #ReturnKey
           beq  EnterReq
           cmp  #' '+$80
           beq  EnterReq
           bra  NextKey07

EnterReq   anop

           lda  TabIndex2

           cmp  #AboutBtn
           bne  Enter01
           jmp  AboutReq

Enter01    anop

           cmp  #SkipBtn
           bne  Enter02
           jmp  QuitReq

Enter02    anop

           cmp  #MakeBtn
           bne  Enter03
           jmp  MakeReq

Enter03    anop

           cmp  #ImgTypeBox
           bne  Enter04
           jsr  SelImgType
           jsr  GetImgSize

           lda  blnSize                 Is same-size on?
           bne  Enter03a
           jmp  PollDevLoop             No, so just get next keystroke.

Enter03a   anop

           lda  #ReloadDevs             Same size on and he changed type so
           sta  RC2                     refresh device display.
           jmp  Exit

Enter04    anop

           cmp  #SameSize
           bne  Enter05
           jsr  ToggleSize
           lda  #ReloadDevs
           sta  RC2
           jmp  Exit

Enter05    anop

NextKey07  anop

           jsr  Beep
           jmp  PollDevLoop

Exit       anop

           rts

KeyPress   ds   1

*
* Do button animation on <cr>
*

AnimateBtn anop

           lda  #M2BtnText
           sta  Ptr1
           lda  #>M2BtnText
           sta  Ptr1+1

           ldx  TabIndex2
           beq  AnimBtn02

AnimBtn01  anop

           clc
           lda  Ptr1
           adc  #12
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           dex
           bne  AnimBtn01

AnimBtn02  anop

           lda  #Normal
           jsr  cout

           jsr  PrtButton

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout

           jsr  PrtButton

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout

           rts

*
* Print button text
*

PrtButton  anop

           lda  #51-1
           sta  HTab
           lda  (Ptr1)
           sta  VTab
           jsr  SetVTab

           ldy  #1
           ldx  #11

PrtButt01  anop

           lda  (Ptr1),y
           jsr  cout
           iny
           dex
           bne  PrtButt01

           rts

*
* Process mouse button press
*

ButtonDown anop

           lda  MouseStat               Button is down but make sure he has also
           bit  #PrevButton             released it and is not holding it down.
           beq  BD00

           lda  HoldCnt                 Check to see how long he's held down the
           cmp  #$FF                    mouse button.
           beq  Repeat                  Long enough so he's repeating.

           inc  HoldCnt                 Hasn't held it long enough to be
           lda  #$01                    considered repeating so count the hold
           jsr  Wait

           jmp  PollDevLoop

HoldCnt    ds   1                       Count how long he's holding the button

BD00       anop

           stz  HoldCnt                 Zero out counter on first button press.

Repeat     anop

* Test for About button click

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

BD01       anop

* Test for Skip button click

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

BD02       anop

* Test for Make Disks button click

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

BD03       anop

* Test for Image Type box click

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

           lda  blnSize                 Is same-size on?
           bne  BD03a
           jmp  PollDevLoop             No, so just get next keystroke.

BD03a      anop

           lda  #ReloadDevs             Same size on and he changed type so
           sta  RC2                     refresh device display.
           rts

BD04       anop

* Test for Same-size disks checkbox click

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

BD05       anop

* Text for scroll list box up

           lda  MouseY
           cmp  #11-1
           bne  BD06

           lda  MouseX
           cmp  #46-1
           bne  BD06

           jmp  UpReq2

BD06       anop

* Test for scroll list box down

           lda  MouseY
           cmp  #15-1
           bne  BD07

           lda  MouseX
           cmp  #46-1
           bne  BD07

           jmp  DownReq2

BD07       anop

* Look for a click on a device inside of list box

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
           cmp  SelLine                 Did he click the same line twice?
           beq  BD08                    Yes so execute double click logic

           sta  SelLine                 No so change selected line pointer.

           lda  #UpdDevLst
           sta  RC2
           rts

BD08       anop                         Double clicked line

           lda  #MakeBtn                Change command to Make Disks
           sta  TabIndex2

           jmp  EnterReq                Pretend that he pressed Enter key

BD09       anop

           jsr  Beep
           jmp  PollDevLoop

           rts
*
* Process mouse button release
*

ButtonUp   anop

* Test for About button click

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

           jmp  EnterReq

BU01       anop

* Test for Skip button click

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

           jmp  EnterReq

BU02       anop

* Test for Make Disks button click

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

           jmp  EnterReq

BU03       anop

* Test for Same-size disks checkbox click

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

           jmp  EnterReq

BU04       anop

           jmp  PollDevLoop

           End
