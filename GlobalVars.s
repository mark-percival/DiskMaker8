*          Global variables definition

GlobalVars Data

*          Zero Page

Ptr1       gequ $06
MousePtr   gequ $08
WndLeft    gequ $20
WndWidth   gequ $21
WndTop     gequ $22
WndBottom  gequ $23
HTab       gequ $24
VTab       gequ $25
Ptr2       gequ $80
Ptr3       gequ $82
MsgPtr     gequ $82
acc        gequ $84
aux        gequ $86
ext        gequ $88
TextPtr    gequ $8A

*          C0xx Softswitches

Keyboard   gequ $C000
ClearKbd   gequ $C010
AppleKey   gequ $C061
OptionKey  gequ $C062

*          C3xx 80 Column Firmware Stuff

Init80     gequ $C300
MouseText  gequ $1B
StdText    gequ $18
Inverse    gequ $0F
Normal     gequ $0E

*          Standard ROM Entry Points

*cout      gequ $FDED                   Standard character print routine
Home       gequ $FC58                   Clear screen routine
PrByte     gequ $FDDA                   Print a hexadecimal byte.
PrHex      gequ $FDE3                   Print a hexadecimal digit.
*SetInv    gequ $FE80                   Set cout for inverse text
*SetNorm   gequ $FE84                   Set cout for normal text
*SetVTab   gequ $FC22
Wait       gequ $FCA8                   Wait entry point.

*          MLI Vars

Prefix     gequ $0800 - $083F           Current Prefix
Path       gequ $0840 - $087F           Current file (with or without prefix)
FileType   gequ $0880 - $0880           Current file type
AuxType    gequ $0881 - $0882           Current file aux type
NetDevCnt  gequ $08DE - $08DE           Number of Appleshare volumes
NetDevs    gequ $08DF - $08EC           Unit no's of Appleshare volumes
wrblkUnit  gequ $08ED - $08ED           MLI write block unit number
wrblkBlockNum gequ $08EE - $08EF        MLI write block block number
setMarkRef gequ $08F0 - $08F0           Set mark reference number
setMarkPos gequ $08F1 - $08F3           3 byte value of mark position.
geteofEOF  gequ $08F4 - $08F6           3 byte value of file size.
onlineUnit gequ $08F7 - $08F7           1 byte Unit Number for OnLine call
readReques gequ $08F8 - $08F9           Number of bytes to read
readTrans  gequ $08FA - $08FB           Number of bytes actually read
openRef1   gequ $08FC - $08FC           File open reference number
readRef    gequ $08FD - $08FD           File read reference number
geteofRef  gequ $08FE - $08FE           GetEOF reference number
closeRef   gequ $08FF - $08FF           File close reference number
openBuf1   gequ $0900 - $0AFF           512 byte buffer for file open
Buffer512  gequ $0900 - $0AFF           512 byte buffer.
onlineBuf  gequ $0B00 - $0BFF           256 byte buffer for OnLine call
readBuf    gequ $1000 - $11FF           512 byte read data buffer
readBufE   gequ $1200                   Ending address of readBuf
wrblkDataBuf gequ $1400 - $15FF         MLI write block 512 byte data buffer
Buf512A    gequ $1400 - $14FF           First 256 bytes
Buf512B    gequ $1500 - $15FF           Second 256 bytes.

*          Misc. Vars

TextMode   gequ $0883 - $0883           Used by Menu1 for selected file
MessageBuf gequ $1200 - $13FF           512 byte save area for MessageBox

*          AuxMove declarations

A1L        gequ $3C                     Source starting address      - low byte
A1H        gequ $3D                     Source starting address      - high byte
A2L        gequ $3E                     Source ending address        - low byte
A2H        gequ $3F                     Source ending address        - high byte
A4L        gequ $42                     Destination starting address - low byte
A4H        gequ $43                     Destination starting address - high byte
AuxMove    gequ $C311                   AuxMove entry point

*          Apple Mouse

MouseX     gequ $0884 - $0885           Mouse absolute X
MouseY     gequ $0886 - $0887           Mouse absolute Y
LowClamp   gequ $0888 - $0889           Low clamping value
HighClamp  gequ $088A - $088B           High clamping value

MouseStat  gequ $088C - $088C           Button 0/1 interrupt status byte
MouseMode  gequ $088D - $088D           Mode Byte

* MouseStat bits

MouseMove  gequ %00100000               X/Y moved since last ReadMouse
PrevButton gequ %01000000               Previously button was up (0) or down (1)
CurrButton gequ %10000000               Currently button was up (0) or down (1)

           End
