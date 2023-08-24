Menu1Vars:

RC:        .byte   $00                  ; User Interface return code

Quit       =  %00000001                 ; Quit menu1
NoDirChange = %00000010                 ; No directory change
DirChange  =  %00000100                 ; Directory change
TabOnly    =  %00001000                 ; Tab key button focus change

FileCount: .word   $0000                ; Number of active files in this directory
CurrPage:  .byte   $00                  ; Current page loaded

M1LineCount: .byte   $00                ; Number of lines printed (0 to 8)
SelectLine: .byte   $00                 ; Selected line # (0 -> 8)
SelectPage: .byte   $00                 ; Aux page number of selected file
SelectAddr: .addr   $0000               ; Address of selected file

LinesAbove: .word   $0000               ; Lines available above top line
LinesBelow: .word   $0000               ; Lines avaialbe below bottom line

TabIndex:  .byte   $00                  ; Current active command button.
DisksBtn   =  $0                        ; Disks button value.
OpenBtn    =  $1                        ; Open button value.
CloseBtn   =  $2                        ; Close button value.
CancelBtn  =  $3                        ; Cancel button value.
VolDirPull =  $4                        ; Volume / directory pulldown
LoopBack   =  $5

VolHeader:  .res 39                     ; Save volume header info
blnDblClick: .byte  $00                 ; Boolean set for double clicking

; Vertical tab / Button text

ButtonText:

DisksMsg:  .byte $0A
           asc " Disks  "
OpenMsg:   .byte $0D
           asc "  Open  "
CloseMsg:  .byte $0F
           asc " Close  "
CancelMsg: .byte $11
           asc "  Quit  "
