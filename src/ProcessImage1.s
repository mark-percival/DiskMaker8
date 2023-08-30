           jsr  InitVars

;          jsr  DebugData

           jsr  CheckSize             ; Check to see if image size matchs device
           bne  Canceled              ; selected.

           jsr  VerifyTarget          ; Make sure we can write to the device and
           bne  Canceled              ; format if necessary.

           sec
           lda  EndBlock_M2           ; Subtract 1 from EndBlock_M2 since block
           sbc  #$01                  ;  numbers are zero based.
           sta  EndBlock_M2
           lda  EndBlock_M2+1
           sbc  #$00
           sta  EndBlock_M2+1

           jsr  WriteImage

Canceled:

           rts

InitVars:

           lda  SelAddr_M2
           sta  Ptr1
           lda  SelAddr_M2+1
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
           sta  PIDevType

           rts

TargetUnit: .byte   $00
TargetSize: .word   $0000
PIDevType:   .byte   $00
Volume:    .byte   $00

; Test for image size and destination size to be same.

CheckSize:

           lda  ImageSize_M2             ; Take current image size as default
           sta  EndBlock_M2              ; number of blocks to write.
           lda  ImageSize_M2+1
           sta  EndBlock_M2+1

           lda  TargetSize+1
           cmp  ImageSize_M2+1
           bcc  TooSmall
           beq  PISameSize

TooBig:

           jsr  BigBox
           bra  CheckExit

TooSmall:  jsr  SmallBox
           bra  CheckExit

PISameSize: lda  TargetSize
           cmp  ImageSize_M2
           bcc  TooSmall
           beq  CheckExit
           bra  TooBig

CheckExit:

           rts

BigBox:

           lda  #<MsgBig
           sta  MsgPtr
           lda  #>MsgBig+1
           sta  MsgPtr+1

           jsr  Beep

           jsr  MsgOkCan2

           rts

MsgBig:    asccr "The destination disk is bigger than necessary."
           ascz  "Do you wish to continue anyway?"

SmallBox:

           lda  TargetSize            ; Default size is set yo ImageSize_M2 at this
           sta  EndBlock_M2              ; point and since the device we're writing
           lda  TargetSize+1          ; to isn't big enough, wen need to fall
           sta  EndBlock_M2+1            ; short of writing the entire image.

           lda  #<MsgSmall
           sta  MsgPtr
           lda  #>MsgSmall+1
           sta  MsgPtr+1

           jsr  Beep

           jsr  MsgOkCan2

           rts

MsgSmall:  asccr "The destination disk is too small."
           ascz  "Do you wish to continue anyway?"

SuccessBox:

           jsr  Beep

           lda  #$BF
           jsr  Wait

           jsr  Beep

           lda  #$BF
           jsr  Wait

           jsr  Beep

           lda  PIDevType
           cmp  #RemapDev             ; Can't boot a remapped volume
           beq  NoBoot

           lda  TargetUnit
           bmi  NoBoot                ; Can't boot drive 2

Bootable:

           lda  #<MsgBoot
           sta  MsgPtr
           lda  #>MsgBoot
           sta  MsgPtr+1

           jsr  MsgBootCan
           bne  BootExit              ; Not booting disk

CheckDisk:

           lda  TargetUnit
           sta  onlineUnit

           jsr  MLIOnLine             ; Make sure disk is still there.

           cmp  #$27                  ; IO Error?
           beq  WhereDisk

           cmp  #$2F                  ; Disk offline?
           beq  WhereDisk

           jsr  Home                  ; We are good so setup pointer to boot.

           clc
           lda  TargetUnit
           lsr  a
           lsr  a
           lsr  a
           lsr  a
           ora  #$C0

           sta  Ptr1+1
           stz  Ptr1

           ldx  #$FF                  ; POP all address off stack prior to boot
           txs

           jmp  (Ptr1)                ; Boot

BootExit:

           rts

NoBoot:

           lda  #<MsgNoBoot
           sta  MsgPtr
           lda  #>MsgNoBoot
           sta  MsgPtr+1

           jsr  MBMsgOk

           rts

WhereDisk:

           lda  #<MsgWhere
           sta  MsgPtr
           lda  #>MsgWhere
           sta  MsgPtr+1

           jsr  MsgRetCan1
           beq  CheckDisk             ; Retry

           rts                        ; or cancel.

MsgNoBoot: asccr "Disk created"
           ascz  "successfully"

MsgBoot:   asccr "  Disk created successfully"
           ascz  "Do you wish to boot this disk?"

MsgWhere:  asccr "Error atempting to boot disk"
           ascz  "Please verify disk and retry"

PaintBox:

           lda  #MouseText
           jsr  cout_mark

; First line

           lda  #4-1
           sta  VTab

           lda  #26-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           ldx  #27
           lda  #'L'

BP01:

           jsr  cout_mark
           dex
           bne  BP01

           lda  #'_'
           jsr  cout_mark

; Second line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           ldy  #0
           ldx  #9

BP02:

           lda  Text1,y
           jsr  cout_mark
           iny
           dex
           bne  BP02

           ldx  Path
           ldy  #0

BP03:

           iny
           lda  Path,y
           ora  #$80
           jsr  cout_mark
           dex
           bne  BP03

           lda  #'''+$80
           jsr  cout_mark

           sec
           lda  #15
           sbc  Path

           ina
           tax
           lda  #' '+$80

BP04:

           jsr  cout_mark
           dex
           bne  BP04

           lda  #'_'
           jsr  cout_mark

; Third line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #' '+$80
           jsr  cout_mark

           ldx  #25
           lda  #'_'+$80

BP05:

           jsr  cout_mark
           dex
           bne  BP05

           lda  #' '+$80
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

; Fourth line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark
           jsr  cout_mark

           ldx  #25
           lda  #' '+$80

BP06:

           jsr  cout_mark
           dex
           bne  BP06

           lda  #'_'
           jsr  cout_mark
           jsr  cout_mark

; Fifth line

           lda  #26-1
           sta  HTab
           inc  VTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           lda  #'_'+$80
           jsr  cout_mark

           ldx  #25
           lda  #'\'

BP07:

           jsr  cout_mark
           dex
           bne  BP07

           lda  #'_'+$80
           jsr  cout_mark

           lda  #'_'
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark

           rts

Text1:     asc "Writing '"

ClearBox:

           lda  #4-1
           sta  VTab

           jsr  SetVTab

           ldx  #5                    ; 5 lines to erase

CB01:

           lda  #26-1
           sta  HTab

           ldy  #29                   ; 29 characters per line

           lda  #' '+$80

CB02:

           jsr  cout_mark
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
           jsr  cout_mark

           lda  #'Z'
           jsr  cout_mark

           ldx  #16
           lda  #'L'

SF01:

           jsr  cout_mark
           dex
           bne  SF01

           lda  #'_'
           jsr  cout_mark

; Second line

           inc  VTab
           lda  #32-1
           sta  HTab
           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           ldx  #3
           lda  #' '+$80

SF02:      jsr  cout_mark
           dex
           bne  SF02

           ldy  #0
           ldx  #10

SF03:

           lda  FmtMsg,y
           jsr  cout_mark
           iny
           dex
           bne  SF03

           ldx  #3
           lda  #' '+$80

SF04:

           jsr  cout_mark
           dex
           bne  SF04

           lda  #'_'
           jsr  cout_mark

; Third line

           inc  VTab
           lda  #32-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout_mark

           ldx  #16
           lda  #'_'+$80

SF05:

           jsr  cout_mark
           dex
           bne  SF05

           lda  #'_'
           jsr  cout_mark

           lda  #StdText
           jsr  cout_mark

           rts

FmtMsg:    asc  "Formatting"

ClrFormat:

           lda  #12-1
           sta  VTab

           jsr  SetVTab

           ldx  #3                    ; 3 lines to erase

CF01:

           lda  #32-1
           sta  HTab

           ldy  #18                   ; 18 characters per line

           lda  #' '+$80

CF02:

           jsr  cout_mark
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
;          jsr  cout_mark
;
;          lda  #'='+$80
;          jsr  cout_mark
;
;          lda  #'$'+$80
;          jsr  cout_mark
;
;          lda  ImageSize_M2+1
;          jsr  PrByte
;
;          lda  ImageSize_M2
;          jsr  PrByte
;
;          lda  #' '+$80
;          jsr  cout_mark
;          jsr  cout_mark
;
;          lda  #'T'+$80
;          jsr  cout_mark
;
;          lda  #'='+$80
;          jsr  cout_mark
;
;          lda  #'$'+$80
;          jsr  cout_mark
;
;          lda  TargetUnit
;          jsr  PrByte
;
;          lda  #' '+$80
;          jsr  cout_mark
;
;          lda  #'$'+$80
;          jsr  cout_mark
;
;          lda  TargetSize+1
;          jsr  PrByte
;          lda  TargetSize
;          jsr  PrByte
;
;          lda  #' '+$80
;          jsr  cout_mark
;
;          lda  PIDevType
;          jsr  PrHex
;
;          rts

VerifyTarget:

           jsr  GetVolNum             ; Get DOS 3.3 volume number

ReVerify:

           lda  TargetUnit
           sta  onlineUnit

           jsr  MLIOnLine             ; Check status of target

           cmp  #$2F                  ; *** Device off-line error ***
           bne  VT01

           jsr  OffLine
           bne  VTExit                ; He decided to Cancel
           bra  ReVerify              ; Retry

VT01:

           ldy  OptionKey             ; Option key held?

           bmi  VT01a                 ; Force a format

           cmp  #$27                  ; IO Error (unformatted?)
           bne  VT02

VT01a:

           ldy  Volume                ; DOS 3.3 volume number if 0.
           bne  VT01b

           jsr  FormatReq
           bne  VTExit                ; He canceled format

VT01b:

           jsr  ShowFormat            ; Formatting message
           jsr  FormatDev             ; Format device.
           php                        ; Save error status.
           jsr  ClrFormat             ; Clear formatting message.
           plp                        ; Restore error status.
           bne  VTExit                ; Formatting error.

           bra  ReVerify              ; Check to see if volume is now ok.

VT02:

           cmp  #$52                  ; Non-ProDOS disk
           bne  VT02a                 ; No, check for ProDOS disk...

           ldy  Volume                ; Yes, look if DOS 3.3
           bne  VT01b                 ; DOS 3.3 so format disk.

           beq  VTExit                ; Always taken

VT02a:

           cmp  #0                    ; ProDOS disk
           beq  VT03

           lda  #<MsgMLI               ; Other MLI error
           sta  MsgPtr
           lda  #>MsgMLI
           sta  MsgPtr+1

           jsr  MBMsgOk

           bra  VTExit

MsgMLI:    ascz  "MLIError from MLI_ONLINE call."

VT03:

           jsr  ProDOSWipe            ; Destroying ProDOS volume?

           bne  VTExit                ; He decided to cancel.

           ldy  Volume                ; He's ok with wiping out volume
           bne  VT01b                 ; so see if DOS 3.3 format required.

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

MsgOffLine: ascz  "No disk loaded in device."

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

MsgWipe:   asc "You are about to erase ProDOS volume '"
VolName:   .res    16
           .byte $0D
           ascz  "Do you wish to continue anyway?"

FormatReq:

           lda  #<FormatMsg
           sta  MsgPtr
           lda  #>FormatMsg
           sta  MsgPtr+1

           jsr  Beep
           jsr  MsgFmtCan1

           rts

FormatMsg: asccr "The destination disk appears to be unformatted."
           ascz  "Would you like to format this volume?"

; Format device

FormatDev:

           lda  PIDevType
           cmp  #DiskIIDev
           bne  PISmartPort

DiskII:                               ; Disk ][ device

           lda  Volume
           bne  HaveVolNum

           lda  #$FE                  ; Default volume number

HaveVolNum:

           sta  HyperFormat+5
           lda  TargetUnit
           sta  HyperFormat+6

           jsr  HyperFormat

           stz  Volume

           rts

PISmartPort:                           ; Standard SmartPort device

           jsr  ProFormat

           rts


; Do a ProDOS driver format call.

ProFormat:

           lda  onlineUnit            ; Compute slot/drive offset by dividing
           lsr  a                     ; unit number by 16.
           lsr  a
           lsr  a
           tax                        ; Move offset to index.

           lda  DevAddr,x             ; Get low byte of ProDOS driver address
           sta  Ptr2
           inx
           lda  DevAddr,x             ; Get high byte of ProDOS driver address
           sta  Ptr2+1

           php                        ; Save status
           sei                        ; Interrupts off

           lda  #3
           sta  $42                   ; Format call

           lda  onlineUnit
           sta  $43                   ; Unit number

           lda  #<Buffer512
           sta  $44
           lda  #>Buffer512
           sta  $45

           lda  #0
           sta  $46
           sta  $47

           lda  $C08B                 ; Read and write enable the language card
           lda  $C08B                 ;  with bank 1 on.

           jsr  @CallDriver           ; Call ProDOS driver.

           bit  $C082                 ; Put ROM back on-line
           beq  @OkError

           plp                        ; Restore status

           jsr  WriteError

           lda  #$01                  ; Zero zero bit to indicate error

           rts

@OkError:

           plp                        ; Restore status

           lda  #$00                  ; Clear A to indicate no error.

           rts

@CallDriver:

           jmp  (Ptr2)
