*
*  Disconnect / connect /RAM from ProDOS Technical Reference
*

RamOut     Start

* Configuration device list by device number
* access order is last in list first.

RamSlot    equ  $BF26                   Slot 3, Drive 2 is /RAM's driver vector
DevNum     equ  $BF30                   Most recent accessed device
DevCnt     equ  $BF31                   Global page device count
DevLst     equ  $BF32 - $BF3F           Global page device list
MemTabl    equ  $BF58 - $BF6F           Memory map for lower 48K.
MachID     equ  $BF98                   Global page machine ID byte

* NoDev is the global page slot zero, drive 1 disk drive vector.
* It is reserved for use as the "No Device Connected" vector

NoDev      equ  $BF10

           php                          Save status and
           sei                           make sure interrupts are off!

* First think to do is to see of there is a /RAM to disconnect!

           lda  MachId                  Load the machine ID byte
           and  #$30                     to check for a 128K system.
           cmp  #$30                    Is it 128K?
           bne  RO9                     If not, then branch since no /RAM!

           lda  RamSlot                 It is 128K; Is a device there?
           cmp  NoDev                   Compare with low byte of NoDev
           bne  RO1                     Branch if not equal, device is connected
           lda  RamSlot+1               Check hi byte for match
           cmp  NoDev+1                 Are we connected?
           beq  RO9

* At this point /RAM (or some other device) is connected in
* the slot 3, drive 2 vector.  Now we must go through the device
* list and find the slot 3, drive 2 unit number of /RAM ($BF)
* The actual unit number, (that is to say 'device') that will
* be removed will be $BF, $BB, $B7, $B3.  /RAM's device number
* is $BF.  Thus this convention will allow other devices that
* do not necessarily resemble (or in fact, are completely different
* from) /RAM to remain intact in the system.

RO1        ldy  DevCnt                  Get the number of devices online
RO2        lda  DevLst,y                Start looking for /RAM or facsimile
           and  #$F3                    looking for $BF, $BB, $B7, $B3
           cmp  #$B3                    Is device number in ($BF,$BB,$B7,$B3)?
           beq  RO3                     Branch if found..
           dey                          Otherwise check out the next unit #.
           bpl  RO2                     Branch unless you run out of units
           bmi  RO9                     Since you have run out of units
RO3        lda  DevLst,y                Get the original unit number back
           sta  RamUnitId               and save it off for later restoration.

* Now we must remove the unit from the device list by bubbling
* up the trainling units.

RO4        lda  DevLst+1,y              Get the next unit number
           sta  DevLst,y                and move it up.
           beq  RO5                     Branch when done(zeros trail the DevLst)
           iny                          Continue to the next unit number...
           bne  RO4                     Branch always.

RO5        lda  RamSlot                 Save slot 3, drive 2 device address.
           sta  Address                 Save off low byte of /RAM driver adress
           lda  RamSlot+1               Save off hi byte
           sta  Address+1
           lda  NoDev                   Finally copy the 'No Device Connected'
           sta  RamSlot                 into the slot 3, drive 3 vector and
           lda  NoDev+1
           sta  RamSlot+1
           dec  DevCnt                  decrement the device count.

RO9        plp                          Restore status

           rts

Address    dc   i2'00'
RamUnitId  dc   i1'00'

RamIn      Entry

* This is the example /RAM install routine

           php                          Save processor status
           sei                          and make sure interrupts are off!

           ldy  DevCnt                  Get number of devices - 1.
RI1        lda  DevLst,y                Load the unit number
           and  #$F0                    Check for slot 3, drive 2 unit.
           cmp  #$B0                    Is it the slot 3, drive 2 unit?
           beq  RI3                     If so branch.
           dey                          Otherwise search on...
           bpl  RI1                     Loop until DevLst search is complete

           lda  Address                 Restore the device driver address
           sta  RamSlot                 low byte
           lda  Address+1               Now the
           sta  RamSlot+1               hi byte.
           inc  DevCnt                  After installing device,inc device count
           ldy  DevCnt                  Use y for loop counter
RI2        lda  DevLst-1,y              Bubble down the entries in device list
           sta  DevLst,y
           dey                          Next
           bne  RI2                     Loop until entires moved down.

* Now set up a /RAM format request

           lda  #$03                    Load acc with format request number.
           sta  $42                     Store request number in proper place.

           lda  RamUnitId               Restore the device
           sta  DevLst                  unit number in the device list
           and  #$0F                    strip the device id (zero low nibble)
           sta  $43                     and store the unit number in $43

           lda  #$00                    Load low byte of buffer pointer
           sta  $44                     and store it.
           lda  #$10                    Load hi byte of buffer pointer
           sta  $45                     and store it.

           lda  $C08B                   Read & write enable
           lda  $C08B                   the language card with bank 1 on.

* Note how the driver is called.  You jsr to an indirect jmp so
* control is returned by the driver to the instruction after the jsr.

           jsr  RI4                     Now let driver carry out call.
           bit  $C082                   Now put /RAM in line.

           bcc  RI3                     If the carry is clear --> no error
           jsr  RI5                     Go process the error

RI3        plp                          Restore processor status
           rts                          That's all.

RI4        jmp  (RamSlot)               Call the /RAM driver

RI5        jsr  Beep                    Your error handler code would go here
           rts

           End
