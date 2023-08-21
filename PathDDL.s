*
* Path drop down list
*

PathDDL    Start
           Using Menu1Vars

           lda  Prefix
           sta  InitPrefix
           bne  HavePrefix

           rts

HavePrefix anop

           lda  #TabOnly
           sta  RC
           stz  NumLevels
           lda  #1
           sta  SelLine

           jsr  CalcLevels

           jsr  SaveScreen

Loop       anop

           jsr  ShowDDL
           jsr  DDLUI

           lda  DDLRC
           bne  Loop

           lda  Prefix
           cmp  InitPrefix
           beq  NoChange

           lda  #OpenBtn
           sta  TabIndex

           lda  #DirChange
           sta  RC

NoChange   anop

           jsr  RestScreen

           jsr  PlotMouse

           rts

InitPrefix ds   1
NumLevels  ds   1
LevelsPosn ds   16
SelLine    ds   1
DDLRC      ds   1
LastLine   ds   1

CalcLevels anop

           ldx  Prefix                  Get prefix length
           ldy  #$00                    Zero LevelPosn index

CL01       anop

           lda  Prefix,x                Get prefix character
           cmp  #'/'                    Is it a '/'?
           bne  CL02                    No, move to next character

           txa
           sta  LevelsPosn,y            Save prefix ending position

           cpx  #1                      At root?
           beq  CL03

           cpy  #15                     Move than 15 subdirectories?
           beq  CL03

           iny                          Increment index

CL02       anop

           dex                          Move to next path character
           bne  CL01                    If not zero then loop

CL03       anop

           sty  NumLevels               Save the number of directory levels

           clc
           lda  #10
           adc  NumLevels
           sta  LastLine

           rts

* Display drop down list

ShowDDL    anop

           lda  #8-1
           sta  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #MouseText
           jsr  cout

           lda  #'Z'
           jsr  cout

           ldx  #20
           lda  #'L'

SDDL01     anop

           jsr  cout
           dex
           bne  SDDL01

           lda  #'_'
           jsr  cout

           ldx  #0

SDDL02     anop

           inx

           inc  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           ldy  LevelsPosn,x
           iny

           cpy  #2                      At root?
           beq  SDDL03

           lda  #' '+$80
           jsr  cout

           lda  #'X'
           jsr  cout

           lda  #'Y'
           jsr  cout

           bra  SDDL04

SDDL03     anop

           lda  #'Z'
           jsr  cout

           lda  #'\'
           jsr  cout

           lda  #'^'
           jsr  cout

SDDL04     anop

           lda  #' '+$80
           jsr  cout

           cpx  SelLine
           bne  SDDL04a

           lda  #StdText
           jsr  cout

           lda  #Inverse
           jsr  cout

SDDL04a    anop

           phx

           ldx  #15

SDDL05     anop

           lda  Prefix,y
           cmp  #'/'
           beq  SDDL06
           ora  #$80

           jsr  cout

           iny
           dex
           bne  SDDL05
           bra  SDDL07

SDDL06     anop

           lda  #' '+$80
           jsr  cout
           dex
           bne  SDDL06

SDDL07     anop

           lda  #Normal
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'_'
           jsr  cout

           plx
           cpx  NumLevels
           bcs  SDDL07a
           jmp  SDDL02

SDDL07a    anop

           inx

           lda  NumLevels
           cmp  #15
           beq  SDDL09

           inc  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'['
           jsr  cout
           jsr  cout

           lda  #' '+$80
           jsr  cout

           cpx  SelLine
           bne  SDDL07b

           lda  #StdText
           jsr  cout

           lda  #Inverse
           jsr  cout

SDDL07b    anop

           lda  #'D'+$80
           jsr  cout
           lda  #'i'+$80
           jsr  cout
           lda  #'s'+$80
           jsr  cout
           lda  #'k'+$80
           jsr  cout
           lda  #'s'+$80
           jsr  cout

           ldx  #10

           lda  #' '+$80

SDDL08     anop

           jsr  cout
           dex
           bne  SDDL08

           lda  #Normal
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'_'
           jsr  cout

SDDL09     anop

           inc  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           ldx  #20
           lda  #'_'+$80

SDDL10    anop

           jsr  cout
           dex
           bne  SDDL10

           lda  #'_'
           jsr  cout

           lda  #StdText
           jsr  cout

           rts

* Drop down list user interface.

DDLUI      anop

           stz  ClearKbd
           stz  DDLRC

PollDev    anop

           jsr  PlotMouse

PollDevLoop anop

           lda  Keyboard
           bpl  PollMouse
           jmp  KeyDev

PollMouse  anop

           jsr  ReadMouse
           lsr  MouseX
           lsr  MouseY
           lda  MouseStat
           bit  #MouseMove
           bne  MouseDev1
           bit  #CurrButton
           bne  MouseDev2
           bit  #PrevButton
           bne  MouseDev3

           bra  PollDevLoop

* Mouse movement

MouseDev1  anop

           jsr  MoveMouse
           jmp  PollDevLoop

* Mouse button pressed

MouseDev2  anop

           lda  MouseY
           cmp  #8-1
           bcc  MouseDev3
           cmp  LastLine
           bcs  MouseDev3

           lda  MouseX
           cmp  #23-1
           bcc  MouseDev3
           cmp  #46-1
           bcs  MouseDev3

           jsr  ChangePosn

           jmp  PollDevLoop

* Mouse button release

MouseDev3  anop

           rts

* Change pointer to a different directory

ChangePosn anop

           sec
           lda  MouseY
           sbc  #9-1                    First line
           inc  a                       Make one based
           bne  NotZero                 In case he's above the first line
           inc  a

NotZero    anop

           cmp  NumLevels               If he's pointing beyond the last line,
           bcc  InRange                 set it to the last line.
           beq  InRange

           lda  NumLevels
           cmp  #15
           beq  InRange
           inc  a

InRange    anop

           cmp  SelLine
           bne  Changed
           rts

Changed    anop

           sta  SelLine
           jsr  SetPrefix
           jsr  ShowDDL
           jsr  PlotMouse

           rts


* Keyboard routine

UpArrow    equ  $8B
DownArrow  equ  $8A
LeftArrow  equ  $88
RightArrow equ  $95
ReturnKey  equ  $8D
TabKey     equ  $89

KeyDev     anop

           stz  ClearKbd

NextKey01  anop

           cmp  #DownArrow
           beq  DA1
           cmp  #RightArrow
           beq  DA1
           bra  NextKey02

DA1        anop

           lda  NumLevels
           cmp  #15
           beq  DA2

           inc  a

DA2        anop

           cmp  SelLine
           beq  DA3

           inc  SelLine

DA3        anop

           inc  DDLRC

           rts

NextKey02  anop

           cmp  #UpArrow
           beq  UA1
           cmp  #LeftArrow
           beq  UA1
           bra  NextKey03

UA1        anop

           lda  SelLine
           cmp  #1
           beq  UA2

           dec  SelLine

UA2        anop

           inc  DDLRC

           rts

NextKey03  anop

           cmp  #ReturnKey
           bne  BadKey

           jsr  SetPrefix

           rts

BadKey     anop

           jsr  Beep
           jmp  PollDevLoop


* Set the prefix based upon line number selected.

SetPrefix  anop

           lda  NumLevels
           cmp  SelLine

           bcs  CR01

           stz  Prefix

           rts

CR01       anop

           ldx  SelLine
           lda  LevelsPosn-1,x

           sta  Prefix

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
           lda  #24-1                   HTab start
           sta  StartHTab
           adc  #22                     # char wide
           sta  EndHTab                 Ending HTab

           sec
           lda  #8-1                    Base VTab
           sta  StartVTab
           sta  CurrLine

           lda  #MessageBuf             Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #15+3                   Max # of line + 2 for borders + 1 for
*                                        being zero base.
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
