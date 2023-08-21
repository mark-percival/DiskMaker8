*
* Load information on devices
*

LoadDevs   Start
           Using Menu2Vars

           lda  #Buffer8K
           sta  Ptr1
           lda  #>Buffer8K
           sta  Ptr1+1

           stz  DevEntCnt

           lda  #7                      7 slots to scan
           sta  Slot

SetUnitNo  anop

           asl  a                       Setup unit number by shifting slot
           asl  a                        number to left nibble.
           asl  a
           asl  a

           ldx  #RemapDev               Default to a remapped Smartport dev.
           stx  DevType

NextDrive  anop

           sta  onlineUnit              Setup unit no for call.
           jsr  MLIOnline               Call MLI Online

           cmp  #$28                    Device not connected error
           beq  Skip

           jsr  IsNetwork               Is this an Appleshare volume?
           bcs  Skip

           jsr  GetDevSize              Get valid device block size

           lda  DevSize                 Couldn't find size so skip.
           ora  DevSize+1
           beq  Skip

           lda  blnSize                 See if Same Size checkbox is on
           beq  SizeOk                  No, so process save device info.

           lda  ImageSize+1             Check to see if the device size
           cmp  DevSize+1               matches the image size we have.
           bne  Skip

           lda  ImageSize
           cmp  DevSize
           bne  Skip

SizeOk     anop

           inc  DevEntCnt               Valid device, count it.
           jsr  SaveDevInfo             Save device data to buffer.

Skip       anop

           lda  onlineUnit              Have we tested drive 2 for this slot?
           bmi  NextSlot                Yes so go to next slot.

           ora  #%10000000              Set to drive 2 and
           bra  NextDrive                test device.

NextSlot   anop

           dec  Slot                    Move to next slot.
           lda  Slot                    Are we now at slot 0?
           bne  SetUnitno               No so test for device.

           rts

Slot       ds   1
DevSize    ds   2
DevType    ds   1

* Check to see if we have an Appleshare unit number in accumulator.

IsNetwork  anop

           ldy  #0
           ldx  NetDevCnt
           beq  IN95                    No network volumes

IN01       anop

           lda  NetDevs,y
           cmp  onlineUnit
           beq  IN90

           iny
           dex
           bne  IN01
           bra  IN95

In90       anop

           sec
           rts

IN95       anop

           clc
           rts

GetDevSize anop

           lda  #$C0                    Set up slot address
           ora  Slot
           sta  Ptr2+1

           lda  #$01                    1st ID byte
           sta  Ptr2
           lda  (Ptr2)
           cmp  #$20
           beq  Ok1
           jmp  ProStatus

Ok1        anop

           lda  #$03                    2nd ID byte
           sta  Ptr2
           lda  (Ptr2)
           beq  Ok2
           jmp  ProStatus

Ok2        anop

           lda  #$05                    3rd ID byte
           sta  Ptr2
           lda  (Ptr2)
           cmp  #$03
           beq  BlockDev
           jmp  ProStatus

* We have a block device of some sort here.

BlockDev   anop

           lda  #$FF
           sta  Ptr2
           lda  (Ptr2)
           bne  NotDiskII

* It's a Disk ][ so hard code it's size to 280 ($0118) blocks.

           lda  #$01
           sta  DevSize+1
           lda  #$18
           sta  DevSize

           lda  #DiskIIDev              Set device type to Disk ][
           sta  DevType

           rts

NotDiskII  anop

           lda  #SmartDev               Smartport in this slot
           sta  DevType

           lda  #$07                    4th ID byte
           sta  Ptr2
           lda  (Ptr2)
           beq  Smartport
           jmp  ProStatus

Smartport  anop

* We have a Smartport device so get it's blocksize from $FC and $FD offset.
* If this value is zeros then we must do a Smartport status call to get size.

           lda  #$FC
           sta  Ptr2
           lda  (Ptr2)
           sta  DevSize
           inc  Ptr2
           lda  (Ptr2)
           sta  DevSize+1
           ora  DevSize
           bne  GoodSize
           jmp  SmartStatus

GoodSize   anop

           rts

* Do a ProDOS driver status call to retrieve device block size.

ProStatus  anop

DevAddr    equ  $BF10

           lda  onlineUnit              Compute slot/drive offset by dividing
           lsr  a                       unit number by 16.
           lsr  a
           lsr  a
           tax                          Move offset to index.

           lda  DevAddr,x               Get low byte of ProDOS driver address
           sta  Ptr2
           inx
           lda  DevAddr,x               Get high byte of ProDOS driver address
           sta  Ptr2+1

           php                          Save status
           sei                          Interrupts off

           lda  #0
           sta  $42                     Status call

           lda  onlineUnit
           sta  $43                     Unit number

           lda  #Buffer512
           sta  $44
           lda  #>Buffer512
           sta  $45

           lda  #0
           sta  $46
           sta  $47

           lda  $C08B                   Read and write enable the language card
           lda  $C08B                    with bank 1 on.

           jsr  CallDriver              Call ProDOS driver.

           bit  $C082                   Put ROM back on-line
           bcs  Error

OkError    anop

           stx  DevSize                 Save device size.
           sty  DevSize+1

NoMessage  anop

           plp                          Restore status

           rts

CallDriver anop

           jmp  (Ptr2)

Error      anop

           cmp  #$2B                    Write protect error is ok.
           beq  OKError
           cmp  #$2F                    Disk offline error
           beq  OKError

           stz  DevSize                 Unknown size
           stz  DevSize+1

           cmp  #$28                    Device not connected error
           beq  NoMessage               (This error shouldn't happen here)

           plp                          Restore status

           tay
           lsr  a
           lsr  a
           lsr  a
           lsr  a
           tax
           lda  AscIITable,x
           sta  E1Code

           tya
           and  #$0F
           tax
           lda  AscIITable,x
           sta  E1Code+1

           lda  #E1
           sta  MsgPtr
           lda  #>E1
           sta  MsgPtr+1
           jsr  MsgOk

           rts

           Msb  On

E1         dc   c'ProDOS driver status call',h'0D'
           dc   c'error $'
E1Code     dc   c'00'
           dc   c' encountered.',h'00'

           Msb  Off

* Do a Smartport status call to retrieve device block size

Smartstatus anop

           lda  #$FF                    Setup Smartport dispatch address in Ptr2
           sta  Ptr2
           lda  (Ptr2)
           sta  Ptr2

           clc
           lda  Ptr2
           adc  #3
           sta  Ptr2

           lda  onlineUnit              Is this drive 1 or 2?
           bmi  SPD2

SPD1       anop

           lda  #1
           sta  SPUnitNo
           bra  CallSP

SPD2       anop

           lda  #2
           sta  SPUnitNo

CallSP     anop

           jsr  Dispatch

CmdNum     dc   h'00'
CmdList    dc   a'SPParms'
           bcs  SPError
           lda  DSB+3
           beq  DSBSizeOk

           lda  #$FF
           sta  DevSize
           sta  DevSize+1
           rts

DSBSizeOk  anop

           lda  DSB+1                   Do we still have a zero byte device?
           ora  DSB+2
           beq  CheckType               Yes, check device type for Disk3.5

           lda  DSB+1                   Save size.
           sta  DevSize
           lda  DSB+2
           sta  DevSize+1

           rts

CheckType  anop

           lda  DSB+21                  If we have a 1 here then this is a
           cmp  #1                      Disk 3.5 (or Unidisk) so set default
           beq  Disk35                  value.

           stz  DevSize                 Not a Disk35 so I don't know what type
           stz  DevSize+1               of device we have so set size to zero.

           rts

Disk35     anop

           lda  #$40                    Set Disk 3.5 default to 1600 ($0640)
           sta  DevSize                  blocks.
           lda  #$06
           sta  DevSize+1

           rts

Dispatch   anop

           jmp  (Ptr2)

SPParms    anop
SPCount    dc   h'03'
SPUnitNo   dc   h'00'
SPListPtr  dc   a'DSB'
SPCode     dc   h'03'

DSB        ds   25

SPError    anop

           stz  DevSize
           stz  DevSize+1

           tay
           lsr  a
           lsr  a
           lsr  a
           lsr  a
           tax
           lda  AscIITable,x
           sta  E2Code

           tya
           and  #$0F
           tax
           lda  AscIITable,x
           sta  E2Code+1

           lda  #E2
           sta  MsgPtr
           lda  #>E2
           sta  MsgPtr+1
           jsr  MsgOk

           rts

           Msb  On

E2         dc   c'Smartport status call error $'
E2Code     dc   c'00'
           dc   c' encountered.',h'00'

           Msb  Off

*
* Save valid device data to buffer.
*

SaveDevInfo anop

           ldx  Slot
           lda  AscIITable,x
           ldy  #oSlot
           sta  (Ptr1),y

           ldy  #oDrive
           lda  onlineBuf
           bmi  D2

D1         anop

           lda  #'1'+$80
           bra  SaveDrive

D2         anop

           lda  #'2'+$80

SaveDrive  anop

           sta  (Ptr1),y

           ldx  #1
           ldy  #oVolume

           lda  onlineBuf
           and  #$0F                    Keep volume name length
           sta  NameLength
           bne  NextChar
           jmp  DevMessage

NextChar   anop

           lda  onlineBuf,x
           ora  #$80
           sta  (Ptr1),y
           iny
           inx
           cpx  NameLength
           bcc  NextChar
           beq  NextChar

           cpx  #16
           beq  SaveUnitNo

PrtSpaces  anop

           sec
           lda  #15
           sbc  NameLength
           tax
           lda  #' '+$80

AddSpace   anop

           sta  (Ptr1),y
           iny
           dex
           bne  AddSpace

SaveUnitNo anop

           lda  onlineUnit
           ldy  #oUnitNo
           sta  (Ptr1),y

           lda  DevSize
           ldy  #oSizeHex
           sta  (Ptr1),y

           lda  DevSize+1
           iny
           sta  (Ptr1),y

SaveSize   anop

           lda  DevSize
           ora  DevSize+1
           bne  WeHaveASize

           lda  #'?'+$80
           ldx  #4
           ldy  #oSize

SaveQuest  anop

           sta  (Ptr1),y
           iny
           dex
           bne  SaveQuest

           lda  #' '+$80
           ldy  #oUnit
           sta  (Ptr1),y
           rts

WeHaveASize anop

           lsr  DevSize+1               Divide DevSize by 2 to convert
           ror  DevSize                 block into kilobytes.
           bcc  NoRounding

           inc  DevSize
           bne  NoRounding
           inc  DevSize+1

NoRounding anop

           lda  DevSize+1
           cmp  #$04                    See if size > 1024K ($0400)
           bcc  Kilobytes

MegaBytes  anop

           ldx  #4                      First divide DevSize by 16

Loop1      anop

           lsr  DevSize+1
           ror  DevSize
           dex
           bne  Loop1

           lda  DevSize+1
           sta  Multiplier+1
           lda  DevSize
           sta  Multiplier

           asl  DevSize                 Multiply by 5 doing a multiply by 4 and
           rol  DevSize+1                adding the original value another time.
           asl  DevSize
           rol  DevSize+1

           clc
           lda  DevSize
           adc  Multiplier
           sta  DevSize
           lda  DevSize+1
           adc  Multiplier+1
           sta  DevSize+1

           ldx  #5                      Divide by 32 for final result

Loop2      anop

           lsr  DevSize+1
           ror  DevSize
           dex
           bne  Loop2

           lda  #'M'+$80
           ldy  #oUnit
           sta  (Ptr1),y
           ldx  #3
           bra  ConvAscii

Kilobytes  anop

           lda  #'K'+$80
           ldy  #oUnit
           sta  (Ptr1),y
           ldx  #4

ConvAscii  anop

           txa
           tay
           lda  DevSize+1
           sta  ACC+1
           lda  DevSize
           sta  ACC

           stz  AUX+1
           lda  #10
           sta  AUX

Loop3      anop

           lda  ACC
           ora  ACC+1
           bne  NotZero

           lda  #' '+$80
           bra  SaveValue

NotZero    anop

           phx
           jsr  Divide
           plx
           lda  EXT

SaveValue  anop

           pha
           dex
           bne  Loop3

           tya
           tax
           ldy  #oSize

Loop4      anop

           pla
           cmp  #' '+$80
           beq  LeadZero
           phy
           tay
           lda  AsciiTable,y
           ply

LeadZero   anop

           sta  (Ptr1),y
           iny
           dex
           bne  Loop4

           cpy  #oSize+3
           bne  NoDecimal

Decimal    anop

           sta  (Ptr1),y
           dey
           lda  #'.'+$80
           sta  (Ptr1),y

NoDecimal  anop

           ldy  #oDevType               Save device type data
           lda  DevType

           sta  (Ptr1),y

           clc                          Setup buffer address for next record.
           lda  Ptr1
           adc  #oEntryLen
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           rts

NameLength ds   1
Multiplier ds   2

*
* Device messages when a volume not mounted
*

DevMessage anop

           lda  onlineBuf+1
           cmp  #$27                    IO Error on a Disk ][
           beq  NoDisk
           cmp  #$2F                    Device Off-line
           beq  NoDisk
           cmp  #$52                    Non-ProDOS
           beq  NonProDOS
           jmp  PrtSpaces               Mystery error?

NoDisk     anop

           ldx  #0

NoDisk01   anop

           lda  DevMes1,x
           sta  (Ptr1),y
           iny
           inx
           cpx  #DevMes1E-DevMes1
           bcc  NoDisk01

           lda  #DevMes1E-DevMes1
           sta  NameLength
           jmp  PrtSpaces

NonProDOS  anop

           ldx  #0

NonProDOS1 anop

           lda  DevMes2,x
           sta  (Ptr1),y
           iny
           inx
           cpx  #DevMes2E-DevMes2
           bcc  NonProDOS1

           lda  #DevMes2E-DevMes2
           sta  NameLength
           jmp  PrtSpaces

           Msb  On

DevMes1    dc   c'<No Disk>'
DevMes1E   anop
DevMes2    dc   c'<Non ProDOS>'
DevMes2E   anop

           Msb  Off

           End
