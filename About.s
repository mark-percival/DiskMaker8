*
* About box
*

About      Start

           jsr  SaveScreen
           jsr  ShowAbout
           jsr  AboutUI
           jsr  RestScreen

           jsr  PlotMouse

           rts

ShowAbout  anop

           lda  #MouseText
           jsr  cout

* Line 1

           lda  #10-1
           sta  HTab
           lda  #8-1
           sta  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #'L'
           ldx  #59

L1A        anop

           jsr  cout
           dex
           bne  L1A

           lda  #'_'
           jsr  cout

* Line 2

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #22

L2A        anop

           jsr  cout
           dex
           bne  L2A

           ldx  #0

L2B        anop

           lda  Line2Text,x
           beq  L2C
           jsr  cout
           inx
           bra  L2B

L2C        anop

           lda  #' '+$80
           ldx  #21

L2D        anop

           jsr  cout
           dex
           bne  L2D

           lda  #'_'
           jsr  cout

* Line 3

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #14

L3A        anop

           jsr  cout
           dex
           bne  L3A

           ldx  #0

L3B        anop

           lda  Line3Text,x
           beq  L3C
           jsr  cout
           inx
           bra  L3B

L3C        anop

           lda  #' '+$80
           ldx  #14

L3D        anop

           jsr  cout
           dex
           bne  L3D

           lda  #'_'
           jsr  cout


* Line 4

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #59

L4A        anop

           jsr  cout
           dex
           bne  L4A

           lda  #'_'
           jsr  cout

* Line 5

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L5A        anop

           lda  Line5Text,x
           beq  L5B
           jsr  cout
           inx
           bra  L5A

L5B        anop

           lda  #' '+$80
           ldx  #2

L5C        anop

           jsr  cout
           dex
           bne  L5C

           lda  #'_'
           jsr  cout

* Line 6

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L6A        anop

           lda  Line6Text,x
           beq  L6B
           jsr  cout
           inx
           bra  L6A

L6B        anop

           lda  #' '+$80
           ldx  #8

L6C        anop

           jsr  cout
           dex
           bne  L6C

           lda  #'_'
           jsr  cout

* Line 7

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L7A        anop

           lda  Line7Text,x
           beq  L7B
           jsr  cout
           inx
           bra  L7A

L7B        anop

           lda  #' '+$80
           ldx  #6

L7C        anop

           jsr  cout
           dex
           bne  L7C

           lda  #'_'
           jsr  cout

* Line 8

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L8A        anop

           lda  Line8Text,x
           beq  L8B
           jsr  cout
           inx
           bra  L8A

L8B        anop

           lda  #' '+$80
           ldx  #1

L8C        anop

           jsr  cout
           dex
           bne  L8C

           lda  #'_'
           jsr  cout

* Line 9

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #25

L9A        anop

           jsr  cout
           dex
           bne  L9A

           lda  #'_'+$80
           ldx  #10

L9B        anop

           jsr  cout
           dex
           bne  L9B

           lda  #' '+$80
           ldx  #24

L9C        anop

           jsr  cout
           dex
           bne  L9C

           lda  #'_'
           jsr  cout

* Line 10

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #24

L10A       anop

           jsr  cout
           dex
           bne  L10A

           lda  #'Z'
           jsr  cout

           lda  #StdText
           jsr  cout

           lda  #' '
           jsr  cout

           lda  #Inverse
           jsr  cout

           ldx  #0

L10B       anop

           lda  OkText,x
           beq  L10C
           jsr  cout
           inx
           bra  L10B

L10C       anop

           lda  #Normal
           jsr  cout

           lda  #' '
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #'_'
           jsr  cout

           lda  #' '+$80
           ldx  #23

L10D       anop

           jsr  cout
           dex
           bne  L10D

           lda  #'_'
           jsr  cout

* Line 11

           jsr  NextLine

           lda  #'Z'
           jsr  cout

           lda  #'_'+$80
           ldx  #25

L11A       anop

           jsr  cout
           dex
           bne  L11A

           lda  #'\'
           ldx  #10

L11B       anop

           jsr  cout
           dex
           bne  L11B

           lda  #'_'+$80
           ldx  #24

L11C       anop

           jsr  cout
           dex
           bne  L11C

           lda  #'_'
           jsr  cout

* Exit

           lda  #StdText
           jsr  cout

           rts

           Msb  On
Line2Text  dc   c'DiskMaker 8 v1.1',h'00'
Line3Text  dc   c'Copyright 2006 by Mark Percival',h'00'
Line5Text  dc   c'Converts Universal Disk Image, DiskCopy 4.2, DiskCopy 6,'
           dc   h'00'
Line6Text  dc   c'DOS Order 5.25" and ProDOS Order 5.25" images into',h'00'
Line7Text  dc   c'actual disks.  Please support the Apple II by paying',h'00'
Line8Text  dc   c'the $5 shareware fee.  See the documentation for details.'
           dc   h'00'
OkText     dc   c'   Ok   ',h'00'
           Msb  Off

NextLine   anop

           lda  #10-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           rts

AboutUI    anop

ReturnKey  equ  $8D
TabKey     equ  $89

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

           bra  PollDevLoop

*
* Process mouse button release
*

MouseDev3  anop

           lda  MouseY
           cmp  #17-1
           bne  No
           lda  MouseX
           cmp  #37-1
           bcc  No
           cmp  #45-1
           bcs  No

           jsr  AnimateBtn

           rts

No         anop

           bra  PollDevLoop

*
* Process keyboard key press
*

KeyDev     anop

           stz  ClearKbd                Clear keyboard strobe

           cmp  #ReturnKey
           beq  Return
           cmp  #' '+$80
           beq  Return
           cmp  #TabKey
           beq  Tab

           jsr  Beep

           jmp  PollDevLoop

Tab        anop

           jmp  PollDevLoop

Return     anop

           jsr  AnimateBtn

           rts

AnimateBtn anop

           lda  #Normal
           jsr  cout

           lda  #17-1
           sta  VTab
           lda  #37-1
           sta  HTab

           jsr  SetVTab

           ldx  #8
           ldy  #0

AB01       anop

           lda  OkText,y
           jsr  cout
           iny
           dex
           bne  AB01

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout

           lda  #17-1
           sta  VTab
           lda  #37-1
           sta  HTab

           jsr  SetVTab

           ldx  #8
           ldy  #0

AB02       anop

           lda  OkText,y
           jsr  cout
           iny
           dex
           bne  AB02

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout

           rts

* Save / Restore Screen routine.

TextLine   anop                         Text screen line starting addresses

TextLine00 dc   i'$0400'
TextLine01 dc   i'$0480'
TextLine02 dc   i'$0500'
TextLine03 dc   i'$0580'
TextLine04 dc   i'$0600'
TextLine05 dc   i'$0680'
TextLine06 dc   i'$0700'
TextLine07 dc   i'$0780'
TextLine08 dc   i'$0428'
TextLine09 dc   i'$04A8'
TextLine10 dc   i'$0528'
TextLine11 dc   i'$05A8'
TextLine12 dc   i'$0628'
TextLine13 dc   i'$06A8'
TextLine14 dc   i'$0728'
TextLine15 dc   i'$07A8'
TextLine16 dc   i'$0450'
TextLine17 dc   i'$04D0'
TextLine18 dc   i'$0550'
TextLine19 dc   i'$05D0'
TextLine20 dc   i'$0650'
TextLine21 dc   i'$06D0'
TextLine22 dc   i'$0750'
TextLine23 dc   i'$07D0'

On80Store  equ  $C001
Page1      equ  $C054
Page2      equ  $C055

SaveRtn    ds   1

StartHTab  ds   1
EndHTab    ds   1
StartVTab  ds   1
CurrLine   ds   1

*
* SaveScreen - save screen data under list box
* RestScreen - restore screen data under messagebox
*
* Ptr1 = screen data : Ptr2 = save buffer
*

SaveScreen anop

           lda  #1
           sta  SaveRtn
           bra  StartRtn

RestScreen anop

           stz  SaveRtn

StartRtn   anop

           sta  On80Store               Make sure 80STORE is on.

           clc
           lda  #10-1                   HTab start
           sta  StartHTab
           adc  #61                     # char wide
           sta  EndHTab                 Ending HTab

           sec
           lda  #8-1                    Base VTab
           sta  StartVTab
           sta  CurrLine

           lda  #MessageBuf             Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #11                     Max # of lines

SSLoop1    anop

           lda  CurrLine
           asl  a
           tay
           lda  TextLine,y
           sta  Ptr1
           iny
           lda  TextLine,y
           sta  Ptr1+1

           ldy  StartHTab

SSLoop2    anop

           phy
           tya
           lsr  a
           bcs  FromMain

FromAux    anop

           sta  Page2
           bra  GetChar

FromMain   anop

           sta  Page1

GetChar    anop

           tay
           lda  SaveRtn
           beq  Restore

           lda  (Ptr1),y
           sta  (Ptr2)
           bra  Continue

Restore    anop

           lda  (Ptr2)
           sta  (Ptr1),y

Continue   anop

           ply

           inc  Ptr2                    Increment save buffer pointer
           bne  NoOF

           inc  Ptr2+1

NoOF       anop                         No overflow

           iny
           cpy  EndHTab                 If y <= EndHTab, SSLoop2 to continue
           bcc  SSLoop2                  saving this line
           beq  SSLoop2

           inc  CurrLine                Move to next line
           dex                          Another line?
           bne  SSLoop1

           lda  Page1                   Set back to Main for exit.

           rts

           End
