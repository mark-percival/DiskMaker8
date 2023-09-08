MLISetMark:

;          MLI SET_MARK ($CE) Call
;
;          Usage       : jsr MLISetMark
;          Requirements: 'setMarkRef' 1 byte file reference number
;                        'setMarkPos' 3 byte absolute position to move to
;          Returns     : Nothing
;

MLICode_CE  =   $CE
;MLI         =   $BF00

           lda  setMarkRef
           sta  @ref_num

           lda  setMarkPos
           sta  @position

           lda  setMarkPos+1
           sta  @position+1

           lda  setMarkPos+2
           sta  @position+2

           jsr  MLI
           .byte MLICode_CE
           .addr @Parms

           bne  @CheckError             ; MLI error

           bra  @GoodError

@Parms:

@parm_count: .byte $02
@ref_num:    .res 1
@position:   .res 3

@CheckError:

           pha                          ; Save MLI error
           lda  #MLICode_CE
           pha                          ; Save calling routine
           jmp  MLIError

@GoodError:

           rts


