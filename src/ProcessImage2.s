; Write image to device.

WriteImage:

           jsr  PaintBox                ; Put "Writing" box on screen.

           jsr  InitProgBar             ; Initialize progressbar variables

           stz  CurrBlock               ; Start at writing at block zero.
           stz  CurrBlock+1

           ldx  #$07

           jsr  InitMarker

           lda  ImageType
           cmp  #Type_DO
           bne  StdImage

DOImage:   lda  PDosOrder,x             ; Table to convert DO image to PO
           sta  SectorTable,x           ;  for block write.
           dex
           bpl  DOImage
           bra  Skip1

StdImage:  lda  StdOrder,x              ; Standard sector order so no conversion
           sta  SectorTable,x           ;  required.
           dex
           bpl  StdImage

Skip1:     lda  TargetUnit              ; Setup target unit number for write block
           sta  wrblkUnit

           jsr  MLIOpen1                ; Open disk image.
           lda  openRef1                ; Save file references.
           sta  setMarkRef
           sta  readRef
           sta  closeRef

           jsr  MLISetMark

Process4K: jsr  MLIRead4K

           ldx  #$00

ProcBlock: lda  #<Buffer8K
           sta  Ptr1
           lda  #>Buffer8K
           sta  Ptr1+1
           lda  SectorTable,x
           ldy  #$04

ShiftRight: lsr  a
           dey
           bne  ShiftRight

           sta  Offset

           clc
           lda  Ptr1+1
           adc  Offset
           sta  Ptr1+1

           ldy  #$00

@Loop1:    lda  (Ptr1),y
           sta  Buf512A,y
           iny
           bne  @Loop1

           lda  #>Buffer8K
           sta  Ptr1+1
           lda  SectorTable,x
           and  #$0F
           sta  Offset

           clc
           lda  Ptr1+1
           adc  Offset
           sta  Ptr1+1

@Loop2:     lda  (Ptr1),y
           sta  Buf512B,y
           iny
           bne  @Loop2

           lda  CurrBlock
           sta  wrblkBlockNum
           lda  CurrBlock+1
           sta  wrblkBlockNum+1

           jsr  MLIWriteBlk
           beq  GoodWrite
           jsr  WriteError
           jsr  MLIClose                ; Close files after error.
           bra  Done

GoodWrite:

           sec
           lda  counter
           sbc  #1
           sta  counter
           lda  counter+1
           sbc  #0
           sta  counter+1
           ora  counter

           bne  CheckForEnd

           jsr  MoveProgBar

CheckForEnd:

           lda  CurrBlock+1
           cmp  EndBlock+1
           bne  NextBlock
           lda  CurrBlock
           cmp  EndBlock
           beq  Success

NextBlock: inc  CurrBlock
           bne  NB01
           inc  CurrBlock+1

NB01:      inx
           cpx  #$08
           bcs  NB02
           jmp  ProcBlock
NB02:      jmp  Process4K

Success:

           jsr  MLIClose                ; Close files.

           jsr  SuccessBox
           lda  #Quit2                  ; Allows for exiting back to image
           sta  RC2                     ;  selection screen.

Done:      jsr  ClearBox

           rts

WriteError:

           cmp  #$27                    ; IO Error
           beq  IOError
           cmp  #$28                    ; No device connected
           beq  NoDevice
           cmp  #$2B                    ; Disk write protected
           beq  WriteProtect
           cmp  #$2F
           beq  DevOffline
           bra  Unknown

IOError:   lda  #<Msg27
           sta  MsgPtr
           lda  #>Msg27
           sta  MsgPtr+1
           jmp  PrintErr

NoDevice:  lda  #<Msg28
           sta  MsgPtr
           lda  #>Msg28
           sta  MsgPtr+1
           jmp  PrintErr

WriteProtect: lda #<Msg2B
           sta  MsgPtr
           lda  #>Msg2B
           sta  MsgPtr+1
           jmp  PrintErr

DevOffline: lda #<Msg2F
           sta  MsgPtr
           lda  #>Msg2F
           sta  MsgPtr+1
           jmp  PrintErr

Unknown:   tay
           clc
           lsr  a
           lsr  a
           lsr  a
           lsr  a
           tax
           lda  ASCIITable,x
           sta  PError
           tya
           and  #$0F
           tax
           lda  ASCIITable,x
           sta  PError+1

           lda  #<MsgUnk
           sta  MsgPtr
           lda  #>MsgUnk
           sta  MsgPtr+1

PrintErr:  jsr  Beep
           jsr  MsgOk
           rts

Msg27:     asccr "Error encountered writing image"
           ascz  "           IO Error"

Msg28:     asccr "Error encountered writing image"
           ascz  "     Device not connected"

Msg2B:     asccr "Error encountered writing image"
           ascz  "      Write protect error"

Msg2F:     asccr "Error encountered writing image"
           ascz "        Device offline"

MsgUnk:    asccr "Error encountered writing image"
           asc   "ProDOS error "
PError:    ascz  "xx Encountered."

Offset:    .res  1

StdOrder:  .byte $01, $23, $45, $67, $89, $AB, $CD, $EF
PDosOrder: .byte $0E, $DC, $BA, $98, $76, $54, $32, $1F
SectorTable: .res 8

;
; Initialize progress bar variables
;

InitProgBar:

           lda  EndBlock
           sta  acc
           lda  EndBlock+1
           sta  acc+1
           lda  #25
           sta  aux
           stz  aux+1

           jsr  Divide

           lda  acc
           sta  BlkPerInd
           sta  counter
           lda  acc+1
           sta  BlkPerInd+1
           sta  counter+1

           stz  Indicators

           rts

BlkPerInd: .res 2
counter:   .res 2
Indicators: .res 1

;
; Move progress bar
;

MoveProgBar:

           inc  Indicators

           lda  #7-1
           sta  VTab

           clc
           lda  #27-1
           adc  Indicators
           sta  HTab

           jsr  SetVTab

           lda  #' '
           jsr  cout

           lda  BlkPerInd
           sta  counter
           lda  BlkPerInd+1
           sta  counter+1

           rts

InitMarker:                             ; Initalize beginning of image marker

           stz  setMarkPos
           stz  setMarkPos+1
           stz  setMarkPos+2

           lda  ImageType
           cmp  #Type_2IMG              ; 2mg file header offset
           bne  NextCheck1

           lda  #64
           sta  setMarkPos
           rts

NextCheck1: cmp  #Type_DC               ; DiskCopy 4.2 header offset
           bne  NextCheck2

           lda  #84
           sta  setMarkPos

NextCheck2:

           rts


GetVolNum:                              ; Get DOS 3.3 volume number

           stz  Volume                  ; Default volume number

           lda  PI_DevType
           cmp  #DiskIIDev              ; Is this a Disk ][?
           bne  NotDOS33

           lda  ImageSize+1             ; Image too small?
           beq  NotDOS33

           jsr  InitMarker

           lda  #$10                    ; Track $11
           sta  setMarkPos+1

           lda  #$01
           sta  setMarkPos+2

           jsr  MLIOpen1

           lda  openRef1
           sta  setMarkRef
           sta  readRef
           sta  closeRef

           jsr  MLISetMark

           lda  #$FF                    ; Get 255 bytes (1 sector)
           sta  readRequest
           stz  readRequest+1

           jsr  MLIRead

           jsr  MLIClose

           ldx  #3
           lda  readBuf,x
           cmp  #3                      ; DOS release number
           bne  NotDOS33

           ldx  #$27
           lda  readBuf,x
           cmp  #$7A                    ; Max # track sect list pairs
           bne  NotDOS33

           ldx  #$34
           lda  readBuf,x
           cmp  #$23                    ; Tracks per diskette
           bne  NotDOS33

           ldx  #$35
           lda  readBuf,x
           cmp  #$10                    ; Sectors per track
           bne  NotDOS33

           ldx  #$36
           lda  readBuf,x
           cmp  #$00                    ; Bytes per sector - low
           bne  NotDOS33

           ldx  #$37
           lda  readBuf,x
           cmp  #$01                    ; Bytes per sector - high
           bne  NotDOS33

;          Good VTOC

           ldx  #$06
           lda  readBuf,x               ; Volume number
           sta  Volume

NotDOS33:

           rts
