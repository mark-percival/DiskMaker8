MLIClose:

;          MLI Close($CC) Call
;
;          Usage       : jsr MLIClose
;          Requirements: 'closeRef' 1 byte file reference number
;          Returns     : None.

ProDOSClose    =  $CC

           lda  closeRef
           sta  @ref_num

           jsr  MLI
           .byte ProDOSClose
           .addr @Parms

           bne  @CheckError           ; MLI error

           rts

@Parms:

@parm_count: .byte  $01
@ref_num:   .byte   $00

@CheckError:

           pha                        ; Save MLI error
           lda  #ProDOSClose
           pha                        ; Save calling routine
           jmp  MLIError
