SetBackGrnd:

           lda  #' '+$80
           jsr  Init80                ; Put into 80 column mode
           jsr  Home                  ; Clear screen

;          L i n e   1

           jsr  SetInv                ; Inverse text

           lda  #MouseText
           jsr  cout                  ; Turn on mousetext

           lda  #'Z'
           jsr  cout                  ; Print left |

           lda  #StdText
           jsr  cout

           lda  #' '+$80              ; Set space to print
           ldx  #15                   ; Index 14 spaces

PrintNext1:

           jsr  cout                  ; print space
           dex                        ; count space
           bne  PrintNext1            ; Branch if more to print

           ldx  #HeaderEnd-Header     ; Load header byte size
           ldy  #$00                  ; zero index

PrintNext2:

           lda  Header,y              ; Load header character
           jsr  cout                  ; Print it
           iny                        ; increment index
           dex                        ; count character printed
           bne  PrintNext2            ; more to print, get next character

           ldx  #16
           lda  #' '+$80              ; Setup for 16 spaces

PrintNext3:

           jsr  cout                  ; Print space
           dex                        ; count it
           bne  PrintNext3            ; More?
           lda  #MouseText
           jsr  cout                  ; Turn on mousetext

           lda  #'_'
           jsr  cout                  ; print right |

;          L i n e   2   t h r o u g h   23

           ldx  #22                   ; 22 identical lines

PrintNext4:

           lda  #1-1
           sta  HTab

           lda  #'Z'
           jsr  cout

           lda  #80-1
           sta  HTab

           lda  #'_'
           jsr  cout

           dex
           bne  PrintNext4

;          L i n e   2 4

           lda  #1-1
           sta  HTab                  ; Tab 1st column

           lda  #'Z'
           jsr cout

           lda  #StdText
           jsr  cout

           jsr  SetNorm

           ldx  #78                   ; Print only 77

           lda  #'_'+$80              ; Print _ on bottom.

PrintNext5:

           jsr  cout
           dex
           bne  PrintNext5

           lda  #$5F
           sta  $07F7                 ; Force | into last position

           jsr  SetNorm               ; Back to normal text

           rts

Header:    asc "DiskMaker 8 v1.1 - Copyright 2006 Mark Percival"
HeaderEnd:
