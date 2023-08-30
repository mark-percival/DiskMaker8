;
; Paint basic frame for menu 2
;

PaintMenu2:

;   L i n e   8

           lda  #8-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #MouseText
           jsr  cout_mark

           lda  #'Z'
           jsr  cout_mark             ; Left |

           ldx  #48
           lda  #'L'                  ; Top of box

L8Loop1:

           jsr  cout_mark
           dex
           bne  L8Loop1

           lda  #'_'
           jsr  cout_mark             ; Right |

;   L i n e   9

           inc  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark             ; Left side |

           lda  #18-1                 ; Skip a space
           sta  HTab

           ldy  #0
           ldx  #PMLine9TextE-PMLine9Text

L9Loop1:

           lda  PMLine9Text,y
           jsr  cout_mark
           iny
           dex
           bne  L9Loop1

           lda  #47-1
           sta  HTab                  ; Skip a space

           lda  #'''+$80              ; Quote
           jsr  cout_mark

           ldx  Path
           ldy  #0

L9Loop2:

           iny
           lda  Path,y
           ora  #$80
           jsr  cout_mark
           dex
           bne  L9Loop2

           lda  #'''+$80              ; Quote
           jsr  cout_mark

           lda  #65-1
           sta  HTab                  ; Skip a space

           lda  #'_'
           jsr  cout_mark             ; Right side |

;   L i n e   1 0

           lda  #16-1
           sta  HTab
           inc  VTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark             ; Left side |

           lda  #18-1
           sta  HTab

           ldx  #29
           lda  #'_'+$80              ; Underscore

L10Loop1:

           jsr  cout_mark
           dex
           bne  L10Loop1

           lda  #50-1
           sta  HTab

           ldx  #13
           lda  #'_'+$80

L10Loop2:

           jsr  cout_mark
           dex
           bne  L10Loop2

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark             ; Right side |

;   L i n e   1 1

           lda  #11-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #18-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

           lda  #45-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'R'
           jsr  cout_mark

           lda  #49-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark
           lda  #' '
           jsr  cout_mark

           ldx  #11
           ldy  #1

L11Loop1:

           lda  AboutText_M2,y
           jsr  cout_mark
           iny
           dex
           bne  L11Loop1

           lda  #' '
           jsr  cout_mark

           lda  #MouseText
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;   L i n e   1 2

           lda  #12-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #18-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

           lda  #45-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'V'
           jsr  cout_mark

           lda  #50-1
           sta  HTab

           ldx  #13
           lda  #'\'

L12Loop1:

           jsr  cout_mark
           dex
           bne  L12Loop1

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;   L i n e   1 3

           lda  #13-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #18-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

           lda  #45-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'V'
           jsr  cout_mark

           lda  #49-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark
           lda  #' '
           jsr  cout_mark

           ldx  #11
           ldy  #1

L13Loop1:

           lda  SkipText_M2,y
           jsr  cout_mark
           iny
           dex
           bne  L13Loop1

           lda  #' '
           jsr  cout_mark

           lda  #MouseText
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;   L i n e   1 4

           lda  #14-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #18-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

           lda  #45-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'V'
           jsr  cout_mark

           lda  #50-1
           sta  HTab

           ldx  #13
           lda  #'\'

L14Loop1:

           jsr  cout_mark
           dex
           bne  L14Loop1

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;   L i n e   1 5

           lda  #15-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #18-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

           lda  #45-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'Q'
           jsr  cout_mark

           lda  #49-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark
           lda  #' '
           jsr  cout_mark

           ldx  #11
           ldy  #1

L15Loop1:

           lda  MakeText_M2,y
           jsr  cout_mark
           iny
           dex
           bne  L15Loop1

           lda  #' '
           jsr  cout_mark

           lda  #MouseText
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;   L i n e   16

           lda  #16-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #18-1
           sta  HTab

           ldx  #22
           lda  #'\'

L16Loop1:

           jsr  cout_mark
           dex
           bne  L16Loop1

           lda  #'L'
           jsr  cout_mark
           jsr  cout_mark

           lda  #'\'
           jsr  cout_mark

           ldx  #4
           lda  #'L'

L16Loop2:

           jsr  cout_mark
           dex
           bne  L16Loop2

           lda  #50-1
           sta  HTab

           ldx  #13
           lda  #'L'

L16Loop3:

           jsr  cout_mark
           dex
           bne  L16Loop3

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;   L i n e   1 7

           lda  #17-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #18-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

           jsr  PrtImgType

           lda  #39-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #41-1
           sta  HTab

           lda  #'Z'
           jsr  cout_mark

           lda  #43-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

           ldy  #0
           ldx  #Line17TexE-Line17Text

L17Loop1:

           lda  Line17Text,y
           jsr  cout_mark
           iny
           dex
           bne  L17Loop1

           lda  #65-1
           sta  HTab

           lda  #'_'
           jsr  cout_mark

;   L i n e   1 8

           lda  #18-1
           sta  VTab
           lda  #16-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'_'+$80
           jsr  cout_mark

           ldx  #22
           lda  #'\'

L18Loop1:

           jsr  cout_mark
           dex
           bne  L18Loop1

           lda  #'_'+$80
           jsr  cout_mark
           jsr  cout_mark

           lda  #'\'
           jsr  cout_mark

           ldx  #22
           lda  #'_'+$80

L18Loop2:

           jsr  cout_mark
           dex
           bne  L18Loop2

           lda  #'_'
           jsr  cout_mark

           rts

PMLine9Text: asc "Select target for the image:"
PMLine9TextE:

Line17Text: asc "Same-size disks only"
Line17TexE:

;
; Clear menu2 data area
;

ClearMenu2:

           lda  #16-1                 ; Start at HTab 16
           sta  HTab
           lda  #8-1                  ; Start at VTab 8
           sta  VTab
           jsr  SetVTab

           ldy  #11                   ; Total lines to wipe out

@NextLine:

           phy                        ; Save y register
           lda  #' '+$80              ; Space character
           ldx  #50                   ; Character per line to wipe out

@NextChar:

           jsr  cout_mark             ; Print space
           dex                        ; Count space printed
           bne  @NextChar             ; More?

           lda  #16-1                 ; Line complete
           sta  HTab                  ; Set HTab back to 17
           inc  VTab                  ; Bump up VTAB
           jsr  SetVTab

           ply                        ; Restore y register
           dey                        ; Count line printed
           bne  @NextLine             ; More

           rts                        ; Return
