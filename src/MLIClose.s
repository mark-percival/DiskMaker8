MLIClose:

;          MLI Close($CC) Call
;
;          Usage       : jsr MLIClose
;          Requirements: 'closeRef' 1 byte file reference number
;          Returns     : None.

MLICode_CC  =   $CC
;MLI         =   $BF00

           lda  closeRef
           sta  @ref_num

           jsr  MLI
           .byte MLICode_CC
           .addr @Parms

           bne  @CheckError              ; MLI error

           rts

@Parms:

@parm_count: .byte $01
@ref_num:    .res 1

@CheckError:

           pha                          ; Save MLI error
           lda  #MLICode_CC
           pha                          ; Save calling routine
           jmp  MLIError


