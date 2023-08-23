MLIOnLine:

;          MLI OnLine($C5) Call
;
;          Usage       : jsr MLIOnLine
;          Requirements: onlineUnit = 1 byte unit number
;                        onlineBuf = 256 byte data buffer

ProDOSOnline    =  $C5

           lda  onlineUnit
           sta  @Unit_Num

           jsr  MLI
           .byte ProDOSOnline
           .addr @Parms
           bne  @CheckError

@OkError:

           rts

@Parms:

           .byte $02
@Unit_Num:  .byte $00
@DataBuffer: .addr onlineBuf

@CheckError:

           cmp  #$27                  ; I/O Error
           beq  @OkError
           cmp  #$28                  ; No Device Connected
           beq  @OkError
           cmp  #$2F                  ; Device Off-line
           beq  @OkError
           cmp  #$52                  ; Not a ProDOS disk
           beq  @OkError
           pha                        ; Save MLI error
           lda  #ProDOSOnline
           pha                        ; Save calling routine
           jmp  MLIError
