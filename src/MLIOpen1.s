MLIOpen1:

;          MLI Open ($C8) Call
;
;          Usage       : jsr MLIOpen
;          Requirements: 'Path' location of Path to be opened
;                        'openBuf1' a 512 byte buffer
;          Returns     : 'openRef1' 1 byte file reference number

ProDOSOpen    =  $C8

           jsr  MLI
           .byte ProDOSOpen
           .addr @OpenParms

           pha                        ; Save possible MLI error code
           lda  @ref_num               ; Get file reference number
           sta  openRef1              ; Save reference number for user
           pla                        ; Restore possible MLI error code

           bne  @OpenCheckError        ;  MLI error
           rts

@OpenParms:

@parm_count: .byte $03
@path_name: .addr Path
@io_buffer: .addr openBuf1
@ref_num:   .byte   $00

@OpenCheckError:

           pha                        ; Save MLI error
           lda  #ProDOSOpen
           pha                        ; Save calling routine
           jmp  MLIError
