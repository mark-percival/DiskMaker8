MLIOpen1:

;          MLI Open ($C8) Call
;
;          Usage       : jsr MLIOpen
;          Requirements: 'path' location of path to be opened
;                        'openBuf1' a 512 byte buffer
;          Returns     : 'openRef1' 1 byte file reference number

MLICode_C8  =   $C8
;MLI         =   $BF00

           jsr  MLI
           .byte MLICode_C8
           .addr @Parms

           pha                          ; Save possible MLI error code
           lda  @ref_num                ; Get file reference number
           sta  openRef1                ; Save reference number for user
           pla                          ; Restore possible MLI error code

           bne  @CheckError             ; MLI error
           rts

@Parms:

@parm_count: .byte $03
@path_name:  .addr Path
@io_buffer:  .addr openBuf1
@ref_num:    .res 1

@CheckError:

           pha                          ; Save MLI error
           lda  #MLICode_C8
           pha                          ; Save calling routine
           jmp  MLIError


