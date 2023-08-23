MLIRead:

;          MLI Read ($CA) Call
;
;          Usage       : jsr MLIRead
;          Requirements: 'readRef' 1 byte file reference number
;                        'readRequest' 2 byte number of byte to read
;                        'readBuf' destination data buffer
;          Returns     : 'readTrans' 2 byte number of bytes actually read
;                                    0 = EOF

ProDOSRead    =  $CA

           lda  readRef
           sta  @ref_num
           lda  readRequest
           sta  @req_count
           lda  readRequest+1
           sta  @req_count+1

           jsr  MLI
           .byte ProDOSRead
           .addr @Parms

           bne  @CheckError            ; MLI error

           bra  @GoodError

@Parms:

@parm_count: .byte $04
@ref_num:   .res  1
@data_buf:  .addr readBuf
@req_count: .res  2
@tran_count: .res  2

@CheckError:

           cmp  #$4C                  ; EOF error code
           beq  @GoodError

           pha                        ; Save MLI error
           lda  #ProDOSRead
           pha                        ; Save calling routine
           jmp  MLIError

@GoodError:

           pha                        ; Save error code
           lda  @tran_count           ; return byte transfer count
           sta  readTrans
           lda  @tran_count+1
           sta  readTrans+1
           pla                        ; Restore error code

           rts
