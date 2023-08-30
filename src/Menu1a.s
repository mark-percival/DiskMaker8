           bra  M1Start

;          Offsets

oNextBlock =  $02 ; -> $03            Next block number (0 = last block)

;          Storage declarations

EntLength: .byte   $00                ; Length of file entry
EntPerBlk: .byte   $00                ; Number of file entries per block

FirstPage: .byte   $00                ; Aux page number of first line entry
FirstAddr: .addr   $0000              ; Address of first line entry
FstEntCnt: .byte   $00                ; Remaining entries in blk at first line

EntRemain: .byte   $00                ; Entries remaining in current block

M1Start:

           jsr  PaintMenu1            ; Paint menu1 frame

           lda  #OpenBtn
           sta  TabIndex_M1           ; Initialize tabindex to open button.

Menu01:

           jsr  MLISetPrefix          ; Set Current Prefix

           jsr  LoadDirectory         ; Load current directory into memory

           jsr  M1Initialize          ; Initialize variables

           jsr  SaveVolHeader         ; Save volume header info

Menu02:

           jsr  ListFiles             ; List 8 files from FirstAddr

Menu03:

           jsr  MBRefreshBtn          ; Refresh command buttons display

           jsr  Menu1UI               ; Menu 1 User Interface

           lda  #DirChange            ; *** Directory Refresh ***
           bit  RC_M1
           bne  Menu01

           lda  #NoDirChange          ; *** No Directory Refresh ***
           bit  RC_M1
           bne  Menu02

           lda  #TabOnly              ; *** Tab Key Button Focus Change ***
           bit  RC_M1
           bne  Menu03

           lda  #Quit                 ; *** Quit Code ***
           bit  RC_M1
           bne  Menu99

           jsr  ClearMenu1            ; Remove menu1 data from screen
           jsr  Menu2                 ; Go to Menu2.
           jmp  Start                 ; Back to the top

Menu99:

           rts

M1Initialize:

           lda  #$08
           sta  FirstPage             ; Set initial first aux page number
           sta  CurrPage_M1           ; Set page to load

           jsr  GetBlock              ; Get block from aux memory

           lda  readBuf+oEntLength    ; Get file entry length
           sta  EntLength

           lda  readBuf+oEntPerBlk    ; Get number of entries per block
           sta  EntPerBlk
           sta  FstEntCnt             ; First line entries remaining.

           lda  readBuf+oFileCount    ; Get number of active files
           sta  FileCount_M1
           lda  readBuf+oFileCount+1
           sta  FileCount_M1+1

           stz  LinesAbove_M1         ; Since we're starting, lines above
           stz  LinesAbove_M1+1       ;  top is zero.

           sec                        ; Calculcate lines below
           lda  FileCount_M1
           sbc  #8
           sta  LinesBelow_M1         ; LinesBelow_M1 = FileCount_M1 - 8
           lda  FileCount_M1+1
           sbc  #0
           sta  LinesBelow_M1+1

           bpl  Init01

           stz  LinesBelow_M1         ; If LinesBelow_M1 is less than our
           stz  LinesBelow_M1+1       ; total FileCount_M1, zero it out.

Init01:

           lda  #<readBuf+4
           sta  FirstAddr
           lda  #>readBuf+4
           sta  FirstAddr+1

           lda  Prefix                ; Don't attempt to move past header
           beq  Init02                ; for volume listing

           lda  FileCount_M1          ; Don't bother finding the first entry
           ora  FileCount_M1+1        ; if there is none.
           beq  Init02

           jsr  FindFstEnt            ; Move past Vol/Dir header

Init02:

           lda  #Normal               ; Normal text for non selected file.
           sta  TextMode

           lda  #1                    ; Default line selected
           sta  SelectLine_M1

           rts

ListFiles:

;          List up to 8 files starting from FirstAddr

           lda  #22-1
           sta  HTab                  ; HTab 22
           lda  #11-1
           sta  VTab                  ; VTab 11 to start
           jsr  SetVTab

           lda  SelectLine_M1
           bne  NotUp

           jsr  ScrollUp
           bra  NoScrollDn

NotUp:

           cmp  #9
           bcc  NoScrollDn

           jsr  M1ScrollDown

NoScrollDn:

           lda  FirstAddr             ; Set up first line address
           sta  Ptr1
           lda  FirstAddr+1
           sta  Ptr1+1

           lda  FirstPage             ; Set up first line source aux page
           sta  CurrPage_M1              ; number.

           lda  FstEntCnt             ; Set up remaining entries from first
           sta  EntRemain             ; line.

           jsr  GetBlock              ; Get block from aux memory

           stz  LineCount_M1          ; Zero out lines printed counter.

ListFile01:

           lda  Prefix                ; Zero prefix length means this is a
           beq  ListFile02            ; volume listing and not a file listing.

           lda  (Ptr1)
           beq  ListFile90            ; Deleted entry
           and  #$E0
           cmp  #$E0                  ; Skips volume and directory headers
           beq  ListFile90

ListFile02:

           inc  LineCount_M1          ; We're printing this line so count it
           lda  LineCount_M1
           cmp  SelectLine_M1         ; Is this the line selected?
           bne  ListFile03            ; No

           lda  #Inverse              ; Selected line so set TextMode to inverse
           sta  TextMode              ; to display as selected.

           lda  CurrPage_M1           ; Also save the aux page number and
           sta  SelectPage_M1         ; address in that page that the selected
           lda  Ptr1                  ; entry appears on.
           sta  SelectAddr_M1
           lda  Ptr1+1
           sta  SelectAddr_M1+1

ListFile03:

           jsr  PrtFileName           ; It's good so print it.

           lda  #22-1                 ; Move to next line
           sta  HTab
           inc  VTab
           jsr  SetVTab

ListFile90:

           lda  LineCount_M1
           cmp  #$08
           beq  ListFile99            ; 8 lines printed so exit

           lda  FileCount_M1+1        ; Check to see if we're at the end of the
           bne  ListFile95            ; filelist when we have less than 8 files
           lda  FileCount_M1          ; total to display.
           cmp  LineCount_M1
           beq  ListFile96

ListFile95:

           clc
           lda  Ptr1                  ; Move to next file.
           adc  EntLength
           sta  Ptr1
           lda  Ptr1+1
           adc  #$00
           sta  Ptr1+1

           dec  EntRemain
           lda  EntRemain
           bne  MoreToProcess         ; See if there are entries remaining

           jsr  GetNextBlk            ; No more remaining so get next block

MoreToProcess:

           jmp  ListFile01

ListFile96:                           ; Clear entries on a short list

           sec                        ; Calculate number of blank lines required
           lda  #$08
           sbc  LineCount_M1
           tax                        ; x = number of blank lines

ListFile97:

           lda  #' '+$80              ; Space
           ldy  #23                   ; 23 spaces in a line

ListFile98:

           jsr  cout_mark             ; Print space
           dey
           bne  ListFile98            ; Finished this line?

           lda  #22-1                 ; Move HTab to beginning of line
           sta  HTab
           inc  VTab                  ; Increment VTab
           jsr  SetVTab               ;   and set it.
           dex
           bne  ListFile97            ; More lines required?

ListFile99:

           rts

GetNextBlk:

           inc  CurrPage_M1           ; Move current page pointer up by
           inc  CurrPage_M1           ; 1 block (512 bytes)

           lda  EntPerBlk             ; Reinitialize entries remaining
           sta  EntRemain             ; in block.

           lda  #<readBuf+4           ; Put current line pointer back at first
           sta  Ptr1                  ; entry in block.
           lda  #>readBuf+4
           sta  Ptr1+1

GetBlock:

;          Get directory block from aux memory

           lda  CurrPage_M1
           sta  A1H                   ; Source starting - high byte
           lda  #$00
           sta  A1L                   ; Source starting - low byte
           lda  CurrPage_M1
           ina
           sta  A2H                   ; Source ending   -  high byte
           lda  #$FF
           sta  A2L                   ; Source ending   - low byte
           lda  #>readBuf
           sta  A4H                   ; Destination     - high byte
           lda  #<readBuf
           sta  A4L                   ; Destination     - low byte

           clc                        ; Move from aux to main
           jsr  AuxMove               ; Get block

           rts

;  Save volume header info

SaveVolHeader:

           ldx  #$26                  ; $27 bytes long (zero based)

SVH01:

           lda  readBuf+4,x           ; Get byte
           sta  VolHeader_M1,x        ; Save byte
           dex                        ; Move index
           bpl  SVH01                 ; Done?

           rts
