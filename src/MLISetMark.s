MLISetMark:

;          MLI SET_MARK ($CE) Call
;
;          Usage       : jsr MLISetMark
;          Requirements: 'setMarkRef' 1 byte file reference number
;                        'setMarkPos' 3 byte absolute position to move to
;          Returns     : Nothing
;

           lda  setMarkRef
           sta  @ref_num

           lda  setMarkPos
           sta  @position

           lda  setMarkPos+1
           sta  @position+1

           lda  setMarkPos+2
           sta  @position+2

           jsr  MLI
           .byte MLI_SET_MARK
           .addr @Parms

           bne  @CheckError             ; MLI error

           bra  @GoodError

@Parms:

@parm_count: .byte $02
@ref_num:    .res 1
@position:   .res 3

@CheckError:

           pha                          ; Save MLI error
           lda  #MLI_SET_MARK
           pha                          ; Save calling routine
           jmp  MLIError

@GoodError:

           rts


