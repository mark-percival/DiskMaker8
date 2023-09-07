Menu2Vars:

; Online devices offsets

oSlot       =   0  ;- 0
oDrive      =   1  ;- 1
oVolume     =   2  ;- 16
oSize       =   17 ;- 20
oUnit       =   21 ;- 21
oUnitNo     =   22 ;- 22
oSizeHex    =   23 ;- 24
oDevType    =   25 ;- 25
oEntryLen   =   26

; oDevType settings

DiskIIDev   =   0
SmartDev    =   1
RemapDev    =   2

; Shared variables

DevEntCnt:  .res 1                       ; Total number of valid devices
Above:      .res 1
Below:      .res 1
FstAddr:    .res 2
M2_SelLine: .res 1
SelAddr:    .res 2
TabIndex2:  .res 1
RC2:        .res 1

AboutBtn    =   0
SkipBtn     =   1
MakeBtn     =   2
ImgTypeBox  =   3
SameSize    =   4
LoopBack2   =   5

Quit2       =   1
ReloadDevs  =   2
UpdDevLst   =   3
Nothing     =   4
MakingDisk  =   5

;         Msb  On

M2BtnText:
AboutText: .byte $0A
           asc " About...  "
SkipText:  .byte $0C
           asc "   Back    "
MakeText:  .byte $0E
           asc " Make Disk "

ASCIITable: asc "0123456789ABCDEF"   

; Disk image type flag with settings

ImageType:  .res 1

Type_2IMG   =   0
Type_DC     =   1
Type_DC6    =   2
Type_PO     =   3
Type_DO     =   4

ImageSize:  .res 2                       ; Image size in number of blocks.
EndBlock:   .res 2                       ; Number of blocks to write.
CurrBlock:  .res 2                       ; Current block pointer

; Same-size disks variables

blnSize:    .byte $01                   ; 0 = off; 1 = on

; Format 5.25 buffer areas.

; TrkBuf     .res $1940
; TrkBufEnd  anop

; EOFMarker  .byte $00                 ;   End of buffer marker.

Buffer8K    =   $9000
; VfyBuf     .res $2000
; VfyBufEnd  anop


;          Msb  Off


