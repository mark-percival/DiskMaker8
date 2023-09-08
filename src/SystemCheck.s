;
; Check system to ensure it meets program requirements:
; - 128K Enhanced Apple IIe
; - Apple IIc
; - Apple IIc plus
; - Apple IIgs (any ROM version)
;

SystemCheck:



;Keyboard    =   $C000
;Clear       =   $C010
;Home        =   $FC58
;Cout        =   $FDED
;SetVTab     =   $FC22

Ptr         =   $06
;HTab        =   $24
;VTab        =   $25

; Processor check

           ldy  #$00
           sed
           lda  #$99
           clc
           adc  #$01
           cld
           bmi  @Error                  ; 6502 test

; ROM Check

           ldy  #$01

           lda  $FBB3
           cmp  #$06
           bne  @Error                  ; Apple II/II plus test

           lda  $FBC0
           cmp  #$EA
           beq  @Error                  ; Unenhanced Apple IIe test

; Memory Check

           ldy  #$02
           lda  $BF98                   ; MACHID from ProDOS
           and  #%00110000              ; 128K?
           cmp  #%00110000
           bne  @Error                  ; No aux RAM

           clc                          ; Passed tests

           rts

@Error:

           sty  YSave

           jsr  Home                    ; Clear screen

           lda  #11-1
           sta  VTab
           lda  #$00
           sta  HTab

           jsr  setvtab_rom

           ldx  #$00

E1Loop:

           lda  Line1,x
           beq  Part2
           jsr  cout_rom
           inx
           bne  E1Loop                  ; Always taken

Part2:

           inc  VTab
           inc  VTab
           lda  #$00
           sta  HTab

           jsr  setvtab_rom

           ldy  YSave

           cpy  #$00
           beq  ErrorA
           cpy  #$01
           beq  ErrorB
           bne  ErrorC

ErrorA:

           lda  #<Line2a
           sta  Ptr
           lda  #>Line2a
           sta  Ptr+1
           jmp  Write2

ErrorB:

           lda  #<Line2b
           sta  Ptr
           lda  #>Line2b
           sta  Ptr+1
           jmp  Write2

ErrorC:

           lda  #<Line2c
           sta  Ptr
           lda  #>Line2c
           sta  Ptr+1

Write2:

           ldy  #$00

E2Loop:

           lda  (Ptr),y
           beq  ErrorExit
           jsr  cout_rom
           iny
           bne  E2Loop

ErrorExit:

           sta  ClearKbd                ; Keyboard strobe

KeyLoop:   lda  Keyboard
           bpl  KeyLoop

           sta  ClearKbd

           sec

           rts

YSave:      .res 1

;          MSB  On
Line1:     ascz "REQUIRES 128K ENHANCED IIE, IIC OR IIGS"
Line2a:    ascz "PROCESSOR TEST FAILURE"
Line2b:    ascz "ROM TEST FAILURE"
Line2c:    ascz "AUX RAM TEST FAILURE"
;          MSB  Off


