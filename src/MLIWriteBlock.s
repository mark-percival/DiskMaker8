MLIWriteBlk:

;          MLI Write Block ($81) Call
;
;          Usage       : jsr MLIWriteBlock
;          Requirements: 'wrblkUnit' 1 byte unit number.
;                        'wrblkDataBuf' 512 byte buffer to be written.
;                        'wrblkBlockNum' 2 byte block number to write

MLICode_81  =   $81
;MLI         =   $BF00

           lda  wrblkUnit
           sta  @unit_num
           lda  wrblkBlockNum
           sta  @block_num
           lda  wrblkBlockNum+1
           sta  @block_num+1

           jsr  MLI
           .byte MLICode_81
           .addr @Parms

           bne  @CheckError             ; MLI error

           bra  @GoodError

@Parms:

@parm_count: .byte $03
@unit_num:   .res 1
@data_buf:   .addr wrblkDataBuf
@block_num:  .res 2

@CheckError:

           cmp  #$27                    ; IO Error
           beq  @GoodError
           cmp  #$28                    ; No device connected
           beq  @GoodError
           cmp  #$2B                    ; Disk write protect
           beq  @GoodError
           cmp  #$2F                    ; Device offline
           beq  @GoodError

           pha                          ; Save MLI error
           lda  #MLICode_81
           pha                          ; Save calling routine
           jmp  MLIError

@GoodError:

           cmp  #$00                    ; Set status register

           rts


