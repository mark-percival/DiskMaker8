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
           jsr  cout_mark

           lda  TabIndex_M2
           cmp  #SameSize
           beq  Selected

           lda  blnSize_M2
           beq  UnSelOff

UnSelOn:

           lda  #SizeOn
           jsr  cout_mark
           bra  PrtExit

UnSelOff:

           lda  #SizeOff
           jsr  cout_mark
           bra  PrtExit

Selected:

           lda  blnSize_M2
           beq  SelOff

SelOn:

           lda  #SizeOnSel
           jsr  cout_mark
           bra  PrtExit

SelOff:

           lda  #SizeOffSel
           jsr  cout_mark
           bra  PrtExit

PrtExit:

           lda  #StdText
           jsr  cout_mark

           rts

;
; Toggle same-size checkbox
;

ToggleSize:

           lda  blnSize_M2
           beq  TurnOn

TurnOff:

           stz  blnSize_M2
           bra  ToggleExit

TurnOn:

           inc  blnSize_M2
           bra  ToggleExit

ToggleExit:

           jsr  PrtSameSize

           rts
