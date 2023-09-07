           bra  M1_Start

;          Offsets

oNextBlock  =   $02 ;-> $03             ; Next block number (0 = last block)
oEntLength  =   $23                     ; Length of file entry
oEntPerBlk  =   $24                     ; Number of file entries per block
oFileCount  =   $25 ;-> $26             ; Number of active files in this directory

;          Storage declarations

M1_EntLength: .res 1                    ; Length of file entry
M1_EntPerBlk: .res 1                    ; Number of file entries per block

FirstPage: .res 1                       ; Aux page number of first line entry
FirstAddr: .res 2                       ; Address of first line entry
FstEntCnt: .res 1                       ; Remaining entries in blk at first line

EntRemain: .res 1                       ; Entries remaining in current block

M1_Start:

           jsr  PaintMenu1              ; Paint menu1 frame

           lda  #OpenBtn
           sta  M1_TabIndex             ; Initialize tabindex to open button.

Menu01:

           jsr  MLISetPrefix            ; Set Current Prefix

           jsr  LoadDirectory           ; Load current directory into memory

           jsr  M1_Initialize           ; Initialize variables

           jsr  SaveVolHeader           ; Save volume header info

Menu02:

           jsr  ListFiles               ; List 8 files from FirstAddr

Menu03:

           jsr  M1_RefreshBtn           ; Refresh command buttons display

           jsr  Menu1UI                 ; Menu 1 User Interface

           lda  #DirChange              ; *** Directory Refresh ***
           bit  M1_RC
           bne  Menu01

           lda  #NoDirChange            ; *** No Directory Refresh ***
           bit  M1_RC
           bne  Menu02

           lda  #TabOnly                ; *** Tab Key Button Focus Change ***
           bit  M1_RC
           bne  Menu03

           lda  #Quit                   ; *** Quit Code ***
           bit  M1_RC
           bne  Menu99

           jsr  ClearMenu1              ; Remove menu1 data from screen
           jsr  Menu2                   ; Go to Menu2.
           jmp  M1_Start                ; Back to the top

Menu99:

           rts

M1_Initialize:

           lda  #$08
           sta  FirstPage               ; Set initial first aux page number
           sta  CurrPage                ; Set page to load

           jsr  GetBlock                ; Get block from aux memory

           lda  readBuf+oEntLength      ; Get file entry length
           sta  M1_EntLength

           lda  readBuf+oEntPerBlk      ; Get number of entries per block
           sta  M1_EntPerBlk
           sta  FstEntCnt               ; First line entries remaining.

           lda  readBuf+oFileCount      ; Get number of active files
           sta  M1_FileCount
           lda  readBuf+oFileCount+1
           sta  M1_FileCount+1

           stz  LinesAbove              ; Since we're starting, lines above
           stz  LinesAbove+1            ;  top is zero.

           sec                          ; Calculcate lines below
           lda  M1_FileCount
           sbc  #8
           sta  LinesBelow              ; LinesBelow = M1_FileCount - 8
           lda  M1_FileCount+1
           sbc  #0
           sta  LinesBelow+1

           bpl  Init01

           stz  LinesBelow              ; If LinesBelow is less than our
           stz  LinesBelow+1            ; total M1_FileCount, zero it out.

Init01:

           lda  #<readBuf+4
           sta  FirstAddr
           lda  #>readBuf+4
           sta  FirstAddr+1

           lda  Prefix                  ; Don't attempt to move past header
           beq  Init02                  ; for volume listing

           lda  M1_FileCount            ; Don't bother finding the first entry
           ora  M1_FileCount+1          ; if there is none.
           beq  Init02

           jsr  FindFstEnt              ; Move past Vol/Dir header

Init02:

           lda  #Normal                 ; Normal text for non selected file.
           sta  TextMode

           lda  #1                      ; Default line selected
           sta  SelectLine

           rts

ListFiles:

;          List up to 8 files starting from FirstAddr

           lda  #22-1
           sta  HTab                    ; HTab 22
           lda  #11-1
           sta  VTab                    ; VTab 11 to start
           jsr  SetVTab

           lda  SelectLine
           bne  M1_NotUp

           jsr  M1_ScrollUp
           bra  M1_NoScrollDn

M1_NotUp:

           cmp  #9
           bcc  M1_NoScrollDn

           jsr  M1_ScrollDown

M1_NoScrollDn:

           lda  FirstAddr               ; Set up first line address
           sta  Ptr1
           lda  FirstAddr+1
           sta  Ptr1+1

           lda  FirstPage               ; Set up first line source aux page
           sta  CurrPage                ; number.

           lda  FstEntCnt               ; Set up remaining entries from first
           sta  EntRemain               ; line.

           jsr  GetBlock                ; Get block from aux memory

           stz  M1_LineCount            ; Zero out lines printed counter.

ListFile01:

           lda  Prefix                  ; Zero prefix length means this is a
           beq  ListFile02              ; volume listing and not a file listing.

           lda  (Ptr1)
           beq  ListFile90              ; Deleted entry
           and  #$E0
           cmp  #$E0                    ; Skips volume and directory headers
           beq  ListFile90

ListFile02:

           inc  M1_LineCount            ; We're printing this line so count it
           lda  M1_LineCount
           cmp  SelectLine              ; Is this the line selected?
           bne  ListFile03              ; No

           lda  #Inverse                ; Selected line so set TextMode to inverse
           sta  TextMode                ; to display as selected.

           lda  CurrPage                ; Also save the aux page number and
           sta  SelectPage              ; address in that page that the selected
           lda  Ptr1                    ; entry appears on.
           sta  SelectAddr
           lda  Ptr1+1
           sta  SelectAddr+1

ListFile03:

           jsr  PrtFileName             ; It's good so print it.

           lda  #22-1                   ; Move to next line
           sta  HTab
           inc  VTab
           jsr  SetVTab

ListFile90:

           lda  M1_LineCount
           cmp  #$08
           beq  ListFile99              ; 8 lines printed so exit

           lda  M1_FileCount+1          ; Check to see if we're at the end of the
           bne  ListFile95              ; filelist when we have less than 8 files
           lda  M1_FileCount            ; total to display.
           cmp  M1_LineCount
           beq  ListFile96

ListFile95:

           clc
           lda  Ptr1                    ; Move to next file.
           adc  M1_EntLength
           sta  Ptr1
           lda  Ptr1+1
           adc  #$00
           sta  Ptr1+1

           dec  EntRemain
           lda  EntRemain
           bne  MoreToProcess           ; See if there are entries remaining

           jsr  GetNextBlk              ; No more remaining so get next block

MoreToProcess:

           jmp  ListFile01

ListFile96:                             ; Clear entries on a short list

           sec                          ; Calculate number of blank lines required
           lda  #$08
           sbc  M1_LineCount
           tax                          ; x = number of blank lines

ListFile97:

           lda  #' '+$80                ; Space
           ldy  #23                     ; 23 spaces in a line

ListFile98:

           jsr  cout                    ; Print space
           dey
           bne  ListFile98              ; Finished this line?

           lda  #22-1                   ; Move HTab to beginning of line
           sta  HTab
           inc  VTab                    ; Increment VTab
           jsr  SetVTab                 ;   and set it.
           dex
           bne  ListFile97              ; More lines required?

ListFile99:

           rts

GetNextBlk:

           inc  CurrPage                ; Move current page pointer up by
           inc  CurrPage                ; 1 block (512 bytes)

           lda  M1_EntPerBlk               ; Reinitialize entries remaining
           sta  EntRemain               ; in block.

           lda  #<readBuf+4              ; Put current line pointer back at first
           sta  Ptr1                    ; entry in block.
           lda  #>readBuf+4
           sta  Ptr1+1

GetBlock:

;          Get directory block from aux memory

           lda  CurrPage
           sta  A1H                     ; Source starting - high byte
           lda  #$00
           sta  A1L                     ; Source starting - low byte
           lda  CurrPage
           ina
           sta  A2H                     ; Source ending   -  high byte
           lda  #$FF
           sta  A2L                     ; Source ending   - low byte
           lda  #>readBuf
           sta  A4H                     ; Destination     - high byte
           lda  #<readBuf
           sta  A4L                     ; Destination     - low byte

           clc                          ; Move from aux to main
           jsr  AuxMove                 ; Get block

           rts

;  Save volume header info

SaveVolHeader:

           ldx  #$26                    ; $27 bytes long (zero based)

SVH01:

           lda  readBuf+4,x             ; Get byte
           sta  VolHeader,x             ; Save byte
           dex                          ; Move index
           bpl  SVH01                   ; Done?

           rts
