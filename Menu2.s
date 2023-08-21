*
* Selecting disk image target
*

Menu2      Start
           Using Menu2Vars

           jsr  SetImgType              Look at file and set image type
           jsr  GetImgSize              Set an image size based on that type.

           jsr  PaintMenu2              Paint basic screen frame

           lda  #1
           sta  TabIndex2               Start with "Skip" as default.

Menu2_01   anop

           jsr  LoadDevs                Get device info

           jsr  Init2                   Initialize screen

Menu2_02   anop

           jsr  ListDevs                List devices 5 at a time

Menu2_03   anop

           jsr  Refresh2Btn             Refresh command buttons.

           jsr  Menu2UI                 Menu 2 user interface

           lda  RC2
           cmp  #Quit2
           beq  Menu2Exit

           cmp  #ReloadDevs
           beq  Menu2_01

           cmp  #UpdDevLst
           beq  Menu2_02

           cmp  #Nothing
           beq  Menu2_03

           jsr  ClearMenu2
           jsr  ProcessImg              He's making a disk!

           lda  RC2
           cmp  #Quit2
           beq  Menu2Exit

           jmp  Menu2

Menu2Exit  anop

           jsr  ClearMenu2              Clear screen prior to return

           rts

*
* Initialize menu2 variables
*

Init2      anop

           lda  #Buffer8K
           sta  Ptr1
           sta  FstAddr
           lda  #>Buffer8K
           sta  Ptr1+1
           sta  FstAddr+1

           stz  Above

           sec
           lda  DevEntCnt
           sbc  #5
           sta  Below
           bpl  GT5

           stz  Below

GT5        anop

           lda  #1
           sta  SelLine

           lda  #StdText
           jsr  cout

           rts

*
* List devices to screen
*

LineCount  ds   1

ListDevs   anop

           lda  #19-1
           sta  HTab
           lda  #11-1
           sta  VTab
           jsr  SetVtab

           lda  SelLine
           bne  NotUp

           jsr  ScrollUp
           bra  NoScrollDn

NotUp      anop

           cmp  #6
           bcc  NoScrollDn

           jsr  ScrollDown

NoScrollDn anop

           lda  FstAddr                 Setup first line address
           sta  Ptr1
           lda  FstAddr+1
           sta  Ptr1+1

           stz  LineCount

           lda  DevEntCnt               See if there are any lines to print.
           bne  ListDev01

           jmp  ListDev90               Nope, so exit.

ListDev01  anop

           inc  LineCount
           lda  LineCount
           cmp  SelLine
           bne  ListDev02

           lda  #Inverse
           jsr  cout

           lda  Ptr1
           sta  SelAddr
           lda  Ptr1+1
           sta  SelAddr+1

ListDev02  anop

           ldy  #oSlot
           lda  (Ptr1),y
           jsr  cout
           lda  #','+$80
           jsr  cout
           ldy  #oDrive
           lda  (Ptr1),y
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #15
           ldy  #oVolume

ListDev03  anop

           lda  (Ptr1),y
           jsr  cout
           iny
           dex
           bne  ListDev03

           lda  #' '+$80
           jsr  cout

           ldx  #4
           ldy  #oSize

ListDev04  anop

           lda  (Ptr1),y
           jsr  cout
           iny
           dex
           bne  ListDev04

           lda  #' '+$80
           jsr  cout

           ldy  #oUnit
           lda  (Ptr1),y
           jsr  cout

           lda  #Normal
           jsr  cout

           lda  #19-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  LineCount
           cmp  #5                      5 lines max per screen
           beq  ListDev99
           cmp  DevEntCnt               End of screen with < 5 lines?
           beq  ListDev90

           clc
           lda  Ptr1
           adc  #oEntryLen
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1
           jmp  ListDev01

ListDev90  anop

           sec                          Calculate blank lines required.
           lda  #5
           sbc  LineCount
           tax
           beq  ListDev99               No blank lines required.

ListDev92  anop                         Each line

           lda  #' '+$80                Space character
           ldy  #26                     Spaces per line

ListDev94  anop                         Each character in line

           jsr  cout
           dey
           bne  ListDev94

           lda  #19-1                   Set back to start of next line
           sta  HTab
           inc  VTab
           jsr  SetVTab

           dex                          More lines to wipt out?
           bne  ListDev92

ListDev99  anop

           rts

*
* Move dev pointer to next dev
*

ScrollDown anop

           lda  #5
           sta  SelLine

           inc  Above
           dec  Below

           clc
           lda  FstAddr
           adc  #oEntryLen
           sta  FstAddr
           lda  FstAddr+1
           adc  #0
           sta  FstAddr+1

           rts

*
* Move dev pointer to previous entry
*

ScrollUp   anop

           lda  #1
           sta  SelLine

           dec  Above
           inc  Below

           sec
           lda  FstAddr
           sbc  #oEntryLen
           sta  FstAddr
           lda  FstAddr+1
           sbc  #0
           sta  FstAddr+1

           rts

*
* Refresh command buttons based on TabIndex2 setting
*

Refresh2Btn Entry

           lda  #M2BtnText              Set button text address in Ptr1
           sta  Ptr1
           lda  #>M2BtnText
           sta  Ptr1+1

           lda  #Normal                 Make sure inverse is off
           jsr  cout
           lda  #StdText                Mousetext off
           jsr  cout

           ldx  #0                      Index

Refresh01  anop

           cpx  TabIndex2               Is this our active button?
           bne  Refresh02               No so print it normal

           lda  #Inverse                Inverse button
           jsr  cout

Refresh02  anop

           phx                          Save current button

           lda  #51-1
           sta  HTab                    HTab 51
           lda  (Ptr1)                  VTab from table
           sta  VTab
           jsr  SetVTab

           ldy  #1                      Starting position index
           ldx  #11                     Text length index

Refresh03  anop

           lda  (Ptr1),y                Get character
           jsr  cout                    Print
           iny                          Move to next character
           dex                          Count it as printed
           bne  Refresh03               More?

           lda  #Normal                 Reset to normal text
           jsr  cout

           plx                          Get index from stack
           inx                          Move to next button
           cpx  #3                      Button 3?  We're done...
           beq  Refresh05

           clc                          Add 12 to button text pointer
           lda  Ptr1                    to setup next button print.
           adc  #12
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1
           bra  Refresh01               Print next button.

Refresh05  anop

           cpx  TabIndex2
           bne  Refresh06

           lda  #Inverse
           jsr  Cout

Refresh06  anop

           lda  #17-1
           sta  VTab
           jsr  SetVTab
           jsr  PrtImgType
           lda  #Normal
           jsr  cout

Refresh07  anop

           jsr  PrtSameSize

Refresh99  anop

           rts

*
* Get Disk Image Size
*

GetImgSize Entry

           stz  ImageSize
           stz  ImageSize+1

           lda  ImageType

           cmp  #Type_2IMG              2IMG check.
           beq  T_2Img

           cmp  #Type_DC                Diskcopy 4.2 check.
           beq  T_DC

           cmp  #Type_DC6               Diskcopy 6 check
           beq  T_DC6

           cmp  #Type_PO                ProDOS Order check
           beq  T_PO

           bra  T_DO                    Assume DOS Order if it got here.

T_2Img     anop                         2IMG image

*          Use header for image size

           jsr  MLIOpen1
           lda  openRef1
           sta  setMarkRef
           sta  readRef
           sta  closeRef

           lda  #$14                    Image size offset
           sta  setMarkPos
           stz  setMarkPos+1
           stz  setMarkPos+2

           jsr  MLISetMark

           lda  #4                      Bytes to read
           sta  readRequest
           stz  readRequest+1

           jsr  MLIRead

           jsr  MLIClose

           lda  readBuf
           sta  ImageSize
           lda  readBuf+1
           sta  ImageSize+1

           rts

T_DC       anop                         Diskcopy 4.2 image

*          Use header for image size

           jsr  MLIOpen1
           lda  openRef1
           sta  setMarkRef
           sta  readRef
           sta  closeRef

           lda  #64                     Image size offset
           sta  setMarkPos
           stz  setMarkPos+1
           stz  setMarkPos+2

           jsr  MLISetMark

           lda  #4                      Bytes to read
           sta  readRequest
           stz  readRequest+1

           jsr  MLIRead

           jsr  MLIClose

*          Convert from image size in bytes to blocks.

           lda  readBuf+2
           sta  ImageSize
           lda  readBuf+1
           sta  ImageSize+1

           lsr  ImageSize+1
           ror  ImageSize

           rts

T_DC6      anop                         Diskcopy 6 image

*          Get image size from file size.

           jsr  GetFileSize

           rts

T_PO       anop                         ProDOS Order image

*          Get image size from file size.

           jsr  GetFileSize

           rts

T_DO       anop                         DOS Order image

*          Get image size from file size.

           jsr  GetFileSize

           rts

* Call MLIGetEOF the retrieve file size

GetFileSize anop

           jsr  MLIOpen1
           lda  openRef1
           sta  geteofRef
           sta  closeRef
           jsr  MLIGetEOF
           jsr  MLIClose

           lda  geteofEOF+1
           sta  ImageSize
           lda  geteofEOF+2
           sta  ImageSize+1

           lsr  ImageSize
           ror  ImageSize+1

           rts

           End
