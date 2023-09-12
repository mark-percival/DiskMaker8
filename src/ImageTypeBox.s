PrtImgType:


           ; Expected to scope to Menu2Vars.s

           lda  #19-1                   ; Image type display starts at
           sta  HTab                    ; HTab 19.

           lda  ImageType               ; Setup index for text address retrieval
           asl  a
           tax
           lda  TypeIndex,x             ; Get address of image type text
           sta  Ptr1
           inx
           lda  TypeIndex,x
           sta  Ptr1+1

           ldy  #0

IT01:

           lda  (Ptr1),y
           beq  IT02
           jsr  cout
           iny
           bra  IT01

IT02:

           cpy  #20
           beq  IT04

           sty  IT_NextChar

           sec
           lda  #20
           sbc  IT_NextChar
           tax
           lda  #' '+$80

IT03:

           jsr  cout
           dex
           bne  IT03

IT04:

           rts

IT_NextChar: .res 1
InitImgType: .res 1

TypeIndex: .addr   Type0,Type1,Type2,Type3,Type4
TypeMax     =   $04

;          Msb  On
Type0:     ascz "Universal Disk (2MG)"
Type1:     ascz "DiskCopy 4.2"
Type2:     ascz "DiskCopy 6"
Type3:     ascz "ProDOS Order (PO)"
Type4:     ascz "DOS Order (DSK/DO)"
;          Msb  Off

;
; SelImgType : User selection of image type
;

SelImgType:

           lda  ImageType
           sta  InitImgType

           jsr  IT_SaveScreen

@Loop1:

           jsr  ShowBox
           jsr  BoxUI

           lda  BoxRC
           bne  @Loop1

           jsr  IT_RestScreen

           jsr  PlotMouse               ; Refresh mouse data

           lda  #17-1
           sta  VTab
           jsr  SetVTab

           lda  #Inverse
           jsr  cout

           jsr  PrtImgType

           lda  #Normal
           jsr  cout

           rts

; Open image type box

FirstLine:  .res 1
IT_LastLine:   .res 1

ShowBox:

           lda  #MouseText              ; Set mousetext on
           jsr  cout

           lda  #17-1                   ; HTab 17
           sta  HTab
           sec
           lda  #16-1                   ; VTab 16 base.
           sbc  InitImgType
           sta  FirstLine
           inc  FirstLine               ; Save VTab of first line
           sta  VTab
           jsr  SetVTab

           clc
           lda  FirstLine
           adc  #TypeMax+1
           sta  IT_LastLine                ; Save VTab of last line

SB01:

           lda  #'Z'
           jsr  cout

SB02:

           lda  #'L'

SB03:

           ldx  #22

SB04:

           jsr  cout
           dex
           bne  SB04

           lda  #'_'
           jsr  cout

           stz  IT_LineCount

SB05:

           lda  #17-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #StdText
           jsr  cout

           lda  IT_LineCount
           cmp  ImageType
           bne  SB06

           lda  #Inverse
           jsr  cout

SB06:

           lda  ImageType
           pha
           lda  IT_LineCount
           sta  ImageType

           jsr  PrtImgType

           pla
           sta  ImageType

           lda  #Normal
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'_'
           jsr  cout

           inc  IT_LineCount
           lda  IT_LineCount
           cmp  #TypeMax+1
           bne  SB05

           lda  #17-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

SB07:

           lda  #'Z'
           jsr  cout

SB08:

           lda  #'_'+$80

SB09:

           ldx  #22

SB10:

           jsr  cout
           dex
           bne  SB10

           lda  #'_'
           jsr  cout

           lda  #StdText
           jsr  cout

           rts

IT_LineCount:  .res 1

;On80Store   =   $C001
;Page1       =   $C054
;Page2       =   $C055

IT_SaveRtn:    .res 1

IT_StartHTab: .res 1
IT_EndHTab:   .res 1
IT_StartVTab: .res 1
IT_CurrLine:  .res 1

;
; IT_SaveScreen - save screen data under list box
; IT_RestScreen - restore screen data under messagebox
;
; Ptr1 = screen data : Ptr2 = save buffer
;

IT_SaveScreen:

           lda  #1
           sta  IT_SaveRtn
           bra  IT_StartRtn

IT_RestScreen:

           stz  IT_SaveRtn

IT_StartRtn:

           sta  On80Store               ; Make sure 80STORE is on.

           clc
           lda  #17-1                   ; HTab 17 start
           sta  IT_StartHTab
           adc  #24                     ; 24 char wide
           sta  IT_EndHTab              ; Ending HTab

           sec
           lda  #16-1                   ; Base VTab
           sbc  InitImgType
           sta  IT_StartVTab
           sta  IT_CurrLine

           lda  #<MessageBuf             ; Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #TypeMax+3              ; Max # of line + 2 for borders + 1 for
;                                       ;  being zero base.
IT_Loop1:

           lda  IT_CurrLine
           asl  a
           tay
           lda  TextLine,y
           sta  Ptr1
           iny
           lda  TextLine,y
           sta  Ptr1+1

           ldy  IT_StartHTab

IT_Loop2:

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
           lda  IT_SaveRtn
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
           cpy  IT_EndHTab              ; If y <= IT_EndHTab, IT_Loop2 to continue
           bcc  IT_Loop2                ;  saving this line
           beq  IT_Loop2

           inc  IT_CurrLine             ; Move to next line
           dex                          ; Another line?
           bne  IT_Loop1

           lda  Page1                   ; Set back to Main for exit.

           rts

;
; BoxUI - User interface
;

BoxUI:

           stz  ClearKbd
           stz  BoxRC

IT_PollDev:

           jsr  PlotMouse

IT_PollDevLoop:

           lda  Keyboard                ; Get keypress
           bpl  @PollMouse              ; No, keypress - check mouse
           jmp  IT_KeyDev               ; Keypress rtn.

@PollMouse:

           jsr  ReadMouse               ; Read mouse
           lsr  MouseX                  ; Divide by 2 X and Y to bring into the
           lsr  MouseY                  ; 0 to 79 and 0 to 23 range
           lda  MouseStat               ; Get mouse status
           bit  #MouseMove              ; Test for mouse movement
           bne  IT_MouseDev1            ; Moused moved
           bit  #CurrButton             ; Test for button press
           bne  IT_MouseDev2            ; Button pressed
           bit  #PrevButton             ; Test for button release
           bne  IT_MouseDev3            ; Button released

           bra  IT_PollDevLoop

;
; Mouse movement
;

IT_MouseDev1:

           jsr  MoveMouse
           jmp  IT_PollDevLoop

;
; Mouse button pressed
;

IT_MouseDev2:

           lda  MouseY
           cmp  FirstLine
           bcc  IT_MouseDev3
           cmp  IT_LastLine
           bcs  IT_MouseDev3

           lda  MouseX
           cmp  #19-1
           bcc  IT_MouseDev3
           cmp  #39-1
           bcs  IT_MouseDev3

           jsr  ChangeType

           jmp  IT_PollDevLoop

;
; Mouse button released
;

IT_MouseDev3:

           rts

;
; Change image type via mouse movement
;

ChangeType:

           sec
           lda  MouseY
           sbc  FirstLine
           cmp  ImageType
           bne  @Changed
           rts

@Changed:

           sta  ImageType
           jsr  ShowBox
           jsr  PlotMouse

           rts

;
; Keyboard key press routine
;

;UpArrow     =   $8B
;DownArrow   =   $8A
;LeftArrow   =   $88
;RightArrow  =   $95
;ReturnKey   =   $8D
;TabKey      =   $89

BoxRC:      .res 1

IT_KeyDev:

           stz  ClearKbd

; Down / right arrow keypress logic

IT_NextKey01:

           cmp  #DownArrow              ; Down arrow?
           beq  @DA1
           cmp  #RightArrow
           beq  @DA1
           bra  IT_NextKey02

@DA1:

           lda  ImageType
           cmp  #TypeMax
           bcs  @DA2

           inc  ImageType

@DA2:

           lda  #1
           sta  BoxRC

           rts

IT_NextKey02:

           cmp  #UpArrow                ; Up arrow?
           beq  @UA1
           cmp  #LeftArrow
           beq  @UA1
           bra  IT_NextKey03

@UA1:

           lda  ImageType
           beq  @UA2

           dec  ImageType

@UA2:

           lda  #1
           sta  BoxRC

           rts

IT_NextKey03:

           cmp  #ReturnKey              ; <cr>
           bne  @BadKey

           rts

@BadKey:

           jsr  Beep
           jmp  IT_PollDevLoop


