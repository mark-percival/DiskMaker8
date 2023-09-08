;          Global variables definition

;GlobalVars Data

;          Zero Page

Ptr1        =   $06
MousePtr    =   $08
WndLeft     =   $20
WndWidth    =   $21
WndTop      =   $22
WndBottom   =   $23
HTab        =   $24
VTab        =   $25
Ptr2        =   $80
Ptr3        =   $82
MsgPtr      =   $82
acc         =   $84
aux         =   $86
ext         =   $88
TextPtr     =   $8A

;          C0xx Softswitches

Keyboard    =   $C000
Off80Store  =   $C000
On80Store   =   $C001
Read80Store  =  $C018
ClearKbd    =   $C010
ReadPage2   =   $C01C
Speaker     =   $C030
AppleKey    =   $C061
OptionKey   =   $C062
Page1       =   $C054
Page2       =   $C055

;          C3xx 80 Column Firmware Stuff

Init80      =   $C300
MouseText   =   $1B
StdText     =   $18
Inverse     =   $0F
Normal      =   $0E

;          Standard ROM Entry Points

cout_rom    =   $FDED                   ; Standard character print routine
Home        =   $FC58                   ; Clear screen routine
PrByte      =   $FDDA                   ; Print a hexadecimal byte.
PrHex       =   $FDE3                   ; Print a hexadecimal digit.
;SetInv     =   $FE80                   ; Set cout for inverse text
;SetNorm    =   $FE84                   ; Set cout for normal text
setvtab_rom =   $FC22
Wait        =   $FCA8                   ; Wait entry point.

;          MLI Vars

Prefix      =   $0800 ;- $083F          ; Current Prefix
Path        =   $0840 ;- $087F          ; Current file (with or without prefix)
FileType    =   $0880 ;- $0880          ; Current file type
AuxType     =   $0881 ;- $0882          ; Current file aux type
NetDevCnt   =   $08DE ;- $08DE          ; Number of Appleshare volumes
NetDevs     =   $08DF ;- $08EC          ; Unit no's of Appleshare volumes
wrblkUnit   =   $08ED ;- $08ED          ; MLI write block unit number
wrblkBlockNum  =   $08EE ;- $08EF       ; MLI write block block number
setMarkRef  =   $08F0 ;- $08F0          ; Set mark reference number
setMarkPos  =   $08F1 ;- $08F3          ; 3 byte value of mark position.
geteofEOF   =   $08F4 ;- $08F6          ; 3 byte value of file size.
onlineUnit  =   $08F7 ;- $08F7          ; 1 byte Unit Number for OnLine call
readRequest =   $08F8 ;- $08F9          ; Number of bytes to read
readTrans   =   $08FA ;- $08FB          ; Number of bytes actually read
openRef1    =   $08FC ;- $08FC          ; File open reference number
readRef     =   $08FD ;- $08FD          ; File read reference number
geteofRef   =   $08FE ;- $08FE          ; GetEOF reference number
closeRef    =   $08FF ;- $08FF          ; File close reference number
openBuf1    =   $0900 ;- $0AFF          ; 512 byte buffer for file open
Buffer512   =   $0900 ;- $0AFF          ; 512 byte buffer.
onlineBuf   =   $0B00 ;- $0BFF          ; 256 byte buffer for OnLine call
readBuf     =   $1000 ;- $11FF          ; 512 byte read data buffer
readBufE    =   $1200                   ; Ending address of readBuf
wrblkDataBuf  =   $1400 ;- $15FF        ; MLI write block 512 byte data buffer
Buf512A     =   $1400 ;- $14FF          ; First 256 bytes
Buf512B     =   $1500 ;- $15FF          ; Second 256 bytes.

;          Misc. Vars

TextMode    =   $0883 ;- $0883          ; Used by Menu1 for selected file
MessageBuf  =   $1200 ;- $13FF          ; 512 byte save area for MessageBox

;          AuxMove declarations

A1L         =   $3C                     ; Source starting address      - low byte
A1H         =   $3D                     ; Source starting address      - high byte
A2L         =   $3E                     ; Source ending address        - low byte
A2H         =   $3F                     ; Source ending address        - high byte
A4L         =   $42                     ; Destination starting address - low byte
A4H         =   $43                     ; Destination starting address - high byte
AuxMove     =   $C311                   ; AuxMove entry point

;          Apple Mouse

MouseX      =   $0884 ;- $0885          ; Mouse absolute X
MouseY      =   $0886 ;- $0887          ; Mouse absolute Y
LowClamp    =   $0888 ;- $0889          ; Low clamping value
HighClamp   =   $088A ;- $088B          ; High clamping value

MouseStat   =   $088C ;- $088C          ; Button 0/1 interrupt status byte
MouseMode   =   $088D ;- $088D          ; Mode Byte

; MouseStat bits

MouseMove   =   %00100000               ; X/Y moved since last ReadMouse
PrevButton  =   %01000000               ; Previously button was up (0) or down (1)
CurrButton  =   %10000000               ; Currently button was up (0) or down (1)

; ProDOS constants
MLI         =   $BF00