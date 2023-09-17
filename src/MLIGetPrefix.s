MLIGetPrefix:

;          MLI Get Prefix($C7) Call
;
;          Usage       : jsr MLIGetPrefix
;          Requirements: buffer named 'prefix' 64 bytes long

           jsr  MLI
           .byte MLI_GET_PREFIX
           .addr @Parms
           bne  @CheckError
           rts

@Parms:

           .byte $01
           .addr Prefix

@CheckError:

           pha                          ; Save MLI error
           lda  #MLI_GET_PREFIX
           pha                          ; Save calling routine
           jmp  MLIError


