Beep:

;
;          Beep speaker
;

;Wait        =   $FCA8
;Speaker     =   $C030

           lda  #$20
           sta  Length

B1:        lda  #$02
           jsr  Wait
           sta  Speaker
           lda  #$24
           jsr  Wait
           sta  Speaker
           dec  Length
           bne  B1

           rts

Length:     .res 1


