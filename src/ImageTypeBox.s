PrtImgType:

           lda  #19-1                 ; Image type display starts at
           sta  HTab                  ; HTab 19.

           lda  ImageType_M2             ; Setup index for text address retrieval
           asl  a
           tax
           lda  TypeIndex,x           ; Get address of image type text
           sta  Ptr1
           inx
           lda  TypeIndex,x
           sta  Ptr1+1

           ldy  #0

IT01:

           lda  (Ptr1),y
           beq  IT02
           jsr  cout_mark
           iny
           bra  IT01

IT02:

           cpy  #20
           beq  IT04

           sty  ITBNextChar

           sec
           lda  #20
           sbc  ITBNextChar
           tax
           lda  #' '+$80

IT03:

           jsr  cout_mark
           dex
           bne  IT03

IT04:

           rts

ITBNextChar: .byte   $00
InitImgType: .byte   $00

TypeIndex: .addr   Type0,Type1,Type2,Type3,Type4
TypeMax    =  $04

Type0:     ascz  "Universal Disk (2MG)"
Type1:     ascz  "DiskCopy 4.2"
Type2:     ascz  "DiskCopy 6"
Type3:     ascz  "ProDOS Order (PO)"
Type4:     ascz  "DOS Order (DSK/DO)"

;
; SelImgType : User selection of image type
;

SelImgType:

           lda  ImageType_M2
           sta  InitImgType

           jsr  ITSaveScreen

@Loop1:

           jsr  ShowBox
           jsr  BoxUI

           lda  ITBoxRC
           bne  @Loop1

           jsr  ITRestScreen

           jsr  PlotMouse             ; Refresh mouse data

           lda  #17-1
           sta  VTab
           jsr  SetVTab

           lda  #Inverse
           jsr  cout_mark

           jsr  PrtImgType

           lda  #Normal
           jsr  cout_mark

           rts

; Open image type box

ITFirstLine: .byte   $00
ITLastLine:  .byte   $00

ShowBox:

           lda  #MouseText            ; Set mousetext on
           jsr  cout_mark

           lda  #17-1                 ; HTab 17
           sta  HTab
           sec
           lda  #16-1                 ; VTab 16 base.
           sbc  InitImgType
           sta  ITFirstLine
           inc  ITFirstLine           ; Save VTab of first line
           sta  VTab
           jsr  SetVTab

           clc
           lda  ITFirstLine
           adc  #TypeMax+1
           sta  ITLastLine            ; Save VTab of last line

SB01:

           lda  #'Z'
           jsr  cout_mark

SB02:

           lda  #'L'

SB03:

           ldx  #22

SB04:

           jsr  cout_mark
           dex
           bne  SB04

           lda  #'_'
           jsr  cout_mark

           stz  LineCount

SB05:

           lda  #17-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark

           lda  LineCount
           cmp  ImageType_M2
           bne  SB06

           lda  #Inverse
           jsr  cout_mark

SB06:

           lda  ImageType_M2
           pha
           lda  LineCount
           sta  ImageType_M2

           jsr  PrtImgType

           pla
           sta  ImageType_M2

           lda  #Normal
           jsr  cout_mark

           lda  #MouseText
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           inc  LineCount
           lda  LineCount
           cmp  #TypeMax+1
           bne  SB05

           lda  #17-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

SB07:

           lda  #'Z'
           jsr  cout_mark

SB08:

           lda  #'_'+$80

SB09:

           ldx  #22

SB10:

           jsr  cout_mark
           dex
           bne  SB10

           lda  #'_'
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark

           rts

LineCount: .byte   $00

ITSaveRtn:   .byte   $00

ITStartHTab: .byte   $00
ITEndHTab:   .byte   $00
ITStartVTab: .byte   $00
ITCurrLine:  .byte   $00

;
; ITSaveScreen - save screen data under list box
; ITRestScreen - restore screen data under messagebox
;
; Ptr1 = screen data : Ptr2 = save buffer
;

ITSaveScreen:

           lda  #1
           sta  ITSaveRtn
           bra  ITStartRtn

ITRestScreen:

           stz  ITSaveRtn

ITStartRtn:

           sta  On80Store             ; Make sure 80STORE is on.

           clc
           lda  #17-1                 ; HTab 17 start
           sta  ITStartHTab
           adc  #24                   ; 24 char wide
           sta  ITEndHTab             ; Ending HTab

           sec
           lda  #16-1                 ; Base VTab
           sbc  InitImgType
           sta  ITStartVTab
           sta  ITCurrLine

           lda  #<MessageBuf          ; Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #TypeMax+3            ; Max # of line + 2 for borders + 1 for
                                      ;  being zero base.
@SSLoop1:

           lda  ITCurrLine
           asl  a
           tay
           lda  TextLine,y
           sta  Ptr1
           iny
           lda  TextLine,y
           sta  Ptr1+1

           ldy  ITStartHTab

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
           lda  ITSaveRtn
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
           cpy  ITEndHTab             ; If y <= ITEndHTab, SSLoop2 to continue
           bcc  @SSLoop2              ;  saving this line
           beq  @SSLoop2

           inc  ITCurrLine            ; Move to next line
           dex                        ; Another line?
           bne  @SSLoop1

           lda  Page1                 ; Set back to Main for exit.

           rts

;
; BoxUI - User interface
;

BoxUI:

           stz  ClearKbd
           stz  ITBoxRC

@PollDev:

           jsr  PlotMouse

ITPollDevLoop:

           lda  Keyboard              ; Get keypress
           bpl  @PollMouse            ; No, keypress - check mouse
           jmp  ITKeyDev              ; Keypress rtn.

@PollMouse:

           jsr  ReadMouse             ; Read mouse
           lsr  MouseX                ; Divide by 2 X and Y to bring into the
           lsr  MouseY                ; 0 to 79 and 0 to 23 range
           lda  MouseStat             ; Get mouse status
           bit  #MouseMove            ; Test for mouse movement
           bne  @MouseDev1            ; Mouse moved
           bit  #CurrButton           ; Test for button press
           bne  @MouseDev2            ; Button pressed
           bit  #PrevButton           ; Test for button release
           bne  @MouseDev3            ; Button released

           bra  ITPollDevLoop

;
; Mouse movement
;

@MouseDev1:

           jsr  MoveMouse
           jmp  ITPollDevLoop

;
; Mouse button pressed
;

@MouseDev2:

           lda  MouseY
           cmp  ITFirstLine
           bcc  @MouseDev3
           cmp  ITLastLine
           bcs  @MouseDev3

           lda  MouseX
           cmp  #19-1
           bcc  @MouseDev3
           cmp  #39-1
           bcs  @MouseDev3

           jsr  ChangeType

           jmp  ITPollDevLoop

;
; Mouse button released
;

@MouseDev3:

           rts

;
; Change image type via mouse movement
;

ChangeType:

           sec
           lda  MouseY
           sbc  ITFirstLine
           cmp  ImageType_M2
           bne  @Changed
           rts

@Changed:

           sta  ImageType_M2
           jsr  ShowBox
           jsr  PlotMouse

           rts

ITBoxRC:     .byte   $00

ITKeyDev:

           stz  ClearKbd

; Down / right arrow keypress logic

@NextKey01:

           cmp  #DownArrow            ; Down arrow?
           beq  @DA1
           cmp  #RightArrow
           beq  @DA1
           bra  @NextKey02

@DA1:

           lda  ImageType_M2
           cmp  #TypeMax
           bcs  @DA2

           inc  ImageType_M2

@DA2:

           lda  #1
           sta  ITBoxRC

           rts

@NextKey02:

           cmp  #UpArrow              ; Up arrow?
           beq  @UA1
           cmp  #LeftArrow
           beq  @UA1
           bra  @NextKey03

@UA1:

           lda  ImageType_M2
           beq  @UA2

           dec  ImageType_M2

@UA2:

           lda  #1
           sta  ITBoxRC

           rts

@NextKey03:

           cmp  #ReturnKey            ; <cr>
           bne  @BadKey

           rts

@BadKey:

           jsr  Beep
           jmp  ITPollDevLoop
