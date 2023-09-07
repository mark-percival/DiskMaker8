;
; ID Apple IIe System
; ===================
;
; $3CF (Return Value)
; -------------------
; $00 (0)    = not an Apple IIe
; $20 (32)   = Apple IIe but no Apple IIe 80-Column Text Card
; $40 (64)   = Apple IIe with 80-Column Text Card without auxilliary memory
; $80 (128)  = Apple IIe with Extended 80-Column Text Card
;

;          org  $2D4

SysID:

Param       =   $3CF
Safe        =   $0001                   ; Start of code relocation on page zero
Save        =   $2D0                    ; Start of four byte language card ID
           php                          ; Disable interrupts
           sei
           lda  $E000                   ; Save 4 bytes from
           sta  Save                    ; ROMRAM area for later
           lda  $D000                   ; restoring of RAMROM
           sta  Save+1                  ; to original condition
           lda  $D400
           sta  Save+2
           lda  $D800
           sta  Save+3
           lda  $C081                   ; Ensure reading ROM by turning off
           lda  $C081                   ; bankable mem.
           lda  $FBB3                   ; Get Apple II signature byte
           cmp  #$06
           bne  out1                    ; If not #6 then not AppleIIe
           lda  $C017                   ; Was 80 columns found during startup
           bmi  out2                    ; If hi bit on then no 80 column card
           lda  $C013                   ; See if aux memory being read
           bmi  out4                    ; Aux mem being used so aux mem avail.
           lda  $C016                   ; See if aux zp being used.
           bmi  out4                    ; Aux zp being used so aux mem avail.
           ldy  #SI_Done-SI_Start       ; Not sure yet so keep checking.
mv:        ldx  SI_Start-1,y            ; Swap section of zp with
           lda  Safe-1,y                ; code needing safe location curing
           stx  Safe-1,y                ; read aux mem
           sta  SI_Start-1,y
           dey
           bne  mv
           jmp  Safe                    ; Jump to safe ground
On:        php                          ; Back from safe ground, save status
           ldy  #SI_Done-SI_Start       ; Move zero page back
mv2:       lda  SI_Start-1,y
           sta  SI_Safe-1,y
           dey
           bne  mv2
           pla                          ; Get back status
           bcs  out3                    ; Carry set so no aux mem
out4:      lda  #$80                    ; Made it so there is aux mem set
           sta  Param                   ; Param=$80
           jmp  out
out3:      lda  #$40                    ; 80 columns but no aux so set
           sta  Param                   ; Param=$40
           jmp  out
out2:      lda  #$20                    ; Apple IIe but no card so set
           sta  Param                   ; Param=$20
           jmp  out
out1:      lda  #$00                    ; Not an Apple IIe so set Param=0
           sta  Param
out:       lda  $E000                   ; If all 4 bytes the same
           cmp  Save                    ; the language card never
           bne  outon                   ; was on so do nothing
           lda  $D000
           cmp  Save+1
           bne  outon
           lda  $D400
           cmp  Save+2
           bne  outon
           lda  $D800
           cmp  Save+3
           beq  goout
outon:     lda  $C088                   ; No match, so turn first
           lda  $E000                   ; bank of lc on and check
           cmp  Save
           beq  outon0
           lda  $C080
           jmp  goout
outon0:    lda  $D000
           cmp  Save+1                  ; If all locations check
           beq  onout1                  ; then do nothing more
           lda  $C080                   ; otherwise turn on bank 2
           jmp  goout
onout1:    lda  $D400                   ; Check second byte in bank 1
           cmp  Save+2
           beq  onout2
           lda  $C080                   ; Select bank 2
           jmp  goout
onout2:    lda  $D800                   ; Check third byte in bank 1
           cmp  Save+3
           beq  goout
           lda  $C080                   ; Select bank 2
goout:     plp                          ; Reset interrupts
           rts

;** Routine run in safe area not affected by moves ***

SI_Start:  lda  #$EE                    ; Try storing in aux mem
           sta  $C005                   ; Write to aux while on main zp
           sta  $C003                   ; Set to read aux RAM
           sta  $800                    ; Check for sparse mem mapping
           lda  $C00                    ; See if sparse memory -same value
           cmp  #$EE                    ; 1 k away
           bne  auxmem
           asl  $C00                    ; May be sparse mem so change value
           lda  $800                    ; & see what happens
           cmp  $C00
           bne  auxmem
           sec                          ; Sparse mapping so no aux mem
           bcs  back
auxmem:    clc                          ; There is aux mem
back:      sta  $C004                   ; Switch back to write main RAM
           sta  $C002                   ; Switch back main RAM read
           jmp  on                      ; Continue program on pg 3 main RAM
SI_Done:   nop                          ; End of relocation program marker


