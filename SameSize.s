SameSizeRtn Start
           using Menu2vars

*
* Print the same-size disks only setting
*

SizeOff    equ  ' '+$80                 Normal space
SizeOffSel equ  ' '                     Inverse space
SizeOn     equ  'D'                     Normal check mark
SizeOnSel  equ  'E'                     Inverse check mark

PrtSameSize Entry

           lda  #42-1                   HTab 42
           sta  HTab
           lda  #17-1                   VTab 17
           sta  VTab
           jsr  SetVTab

           lda  #MouseText
           jsr  cout

           lda  TabIndex2
           cmp  #SameSize
           beq  Selected

           lda  blnSize
           beq  UnselOff

UnSelOn    anop

           lda  #SizeOn
           jsr  cout
           bra  PrtExit

UnSelOff   anop

           lda  #SizeOff
           jsr  cout
           bra  PrtExit

Selected   anop

           lda  blnSize
           beq  SelOff

SelOn      anop

           lda  #SizeOnSel
           jsr  cout
           bra  PrtExit

SelOff     anop

           lda  #SizeOffSel
           jsr  cout
           bra  PrtExit

PrtExit    anop

           lda  #StdText
           jsr  cout

           rts

*
* Toggle same-size checkbox
*

ToggleSize Entry

           lda  blnSize
           beq  TurnOn

TurnOff    anop

           stz  blnSize
           bra  ToggleExit

TurnOn     anop

           inc  blnSize
           bra  ToggleExit

ToggleExit anop

           jsr  PrtSameSize

           rts

           End
