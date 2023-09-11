***********************************
*                                 *
*       ProDOS Hyper-FORMAT       *
*                                 *
*     created by Jerry Hewett     *
*         copyright  1985         *
*     Living Legends Software     *
*                                 *
* A Public Domain disk formatting *
* routine for the ProDOS Disk Op- *
* erating System.  These routines *
* can be included within your own *
* software as long as you give us *
* credit for developing them.     *
*                                 *
*       Updated on: 23Aug85       *
*                                 *
***********************************

***********************************
*                                 *
* FORMAT - Format the target disk *
*                                 *
***********************************

           Align 256

HyperFormat Start

Buffer   equ  $0                        ;Address pointer for FORMAT data
WAIT     equ  $FCA8                     ;Delay routine
Step0    equ  $C080                     ;Drive stepper motor positions
Step1    equ  $C081                     ;  |      |      |       |
Step2    equ  $C082                     ;  |      |      |       |
Step4    equ  $C084                     ;  |      |      |       |
Step6    equ  $C086                     ;  |      |      |       |
DiskOFF  equ  $C088                     ;Drive OFF  softswitch
DiskON   equ  $C089                     ;Drive ON   softswitch
Select   equ  $C08A                     ;Starting offset for target device
DiskRD   equ  $C08C                     ;Disk READ  softswitch
DiskWR   equ  $C08D                     ;Disk WRITE softswitch
ModeRD   equ  $C08E                     ;Mode READ  softswitch
ModeWR   equ  $C08F                     ;Mode WRITE softswitch

         jmp   Format

TRKbeg   dc    i1'00'                   ;Starting track number
TRKend   dc    i1'35'                   ;Ending track number
VolNum   dc    i1'$FE'                  ;Volume number
Slot     dc    i1'$60'                  ;ProDOS unit number

Format   anop
         php
         sei
         LDA   Slot                     ;Fetch target drive SLOTNUM value
         PHA                            ;Store it on the stack
         AND   #$70                     ;Mask off bit 7 and the lower 4 bits
         STA   SlotF                    ;Store result in FORMAT slot storage
         TAX                            ;Assume value of $60 (drive #1)
         PLA                            ;Retrieve value from the stack
         BPL   LDrive1                  ;If < $80 the disk is in drive #1
         INX                            ;Set X offset to $61 (drive #2)
LDrive1  LDA   Select,X                 ;Set softswitch for proper drive
         LDX   SlotF                    ;Set X offset to FORMAT slot/drive
         LDA   DiskON,X                 ;Turn the drive on
         LDA   ModeRD,X                 ;Set Mode softswitch to READ
         LDA   DiskRD,X                 ;Read a byte
         LDA   #$23                     ;Assume head is on track 35
         STA   TRKcur
         LDA   #$00                     ;Destination is track 0
         STA   TRKdes
         JSR   SEEK                     ;Move head to track 0
         LDX   SlotF                    ;Turn off all drive phases
         LDA   Step0,X
         LDA   Step2,X
         LDA   Step4,X
         LDA   Step6,X
         LDA   TRKbeg                   ;Move TRKbeg value (0) to Track
         STA   Track
         JSR   BUILD                    ;Build a track in memory at $9700

*******************************
*                             *
* WRITE - Write track to disk *
*                             *
*******************************
Write    Entry
         JSR   CALC                     ;Calculate new track/sector/checksum val
         JSR   TRANS                    ;Transfer track in memory to disk
         BCS   Died                     ;If carry set, something died
MInc     INC   Track                    ;Add 1 to Track value
         LDA   Track                    ;Is Track > ending track # (TRKend)?
         CMP   TRKend
         BEQ   LNext                    ;More tracks to FORMAT
         BCS   DONE                     ;Finished.  Exit FORMAT routine
LNext    STA   TRKdes                   ;Move next track to FORMAT to TRKdes
         JSR   SEEK                     ;Move head to that track
         JMP   WRITE                    ;Write another track
DONE     LDX   SlotF                    ;Turn the drive off
         LDA   DiskOFF,X
         plp
         lda   #$00                     ;MRP - No error
         RTS                            ;FORMAT is finished. Return to calling r

**************************************
*                                    *
* Died - Something awful happened to *
* the disk or drive. Die a miserable *
* death...                           *
*                                    *
**************************************

Died     tay                            ;Save error in y-reg
         ldx   SlotF                    ;MRP - Turn off drive
         lda   DiskOFF,X                ;MRP
         tya                            ;Retrieve error code from y-reg
         plp                            ;Restore interrupts
         jsr   WriteError
         lda   #1
         rts

************************************
*                                  *
* TRANS - Transfer track in memory *
* to target device                 *
*                                  *
************************************

Trans    anop
         LDA   #$00                     ;Set Buffer to $9700
         LDX   #$97
         STA   Buffer
         STX   Buffer+1
         LDY   #$32                     ;Set Y offset to 1st sync byte (max=50)
         LDX   SlotF                    ;Set X offset to FORMAT slot/drive
         SEC                            ;(assum the disk is write protected)
         LDA   DiskWR,X                 ;Write something to the disk
         LDA   ModeRD,X                 ;Reset Mode softswitch to READ
         BMI   LWRprot                  ;If > $7F then disk was write protected
         LDA   #$FF                     ;Write a sync byte to the disk
         STA   ModeWR,X
         CMP   DiskRD,X
         NOP                            ;(kill some time for WRITE sync...)
         JMP   LSync2
LSync1   EOR   #$80                     ;Set MSB, converting $7F to $FF (sync by
*        NOP                            ;(kill time...)
         NOP
         JMP   MStore
LSync2   PHA                            ;(kill more time... [ sheesh! ])
         PLA
LSync3   LDA   (Buffer),Y               ;Fetch byte to WRITE to disk
         beq   WriteExit                ;MRP - new exit
         CMP   #$80                     ;Is it a sync byte? ($7F)
         BCC   LSync1                   ;Yep. Turn it into an $FF
*        NOP
MStore   STA   DiskWR,X                 ;Write byte to the disk
         CMP   DiskRD,X                 ;Set Read softswitch
         INY                            ;Increment Y offset
         BNE   LSync2
         INC   Buffer+1                 ;Increment Buffer by 255
         bne   LSync3                   ;MRP - More data
WriteExit LDA   ModeRD,X                ;Restore Mode softswitch to READ
         LDA   DiskRD,X                 ;Restore Read softswitch to READ
         CLC
         RTS
LWRprot  anop                           ;Disk is write protected! (Nerd!)
         lda   #$2B
         sec
         rts
************************************
*                                  *
* BUILD - Build GAP1 and 16 sector *
* images between $9700 and $B000   *
*                                  *
************************************
Build    anop

         LDA   #$10                     ;Set Buffer to $9710
         LDX   #$97
         STA   Buffer
         STX   Buffer+1
         LDY   #$00                     ;(Y offset always zero)
         LDX   #$F0                     ;Build GAP1 using $7F (sync byte)
         LDA   #$7F
         STA   LByte
         JSR   LFill                    ;Store sync bytes from $9710 to $9800
         LDA   #$10                     ;Set Count for 16 loops
         STA   Count
LImage   LDX   #$00                     ;Build a sector image in the Buffer area
ELoop    LDA   LAddr,X                  ;Store Address header, info & sync bytes
         BEQ   LInfo
         STA   (Buffer),Y
         JSR   LInc                     ;Add 1 to Buffer offset address
         INX
         BNE   ELoop
LInfo    LDX   #$AB                     ;Move 343 bytes into data area
         LDA   #$96                     ;(4&4 encoded version of hex $00)
         STA   LByte
         JSR   LFill
         LDX   #$AC
         JSR   LFill
         LDX   #$00
YLoop    LDA   LData,X                  ;Store Data Trailer and GAP3 sync bytes
         BEQ   LDecCnt
         STA   (Buffer),Y
         JSR   LInc
         INX
         BNE   YLoop
LDecCnt  CLC
         DEC   Count
         BNE   LImage
         lda   #$00                     ;MRP - Save EOF marker
         jsr   LInc                     ;MRP
         sta   (Buffer),Y               ;MRP
         RTS                            ;Return to write track to disk (WRITE)
LFill    LDA   LByte
         STA   (Buffer),Y               ;Move A register to Buffer area
         JSR   LInc                     ;Add 1 to Buffer offset address
         DEX
         BNE   LFill
         RTS
LInc     CLC
         INC   Buffer                   ;Add 1 to Buffer address vector
         BNE   LDone
         INC   Buffer+1
LDone    RTS
***********************************
*                                 *
* CALC - Calculate Track, Sector, *
* and Checksum values of the next *
* track using 4&4 encoding        *
*                                 *
***********************************
Calc     anop

         LDA   #$03                     ;Set Buffer to $9803
         LDX   #$98
         STA   Buffer
         STX   Buffer+1
         LDA   #$00                     ;Set Sector to 0
         STA   Sector
ZLoop    LDY   #$00                     ;Reset Y offset to 0
         LDA   VolNum                   ;Set Volume # to 254 in 4&4 encoding
         JSR   LEncode
         LDA   Track                    ;Set Track, Sector to 4&4 encoding
         JSR   LEncode
         LDA   Sector
         JSR   LEncode
         LDA   VolNum                   ;Calculate the Checksum using 254
         EOR   Track
         EOR   Sector
         JSR   LEncode
         CLC                            ;Add 385 ($181) to Buffer address
         LDA   Buffer
         ADC   #$81
         STA   Buffer
         LDA   Buffer+1
         ADC   #$01
         STA   Buffer+1
         INC   Sector                   ;Add 1 to Sector value
         LDA   Sector                   ;If Sector > 16 then quit
         CMP   #$10
         BCC   ZLoop
         RTS                            ;Return to write track to disk (WRITE)
LEncode  PHA                            ;Put value on the stack
         LSR   a                        ;Shift everything right one bit
         ORA   #$AA                     ;OR it with $AA
         STA   (Buffer),Y               ;Store 4&4 result in Buffer area
         INY
         PLA                            ;Retrieve value from the stack
         ORA   #$AA                     ;OR it with $AA
         STA   (Buffer),Y               ;Store 4&4 result in Buffer area
         INY
         RTS
*************************************
*                                   *
* SEEK - Move head to desired track *
*                                   *
*************************************
Seek     anop

         LDA   #$00                     ;Set InOut flag to 0
         STA   LInOut
         LDA   TRKcur                   ;Fetch current track value
         SEC
         SBC   TRKdes                   ;Subtract destination track value
         BEQ   LExit                    ;If = 0 we're done
         BCS   LMove
         EOR   #$FF                     ;Convert resulting value to a positive number
         ADC   #$01
LMove    STA   Count                    ;Store track value in Count
         ROL   LInOut                   ;Condition InOut flag
         LSR   TRKcur                   ;Is track # odd or even?
         ROL   LInOut                   ;Store result in InOut
         ASL   LInOut                   ;Shift left for .Table offset
         LDY   LInOut
ALoop    LDA   LTable,Y                 ;Fetch motor phase to turn on
         JSR   PHASE                    ;Turn on stepper motor
         LDA   LTable+1,Y               ;Fetch next phase
         JSR   PHASE                    ;Turn on stepper motor
         TYA
         EOR   #$02                     ;Adjust Y offset into LTable
         TAY
         DEC   Count                    ;Subtract 1 from track count
         BNE   ALoop
         LDA   TRKdes                   ;Move current track location to TRKcur
         STA   TRKcur
LExit    RTS                            ;Return to calling routine
**********************************
*                                *
* PHASE - Turn the stepper motor *
* on and off to move the head    *
*                                *
**********************************

Phase    anop
         ORA   SlotF                    ;OR Slot value to PHASE
         TAX
         LDA   Step1,X                  ;PHASE on...
         LDA   #$56                     ;20 ms. delay
         JSR   WAIT
         LDA   Step0,X                  ;PHASE off...
         RTS


*************************
*                       *
* Variable Storage Area *
*                       *
*************************

LByte    ds    1                        ;Storage for byte value used in Fill
LAddr    dc    H'D5 AA 96'              ;Address header
         dc    8i1'$AA'                 ;Volume #, Track, Sector, Checksum
         dc    H'DE AA EB'              ;Address trailer
         dc    6i1'$7F'                 ;GAP2 sync bytes
         dc    H'D5 AA AD'              ;Buffer header
         dc    H'00'                    ;End of Address information
LData    dc    H'DE AA EB'              ;Data trailer
         dc    16i1'$7F'                ;GAP3 sync bytes
         dc    H'00'                    ;End of Data information

LInOut   DS    1                        ;Inward/Outward phase for stepper motor
LTable   dc    H'02040600'              ;Phases for moving head inward
         dc    H'06040200'              ;   |    |    |      |  outward
Count    DS    3                        ;General purpose counter/storage byte
Track    DS    2                        ;Track number being FORMATted
Sector   DS    2                        ;Current sector number (max=16)
SlotF    DS    2                        ;Slot/Drive of device to FORMAT
TRKcur   DS    2                        ;Current track position
TRKdes   DS    2                        ;Destination track position
         End