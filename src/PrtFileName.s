
PrtFileName:

;
;          Print file entry to screen
;
;          Prints a file entry at starting cursor position
;
;          Requires: Ptr1 set to address of entry to print
;                    Prt2 is used for mixed case conversion
;                    TextMode toggles inverse for selected file

; Offsets

oFileName  =  $00
oFileTypeA =  $11 ; - $13             Converted to ASCII by LoadDirectory
oLower1    =  $1D
oLower2    =  $1C
oLowerVol1 =  $17                   ; $1B - $04
oLowerVol2 =  $16                   ; $1A - $04

           bra  Start

FileLength: .byte   $00

Start:

           ldy  #oFileName            ; Filename offset
           lda  (Ptr1),y              ; Get storage type / filename length
           and  #$F0                  ; Keep only storage type
           cmp  #$F0                  ; Volume directory header?
           bne  PrtFile02             ; No

;          A volume directory

           ldy  #oLowerVol1
           lda  (Ptr1),y              ; Get first set of mixed case bits
           sta  Ptr2
           ldy  #oLowerVol2           ; Get 2nd set of mixed case bits
           lda  (Ptr1),y
           ldy  #oLower2              ; Save in position for normal file/dir.
           sta  (Ptr1),y
           asl  Ptr2                  ; Test for mixed case.
           bcs  PrtFile01             ; Yes, process as normal.

           lda  #0                    ; No, zero out bits to force upper case
           sta  Ptr2
           ldy  #oLowerVol2
           sta  (Ptr1),y

PrtFile01:

           lda  #MouseText            ; Mousetext on
           jsr  cout_mark
           lda  #'Z'
           jsr  cout_mark             ; |
           lda  #'\'
           jsr  cout_mark             ; Two horizontal lines
           lda  #'^'
           jsr  cout_mark             ; Box with dot
           bra  PrtFile06             ; Print file name

PrtFile02:

           ldy  #oFileName            ; Filename offset
           lda  (Ptr1),y              ; Get storage type / filename length
           and  #$F0                  ; Keep only storage type
           cmp  #$E0                  ; Directory header?
           bne  PrtFile03             ; No

;          A directory file header

           lda  #0                    ; No mixed case info for a directory file
           sta  Ptr2                  ; header so make it zeros to force upper
           ldy  #oLower2              ; case only.
           sta  (Ptr1),y

           lda  #MouseText
           jsr  cout_mark
           lda  #' '+$80
           jsr  cout_mark
           lda  #'X'
           jsr  cout_mark             ; Left half of folder
           lda  #'Y'
           jsr  cout_mark             ; Right half of folder
           bra  PrtFile06             ; Print file name

PrtFile03:

           ldy  #oLower1
           lda  (Ptr1),y              ; Get first set of mixed case bits
           sta  Ptr2
           asl  Ptr2                  ; Test for mixed case.
           bcs  PrtFile04             ; Yes, process as normal.

           lda  #0                    ; No, zero out bits to force upper case
           sta  Ptr2
           ldy  #oLower2
           sta  (Ptr1),y

PrtFile04:

           ldy  #oFileName            ; Filename offset
           lda  (Ptr1),y              ; Get storage type / filename length
           and  #$F0                  ; Keep only storage type
           cmp  #$D0                  ; Directory entry?
           bne  PrtFile05             ; No

;          Directory file entry

           lda  #MouseText
           jsr  cout_mark
           lda  #' '+$80
           jsr  cout_mark
           lda  #'X'
           jsr  cout_mark             ; Left half of folder
           lda  #'Y'
           jsr  cout_mark             ; Right half of folder
           bra  PrtFile06             ; Print file name

PrtFile05:

;          Regular file entry

           lda  #' '+$80
           jsr  cout_mark
           jsr  cout_mark             ; Print three spaces
           jsr  cout_mark

PrtFile06:

           lda  #StdText              ; Normal text
           jsr  cout_mark

           ldy  #oFileName            ; Get file type
           lda  (Ptr1),y
           and  #$F0
           cmp  #$40                  ; File type < $40 is a regular file
           bcc  PtrFile06a
           cmp  #$D0                  ; File type >= $D0 is a directory or
           bcs  PtrFile06a            ;  a directory header

           lda  #'+'+$80              ; At here we have a non-ProDOS 8 file
           jsr  cout_mark             ;  of some sort.
           bra  PtrFile06b

PtrFile06a:

           lda  #' '+$80              ; Space
           jsr  cout_mark             ; Print space

PtrFile06b:

           lda  TextMode              ; Set selected/not selected entry
           jsr  cout_mark
           lda  #Normal               ; Set default TextMode to Normal text
           sta  TextMode

;          Start printing file name

           ldy  #oFileName
           lda  (Ptr1),y
           and  #$0F                  ; Keep only filename length
           sta  FileLength            ; Temp save for later
           tax                        ; x reg = remaining chars to print
           ldy  #oFileName            ; y reg = index
           iny                        ; Move to first character of name

PrtFile07:

           lda  (Ptr1),y              ; Get character
           asl  Ptr2                  ; Check for lower case character
           bcc  PrtFile08             ; No, so skip lower case conversion.

           clc
           adc  #32                   ; Convert to lower case

PrtFile08:

           ora  #$80                  ; Set high bit on
           jsr  cout_mark             ; Print character

           iny                        ; Move index to next character
           cpy  #oFileName+8          ; Check to see if we need the 2nd set of
           bne  PrtFile09             ; mixed case bits.

           phy                        ; Save y-reg
           ldy  #oLower2              ; Get location of 2nd set of mixed bits.
           lda  (Ptr1),y              ; Retrieve next set of midex case bits
           sta  Ptr2                  ; Save bits in our pointer.
           ply                        ; Restore y-reg.

PrtFile09:

           dex                        ; More to print?
           bne  PrtFile07             ; Yes

           lda  #15                   ; Calculate spaces required to pad
           sec
           sbc  FileLength
           beq  PrtFile11             ; No spaces required, exit.

           tax
           lda  #' '+$80              ; Space

PrtFile10:

           jsr  cout_mark             ; Print space
           dex
           bne  PrtFile10

PrtFile11:

           lda  Ptr1
           cmp  #<VolHeader_M1
           bne  PrtFile12
           lda  Ptr1+1
           cmp  #>VolHeader_M1
           bne  PrtFile12
           bra  PrtFile14

PrtFile12:

           lda  #' '+$80
           jsr  cout_mark             ; Print a space

           ldx  #3
           ldy  #oFileTypeA

PrtFile13:                            ; Print file type loop

           lda  (Ptr1),y
           ora  #$80
           jsr  cout_mark
           iny
           dex
           bne  PrtFile13

PrtFile14:

           lda  #Normal               ; Make sure Normal text mode.
           jsr  cout_mark

           rts
