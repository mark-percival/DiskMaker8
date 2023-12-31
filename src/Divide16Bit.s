Divide:

;
; 16 Bit Divide Routine
;
; acc / aux -> acc with remainder in ext
;
;          Define acc, aux and ext as 2 byte ZP locations
;
           lda  #0
           sta  ext+1
           ldx  #$10

Div1:

           asl  acc
           rol  acc+1
           rol  a
           rol  ext+1
           pha
           cmp  aux
           lda  ext+1
           sbc  aux+1
           bcc  Div2
           sta  ext+1
           pla
           sbc  aux
           pha
           inc  acc

Div2:

           pla
           dex
           bne  Div1
           sta  ext

           rts


