Menu2Vars:

; Online devices offsets

oSlot      =  0 ; - 0
oDrive     =  1 ; - 1
oVolume    =  2 ; - 16
oSize      =  17; - 20
oUnit      =  21; - 21
oUnitNo    =  22; - 22
oSizeHex   =  23; - 24
oDevType   =  25; - 25
oEntryLen  =  26

; oDevType settings

DiskIIDev  =  0
SmartDev   =  1
RemapDev   =  2

; Shared variables

DevEntCnt_M2: .byte   $00             ; Total number of valid devices
Above_M2:     .byte   $00
Below_M2:     .byte   $00
FstAddr_M2:   .word   $0000
SelLine_M2:   .byte   $00
SelAddr_M2:   .word   $0000
TabIndex_M2:  .byte   $00
RC_M2:        .byte   $00

AboutBtn   =  0
SkipBtn    =  1
MakeBtn    =  2
ImgTypeBox =  3
SameSize   =  4
LoopBack2  =  5

Quit2      =  1
ReloadDevs =  2
UpdDevLst  =  3
Nothing    =  4
MakingDisk =  5

M2BtnText:
AboutText_M2: .byte $0A
           asc " About...  "
SkipText_M2:  .byte $0C
           asc "   Back    "
MakeText_M2:  .byte $0E
           asc " Make Disk "

; Disk image type flag with settings

ImageType_M2: .byte   $00

Type_2IMG  =  0
Type_DC    =  1
Type_DC6   =  2
Type_PO    =  3
Type_DO    =  4

ImageSize_M2: .word   $0000           ; Image size in number of blocks.
EndBlock_M2:  .word   $0000           ; Number of blocks to write.
CurrBlock_M2: .word   $0000           ; Current block pointer

; Same-size disks variables

blnSize_M2:   .byte   $01             ; 0 = off; 1 = on

; Format 5.25 buffer areas.

Buffer8K   =  $9000
