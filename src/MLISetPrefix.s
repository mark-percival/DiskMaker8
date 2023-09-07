MLISetPrefix:

;          MLI Set Prefix($C6) Call
;
;          Usage       : jsr MLISetPrefix
;          Requirements: buffer named 'prefix' 64 bytes long

MLICode_C6  =   $C6
;MLI         =   $BF00

           jsr  MLI
           .byte MLICode_C6
           .addr @Parms
           bne  @CheckError
           rts

@Parms:

           .byte $01
           .addr Prefix

@CheckError:

           pha                          ; Save MLI error
           lda  #MLICode_C6
           pha                          ; Save calling routine
           jmp  MLIError


