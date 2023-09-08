;
; About box
;

About:

           jsr  A_SaveScreen
           jsr  ShowAbout
           jsr  AboutUI
           jsr  A_RestScreen

           jsr  PlotMouse

           rts

ShowAbout:

           lda  #MouseText
           jsr  cout

; Line 1

           lda  #10-1
           sta  HTab
           lda  #8-1
           sta  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #'L'
           ldx  #59

L1A:

           jsr  cout
           dex
           bne  L1A

           lda  #'_'
           jsr  cout

; Line 2

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #22

L2A:

           jsr  cout
           dex
           bne  L2A

           ldx  #0

L2B:

           lda  Line2Text,x
           beq  L2C
           jsr  cout
           inx
           bra  L2B

L2C:

           lda  #' '+$80
           ldx  #21

L2D:

           jsr  cout
           dex
           bne  L2D

           lda  #'_'
           jsr  cout

; Line 3

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #14

L3A:

           jsr  cout
           dex
           bne  L3A

           ldx  #0

L3B:

           lda  Line3Text,x
           beq  L3C
           jsr  cout
           inx
           bra  L3B

L3C:

           lda  #' '+$80
           ldx  #14

L3D:

           jsr  cout
           dex
           bne  L3D

           lda  #'_'
           jsr  cout


; Line 4

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #59

L4A:

           jsr  cout
           dex
           bne  L4A

           lda  #'_'
           jsr  cout

; Line 5

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L5A:

           lda  Line5Text,x
           beq  L5B
           jsr  cout
           inx
           bra  L5A

L5B:

           lda  #' '+$80
           ldx  #2

L5C:

           jsr  cout
           dex
           bne  L5C

           lda  #'_'
           jsr  cout

; Line 6

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L6A:

           lda  Line6Text,x
           beq  L6B
           jsr  cout
           inx
           bra  L6A

L6B:

           lda  #' '+$80
           ldx  #8

L6C:

           jsr  cout
           dex
           bne  L6C

           lda  #'_'
           jsr  cout

; Line 7

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L7A:

           lda  A_Line7Text,x
           beq  L7B
           jsr  cout
           inx
           bra  L7A

L7B:

           lda  #' '+$80
           ldx  #6

L7C:

           jsr  cout
           dex
           bne  L7C

           lda  #'_'
           jsr  cout

; Line 8

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #0

L8A:

           lda  Line8Text,x
           beq  L8B
           jsr  cout
           inx
           bra  L8A

L8B:

           lda  #' '+$80
           ldx  #1

L8C:

           jsr  cout
           dex
           bne  L8C

           lda  #'_'
           jsr  cout

; Line 9

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #25

L9A:

           jsr  cout
           dex
           bne  L9A

           lda  #'_'+$80
           ldx  #10

L9B:

           jsr  cout
           dex
           bne  L9B

           lda  #' '+$80
           ldx  #24

L9C:

           jsr  cout
           dex
           bne  L9C

           lda  #'_'
           jsr  cout

; Line 10

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           ldx  #24

L10A:

           jsr  cout
           dex
           bne  L10A

           lda  #'Z'
           jsr  cout

           lda  #StdText
           jsr  cout

           lda  #' '
           jsr  cout

           lda  #Inverse
           jsr  cout

           ldx  #0

L10B:

           lda  OkText,x
           beq  L10C
           jsr  cout
           inx
           bra  L10B

L10C:

           lda  #Normal
           jsr  cout

           lda  #' '
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #'_'
           jsr  cout

           lda  #' '+$80
           ldx  #23

L10D:

           jsr  cout
           dex
           bne  L10D

           lda  #'_'
           jsr  cout

; Line 11

           jsr  A_NextLine

           lda  #'Z'
           jsr  cout

           lda  #'_'+$80
           ldx  #25

L11A:

           jsr  cout
           dex
           bne  L11A

           lda  #'\'
           ldx  #10

L11B:

           jsr  cout
           dex
           bne  L11B

           lda  #'_'+$80
           ldx  #24

L11C:

           jsr  cout
           dex
           bne  L11C

           lda  #'_'
           jsr  cout

; Exit

           lda  #StdText
           jsr  cout

           rts

;          Msb  On
Line2Text: ascz "DiskMaker 8 v1.1"
Line3Text: ascz "Copyright 2006 by Mark Percival"
Line5Text: ascz "Converts Universal Disk Image, DiskCopy 4.2, DiskCopy 6,"
Line6Text: asc  "DOS Order 5.25"
           .byte '"'+$80
           asc  " and ProDOS Order 5.25"
           .byte '"'+$80
           ascz " images into"
A_Line7Text: ascz "actual disks.  Please support the Apple II by paying"
Line8Text: ascz "the $5 shareware fee.  See the documentation for details."
OkText:    ascz "   Ok   "
;          Msb  Off

A_NextLine:

           lda  #10-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           rts

AboutUI:

;ReturnKey   =   $8D
;TabKey      =   $89

           stz  ClearKbd                ; Clear keyboard strobe

A_PollDev:

           jsr  PlotMouse               ; Put mouse cursor on screen

A_PollDevLoop:

           lda  Keyboard                ; Get keypress
           bpl  @PollMouse              ; No keypress, check mouse
           jmp  A_KeyDev

@PollMouse:

           jsr  ReadMouse               ; Readmouse
           lsr  MouseX                  ; Put x and y mouse coordinates into
           lsr  MouseY                  ;  0 to 79 and 0 to 23 range.
           lda  MouseStat               ; Get mouse status
           bit  #MouseMove              ; Move moved?
           bne  A_MouseDev1             ; Yes, process mouse movement
           bit  #CurrButton             ; Mouse button pressed?
           bne  A_MouseDev2             ; Yes, process mouse button press.
           bit  #PrevButton             ; Mouse button released?
           bne  A_MouseDev3             ; Yes, process mouse button release.

           bra  A_PollDevLoop           ; Check keyboard and mouse again.

;
; Process mouse movement
;

A_MouseDev1:

           jsr  MoveMouse
           bra  A_PollDevLoop

;
; Process mouse button press
;

A_MouseDev2:

           bra  A_PollDevLoop

;
; Process mouse button release
;

A_MouseDev3:

           lda  MouseY
           cmp  #17-1
           bne  No
           lda  MouseX
           cmp  #37-1
           bcc  No
           cmp  #45-1
           bcs  No

           jsr  A_AnimateBtn

           rts

No:

           bra  A_PollDevLoop

;
; Process keyboard key press
;

A_KeyDev:

           stz  ClearKbd                ; Clear keyboard strobe

           cmp  #ReturnKey
           beq  Return
           cmp  #' '+$80
           beq  Return
           cmp  #TabKey
           beq  Tab

           jsr  Beep

           jmp  A_PollDevLoop

Tab:

           jmp  A_PollDevLoop

Return:

           jsr  A_AnimateBtn

           rts

A_AnimateBtn:

           lda  #Normal
           jsr  cout

           lda  #17-1
           sta  VTab
           lda  #37-1
           sta  HTab

           jsr  SetVTab

           ldx  #8
           ldy  #0

AB01:

           lda  OkText,y
           jsr  cout
           iny
           dex
           bne  AB01

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout

           lda  #17-1
           sta  VTab
           lda  #37-1
           sta  HTab

           jsr  SetVTab

           ldx  #8
           ldy  #0

AB02:

           lda  OkText,y
           jsr  cout
           iny
           dex
           bne  AB02

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout

           rts

; Save / Restore Screen routine.

A_TextLine:                             ; Text screen line starting addresses

A_TextLine00: .addr $0400
A_TextLine01: .addr $0480
A_TextLine02: .addr $0500
A_TextLine03: .addr $0580
A_TextLine04: .addr $0600
A_TextLine05: .addr $0680
A_TextLine06: .addr $0700
A_TextLine07: .addr $0780
A_TextLine08: .addr $0428
A_TextLine09: .addr $04A8
A_TextLine10: .addr $0528
A_TextLine11: .addr $05A8
A_TextLine12: .addr $0628
A_TextLine13: .addr $06A8
A_TextLine14: .addr $0728
A_TextLine15: .addr $07A8
A_TextLine16: .addr $0450
A_TextLine17: .addr $04D0
A_TextLine18: .addr $0550
A_TextLine19: .addr $05D0
A_TextLine20: .addr $0650
A_TextLine21: .addr $06D0
A_TextLine22: .addr $0750
A_TextLine23: .addr $07D0

;On80Store   =   $C001
;Page1       =   $C054
;Page2       =   $C055

A_SaveRtn:    .res 1

A_StartHTab: .res 1
A_EndHTab:   .res 1
A_StartVTab: .res 1
A_CurrLine:  .res 1

;
; A_SaveScreen - save screen data under list box
; A_RestScreen - restore screen data under messagebox
;
; Ptr1 = screen data : Ptr2 = save buffer
;

A_SaveScreen:

           lda  #1
           sta  A_SaveRtn
           bra  A_StartRtn

A_RestScreen:

           stz  A_SaveRtn

A_StartRtn:

           sta  On80Store               ; Make sure 80STORE is on.

           clc
           lda  #10-1                   ; HTab start
           sta  A_StartHTab
           adc  #61                     ; # char wide
           sta  A_EndHTab                 ; Ending HTab

           sec
           lda  #8-1                    ; Base VTab
           sta  A_StartVTab
           sta  A_CurrLine

           lda  #<MessageBuf             ; Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #11                     ; Max # of lines

A_Loop1:

           lda  A_CurrLine
           asl  a
           tay
           lda  A_TextLine,y
           sta  Ptr1
           iny
           lda  A_TextLine,y
           sta  Ptr1+1

           ldy  A_StartHTab

A_Loop2:

           phy
           tya
           lsr  a
           bcs  @FromMain

;FromAux:

           sta  Page2
           bra  @GetChar

@FromMain:

           sta  Page1

@GetChar:

           tay
           lda  A_SaveRtn
           beq  @Restore

           lda  (Ptr1),y
           sta  (Ptr2)
           bra  @Continue

@Restore:

           lda  (Ptr2)
           sta  (Ptr1),y

@Continue:

           ply

           inc  Ptr2                    ; Increment save buffer pointer
           bne  @NoOF

           inc  Ptr2+1

@NoOF:                                  ; No overflow

           iny
           cpy  A_EndHTab               ; If y <= A_EndHTab, A_Loop2 to continue
           bcc  A_Loop2                 ;  saving this line
           beq  A_Loop2

           inc  A_CurrLine              ; Move to next line
           dex                          ; Another line?
           bne  A_Loop1

           lda  Page1                   ; Set back to Main for exit.

           rts


