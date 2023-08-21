Menu2Vars  Data

* Online devices offsets

oSlot      equ  0  - 0
oDrive     equ  1  - 1
oVolume    equ  2  - 16
oSize      equ  17 - 20
oUnit      equ  21 - 21
oUnitNo    equ  22 - 22
oSizeHex   equ  23 - 24
oDevType   equ  25 - 25
oEntryLen  equ  26

* oDevType settings

DiskIIDev  equ  0
SmartDev   equ  1
RemapDev   equ  2

* Shared variables

DevEntCnt  ds   1                       Total number of valid devices
Above      ds   1
Below      ds   1
FstAddr    ds   2
SelLine    ds   1
SelAddr    ds   2
TabIndex2  ds   1
RC2        ds   1

AboutBtn   equ  0
SkipBtn    equ  1
MakeBtn    equ  2
ImgTypeBox equ  3
SameSize   equ  4
LoopBack2  equ  5

Quit2      equ  1
ReloadDevs equ  2
UpdDevLst  equ  3
Nothing    equ  4
MakingDisk equ  5

          Msb  On

M2BtnText  anop
AboutText  dc   h'0A',c' About...  '
SkipText   dc   h'0C',c'   Back    '
MakeText   dc   h'0E',c' Make Disk '

AscIITable dc   c'0123456789ABCDEF'

* Disk image type flag with settings

ImageType  ds   1

Type_2IMG  equ  0
Type_DC    equ  1
Type_DC6   equ  2
Type_PO    equ  3
Type_DO    equ  4

ImageSize  ds   2                       Image size in number of blocks.
EndBlock   ds   2                       Number of blocks to write.
CurrBlock  ds   2                       Current block pointer

* Same-size disks variables

blnSize    dc   h'01'                   0 = off; 1 = on

* Format 5.25 buffer areas.

* TrkBuf     ds   $1940
* TrkBufEnd  anop

* EOFMarker  dc   h'00'                   End of buffer marker.

Buffer8K   equ  $9000
* VfyBuf     ds   $2000
* VfyBufEnd  anop


           Msb  Off

           End
