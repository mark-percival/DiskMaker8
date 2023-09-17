cout:

;
; Custom COUT - Mark Percival
;

; Step 1 - Process Special Characters

           pha
           sta  Character
           cmp  #SetInverse
           bne  CO1
           lda  Flags
           ora  #InvOn
           sta  Flags
           pla
           rts

CO1:

           cmp  #SetNormal
           bne  CO2
           lda  Flags
           and  #InvOff
           sta  Flags
           pla
           rts

CO2:

           cmp  #SetMouseTxt
           bne  CO3
           lda  Flags
           ora  #MouseOn
           sta  Flags
           pla
           rts

CO3:

           cmp  #SetStdTxt
           bne  CO4
           lda  Flags
           and  #MouseOff
           sta  Flags
           pla
           rts

; Step 2 - Character Conversion

CO4:

           lda  Flags
           bit  #InvOn
           beq  CO5
           lda  Character
           and  #$7F
           sta  Character

CO5:

           lda  Flags
           bit  #MouseOn
           bne  CO6
           lda  Character
           cmp  #$40
           bcc  CO6
           cmp  #$60
           bcs  CO6
           sec
           sbc  #$40
           sta  Character

; Step 3 - Print Character

CO6:

           phx
           phy

           sta  On80Store
           lda  VTab
           asl  a
           tax
           lda  TextLine,x
           sta  TextPtr
           inx
           lda  TextLine,x
           sta  TextPtr+1

           lda  HTab
           lsr  a
           tay
           bcs  MainRAM

AuxRAM:

           sta  Page2
           bra  PrtChar

MainRAM:

           sta  Page1

PrtChar:

           lda  Character
           sta  (TextPtr),y

           sta  Page1

           ply
           plx

           lda  HTab
           inc  a
           cmp  #80
           bcc  Less80

           stz  HTab
           inc  VTab
           bra  COExit

Less80:

           sta  HTab

COExit:

           pla

           rts

Character:  .res 1
Flags:      .byte $00
InvOn       =   %00000001
InvOff      =   %11111110
MouseOn     =   %00000010
MouseOff    =   %11111101

;On80Store   =   $C001
;Page1       =   $C054
;Page2       =   $C055

SetInverse  =   $0F
SetNormal   =   $0E
SetMouseTxt  =  $1B
SetStdTxt   =   $18

; Dummy routine to replace unneeded monitor routine

SetVTab:

           rts

SetInv:

           lda  #SetInverse
           jmp  cout


SetNorm:

           lda  #SetNormal
           jmp  cout


