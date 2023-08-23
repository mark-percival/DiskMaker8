SameSizeRtn:

;
; Print the same-size disks only setting
;

SizeOff    =  ' '+$80                 ; Normal space
SizeOffSel =  ' '                     ; Inverse space
SizeOn     =  'D'                     ; Normal check mark
SizeOnSel  =  'E'                     ; Inverse check mark

PrtSameSize:

           lda  #42-1                 ; HTab 42
           sta  HTab
           lda  #17-1                 ; VTab 17
           sta  VTab
           jsr  SetVTab

           lda  #MouseText
           jsr  cout

           lda  TabIndex2
           cmp  #SameSize
           beq  Selected

           lda  blnSize
           beq  UnSelOff

UnSelOn:

           lda  #SizeOn
           jsr  cout
           bra  PrtExit

UnSelOff:

           lda  #SizeOff
           jsr  cout
           bra  PrtExit

Selected:

           lda  blnSize
           beq  SelOff

SelOn:

           lda  #SizeOnSel
           jsr  cout
           bra  PrtExit

SelOff:

           lda  #SizeOffSel
           jsr  cout
           bra  PrtExit

PrtExit:

           lda  #StdText
           jsr  cout

           rts

;
; Toggle same-size checkbox
;

ToggleSize:

           lda  blnSize
           beq  TurnOn

TurnOff:

           stz  blnSize
           bra  ToggleExit

TurnOn:

           inc  blnSize
           bra  ToggleExit

ToggleExit:

           jsr  PrtSameSize

           rts
