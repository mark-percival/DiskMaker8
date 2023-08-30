;
; Check system to ensure it meets program requirements:
; - 128K Enhanced Apple IIe
; - Apple IIc
; - Apple IIc plus
; - Apple IIgs (any ROM version)
;

SystemCheck:

Ptr         =  $06
;HTab       =  $24
;VTab       =  $25

; Processor check

           ldy  #$00
           sed
           lda  #$99
           clc
           adc  #$01
           cld
           bmi  SCError                 ; 6502 test

; ROM Check

           ldy  #$01

           lda  $FBB3
           cmp  #$06
           bne  SCError                 ; Apple II/II plus test

           lda  $FBC0
           cmp  #$EA
           beq  SCError                 ; Unenhanced Apple IIe test

; Memory Check

           ldy  #$02
           lda  $BF98                 ; MachID from ProDOS
           and  #%00110000            ; 128K?
           cmp  #%00110000
           bne  SCError                ; No aux RAM

           clc                        ; Passed tests

           rts

SCError:

           sty  YSave

           jsr  Home                  ; Clear screen

           lda  #11-1
           sta  VTab
           lda  #$00
           sta  HTab

           jsr  SetVTab

           ldx  #$00

E1Loop:

           lda  Line1,x
           beq  Part2
           jsr  cout_orig
           inx
           bne  E1Loop                ; Always taken

Part2:

           inc  VTab
           inc  VTab
           lda  #$00
           sta  HTab

           jsr  SetVTab

           ldy  YSave

           cpy  #$00
           beq  SCErrorA
           cpy  #$01
           beq  SCErrorB
           bne  SCErrorC

SCErrorA:

           lda  #<Line2a
           sta  Ptr
           lda  #>Line2a
           sta  Ptr+1
           jmp  Write2

SCErrorB:

           lda  #<Line2b
           sta  Ptr
           lda  #>Line2b
           sta  Ptr+1
           jmp  Write2

SCErrorC:

           lda  #<Line2c
           sta  Ptr
           lda  #>Line2c
           sta  Ptr+1

Write2:

           ldy  #$00

E2Loop:

           lda  (Ptr),y
           beq  SCErrorExit
           jsr  cout_orig
           iny
           bne  E2Loop

SCErrorExit:

           sta  ClearKbd              ; Keyboard pause

KeyLoop:   lda  Keyboard
           bpl  KeyLoop

           sta  ClearKbd

           sec

           rts

YSave:     .byte   $00

Line1:     ascz "REQUIRES 128K ENHANCED IIE, IIC OR IIGS"
Line2a:    ascz "PROCESSOR TEST FAILURE"
Line2b:    ascz "ROM TEST FAILURE"
Line2c:    ascz "AUX RAM TEST FAILURE"
