MLIGetPrefix:

;          MLI Get Prefix($C7) Call
;
;          Usage       : jsr MLIGetPrefix
;          Requirements: buffer named 'prefix' 64 bytes long

MLICode_C7  =   $C7
;MLI         =   $BF00

           jsr  MLI
           .byte MLICode_C7
           .addr @Parms
           bne  @CheckError
           rts

@Parms:

           .byte $01
           .addr Prefix

@CheckError:

           pha                          ; Save MLI error
           lda  #MLICode_C7
           pha                          ; Save calling routine
           jmp  MLIError


