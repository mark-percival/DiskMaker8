;
; Paint basic menu1 frame
;

PaintMenu1:

;          L i n e   6

           lda  #Inverse              ; Setup for mousetext
           jsr  cout_mark
           lda  #MouseText
           jsr  cout_mark

           lda  #6-1                  ; Set to line 6
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr cout_mark

           ldx  #40                   ; 40 characters
           lda  #'L'                  ; Top _ of box

PM_Line6_1:

           jsr  cout_mark
           dex
           bne  PM_Line6_1

           lda  #'_'                  ; Right side |
           jsr cout_mark

;          L i n e   7

           lda  #7-1                  ; Set to line 7
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark

           lda  #61-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;          L i n e   8

           lda  #8-1                  ; Set to line 8
           sta  VTab
           lda  #20-1                 ; HTab 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark

           lda  #61-1
           sta  HTab                  ; HTab 61

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   9

           lda  #9-1                  ; Set to line 9
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark

           lda  #61-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;          L i n e   1 0

           lda  #10-1                 ; Set to line 10
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark

           lda  #22-1
           sta  HTab                  ; HTab 22

           jsr  SetNorm               ; Normal text

           ldx  #25
           lda  #'_'+$80              ; 25 underscores

PM_Lin10_1:

           jsr  cout_mark
           dex
           bne  PM_Lin10_1

           lda  #49-1
           sta  HTab                  ; HTab 49

           ldx  #10
           lda  #'_'+$80              ; 10 underscores

PM_Lin10_2:

           jsr  cout_mark
           dex
           bne  PM_Lin10_2

           jsr  SetInv

           lda  #61-1
           sta  HTab

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   1 1

           lda  #11-1                 ; Set to line 11
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x 2

           lda  #45-1
           sta  HTab                  ; HTab 45

           lda  #'Z'
           jsr  cout_mark             ; |

           lda  #'R'
           jsr  cout_mark             ; Up scroll arrow

           lda  #48-1
           sta  HTab                  ;  HTab 47

           lda  #'Z'
           jsr  cout_mark             ;  |

           lda  #StdText
           jsr  cout_mark             ;  Normal text

           lda  #' '+$80
           jsr  cout_mark             ;  Inverse block

           lda  #Normal
           jsr  cout_mark

           ldx  #DisksTextE-DisksText
           ldy  #$00

PM_Line11_1:

           lda  DisksText,y
           jsr  cout_mark
           iny
           dex
           bne  PM_Line11_1

           lda  #Inverse
           jsr  cout_mark

           lda  #MouseText            ; Mousetext back on
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark             ; Inverse block

           lda  #MouseText            ; Mousetext back on
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           pha                        ; Save character to print
           lda  #61-1
           sta  HTab                  ; HTab 61

           pla                        ; Restore character
           jsr  cout_mark

;          L i n e   1 2

           lda  #12-1                 ; Set to line 12
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x2
           pha                        ; Save character

           lda  #45-1
           sta  HTab                  ; HTab 45

           pla                        ; Restore character
           jsr  cout_mark

           lda  #'V'                  ; Checkerboard
           jsr  cout_mark

           lda  #49-1
           sta  HTab                  ; HTab 49

           ldx  #10
           lda  #'L'                  ; 10 underscores

PM_Lin12_1:

           jsr  cout_mark
           dex
           bne  PM_Lin12_1

           lda  #61-1
           sta  HTab

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   1 3

           lda  #13-1                 ; Set to line 13
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x2
           pha                        ; Save character

           lda  #45-1
           sta  HTab                  ; HTab 45

           pla                        ; Restore character
           jsr  cout_mark

           lda  #'V'                  ; Checkerboard
           jsr  cout_mark

           lda  #49-1
           sta  HTab                  ; HTab 49

           jsr  SetNorm
           ldx  #10
           lda  #'_'+$80              ; 10 underscores

PM_Lin13_1:

           jsr  cout_mark
           dex
           bne  PM_Lin13_1

           jsr  SetInv

           lda  #61-1
           sta  HTab

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   1 4

           lda  #14-1                 ; Set to line 14
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x2
           pha                        ; Save character

           lda  #45-1
           sta  HTab                  ; HTab 45

           pla                        ; Restore character
           jsr  cout_mark

           lda  #'V'                  ; Checkerboard
           jsr  cout_mark

           lda  #48-1
           sta  HTab                  ; HTab 48

           lda  #'Z'
           jsr  cout_mark             ; |

           lda  #StdText
           jsr  cout_mark             ; Normal text

           lda  #' '+$80
           jsr  cout_mark             ; Inverse block

           ldx  #OpenTextE-OpenText
           ldy  #$00

PM_Line14_1:

           lda  OpenText,y
           jsr  cout_mark
           iny
           dex
           bne  PM_Line14_1

           lda  #MouseText            ; Mousetext back on
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark             ; Inverse block

           lda  #MouseText            ; Mousetext back on
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #61-1
           sta  HTab

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   1 5

           lda  #15-1                 ; Set to line 14
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x2
           pha                        ; Save character

           lda  #45-1
           sta  HTab                  ; HTab 45

           pla                        ; Restore character
           jsr  cout_mark

           lda  #'V'                  ; Checkerboard
           jsr  cout_mark

           lda  #49-1
           sta  HTab                  ; HTab 49

           jsr  SetNorm
           ldx  #10
           lda  #'\'                  ; 10 underscores

PM_Lin15_1:

           jsr  cout_mark
           dex
           bne  PM_Lin15_1

           lda  #61-1
           sta  HTab

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   1 6

           lda  #16-1                 ; Set to line 16
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x2
           pha                        ; Save character

           lda  #45-1
           sta  HTab                  ; HTab 45

           pla                        ; Restore character
           jsr  cout_mark

           lda  #'V'                  ; Checkerboard
           jsr  cout_mark

           lda  #48-1
           sta  HTab                  ; HTab 48

           lda  #'Z'
           jsr  cout_mark             ; |

           lda  #StdText
           jsr  cout_mark             ; Normal text

           jsr  SetInv

           lda  #' '+$80
           jsr  cout_mark             ; Inverse block

           lda  #Normal
           jsr  cout_mark

           ldx  #CloseTextE-CloseText
           ldy  #$00

PM_Line16_1:

           lda  CloseText,y
           jsr  cout_mark
           iny
           dex
           bne  PM_Line16_1

           lda  #Inverse
           jsr  cout_mark

           lda  #MouseText            ; Mousetext back on
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark             ; Inverse block

           lda  #'_'
           jsr  cout_mark

           lda  #61-1
           sta  HTab

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   1 7

           lda  #17-1                 ; Set to line 17
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x2
           pha                        ; Save character

           lda  #45-1
           sta  HTab                  ; HTab 45

           pla                        ; Restore character
           jsr  cout_mark

           lda  #'V'                  ; Checkerboard
           jsr  cout_mark

           lda  #49-1
           sta  HTab                  ; HTab 49

           jsr  SetNorm
           ldx  #10
           lda  #'\'                  ; 10 underscores

PM_Lin17_1:

           jsr  cout_mark
           dex
           bne  PM_Lin17_1

           lda  #61-1
           sta  HTab

           lda  #'_'                  ; Right side |
           jsr  cout_mark

;          L i n e   1 8

           lda  #18-1                 ; Set to line 18
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           lda  #'Z'                  ; Left side |
           jsr  cout_mark
           jsr  cout_mark             ; x 2

           lda  #45-1
           sta  HTab                  ; HTab 45

           lda  #'Z'
           jsr  cout_mark             ; |

           lda  #'Q'
           jsr  cout_mark             ; Down scroll arrow

           lda  #48-1
           sta  HTab                  ; HTab 48

           lda  #'Z'
           jsr  cout_mark             ; |

           lda  #StdText
           jsr  cout_mark             ; Normal text

           jsr  SetInv

           lda  #' '+$80
           jsr  cout_mark             ; Inverse block

           lda  #Normal
           jsr  cout_mark

           ldx  #CanclTextE-CanclText
           ldy  #$00

PM_Line18_1:

           lda  CanclText,y
           jsr  cout_mark
           iny
           dex
           bne  PM_Line18_1

           lda  #Inverse
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark             ; Inverse block

           lda  #MouseText            ; Mousetext back on
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           pha                        ; Save character to print
           lda  #61-1
           sta  HTab                  ; HTab 61

           pla                        ; Restore character
           jsr  cout_mark

;          L i n e   1 9

           lda  #19-1                 ; Set to line 19
           sta  VTab
           lda  #20-1                 ; Set to column 20
           sta  HTab

           jsr  SetVTab

           jsr  SetNorm

           lda  #'Z'                  ; Left side |
           jsr  cout_mark

           lda  #'_'+$80
           jsr  cout_mark             ; HTab 22

           ldx  #25
           lda  #'\'                  ; 25 underscores

PM_Lin19_1:

           jsr  cout_mark
           dex
           bne  PM_Lin19_1

           lda  #'_'+$80
           jsr  cout_mark
           jsr  cout_mark

           ldx  #10
           lda  #'\'                  ; 10 underscores

PM_Lin19_2:

           jsr  cout_mark
           dex
           bne  PM_Lin19_2

           lda  #'_'+$80
           jsr  cout_mark
           jsr  cout_mark

           lda  #'_'                  ; Right side |
           jsr  cout_mark

           jsr  SetNorm
           rts

DisksText:

           asc " Disks  "

DisksTextE:

OpenText:

           asc "  Open  "

OpenTextE:

CloseText:

           asc " Close  "

CloseTextE:

CanclText:

           asc " Cancel "

CanclTextE:

;
; Clear menu1 data area
;

ClearMenu1:

           lda  #20-1                 ; Start at HTab 20
           sta  HTab
           lda  #6-1                  ; Start at VTab 6
           sta  VTab
           jsr  SetVTab

           ldy  #15                   ; Total lines to wipe out

NextLine:

           phy                        ; Save y register
           lda  #' '+$80              ; Space character
           ldx  #42                   ; Character per line to wipe out

@NextChar:

           jsr  cout_mark             ; Print space
           dex                        ; Count space printed
           bne  @NextChar             ; More?

           lda  #20-1                 ; Line complete
           sta  HTab                  ; Set HTab back to 20
           inc  VTab                  ; Bump up VTAB
           jsr  SetVTab

           ply                        ; Restore y register
           dey                        ; Count line printed
           bne  NextLine              ; More

           rts                        ; Return
