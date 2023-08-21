* Put message box on screen

DisplayBox anop

* VTab 10

           lda  #10-1
           sta  VTab
           lda  StartHTab
           sta  HTab
           jsr  SetVTab

           lda  #MouseText
           jsr  cout

           lda  #'Z'
           jsr  cout

           lda  BoxWidth
           dec  a
           dec  a
           tax

           lda  #' '

Line10a    anop

           jsr  cout
           dex
           bne  Line10a

           lda  #'_'
           jsr  cout

* VTab 11

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  BoxWidth
           dec  a
           dec  a
           tax

           lda  #' '+$80

Line11a    anop

           jsr  cout
           dex
           bne  Line11a

           lda  #'_'
           jsr  cout

* VTab 12

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #'='+$80
           jsr  cout

           lda  #'\'+$80
           jsr  cout

           ldx  #3
           lda  #' '+$80

Line12a    anop

           jsr  cout
           dex
           bne  Line12a

           ldx  #3
           lda  #'_'+$80

Line12b    anop

           jsr  cout
           dex
           bne  Line12b

           lda  #' '+$80
           jsr  cout
           jsr  cout

           ldy  #0                      Message index
           ldx  #0

Line12c    anop

           lda  (MsgPtr),y
           beq  Line12d
           cmp  #$0D
           beq  Line12d
           ora  #$80
           jsr  cout
           iny
           inx
           bra  Line12c

Line12d    anop

           stx  TempSave
           sec
           lda  MsgWidth
           sbc  TempSave

           tax
           inx
           inx
           lda  #' '+$80

Line12e    anop

           jsr  cout
           dex
           bne  Line12e

           lda  #'_'
           jsr  cout

* VTab 13

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'o'+$80
           jsr  cout

           lda  #'_'
           jsr  cout

           lda  #' '+$80
           jsr  cout
           jsr  cout

           lda  #'_'
           jsr  cout

           lda  #'?'+$80
           jsr  cout

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout
           jsr  cout

           ldx  #0
           lda  (MsgPtr),y
           beq  Line13b

           iny

Line13a    anop

           lda  (MsgPtr),y
           beq  Line13b
           cmp  #$0D
           beq  Line13a1

           ora  #$80
           jsr  cout
           inx

Line13a1   anop

           iny
           bra  Line13a

Line13b    anop

           stx  TempSave
           sec
           lda  MsgWidth
           sbc  TempSave

           tax
           inx
           inx
           lda  #' '+$80

Line13c    anop

           jsr  cout
           dex
           bne  Line13c

           lda  #'_'
           jsr  cout

* VTab 14

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'I'
           jsr  cout

           lda  #'Y'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'/'+$80
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'!'+$80
           jsr  cout

           lda  #'Z'
           jsr  cout

           sec                          Setup for subtraction
           lda  MsgWidth                A = MsgWidth - MinMsg  (= extra chars)
           sbc  MinMsg
           lsr  a                       Divide by 2 to center
           inc  a                       Add 2 for extra spaces in layout
           inc  a

Line14a    anop

           tax                          Move to index
           lda  #' '+$80

Line14b    anop

           jsr  cout
           dex
           bne  Line14b

           ldx  #10
           lda  #'_'+$80

Line14c    anop

           jsr  cout
           dex
           bne  Line14c

           ldx  Mode
           cpx  #ModeOk
           beq  Line14f

           ldx  #3
           lda  #' '+$80

Line14d    anop

           jsr  cout
           dex
           bne  Line14d

           ldx  #10
           lda  #'_'+$80

Line14e    anop

           jsr  cout
           dex
           bne  Line14e

Line14f    anop

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           bcc  Line14g

           inc  a

Line14g    anop


Line14h    anop

           tax
           inx
           inx
           lda  #' '+$80

Line14i    anop

           jsr  cout
           dex
           bne  Line14i

           lda  #'_'
           jsr  cout

* HTab 15

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'M'
           jsr  cout

           lda  #' '+$80
           jsr  cout
           jsr  cout

           ldx  #4
           lda  #'L'

Line15a    anop

           jsr  cout
           dex
           bne  Line15a

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a

           tax

           clc                          Calculate HTab positions for buttons.
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

Line15b    anop

           jsr  cout
           dex
           bne  Line15b

           lda  #'Z'
           jsr  cout

           lda  #' '
           jsr  cout

           ldx  #8
           ldy  #0

Line15c    anop

           lda  B1Text,y
           jsr  cout
           iny
           dex
           bne  Line15c

           lda  #' '
           jsr  cout

           lda  #'_'
           jsr  cout

           ldx  Mode
           cpx  #ModeOk
           beq  Line15d1

           lda  #' '+$80
           jsr  cout

           lda  #'Z'
           jsr  cout

           lda  #' '
           jsr  cout

           ldx  #8
           ldy  #0

Line15d    anop

           lda  B2Text,y
           jsr  cout
           iny
           dex
           bne  Line15d

           lda  #' '
           jsr  cout

           lda  #'_'
           jsr  cout

Line15d1   anop

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           tax
           bcc  Line15e

           inx

Line15e    anop

           inx
           lda  #' '+$80

Line15f    anop

           jsr  cout
           dex
           bne  Line15f

           lda  #'_'
           jsr  cout

* HTab 16

           lda  StartHTab
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           clc
           adc  #10
           tax
           lda  #'_'+$80

Line16a    anop

           jsr  cout
           dex
           bne  Line16a

           ldx  #10
           lda  #'\'

Line16b    anop

           jsr  cout
           dex
           bne  Line16b

           ldx  Mode
           cpx  #ModeOk
           beq  Line16d1

           ldx  #3
           lda  #'_'+$80

Line16c    anop

           jsr  cout
           dex
           bne  Line16c

           ldx  #10
           lda  #'\'

Line16d    anop

           jsr  cout
           dex
           bne  Line16d

Line16d1   anop

           sec
           lda  MsgWidth
           sbc  MinMsg
           lsr  a
           tax
           bcc  Line16e

           inx

Line16e    anop

           inx
           inx
           lda  #'_'+$80

Line16f    anop

           jsr  cout
           dex
           bne  Line16f

           lda  #'_'
           jsr  cout

           rts

TextLine   anop                         Text screen line starting addresses

TextLine09 dc   i'$04A8'                1st message box line
TextLine10 dc   i'$0528'                2nd message box line
TextLine11 dc   i'$05A8'                3rd message box line
TextLine12 dc   i'$0628'                4th message box line
TextLine13 dc   i'$06A8'                5th message box line
TextLine14 dc   i'$0728'                6th message box line
TextLine15 dc   i'$07A8'                7th message box line

EndHTab    ds   1
SaveRtn    ds   1

On80Store  equ  $C001
Page1      equ  $C054
Page2      equ  $C055

*
* SaveScreen - Save screen data under message box.
* RestScreen - Restore screen data under message box.
*
* Ptr1 = screen data address : Ptr2 = Save buffer address
*

SaveScreen anop

           lda  #1
           sta  SaveRtn
           bra  StartRtn

RestScreen anop

           stz  SaveRtn

StartRtn   anop

           sta  On80Store               Make sure 80STORE is on.

           clc                          Calculate ending HTab
           lda  StartHTab
           adc  BoxWidth
           dec  a
           sta  EndHTab

           lda  #MessageBuf             Set save buffer address in Ptr2
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #7                      7 lines to save

SSLoop1    anop

           txa                          Copy lines to save to accumulator
           dec  a                       Subtract one to make it a 0 - 6 number
           asl  a                       Multiply by two for address table index
           tay                          Move to index
           lda  TextLine,y              Get line number starting address and
           sta  Ptr1                    put it in Ptr1.
           iny
           lda  TextLine,y
           sta  Ptr1+1

           ldy  StartHTab

SSLoop2    anop

           phy                          Push HTab to stack.
           tya                          Put HTab into accumulator
           lsr  a                       Divide by 2 for index
           bcs  FromMain                A remainder then get char from main mem.

FromAux    anop

           sta  Page2                   Set access to aux memory
           bra  GetChar

FromMain   anop

           sta  Page1                   Set access to main memory

GetChar    anop

           tay                          Move index value to y register
           lda  SaveRtn                 Is this a save or restore?
           beq  Restore                 If SaveRtn = 0 then we're restoring

           lda  (Ptr1),y                Get character from screen
           sta  (Ptr2)                  Save to buffer area
           bra  Continue

Restore    lda  (Ptr2)                  Get character from buffer area
           sta  (Ptr1),y                Restore back to screen area

Continue   anop

           ply                          Get HTab from stack

           inc  Ptr2                    Bump up save buffer address
           bne  NoOF                    If Ptr2 = 0 then add 1 to Ptr2+1

           inc  Ptr2+1

NoOF       anop                         No overflow label

           iny                          Add 1 to HTab
           cpy  EndHTab                 Compare to ending HTab
           bcc  SSLoop2                 < or
           beq  SSLoop2                   = y register process next character.

           dex                          More lines to process?
           bne  SSLoop1                 Yes

           lda  Page1                   Set back main memory access prior to rts

           rts

*
* RefreshBtn - Redraw command buttons with selected button highlighted
*

RefreshBtn anop

           lda  #15-1
           sta  VTab
           lda  B1HTabS
           sta  HTab
           jsr  SetVTab

           lda  #StdText
           jsr  cout

           lda  TabIndex
           cmp  #Button1
           beq  B1Selected

           lda  #Normal
           jsr  cout
           bra  PrtB1

B1Selected anop

           lda  #Inverse
           jsr  cout

PrtB1      anop

           ldx  #8
           ldy  #0

PrtLoop1   anop

           lda  B1Text,y
           jsr  cout
           iny
           dex
           bne  PrtLoop1

           lda  Mode
           cmp  #ModeOk
           beq  PrtExit

           lda  B2HTabS
           sta  HTab
           jsr  SetVTab

           lda  TabIndex
           cmp  #Button2
           beq  B2Selected

           lda  #Normal
           jsr  cout
           bra  PrtB2

B2Selected anop

           lda  #Inverse
           jsr  cout

PrtB2      anop

           ldx  #8
           ldy  #0

PrtLoop2   anop

           lda  B2Text,y
           jsr  cout
           iny
           dex
           bne  PrtLoop2

PrtExit    anop

           lda  #Normal
           jsr  cout

           rts
