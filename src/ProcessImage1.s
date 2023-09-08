           jsr  InitVars

;          jsr  DebugData

           jsr  CheckSize               ; Check to see if image size matchs device
           bne  Canceled                ; selected.

           jsr  VerifyTarget            ; Make sure we can write to the device and
           bne  Canceled                ; format if necessary.

           sec
           lda  EndBlock                ; Subtract 1 from EndBlock since block
           sbc  #$01                    ;  numbers are zero based.
           sta  EndBlock
           lda  EndBlock+1
           sbc  #$00
           sta  EndBlock+1

           jsr  WriteImage

Canceled:

           rts

InitVars:

           lda  SelAddr
           sta  Ptr1
           lda  SelAddr+1
           sta  Ptr1+1

           ldy  #oUnitNo
           lda  (Ptr1),y
           sta  TargetUnit

           ldy  #oSizeHex
           lda  (Ptr1),y
           sta  TargetSize

           iny
           lda  (Ptr1),y
           sta  TargetSize+1

           ldy  #oDevType
           lda  (Ptr1),y
           sta  PI_DevType

           rts

TargetUnit: .res 1
TargetSize: .res 2
PI_DevType:    .res 1
Volume:     .res 1

; Test for image size and destination size to be same.

CheckSize:

           lda  ImageSize               ; Take current image size as default
           sta  EndBlock                ; number of blocks to write.
           lda  ImageSize+1
           sta  EndBlock+1

           lda  TargetSize+1
           cmp  ImageSize+1
           bcc  TooSmall
           beq  PI_SameSize

TooBig:

           jsr  BigBox
           bra  CheckExit

TooSmall:  jsr  SmallBox
           bra  CheckExit

PI_SameSize: lda  TargetSize
           cmp  ImageSize
           bcc  TooSmall
           beq  CheckExit
           bra  TooBig

CheckExit:

           rts

BigBox:

           lda  #<MsgBig
           sta  MsgPtr
           lda  #>MsgBig
           sta  MsgPtr+1

           jsr  Beep

           jsr  MsgOkCan2

           rts

MsgBig:    .byte "The destination disk is bigger than necessary.",$0d
           .byte "Do you wish to continue anyway?",$00

SmallBox:

           lda  TargetSize              ; Default size is set yo ImageSize at this
           sta  EndBlock                ; point and since the device we're writing
           lda  TargetSize+1            ; to isn't big enough, wen need to fall
           sta  EndBlock+1              ; short of writing the entire image.

           lda  #<MsgSmall
           sta  MsgPtr
           lda  #>MsgSmall
           sta  MsgPtr+1

           jsr  Beep

           jsr  MsgOkCan2

           rts

MsgSmall:  .byte "The destination disk is too small.",$0d
           .byte "Do you wish to continue anyway?",$00

SuccessBox:

           jsr  Beep

           lda  #$BF
           jsr  Wait

           jsr  Beep

           lda  #$BF
           jsr  Wait

           jsr  Beep

           lda  PI_DevType
           cmp  #RemapDev               ; Can't boot a remapped volume
           beq  NoBoot

           lda  TargetUnit
           bmi  NoBoot                  ; Can't boot drive 2

Bootable:

           lda  #<MsgBoot
           sta  MsgPtr
           lda  #>MsgBoot
           sta  MsgPtr+1

           jsr  MsgBootCan
           bne  BootExit                ; Not booting disk

CheckDisk:

           lda  TargetUnit
           sta  onlineUnit

           jsr  MLIOnLine               ; Make sure disk is still there.

           cmp  #$27                    ; IO Error?
           beq  WhereDisk

           cmp  #$2F                    ; Disk offline?
           beq  WhereDisk

           jsr  Home                    ; We are good so setup pointer to boot.

           clc
           lda  TargetUnit
           lsr  a
           lsr  a
           lsr  a
           lsr  a
           ora  #$C0

           sta  Ptr1+1
           stz  Ptr1

           ldx  #$FF                    ; POP all address off stack prior to boot
           txs

           jmp  (Ptr1)                  ; Boot

BootExit:

           rts

NoBoot:

           lda  #<MsgNoBoot
           sta  MsgPtr
           lda  #>MsgNoBoot
           sta  MsgPtr+1

           jsr  MsgOk

           rts

WhereDisk:

           lda  #<MsgWhere
           sta  MsgPtr
           lda  #>MsgWhere
           sta  MsgPtr+1

           jsr  MsgRetCan1
           beq  CheckDisk               ; Retry

           rts                          ; or cancel.

MsgNoBoot: .byte "Disk created",$0d
           .byte "successfully",$00

MsgBoot:   .byte "  Disk created successfully",$0d
           .byte "Do you wish to boot this disk?",$00

MsgWhere:  .byte "Error atempting to boot disk",$0d
           .byte "Please verify disk and retry",$00

PaintBox:

           lda  #MouseText
           jsr  cout

; First line

           lda  #4-1
           sta  VTab

           lda  #26-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           ldx  #27
           lda  #'L'

BP01:

           jsr  cout
           dex
           bne  BP01

           lda  #'_'
           jsr  cout

; Second line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldy  #0
           ldx  #9

BP02:

           lda  Text1,y
           jsr  cout
           iny
           dex
           bne  BP02

           ldx  Path
           ldy  #0

BP03:

           iny
           lda  Path,y
           ora  #$80
           jsr  cout
           dex
           bne  BP03

           lda  #'''+$80
           jsr  cout

           sec
           lda  #15
           sbc  Path

           ina
           tax
           lda  #' '+$80

BP04:

           jsr  cout
           dex
           bne  BP04

           lda  #'_'
           jsr  cout

; Third line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           ldx  #25
           lda  #'_'+$80

BP05:

           jsr  cout
           dex
           bne  BP05

           lda  #' '+$80
           jsr  cout

           lda  #'_'
           jsr  cout

; Fourth line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout
           jsr  cout

           ldx  #25
           lda  #' '+$80

BP06:

           jsr  cout
           dex
           bne  BP06

           lda  #'_'
           jsr  cout
           jsr  cout

; Fifth line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #'_'+$80
           jsr  cout

           ldx  #25
           lda  #'\'

BP07:

           jsr  cout
           dex
           bne  BP07

           lda  #'_'+$80
           jsr  cout

           lda  #'_'
           jsr  cout

           lda  #StdText
           jsr  cout

           rts

;          Msb  On
Text1:     asc "Writing '"
;          Msb  Off

ClearBox:

           lda  #4-1
           sta  VTab

           jsr  SetVTab

           ldx  #5                      ; 5 lines to erase

CB01:

           lda  #26-1
           sta  HTab

           ldy  #29                     ; 29 characters per line

           lda  #' '+$80

CB02:

           jsr  cout
           dey
           bne  CB02

           inc  VTab
           jsr  SetVTab

           dex
           bne  CB01

           rts

ShowFormat:

; First line.

           lda  #12-1
           sta  VTab
           lda  #32-1
           sta  HTab

           jsr  SetVTab

           lda  #MouseText
           jsr  cout

           lda  #'Z'
           jsr  cout

           ldx  #16
           lda  #'L'

SF01:

           jsr  cout
           dex
           bne  SF01

           lda  #'_'
           jsr  cout

; Second line

           inc  VTab
           lda  #32-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           ldx  #3
           lda  #' '+$80

SF02:      jsr  cout
           dex
           bne  SF02

           ldy  #0
           ldx  #10

SF03:

           lda  FmtMsg,y
           jsr  cout
           iny
           dex
           bne  SF03

           ldx  #3
           lda  #' '+$80

SF04:

           jsr  cout
           dex
           bne  SF04

           lda  #'_'
           jsr  cout

; Third line

           inc  VTab
           lda  #32-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           ldx  #16
           lda  #'_'+$80

SF05:

           jsr  cout
           dex
           bne  SF05

           lda  #'_'
           jsr  cout

           lda  #StdText
           jsr  cout

           rts

;          Msb  On
FmtMsg:    asc  "Formatting"   
;          Msb  Off

ClrFormat:

           lda  #12-1
           sta  VTab

           jsr  SetVTab

           ldx  #3                      ; 3 lines to erase

CF01:

           lda  #32-1
           sta  HTab

           ldy  #18                     ; 18 characters per line

           lda  #' '+$80

CF02:

           jsr  cout
           dey
           bne  CF02

           inc  VTab
           jsr  SetVTab

           dex
           bne  CF01

           rts

; DebugData  anop

;          lda  #30-1
;          sta  HTab
;          lda  #18-1
;          sta  VTab
;
;          jsr  SetVTab
;
;          lda  #'S'+$80
;          jsr  cout
;
;          lda  #'='+$80
;          jsr  cout
;
;          lda  #'$'+$80
;          jsr  cout
;
;          lda  ImageSize+1
;          jsr  PrByte
;
;          lda  ImageSize
;          jsr  PrByte
;
;          lda  #' '+$80
;          jsr  cout
;          jsr  cout
;
;          lda  #'T'+$80
;          jsr  cout
;
;          lda  #'='+$80
;          jsr  cout
;
;          lda  #'$'+$80
;          jsr  cout
;
;          lda  TargetUnit
;          jsr  PrByte
;
;          lda  #' '+$80
;          jsr  cout
;
;          lda  #'$'+$80
;          jsr  cout
;
;          lda  TargetSize+1
;          jsr  PrByte
;          lda  TargetSize
;          jsr  PrByte
;
;          lda  #' '+$80
;          jsr  cout
;
;          lda  PI_DevType
;          jsr  PrHex
;
;          rts

VerifyTarget:

           jsr  GetVolNum               ; Get DOS 3.3 volume number

ReVerify:

           lda  TargetUnit
           sta  onlineUnit

           jsr  MLIOnLine               ; Check status of target

           cmp  #$2F                    ; *** Device off-line error ***
           bne  VT01

           jsr  OffLine
           bne  VTExit                  ; He decided to Cancel
           bra  ReVerify                ; Retry

VT01:

           ldy  OptionKey               ; Option key held?

           bmi  VT01a                   ; Force a format

           cmp  #$27                    ; IO Error (unformatted?)
           bne  VT02

VT01a:

           ldy  Volume                  ; DOS 3.3 volume number if 0.
           bne  VT01b

           jsr  FormatReq
           bne  VTExit                  ; He canceled format

VT01b:

           jsr  ShowFormat              ; Formatting message
           jsr  FormatDev               ; Format device.
           php                          ; Save error status.
           jsr  ClrFormat               ; Clear formatting message.
           plp                          ; Restore error status.
           bne  VTExit                  ; Formatting error.

           bra  ReVerify                ; Check to see if volume is now ok.

VT02:

           cmp  #$52                    ; Non-ProDOS disk
           bne  VT02a                   ; No, check for ProDOS disk...

           ldy  Volume                  ; Yes, look if DOS 3.3
           bne  VT01b                   ; DOS 3.3 so format disk.

           beq  VTExit                  ; Always taken

VT02a:

           cmp  #0                      ; ProDOS disk
           beq  VT03

           lda  #<MsgMLI                ; Other MLI error
           sta  MsgPtr
           lda  #>MsgMLI
           sta  MsgPtr+1

           jsr  MsgOk

           bra  VTExit

MsgMLI:    .byte "MLIError from MLI_ONLINE call.",$00

VT03:

           jsr  ProDOSWipe              ; Destroying ProDOS volume?

           bne  VTExit                  ; He decided to cancel.

           ldy  Volume                  ; He's ok with wiping out volume
           bne  VT01b                   ; so see if DOS 3.3 format required.

VTExit:

           rts

OffLine:

           lda  #<MsgOffLine
           sta  MsgPtr
           lda  #>MsgOffLine
           sta  MsgPtr+1

           jsr  Beep
           jsr  MsgRetCan1

           rts

;          Msb  On
MsgOffLine: ascz "No disk loaded in device."
;          Msb  Off

ProDOSWipe:

           lda  onlineBuf
           and  #$0F

           tax
           ldy  #0

PW01:

           lda  onlineBuf+1,y
           ora  #$80
           sta  VolName,y
           iny
           dex
           bne  PW01

           lda  #'''+$80
           sta  VolName,y

           cpy  #15
           beq  NoPadding

           lda  #$0D

SpacePadding:

           iny
           sta  VolName,y
           cpy  #15
           bcc  SpacePadding

NoPadding:

           lda  #<MsgWipe
           sta  MsgPtr
           lda  #>MsgWipe
           sta  MsgPtr+1

           jsr  Beep
           jsr  MsgOkCan2

           rts

MsgWipe:   .byte "You are about to erase ProDOS volume '"
VolName:   .res 16
           .byte $0D
           .byte "Do you wish to continue anyway?",$00

FormatReq:

           lda  #<FormatMsg
           sta  MsgPtr
           lda  #>FormatMsg
           sta  MsgPtr+1

           jsr  Beep
           jsr  MsgFmtCan1

           rts

FormatMsg: .byte "The destination disk appears to be unformatted.",$0d
           .byte "Would you like to format this volume?",$00

; Format device

FormatDev:

           lda  PI_DevType
           cmp  #DiskIIDev
           bne  PI_Smartport

DiskII:                                 ; Disk ][ device

           lda  Volume
           bne  HaveVolNum

           lda  #$FE                    ; Default volume number

HaveVolNum:

           sta  HyperFormat+5
           lda  TargetUnit
           sta  HyperFormat+6

           jsr  HyperFormat

           stz  Volume

           rts

PI_Smartport:                           ; Standard Smartport device

           jsr  ProFormat

           rts


; Do a ProDOS driver format call.

ProFormat:

;DevAddr     =   $BF10

           lda  onlineUnit              ; Compute slot/drive offset by dividing
           lsr  a                       ; unit number by 16.
           lsr  a
           lsr  a
           tax                          ; Move offset to index.

           lda  DevAddr,x               ; Get low byte of ProDOS driver address
           sta  Ptr2
           inx
           lda  DevAddr,x               ; Get high byte of ProDOS driver address
           sta  Ptr2+1

           php                          ; Save status
           sei                          ; Interrupts off

           lda  #3
           sta  $42                     ; Format call

           lda  onlineUnit
           sta  $43                     ; Unit number

           lda  #<Buffer512
           sta  $44
           lda  #>Buffer512
           sta  $45

           lda  #0
           sta  $46
           sta  $47

           lda  $C08B                   ; Read and write enable the language card
           lda  $C08B                   ;  with bank 1 on.

           jsr  @CallDriver              ; Call ProDOS driver.

           bit  $C082                   ; Put ROM back on-line
           beq  @OkError

           plp                          ; Restore status

           jsr  WriteError

           lda  #$01                    ; Zero zero bit to indicate error

           rts

@OkError:

           plp                          ; Restore status

           lda  #$00                    ; Clear A to indicate no error.

           rts

@CallDriver:

           jmp  (Ptr2)
