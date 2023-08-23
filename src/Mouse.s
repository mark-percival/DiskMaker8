;
; Apple Mouse Routines
;
; Requires : MousePtr  - 2 bytes in zero page
;            MouseX    - 2 bytes
;            MouseY    - 2 bytes
;            LowClamp  - 2 bytes
;            HighClamp - 2 bytes

AppleMouse:

oSetMouse   = $12
oServeMouse = $13
oReadMouse  = $14
oClearMouse = $15
oPosMouse   = $16
oClampMouse = $17
oHomeMouse  = $18
oInitMouse  = $19

MouseXL    =  $0478 + Slot            ; Low byte of absolute X position
MouseYL    =  $04F8 + Slot            ; Low byte of absolute Y position
MouseXH    =  $0578 + Slot            ; High byte of absolute X position
MouseYH    =  $05F8 + Slot            ; High byte of absolute Y position

MouseStatL =  $0778 + Slot            ; Button 0/1 interrupt status byte
MouseModeL =  $07F8 + Slot            ; Mode byte

LowClampL  =  $0478                   ; Low byte of low clamp
HighClampL =  $04F8                   ; Low byte of high clamp
LowClampH  =  $0578                   ; High byte of low clamp
HighClampH =  $05F8                   ; High byte of high clamp

Cn:        .res   1                   ; X-reg operand byte
n0:        .res   1                   ; Y-reg operand byte
MouseSlot: .res   1                   ; Mouse slot number

cout_monitor =  $FDED                 ; Standard character output routine

; FindMouse - Find mouse base address

FindMouse:

           stz  Cn                    ; Zero out X & Y reg operand bytes
           stz  n0

           stz  MousePtr              ; Set up first pointer to $C700
           lda  #$C7
           sta  MousePtr+1

           stz  MouseStat             ; Initialize to zero.

SlotSearch:

           ldy  #$05                  ; First ID byte
           lda  (MousePtr),y
           cmp  #$38
           bne  @NextSlot

           ldy  #$07                  ; Second ID byte
           lda  (MousePtr),y
           cmp  #$18
           bne  @NextSlot

           ldy  #$0B                  ; Third ID byte
           lda  (MousePtr),y
           cmp  #$01
           bne  @NextSlot

           ldy  #$0C                  ; Fourth ID byte
           lda  (MousePtr),y
           cmp  #$20
           bne  @NextSlot

           ldy  #$FB                  ; Fifth ID byte
           lda  (MousePtr),y
           cmp  #$D6
           bne  @NextSlot

           lda  MousePtr+1            ; Save mouse slot
           and  #$0F
           sta  MouseSlot

           lda  MousePtr+1            ; Set up x-reg operand byte.
           sta  Cn

           asl  a                     ; Set up y-reg operand byte.
           asl  a
           asl  a
           asl  a
           sta  n0

           clc                        ; Clear carry to indicate mouse found

           rts                        ; Found Mouse Card

@NextSlot:

           dec  MousePtr+1            ; Decrement to next slot
           cmp  #$C0                  ; At slot 0?
           bne  SlotSearch            ; No, continue search

           stz  MousePtr+1            ; No mouse so zero out pointer.

           sec                        ; Set carry to indicate no mouse.

           rts

; SetMouse - Sets mouse operation mode

SetMouse:

           tax                        ; Save requested operation mode
           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse1            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse1:

           lda  #oSetMouse
           sta  MousePtr              ; Set up entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point
           txa                        ; Restore requested operation mode
           php                        ; Save status register
           sei                        ; Set interrupts off
           jsr  GoMouse               ; Make firmware call
           bcs  SetMousErr
           plp                        ; Restore status register

           ldx  MouseSlot             ; Get slot number

           lda  MouseStatL,x          ; Save status byte
           sta  MouseStat
           lda  MouseModeL,x          ; Save mode byte
           sta  MouseMode

           rts

SetMousErr:

           plp                        ; Restore status register
           ldy  #0
           ldx  #SetMouseX-SetMousMsg

SMLoop1:

           lda  SetMousMsg,y
           jsr  cout_monitor
           iny
           dex
           bne SMLoop1

SMLoop2:
           bra  SMLoop2               ; Infinite loop

SetMousMsg: asc "SetMouse - Illegal mode entered."
SetMouseX:

; ServeMouse - Tests for interrupt from mouse and resets interrupt line

ServeMouse:

           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse2            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse2:

           lda  #oServeMouse
           sta  MousePtr              ; Setup entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point
           php                        ; Save status register
           sei                        ; Set interrupts off
           jsr  GoMouse               ; Make firmware call
           plp                        ; Restore status register
           rts

; ReadMouse - Reads delta (X/Y) positions, updates absolute X/Y pos,
;             and reads button statuses from the mouse

ReadMouse:

           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse3            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse3:

           lda  #oReadMouse
           sta  MousePtr              ; Setup entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point
           php                        ; Save status register
           sei                        ; Set interrupts off
           jsr  GoMouse               ; Make firmware call

           ldx  MouseSlot

           lda  MouseXL,x             ; Save mouse x setting
           sta  MouseX
           lda  MouseXH,x
           sta  MouseX+1

           lda  MouseYL,x             ; Save mouse y setting
           sta  MouseY
           lda  MouseYH,x
           sta  MouseY+1

           lda  MouseStatL,x
           sta  MouseStat

           lda  MouseModeL,x
           sta  MouseMode

           plp                        ; Restore status register
           rts

; ClearMouse - Resets buttons, movements and interrupt status 0.

ClearMouse:

           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse4            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse4:

           lda  #oClearMouse
           sta  MousePtr              ; Setup entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point
           php                        ; Save status register
           sei                        ; Set interrupts off
           jsr  GoMouse               ; Make firmware call
           plp                        ; Restore status register
           rts

; PosMouse - Allows caller to change current mouse position.

PosMouse:

           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse5            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse5:

           lda  #oPosMouse
           sta  MousePtr              ; Setup entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point
           php                        ; Save status register
           sei                        ; Set interrupts off

           ldx  MouseSlot

           lda  MouseX                ; Load mouse X corridinate
           sta  MouseXL,x
           lda  MouseX+1
           sta  MouseXH,x

           lda  MouseY                ; Load mouse Y corridinate
           sta  MouseYL,x
           lda  MouseY+1
           sta  MouseYH,x

           jsr  GoMouse               ; Make firmware call
           plp                        ; Restore status register
           rts

; ClampMouse - Sets up clamping window

ClampMouse:

           tax                        ; Save clamping axis

           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse6            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse6:

           lda  #oClampMouse
           sta  MousePtr              ; Setup entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point

           php                        ; Save status register
           sei                        ; Set interrupts off

           lda  LowClamp              ; Set up clamping low value
           sta  LowClampL
           lda  LowClamp+1
           sta  LowClampH

           lda  HighClamp             ; Set up clamping high value
           sta  HighClampL
           lda  HighClamp+1
           sta  HighClampH

           txa                        ; Restore clamping axis

           jsr  GoMouse               ; Make firmware call
           plp                        ; Restore status register
           rts

; HomeMouse - Sets the absolute position to upper-left corner of
;             clamping window.

HomeMouse:

           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse7            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse7:

           lda  #oHomeMouse
           sta  MousePtr              ; Setup entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point
           php                        ; Save status register
           sei                        ; Set interrupts off
           jsr  GoMouse               ; Make firmware call
           plp                        ; Restore status register
           rts

; InitMouse - Sets screen holes to default values and sets clamping windows to
;             default values of 0 to 1023 in both X and Y directions, resets
;             hardware.

InitMouse:

           lda  MousePtr+1            ; Get mouse pointer high byte
           bne  GoodMouse8            ; Is this zero?
           rts                        ; Yes, no mouse so exit

GoodMouse8:

           lda  #oInitMouse
           sta  MousePtr              ; Setup entry point address

           lda  (MousePtr)            ; Get entry point
           sta  MousePtr              ; Setup final entry point
           php                        ; Save status register
           sei                        ; Set interrupts off
           jsr  GoMouse               ; Make firmware call
           plp                        ; Restore status register
           rts

; GoMouse - Makes the mouse firmware call

GoMouse:

           ldx  Cn
           ldy  n0

           jmp  (MousePtr)            ; Make firmware call
