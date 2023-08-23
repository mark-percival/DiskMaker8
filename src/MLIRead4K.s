MLIRead4K:

;          MLI Read ($CA) Call
;
;          Usage       : jsr MLIRead
;          Requirements: 'readRef' 1 byte file reference number
;                        'readRequest' 2 byte number of byte to read
;                        'readBuf' destination data buffer
;          Returns     : 'readTrans' 2 byte number of bytes actually read
;                                    0 = EOF

           lda  readRef
           sta  r4k_ref_num
           stz  r4k_req_count
           lda  #$10
           sta  r4k_req_count+1

           jsr  MLI
           .byte ProDOSRead
           .addr Read4KParms

           bne  @CheckError           ; MLI error

           bra  @GoodError

@CheckError:

           cmp  #$4C                  ; EOF error code
           beq  @GoodError

           pha                        ; Save MLI error
           lda  #ProDOSRead
           pha                        ; Save calling routine
           jmp  MLIError

@GoodError:

           pha                        ; Save error code
           lda  r4k_tran_count        ; return byte transfer count
           sta  readTrans
           lda  r4k_tran_count+1
           sta  readTrans+1
           pla                        ; Restore error code

           rts

Read4KParms:

r4k_parm_count: .byte $04
r4k_ref_num:   .byte $00
r4k_data_buf:  .addr Buffer8K
r4k_req_count: .res  2
r4k_tran_count: .res 2
