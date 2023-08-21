Beep       Start

*
*          Beep speaker
*

Wait       equ  $FCA8
Speaker    equ  $C030

           lda  #$20
           sta  Length

B1         lda  #$02
           jsr  Wait
           sta  Speaker
           lda  #$24
           jsr  Wait
           sta  Speaker
           dec  Length
           bne  B1

           rts

Length     ds   1

           End
