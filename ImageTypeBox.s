PrtImgType Start
           Using Menu2Vars

           lda  #19-1                   Image type display starts at
           sta  HTab                    HTab 19.

           lda  ImageType               Setup index for text address retrieval
           asl  a
           tax
           lda  TypeIndex,x             Get address of image type text
           sta  Ptr1
           inx
           lda  TypeIndex,x
           sta  Ptr1+1

           ldy  #0

IT01       anop

           lda  (Ptr1),y
           beq  IT02
           jsr  cout
           iny
           bra  IT01

IT02       anop

           cpy  #20
           beq  IT04

           sty  NextChar

           sec
           lda  #20
           sbc  NextChar
           tax
           lda  #' '+$80

IT03       anop

           jsr  cout
           dex
           bne  IT03

IT04       anop

           rts

NextChar   ds   1
InitImgType ds  1

TypeIndex  dc   i'Type0',i'Type1',i'Type2',i'Type3',i'Type4'
TypeMax    equ  $04

           Msb  On
Type0      dc   c'Universal Disk (2MG)',h'00'
Type1      dc   c'DiskCopy 4.2',h'00'
Type2      dc   c'DiskCopy 6',h'00'
Type3      dc   c'ProDOS Order (PO)',h'00'
Type4      dc   c'DOS Order (DSK/DO)',h'00'
           Msb  Off

*
* SelImgType : User selection of image type
*

SelImgType Entry

           lda  ImageType
           sta  InitImgType

           jsr  SaveScreen

Loop1      anop

           jsr  ShowBox
           jsr  BoxUI

           lda  BoxRC
           bne  Loop1

           jsr  RestScreen

           jsr  PlotMouse               Refresh mouse data

           lda  #17-1
           sta  VTab
           jsr  SetVTab

           lda  #Inverse
           jsr  cout

           jsr  PrtImgType

           lda  #Normal
           jsr  cout

           rts

* Open image type box

FirstLine  ds   1
LastLine   ds   1

ShowBox    anop

           lda  #MouseText              Set mousetext on
           jsr  cout

           lda  #17-1                   HTab 17
           sta  HTab
           sec
           lda  #16-1                   VTab 16 base.
           sbc  InitImgType
           sta  FirstLine
           inc  FirstLine               Save VTab of first line
           sta  VTab
           jsr  SetVTab

           clc
           lda  FirstLine
           adc  #TypeMax+1
           sta  LastLine                Save VTab of last line

SB01       anop

           lda  #'Z'
           jsr  cout

SB02       anop

           lda  #'L'

SB03       anop

           ldx  #22

SB04       anop

           jsr  cout
           dex
           bne  SB04

           lda  #'_'
           jsr  cout

           stz  LineCount

SB05       anop

           lda  #17-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #StdText
           jsr  cout

           lda  LineCount
           cmp  ImageType
           bne  SB06

           lda  #Inverse
           jsr  cout

SB06       anop

           lda  ImageType
           pha
           lda  LineCount
           sta  ImageType

           jsr  PrtImgType

           pla
           sta  ImageType

           lda  #Normal
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'_'
           jsr  cout

           inc  LineCount
           lda  LineCount
           cmp  #TypeMax+1
           bne  SB05

           lda  #17-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

SB07       anop

           lda  #'Z'
           jsr  cout

SB08       anop

           lda  #'_'+$80

SB09       anop

           ldx  #22

SB10       anop

           jsr  cout
           dex
           bne  SB10

           lda  #'_'
           jsr  cout

           lda  #StdText
           jsr  cout

           rts

LineCount  ds   1

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
           lda  #17-1                   HTab 17 start
           sta  StartHTab
           adc  #24                     24 char wide
           sta  EndHTab                 Ending HTab

           sec
           lda  #16-1                   Base VTab
           sbc  InitImgType
           sta  StartVTab
           sta  CurrLine

           lda  #MessageBuf             Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #TypeMax+3              Max # of line + 2 for borders + 1 for
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

*
* BoxUI - User interface
*

BoxUI      anop

           stz  ClearKbd
           stz  BoxRC

PollDev    anop

           jsr  PlotMouse

PollDevLoop anop

           lda  Keyboard                Get keypress
           bpl  PollMouse               No, keypress - check mouse
           jmp  KeyDev                  Keypress rtn.

PollMouse  anop

           jsr  ReadMouse               Read mouse
           lsr  MouseX                  Divide by 2 X and Y to bring into the
           lsr  MouseY                  0 to 79 and 0 to 23 range
           lda  MouseStat               Get mouse status
           bit  #MouseMove              Test for mouse movement
           bne  MouseDev1               Moused moved
           bit  #CurrButton             Test for button press
           bne  MouseDev2               Button pressed
           bit  #PrevButton             Test for button release
           bne  MouseDev3               Button released

           bra  PollDevLoop

*
* Mouse movement
*

MouseDev1  anop

           jsr  MoveMouse
           jmp  PollDevLoop

*
* Mouse button pressed
*

MouseDev2  anop

           lda  MouseY
           cmp  FirstLine
           bcc  MouseDev3
           cmp  LastLine
           bcs  MouseDev3

           lda  MouseX
           cmp  #19-1
           bcc  MouseDev3
           cmp  #39-1
           bcs  MouseDev3

           jsr  ChangeType

           jmp  PollDevLoop

*
* Mouse button released
*

MouseDev3  anop

           rts

*
* Change image type via mouse movement
*

ChangeType anop

           sec
           lda  MouseY
           sbc  FirstLine
           cmp  ImageType
           bne  Changed
           rts

Changed    anop

           sta  ImageType
           jsr  ShowBox
           jsr  PlotMouse

           rts

*
* Keyboard key press routine
*

UpArrow    equ  $8B
DownArrow  equ  $8A
LeftArrow  equ  $88
RightArrow equ  $95
ReturnKey  equ  $8D
TabKey     equ  $89

BoxRC      ds   1

KeyDev     anop

           stz  ClearKbd

* Down / right arrow keypress logic

NextKey01  anop

           cmp  #DownArrow              Down arrow?
           beq  DA1
           cmp  #RightArrow
           beq  DA1
           bra  NextKey02

DA1        anop

           lda  ImageType
           cmp  #TypeMax
           bcs  DA2

           inc  ImageType

DA2        anop

           lda  #1
           sta  BoxRC

           rts

NextKey02  anop

           cmp  #UpArrow                Up arrow?
           beq  UA1
           cmp  #LeftArrow
           beq  UA1
           bra  NextKey03

UA1        anop

           lda  ImageType
           beq  UA2

           dec  ImageType

UA2        anop

           lda  #1
           sta  BoxRC

           rts

NextKey03  anop

           cmp  #ReturnKey              <cr>
           bne  BadKey

           rts

BadKey     anop

           jsr  Beep
           jmp  PollDevLoop

           End
