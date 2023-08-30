Menu1Vars:

RC_M1:        .byte   $00               ; User Interface return code

Quit       =  %00000001                 ; Quit menu1
NoDirChange = %00000010                 ; No directory change
DirChange  =  %00000100                 ; Directory change
TabOnly    =  %00001000                 ; Tab key button focus change

FileCount_M1: .word   $0000             ; Number of active files in this directory
CurrPage_M1:  .byte   $00               ; Current page loaded

LineCount_M1: .byte   $00               ; Number of lines printed (0 to 8)
SelectLine_M1: .byte   $00              ; Selected line # (0 -> 8)
SelectPage_M1: .byte   $00              ; Aux page number of selected file
SelectAddr_M1: .addr   $0000            ; Address of selected file

LinesAbove_M1: .word   $0000            ; Lines available above top line
LinesBelow_M1: .word   $0000            ; Lines avaialbe below bottom line

TabIndex_M1:  .byte   $00               ; Current active command button.
DisksBtn   =  $0                        ; Disks button value.
OpenBtn    =  $1                        ; Open button value.
CloseBtn   =  $2                        ; Close button value.
CancelBtn  =  $3                        ; Cancel button value.
VolDirPull =  $4                        ; Volume / directory pulldown
LoopBack   =  $5

VolHeader_M1:  .res 39                  ; Save volume header info
blnDblClick_M1: .byte  $00              ; Boolean set for double clicking

; Vertical tab / Button text

ButtonText:

DisksMsg_M1:  .byte $0A
           asc " Disks  "
OpenMsg_M1:   .byte $0D
           asc "  Open  "
CloseMsg_M1:  .byte $0F
           asc " Close  "
CancelMsg_M1: .byte $11
           asc "  Quit  "
