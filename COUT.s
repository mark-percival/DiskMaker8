cout       Start

*
* Custom COUT - Mark Percival
*

* Step 1 - Process Special Characters

           pha
           sta  Character
           cmp  #SetInverse
           bne  CO1
           lda  Flags
           ora  #InvOn
           sta  Flags
           pla
           rts

CO1        anop

           cmp  #SetNormal
           bne  CO2
           lda  Flags
           and  #InvOff
           sta  Flags
           pla
           rts

CO2        anop

           cmp  #SetMouseTxt
           bne  CO3
           lda  Flags
           ora  #MouseOn
           sta  Flags
           pla
           rts

CO3        anop

           cmp  #SetStdTxt
           bne  CO4
           lda  Flags
           and  #MouseOff
           sta  Flags
           pla
           rts

* Step 2 - Character Conversion

CO4        anop

           lda  Flags
           bit  #InvOn
           beq  CO5
           lda  Character
           and  #$7F
           sta  Character

CO5        anop

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

* Step 3 - Print Character

CO6        anop

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

AuxRAM     anop

           sta  Page2
           bra  PrtChar

MainRAM    anop

           sta  Page1

PrtChar    anop

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

Less80     anop

           sta  HTab

COExit     anop

           pla

           rts

Character  ds   1
Flags      dc   h'00'
InvOn      equ  %00000001
InvOff     equ  %11111110
MouseOn    equ  %00000010
MouseOff   equ  %11111101

On80Store  equ  $C001
Page1      equ  $C054
Page2      equ  $C055

SetInverse equ  $0F
SetNormal  equ  $0E
SetMouseTxt equ $1B
SetStdTxt  equ  $18

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

* Dummy routine to replace unneeded monitor routine

SetVTab    Entry

           rts

SetInv     Entry

           lda  #SetInverse
           jmp  cout


SetNorm    Entry

           lda  #SetNormal
           jmp  cout

           End
