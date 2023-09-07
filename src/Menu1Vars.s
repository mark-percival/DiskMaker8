Menu1Vars:

M1_RC:      .res 1                      ; User Interface return code

Quit        =   %00000001               ; Quit menu1
NoDirChange  =  %00000010               ; No directory change
DirChange   =   %00000100               ; Directory change
TabOnly     =   %00001000               ; Tab key button focus change

M1_FileCount: .res 2                    ; Number of active files in this directory
CurrPage:   .res 1                      ; Current page loaded

M1_LineCount: .res 1                    ; Number of lines printed (0 to 8)
SelectLine: .res 1                      ; Selected line # (0 -> 8)
SelectPage: .res 1                      ; Aux page number of selected file
SelectAddr: .res 2                      ; Address of selected file

LinesAbove: .res 2                      ; Lines available above top line
LinesBelow: .res 2                      ; Lines avaialbe below bottom line

M1_TabIndex: .res 1                     ; Current active command button.
DisksBtn    =   $0                      ; Disks button value.
OpenBtn     =   $1                      ; Open button value.
CloseBtn    =   $2                      ; Close button value.
CancelBtn   =   $3                      ; Cancel button value.
VolDirPull  =   $4                      ; Volume / directory pulldown
LoopBack    =   $5

VolHeader:  .res 39                     ; Save volume header info
blnDblClick: .res 1                     ; Boolean set for double clicking

; Vertical tab / Button text

;          Msb  On

ButtonText:

DisksMsg:  .byte $0A
           asc " Disks  "
OpenMsg:   .byte $0D
           asc "  Open  "
CloseMsg:  .byte $0F
           asc " Close  "
CancelMsg: .byte $11
           asc "  Quit  "

;          Msb  Off


