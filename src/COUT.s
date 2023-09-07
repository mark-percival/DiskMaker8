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
           lda  CO_TextLine,x
           sta  TextPtr
           inx
           lda  CO_TextLine,x
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

CO_TextLine:                            ; Text screen line starting addresses

CO_TextLine00: .addr $0400
CO_TextLine01: .addr $0480
CO_TextLine02: .addr $0500
CO_TextLine03: .addr $0580
CO_TextLine04: .addr $0600
CO_TextLine05: .addr $0680
CO_TextLine06: .addr $0700
CO_TextLine07: .addr $0780
CO_TextLine08: .addr $0428
CO_TextLine09: .addr $04A8
CO_TextLine10: .addr $0528
CO_TextLine11: .addr $05A8
CO_TextLine12: .addr $0628
CO_TextLine13: .addr $06A8
CO_TextLine14: .addr $0728
CO_TextLine15: .addr $07A8
CO_TextLine16: .addr $0450
CO_TextLine17: .addr $04D0
CO_TextLine18: .addr $0550
CO_TextLine19: .addr $05D0
CO_TextLine20: .addr $0650
CO_TextLine21: .addr $06D0
CO_TextLine22: .addr $0750
CO_TextLine23: .addr $07D0

; Dummy routine to replace unneeded monitor routine

SetVTab:

           rts

SetInv:

           lda  #SetInverse
           jmp  cout


SetNorm:

           lda  #SetNormal
           jmp  cout


