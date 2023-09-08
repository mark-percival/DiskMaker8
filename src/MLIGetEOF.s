MLIGetEOF:

;          MLI GET_EOF ($D1) Call
;
;          Usage       : jsr MLIGetEOF
;          Requirements: 'geteofRef' 1 byte file reference number
;          Returns     : 'geteofEOF' 3 byte result containing the maximum number
;                                    of bytes that can be read from file

MLICode_D1   =   $D1
;MLI         =   $BF00

           lda  geteofRef
           sta  @ref_num

           jsr  MLI
           .byte MLICode_D1
           .addr @Parms

           bne  @CheckError              ; MLI error

           bra  @GoodError

@Parms:

@parm_count: .byte $02
@ref_num:    .res 1
@eof:        .res 3

@CheckError:

           pha                          ; Save MLI error
           lda  #MLICode_D1
           pha                          ; Save calling routine
           jmp  MLIError

@GoodError:

           pha                          ; Save error code
           lda  @eof
           sta  geteofEOF
           lda  @eof+1
           sta  geteofEOF+1
           lda  @eof+2
           sta  geteofEOF+2
           pla                          ; Restore error code

           rts


