MLISetPrefix:

;          MLI Set Prefix($C6) Call
;
;          Usage       : jsr MLISetPrefix
;          Requirements: buffer named 'prefix' 64 bytes long

           jsr  MLI
           .byte MLI_SET_PREFIX
           .addr @Parms
           bne  @CheckError
           rts

@Parms:

           .byte $01
           .addr Prefix

@CheckError:

           pha                          ; Save MLI error
           lda  #MLI_SET_PREFIX
           pha                          ; Save calling routine
           jmp  MLIError


