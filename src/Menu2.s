;
; Selecting disk image target
;

Menu2:

           jsr  SetImgType            ; Look at file and set image type
           jsr  GetImgSize            ; Set an image size based on that type.

           jsr  PaintMenu2            ; Paint basic screen frame

           lda  #1
           sta  TabIndex_M2          ; Start with "Skip" as default.

Menu2_01:

           jsr  LoadDevs              ; Get device info

           jsr  Init2                 ; Initialize screen

Menu2_02:

           jsr  ListDevs              ; List devices 5 at a time

Menu2_03:

           jsr  Refresh2Btn           ; Refresh command buttons.

           jsr  Menu2UI               ; Menu 2 user interface

           lda  RC_M2
           cmp  #Quit2
           beq  Menu2Exit

           cmp  #ReloadDevs
           beq  Menu2_01

           cmp  #UpdDevLst
           beq  Menu2_02

           cmp  #Nothing
           beq  Menu2_03

           jsr  ClearMenu2
           jsr  ProcessImg            ; He's making a disk!

           lda  RC_M2
           cmp  #Quit2
           beq  Menu2Exit

           jmp  Menu2

Menu2Exit:

           jsr  ClearMenu2            ; Clear screen prior to return

           rts

;
; Initialize menu2 variables
;

Init2:

           lda  #<Buffer8K
           sta  Ptr1
           sta  FstAddr_M2
           lda  #>Buffer8K
           sta  Ptr1+1
           sta  FstAddr_M2+1

           stz  Above_M2

           sec
           lda  DevEntCnt_M2
           sbc  #5
           sta  Below_M2
           bpl  GT5

           stz  Below_M2

GT5:

           lda  #1
           sta  SelLine_M2

           lda  #StdText
           jsr  cout_mark

           rts

;
; List devices to screen
;

M2LineCount: .byte   $00

ListDevs:

           lda  #19-1
           sta  HTab
           lda  #11-1
           sta  VTab
           jsr  SetVTab

           lda  SelLine_M2
           bne  @NotUp

           jsr  M2ScrollUp
           bra  @NoScrollDn

@NotUp:

           cmp  #6
           bcc  @NoScrollDn

           jsr  M2ScrollDown

@NoScrollDn:

           lda  FstAddr_M2               ; Setup first line address
           sta  Ptr1
           lda  FstAddr_M2+1
           sta  Ptr1+1

           stz  M2LineCount

           lda  DevEntCnt_M2             ; See if there are any lines to print.
           bne  ListDev01

           jmp  ListDev90             ; Nope, so exit.

ListDev01:

           inc  M2LineCount
           lda  M2LineCount
           cmp  SelLine_M2
           bne  ListDev02

           lda  #Inverse
           jsr  cout_mark

           lda  Ptr1
           sta  SelAddr_M2
           lda  Ptr1+1
           sta  SelAddr_M2+1

ListDev02:

           ldy  #oSlot
           lda  (Ptr1),y
           jsr  cout_mark
           lda  #','+$80
           jsr  cout_mark
           ldy  #oDrive
           lda  (Ptr1),y
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           ldx  #15
           ldy  #oVolume

ListDev03:

           lda  (Ptr1),y
           jsr  cout_mark
           iny
           dex
           bne  ListDev03

           lda  #' '+$80
           jsr  cout_mark

           ldx  #4
           ldy  #oSize

ListDev04:

           lda  (Ptr1),y
           jsr  cout_mark
           iny
           dex
           bne  ListDev04

           lda  #' '+$80
           jsr  cout_mark

           ldy  #oUnit
           lda  (Ptr1),y
           jsr  cout_mark

           lda  #Normal
           jsr  cout_mark

           lda  #19-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  M2LineCount
           cmp  #5                    ; 5 lines max per screen
           beq  ListDev99
           cmp  DevEntCnt_M2             ; End of screen with < 5 lines?
           beq  ListDev90

           clc
           lda  Ptr1
           adc  #oEntryLen
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1
           jmp  ListDev01

ListDev90:

           sec                        ; Calculate blank lines required.
           lda  #5
           sbc  M2LineCount
           tax
           beq  ListDev99             ; No blank lines required.

ListDev92:                            ; Each line

           lda  #' '+$80              ; Space character
           ldy  #26                   ; Spaces per line

ListDev94:                            ; Each character in line

           jsr  cout_mark
           dey
           bne  ListDev94

           lda  #19-1                 ; Set back to start of next line
           sta  HTab
           inc  VTab
           jsr  SetVTab

           dex                        ; More lines to wipe out?
           bne  ListDev92

ListDev99:

           rts

;
; Move dev pointer to next dev
;

M2ScrollDown:

           lda  #5
           sta  SelLine_M2

           inc  Above_M2
           dec  Below_M2

           clc
           lda  FstAddr_M2
           adc  #oEntryLen
           sta  FstAddr_M2
           lda  FstAddr_M2+1
           adc  #0
           sta  FstAddr_M2+1

           rts

;
; Move dev pointer to previous entry
;

M2ScrollUp:

           lda  #1
           sta  SelLine_M2

           dec  Above_M2
           inc  Below_M2

           sec
           lda  FstAddr_M2
           sbc  #oEntryLen
           sta  FstAddr_M2
           lda  FstAddr_M2+1
           sbc  #0
           sta  FstAddr_M2+1

           rts

;
; Refresh command buttons based on TabIndex_M2 setting
;

Refresh2Btn:

           lda  #<M2BtnText           ; Set button text address in Ptr1
           sta  Ptr1
           lda  #>M2BtnText
           sta  Ptr1+1

           lda  #Normal               ; Make sure inverse is off
           jsr  cout_mark
           lda  #StdText              ; Mousetext off
           jsr  cout_mark

           ldx  #0                    ; Index

@Refresh01:

           cpx  TabIndex_M2             ; Is this our active button?
           bne  @Refresh02             ; No so print it normal

           lda  #Inverse              ; Inverse button
           jsr  cout_mark

@Refresh02:

           phx                        ; Save current button

           lda  #51-1
           sta  HTab                  ; HTab 51
           lda  (Ptr1)                ; VTab from table
           sta  VTab
           jsr  SetVTab

           ldy  #1                    ; Starting position index
           ldx  #11                   ; Text length index

@Refresh03:

           lda  (Ptr1),y              ; Get character
           jsr  cout_mark                  ; Print
           iny                        ; Move to next character
           dex                        ; Count it as printed
           bne  @Refresh03             ; More?

           lda  #Normal               ; Reset to normal text
           jsr  cout_mark

           plx                        ; Get index from stack
           inx                        ; Move to next button
           cpx  #3                    ; Button 3?  We're done...
           beq  @Refresh05

           clc                        ; Add 12 to button text pointer
           lda  Ptr1                  ; to setup next button print.
           adc  #12
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1
           bra  @Refresh01            ; Print next button.

@Refresh05:

           cpx  TabIndex_M2
           bne  @Refresh06

           lda  #Inverse
           jsr  cout_mark

@Refresh06:

           lda  #17-1
           sta  VTab
           jsr  SetVTab
           jsr  PrtImgType
           lda  #Normal
           jsr  cout_mark

@Refresh07:

           jsr  PrtSameSize

@Refresh99:

           rts

;
; Get Disk Image Size
;

GetImgSize:

           stz  ImageSize_M2
           stz  ImageSize_M2+1

           lda  ImageType_M2

           cmp  #Type_2IMG            ; 2IMG check.
           beq  T_2Img

           cmp  #Type_DC              ; Diskcopy 4.2 check.
           beq  T_DC

           cmp  #Type_DC6             ; Diskcopy 6 check
           beq  T_DC6

           cmp  #Type_PO              ; ProDOS Order check
           beq  T_PO

           bra  T_DO                  ; Assume DOS Order if it got here.

T_2Img:                               ; 2IMG image

;          Use header for image size

           jsr  MLIOpen1
           lda  openRef1
           sta  setMarkRef
           sta  readRef
           sta  closeRef

           lda  #$14                  ; Image size offset
           sta  setMarkPos
           stz  setMarkPos+1
           stz  setMarkPos+2

           jsr  MLISetMark

           lda  #4                    ; Bytes to read
           sta  readRequest
           stz  readRequest+1

           jsr  MLIRead

           jsr  MLIClose

           lda  readBuf
           sta  ImageSize_M2
           lda  readBuf+1
           sta  ImageSize_M2+1

           rts

T_DC:                                 ; Diskcopy 4.2 image

;          Use header for image size

           jsr  MLIOpen1
           lda  openRef1
           sta  setMarkRef
           sta  readRef
           sta  closeRef

           lda  #64                   ; Image size offset
           sta  setMarkPos
           stz  setMarkPos+1
           stz  setMarkPos+2

           jsr  MLISetMark

           lda  #4                    ; Bytes to read
           sta  readRequest
           stz  readRequest+1

           jsr  MLIRead

           jsr  MLIClose

;          Convert from image size in bytes to blocks.

           lda  readBuf+2
           sta  ImageSize_M2
           lda  readBuf+1
           sta  ImageSize_M2+1

           lsr  ImageSize_M2+1
           ror  ImageSize_M2

           rts

T_DC6:                                ; Diskcopy 6 image

;          Get image size from file size.

           jsr  GetFileSize

           rts

T_PO:                                 ; ProDOS Order image

;          Get image size from file size.

           jsr  GetFileSize

           rts

T_DO:                                 ; DOS Order image

;          Get image size from file size.

           jsr  GetFileSize

           rts

; Call MLIGetEOF the retrieve file size

GetFileSize:

           jsr  MLIOpen1
           lda  openRef1
           sta  geteofRef
           sta  closeRef
           jsr  MLIGetEOF
           jsr  MLIClose

           lda  geteofEOF+1
           sta  ImageSize_M2
           lda  geteofEOF+2
           sta  ImageSize_M2+1

           lsr  ImageSize_M2
           ror  ImageSize_M2+1

           rts
