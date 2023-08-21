*
* Check system to ensure it meets program requirements:
* - 128K Enhanced Apple IIe
* - Apple IIc
* - Apple IIc plus
* - Apple IIgs (any ROM version)
*

SystemCheck Start

Keyboard   equ  $C000
Clear      equ  $C010
Home       equ  $FC58
Cout       equ  $FDED
SetVTab    equ  $FC22

Ptr        equ  $06
HTab       equ  $24
VTab       equ  $25

* Processor check

           ldy  #$00
           sed
           lda  #$99
           clc
           adc  #$01
           cld
           bmi  Error                   6502 test

* ROM Check

           ldy  #$01

           lda  $FBB3
           cmp  #$06
           bne  Error                   Apple II/II plus test

           lda  $FBC0
           cmp  #$EA
           beq  Error                   Unenhanced Apple IIe test

* Memory Check

           ldy  #$02
           lda  $BF98                   MACHID from ProDOS
           and  #%00110000              128K?
           cmp  #%00110000
           bne  Error                   No aux RAM

           clc                          Passed tests

           rts

Error      anop

           sty  YSave

           jsr  Home                    Clear screen

           lda  #11-1
           sta  VTab
           lda  #$00
           sta  HTab

           jsr  SetVTab

           ldx  #$00

E1Loop     anop

           lda  Line1,x
           beq  Part2
           jsr  Cout
           inx
           bne  E1Loop                  Always taken

Part2      anop

           inc  VTab
           inc  VTab
           lda  #$00
           sta  HTab

           jsr  SetVTab

           ldy  YSave

           cpy  #$00
           beq  ErrorA
           cpy  #$01
           beq  ErrorB
           bne  ErrorC

ErrorA     anop

           lda  #Line2a
           sta  Ptr
           lda  #>Line2a
           sta  Ptr+1
           jmp  Write2

ErrorB     anop

           lda  #Line2b
           sta  Ptr
           lda  #>Line2b
           sta  Ptr+1
           jmp  Write2

ErrorC     anop

           lda  #Line2c
           sta  Ptr
           lda  #>Line2c
           sta  Ptr+1

Write2     anop

           ldy  #$00

E2Loop     anop

           lda  (Ptr),y
           beq  ErrorExit
           jsr  Cout
           iny
           bne  E2Loop

ErrorExit  anop

           sta  Clear                   Keyboard pause

KeyLoop    lda  Keyboard
           bpl  KeyLoop

           sta  Clear

           sec

           rts

YSave      ds   1

           MSB  On
Line1      dc   c'REQUIRES 128K ENHANCED IIE, IIC OR IIGS',h'00'
Line2a     dc   c'PROCESSOR TEST FAILURE',h'00'
Line2b     dc   c'ROM TEST FAILURE',h'00'
Line2c     dc   c'AUX RAM TEST FAILURE',h'00'
           MSB  Off

           End
