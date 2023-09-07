MLIOnLine:

;          MLI OnLine($C5) Call
;
;          Usage       : jsr MLIOnLine
;          Requirements: onlineUnit = 1 byte unit number
;                        onlineBuf = 256 byte data buffer

MLICode_C5  =   $C5
;MLI         =   $BF00

           lda  onlineUnit
           sta  @Unit_Num

           jsr  MLI
           .byte MLICode_C5
           .addr @Parms
           bne  @CheckError

@OkError:

           rts

@Parms:

           .byte $02
@Unit_Num: .byte $00
@DataBuffer: .addr onlineBuf

@CheckError:

           cmp  #$27                    ; I/O Error
           beq  @OkError
           cmp  #$28                    ; No Device Connected
           beq  @OkError
           cmp  #$2F                    ; Device Off-line
           beq  @OkError
           cmp  #$52                    ; Not a ProDOS disk
           beq  @OkError
           pha                          ; Save MLI error
           lda  #MLICode_C5
           pha                          ; Save calling routine
           jmp  MLIError


