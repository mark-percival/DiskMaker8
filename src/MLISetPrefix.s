MLISetPrefix:

;          MLI Set Prefix($C6) Call
;
;          Usage       : jsr MLISetPrefix
;          Requirements: buffer named 'Prefix' 64 bytes long

ProDOSSetPrefix    =  $C6

           jsr  MLI
           .byte ProDOSSetPrefix
           .addr @Parms
           bne  @CheckError
           rts

@Parms:

           .byte $01
           .addr Prefix

@CheckError:

           pha                        ; Save MLI error
           lda  #ProDOSSetPrefix
           pha                        ; Save calling routine
           jmp  MLIError
