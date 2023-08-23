MLIGetPrefix:

;          MLI Get Prefix($C7) Call
;
;          Usage       : jsr MLIGetPrefix
;          Requirements: buffer named 'Prefix' 64 bytes long

ProDOSGetPrefix    =  $C7

           jsr  MLI
           .byte ProDOSGetPrefix
           .addr @Parms
           bne  @CheckError
           rts

@Parms:

           .byte $01
           .addr Prefix

@CheckError:

           pha                        ; Save MLI error
           lda  #ProDOSGetPrefix
           pha                        ; Save calling routine
           jmp  MLIError
