Menu1Vars  Data

RC         ds   1                       User Interface return code

Quit       equ  %00000001               Quit menu1
NoDirChange equ %00000010               No directory change
DirChange  equ  %00000100               Directory change
TabOnly    equ  %00001000               Tab key button focus change

FileCount  ds   2                       Number of active files in this directory
CurrPage   ds   1                       Current page loaded

LineCount  ds   1                       Number of lines printed (0 to 8)
SelectLine ds   1                       Selected line # (0 -> 8)
SelectPage ds   1                       Aux page number of selected file
SelectAddr ds   2                       Address of selected file

LinesAbove ds   2                       Lines available above top line
LinesBelow ds   2                       Lines avaialbe below bottom line

TabIndex   ds   1                       Current active command button.
DisksBtn   equ  $0                      Disks button value.
OpenBtn    equ  $1                      Open button value.
CloseBtn   equ  $2                      Close button value.
CancelBtn  equ  $3                      Cancel button value.
VolDirPull equ  $4                      Volume / directory pulldown
LoopBack   equ  $5

VolHeader  ds   39                      Save volume header info
blnDblClick ds  1                       Boolean set for double clicking

* Vertical tab / Button text

           Msb  On

ButtonText anop

DisksMsg   dc   h'0A',c' Disks  '
OpenMsg    dc   h'0D',c'  Open  '
CloseMsg   dc   h'0F',c' Close  '
CancelMsg  dc   h'11',c'  Quit  '

           Msb  Off

           End
