;
; About box
;

About:

           jsr  ASaveScreen
           jsr  ShowAbout
           jsr  AboutUI
           jsr  ARestScreen

           jsr  PlotMouse

           rts

ShowAbout:

           lda  #MouseText
           jsr  cout_mark

; Line 1

           lda  #10-1
           sta  HTab
           lda  #8-1
           sta  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'L'
           ldx  #59

L1A:

           jsr  cout_mark
           dex
           bne  L1A

           lda  #'_'
           jsr  cout_mark

; Line 2

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           ldx  #22

L2A:

           jsr  cout_mark
           dex
           bne  L2A

           ldx  #0

L2B:

           lda  Line2Text,x
           beq  L2C
           jsr  cout_mark
           inx
           bra  L2B

L2C:

           lda  #' '+$80
           ldx  #21

L2D:

           jsr  cout_mark
           dex
           bne  L2D

           lda  #'_'
           jsr  cout_mark

; Line 3

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           ldx  #14

L3A:

           jsr  cout_mark
           dex
           bne  L3A

           ldx  #0

L3B:

           lda  Line3Text,x
           beq  L3C
           jsr  cout_mark
           inx
           bra  L3B

L3C:

           lda  #' '+$80
           ldx  #14

L3D:

           jsr  cout_mark
           dex
           bne  L3D

           lda  #'_'
           jsr  cout_mark


; Line 4

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           ldx  #59

L4A:

           jsr  cout_mark
           dex
           bne  L4A

           lda  #'_'
           jsr  cout_mark

; Line 5

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           ldx  #0

L5A:

           lda  Line5Text,x
           beq  L5B
           jsr  cout_mark
           inx
           bra  L5A

L5B:

           lda  #' '+$80
           ldx  #2

L5C:

           jsr  cout_mark
           dex
           bne  L5C

           lda  #'_'
           jsr  cout_mark

; Line 6

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           ldx  #0

L6A:

           lda  Line6Text,x
           beq  L6B
           jsr  cout_mark
           inx
           bra  L6A

L6B:

           lda  #' '+$80
           ldx  #8

L6C:

           jsr  cout_mark
           dex
           bne  L6C

           lda  #'_'
           jsr  cout_mark

; Line 7

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           ldx  #0

L7A:

           lda  Line7Text,x
           beq  L7B
           jsr  cout_mark
           inx
           bra  L7A

L7B:

           lda  #' '+$80
           ldx  #6

L7C:

           jsr  cout_mark
           dex
           bne  L7C

           lda  #'_'
           jsr  cout_mark

; Line 8

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           ldx  #0

L8A:

           lda  Line8Text,x
           beq  L8B
           jsr  cout_mark
           inx
           bra  L8A

L8B:

           lda  #' '+$80
           ldx  #1

L8C:

           jsr  cout_mark
           dex
           bne  L8C

           lda  #'_'
           jsr  cout_mark

; Line 9

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           ldx  #25

L9A:

           jsr  cout_mark
           dex
           bne  L9A

           lda  #'_'+$80
           ldx  #10

L9B:

           jsr  cout_mark
           dex
           bne  L9B

           lda  #' '+$80
           ldx  #24

L9C:

           jsr  cout_mark
           dex
           bne  L9C

           lda  #'_'
           jsr  cout_mark

; Line 10

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           ldx  #24

L10A:

           jsr  cout_mark
           dex
           bne  L10A

           lda  #'Z'
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark

           lda  #' '
           jsr  cout_mark

           lda  #Inverse
           jsr  cout_mark

           ldx  #0

L10B:

           lda  OkText,x
           beq  L10C
           jsr  cout_mark
           inx
           bra  L10B

L10C:

           lda  #Normal
           jsr  cout_mark

           lda  #' '
           jsr  cout_mark

           lda  #MouseText
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #' '+$80
           ldx  #23

L10D:

           jsr  cout_mark
           dex
           bne  L10D

           lda  #'_'
           jsr  cout_mark

; Line 11

           jsr  ANextLine

           lda  #'Z'
           jsr  cout_mark

           lda  #'_'+$80
           ldx  #25

L11A:

           jsr  cout_mark
           dex
           bne  L11A

           lda  #'\'
           ldx  #10

L11B:

           jsr  cout_mark
           dex
           bne  L11B

           lda  #'_'+$80
           ldx  #24

L11C:

           jsr  cout_mark
           dex
           bne  L11C

           lda  #'_'
           jsr  cout_mark

; Exit

           lda  #StdText
           jsr  cout_mark

           rts

Line2Text: ascz  "DiskMaker 8 v1.1"
Line3Text: ascz  "Copyright 2006 by Mark Percival"
Line5Text: ascz  "Converts Universal Disk Image, DiskCopy 4.2, DiskCopy 6"
Line6Text: ascz  "DOS Order 5.25 and ProDOS Order 5.25 images into"
Line7Text: ascz  "actual disks.  Please support the Apple II by paying"
Line8Text: ascz  "the $5 shareware fee.  See the documentation for details."
OkText:    ascz  "   Ok   "

ANextLine:

           lda  #10-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           rts

AboutUI:

           stz  ClearKbd              ; Clear keyboard strobe

@PollDev:

           jsr  PlotMouse             ; Put mouse cursor on screen

@PollDevLoop:

           lda  Keyboard              ; Get keypress
           bpl  @PollMouse            ; No keypress, check mouse
           jmp  @KeyDev

@PollMouse:

           jsr  ReadMouse             ; Readmouse
           lsr  MouseX                ; Put x and y mouse coordinates into
           lsr  MouseY                ;  0 to 79 and 0 to 23 range.
           lda  MouseStat             ; Get mouse status
           bit  #MouseMove            ; Move moved?
           bne  @MouseDev1            ; Yes, process mouse movement
           bit  #CurrButton           ; Mouse button pressed?
           bne  @MouseDev2            ; Yes, process mouse button press.
           bit  #PrevButton           ; Mouse button released?
           bne  @MouseDev3            ; Yes, process mouse button release.

           bra  @PollDevLoop          ; Check keyboard and mouse again.

;
; Process mouse movement
;

@MouseDev1:

           jsr  MoveMouse
           bra  @PollDevLoop

;
; Process mouse button press
;

@MouseDev2:

           bra  @PollDevLoop

;
; Process mouse button release
;

@MouseDev3:

           lda  MouseY
           cmp  #17-1
           bne  @No
           lda  MouseX
           cmp  #37-1
           bcc  @No
           cmp  #45-1
           bcs  @No

           jsr  @AnimateBtn

           rts

@No:

           bra  @PollDevLoop

;
; Process keyboard key press
;

@KeyDev:

           stz  ClearKbd              ; Clear keyboard strobe

           cmp  #ReturnKey
           beq  @Return
           cmp  #' '+$80
           beq  @Return
           cmp  #TabKey
           beq  @Tab

           jsr  Beep

           jmp  @PollDevLoop

@Tab:

           jmp  @PollDevLoop

@Return:

           jsr  @AnimateBtn

           rts

@AnimateBtn:

           lda  #Normal
           jsr  cout_mark

           lda  #17-1
           sta  VTab
           lda  #37-1
           sta  HTab

           jsr  SetVTab

           ldx  #8
           ldy  #0

AB01:

           lda  OkText,y
           jsr  cout_mark
           iny
           dex
           bne  AB01

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout_mark

           lda  #17-1
           sta  VTab
           lda  #37-1
           sta  HTab

           jsr  SetVTab

           ldx  #8
           ldy  #0

AB02:

           lda  OkText,y
           jsr  cout_mark
           iny
           dex
           bne  AB02

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout_mark

           rts

; Save / Restore Screen routine.

ASaveRtn:   .byte   1

AStartHTab: .byte   1
AEndHTab:   .byte   1
AStartVTab: .byte   1
ACurrLine:  .byte   1

;
; ASaveScreen - save screen data under list box
; ARestScreen - restore screen data under messagebox
;
; Ptr1 = screen data : Ptr2 = save buffer
;

ASaveScreen:

           lda  #1
           sta  ASaveRtn
           bra  AStartRtn

ARestScreen:

           stz  ASaveRtn

AStartRtn:

           sta  On80Store             ; Make sure 80STORE is on.

           clc
           lda  #10-1                 ; HTab start
           sta  AStartHTab
           adc  #61                   ; # char wide
           sta  AEndHTab              ; Ending HTab

           sec
           lda  #8-1                  ; Base VTab
           sta  AStartVTab
           sta  ACurrLine

           lda  #<MessageBuf          ; Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #11                   ; Max # of lines

@SSLoop1:

           lda  ACurrLine
           asl  a
           tay
           lda  TextLine,y
           sta  Ptr1
           iny
           lda  TextLine,y
           sta  Ptr1+1

           ldy  AStartHTab

@SSLoop2:

           phy
           tya
           lsr  a
           bcs  @FromMain

@FromAux:

           sta  Page2
           bra  @GetChar

@FromMain:

           sta  Page1

@GetChar:

           tay
           lda  ASaveRtn
           beq  @Restore

           lda  (Ptr1),y
           sta  (Ptr2)
           bra  @Continue

@Restore:

           lda  (Ptr2)
           sta  (Ptr1),y

@Continue:

           ply

           inc  Ptr2                  ; Increment save buffer pointer
           bne  @NoOF

           inc  Ptr2+1

@NoOF:                                ; No overflow

           iny
           cpy  AEndHTab              ; If y <= AEndHTab, @SSLoop2 to continue
           bcc  @SSLoop2              ;  saving this line
           beq  @SSLoop2

           inc  ACurrLine             ; Move to next line
           dex                        ; Another line?
           bne  @SSLoop1

           lda  Page1                 ; Set back to Main for exit.

           rts
