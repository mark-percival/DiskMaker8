           bra  Start

*          Offsets

oNextBlock equ  $02 -> $03              Next block number (0 = last block)
oEntLength equ  $23                     Length of file entry
oEntPerBlk equ  $24                     Number of file entries per block
oFileCount equ  $25 -> $26              Number of active files in this directory

*          Storage declarations

EntLength  ds   1                       Length of file entry
EntPerBlk  ds   1                       Number of file entries per block

FirstPage  ds   1                       Aux page number of first line entry
FirstAddr  ds   2                       Address of first line entry
FstEntCnt  ds   1                       Remaining entries in blk at first line

EntRemain  ds   1                       Entries remaining in current block

Start      anop

           jsr  PaintMenu1              Paint menu1 frame

           lda  #OpenBtn
           sta  TabIndex                Initialize tabindex to open button.

Menu01     anop

           jsr  MLISetPrefix            Set Current Prefix

           jsr  LoadDirectory           Load current directory into memory

           jsr  Initialize              Initialize variables

           jsr  SaveVolHeader           Save volume header info

Menu02     anop

           jsr  ListFiles               List 8 files from FirstAddr

Menu03     anop

           jsr  RefreshBtn              Refresh command buttons display

           jsr  Menu1UI                 Menu 1 User Interface

           lda  #DirChange              *** Directory Refresh ***
           bit  RC
           bne  Menu01

           lda  #NoDirChange            *** No Directory Refresh ***
           bit  RC
           bne  Menu02

           lda  #TabOnly                *** Tab Key Button Focus Change ***
           bit  RC
           bne  Menu03

           lda  #Quit                   *** Quit Code ***
           bit  RC
           bne  Menu99

           jsr  ClearMenu1              Remove menu1 data from screen
           jsr  Menu2                   Go to Menu2.
           jmp  Start                   Back to the top

Menu99     anop

           rts

Initialize anop

           lda  #$08
           sta  FirstPage               Set initial first aux page number
           sta  CurrPage                Set page to load

           jsr  GetBlock                Get block from aux memory

           lda  readBuf+oEntLength      Get file entry length
           sta  EntLength

           lda  readBuf+oEntPerBlk      Get number of entries per block
           sta  EntPerBlk
           sta  FstEntCnt               First line entries remaining.

           lda  readBuf+oFileCount      Get number of active files
           sta  FileCount
           lda  readBuf+oFileCount+1
           sta  FileCount+1

           stz  LinesAbove              Since we're starting, lines above
           stz  LinesAbove+1             top is zero.

           sec                          Calculcate lines below
           lda  FileCount
           sbc  #8
           sta  LinesBelow              LinesBelow = FileCount - 8
           lda  FileCount+1
           sbc  #0
           sta  LinesBelow+1

           bpl  Init01

           stz  LinesBelow              If LinesBelow is less than our
           stz  LinesBelow+1            total FileCount, zero it out.

Init01     anop

           lda  #readBuf+4
           sta  FirstAddr
           lda  #>readBuf+4
           sta  FirstAddr+1

           lda  Prefix                  Don't attempt to move past header
           beq  Init02                  for volume listing

           lda  FileCount               Don't bother finding the first entry
           ora  FileCount+1             if there is none.
           beq  Init02

           jsr  FindFstEnt              Move past Vol/Dir header

Init02     anop

           lda  #Normal                 Normal text for non selected file.
           sta  TextMode

           lda  #1                      Default line selected
           sta  SelectLine

           rts

ListFiles  anop

*          List up to 8 files starting from FirstAddr

           lda  #22-1
           sta  HTab                    HTab 22
           lda  #11-1
           sta  VTab                    VTab 11 to start
           jsr  SetVTab

           lda  SelectLine
           bne  NotUp

           jsr  ScrollUp
           bra  NoScrollDn

NotUp      anop

           cmp  #9
           bcc  NoScrollDn

           jsr  ScrollDown

NoScrollDn anop

           lda  FirstAddr               Set up first line address
           sta  Ptr1
           lda  FirstAddr+1
           sta  Ptr1+1

           lda  FirstPage               Set up first line source aux page
           sta  CurrPage                number.

           lda  FstEntCnt               Set up remaining entries from first
           sta  EntRemain               line.

           jsr  GetBlock                Get block from aux memory

           stz  LineCount               Zero out lines printed counter.

ListFile01 anop

           lda  Prefix                  Zero prefix length means this is a
           beq  ListFile02              volume listing and not a file listing.

           lda  (Ptr1)
           beq  ListFile90              Deleted entry
           and  #$E0
           cmp  #$E0                    Skips volume and directory headers
           beq  ListFile90

ListFile02 anop

           inc  LineCount               We're printing this line so count it
           lda  LineCount
           cmp  SelectLine              Is this the line selected?
           bne  ListFile03              No

           lda  #Inverse                Selected line so set TextMode to inverse
           sta  TextMode                to display as selected.

           lda  CurrPage                Also save the aux page number and
           sta  SelectPage              address in that page that the selected
           lda  Ptr1                    entry appears on.
           sta  SelectAddr
           lda  Ptr1+1
           sta  SelectAddr+1

ListFile03 anop

           jsr  PrtFileName             It's good so print it.

           lda  #22-1                   Move to next line
           sta  HTab
           inc  VTab
           jsr  SetVTab

ListFile90 anop

           lda  LineCount
           cmp  #$08
           beq  ListFile99              8 lines printed so exit

           lda  FileCount+1             Check to see if we're at the end of the
           bne  ListFile95              filelist when we have less than 8 files
           lda  FileCount               total to display.
           cmp  LineCount
           beq  ListFile96

ListFile95 anop

           clc
           lda  Ptr1                    Move to next file.
           adc  EntLength
           sta  Ptr1
           lda  Ptr1+1
           adc  #$00
           sta  Ptr1+1

           dec  EntRemain
           lda  EntRemain
           bne  MoreToProcess           See if there are entries remaining

           jsr  GetNextBlk              No more remaining so get next block

MoreToProcess anop

           jmp  ListFile01

ListFile96 anop                         Clear entries on a short list

           sec                          Calculate number of blank lines required
           lda  #$08
           sbc  LineCount
           tax                          x = number of blank lines

ListFile97 anop

           lda  #' '+$80                Space
           ldy  #23                     23 spaces in a line

ListFile98 anop

           jsr  cout                    Print space
           dey
           bne  ListFile98              Finished this line?

           lda  #22-1                   Move HTab to beginning of line
           sta  HTab
           inc  VTab                    Increment VTab
           jsr  SetVTab                   and set it.
           dex
           bne  ListFile97              More lines required?

ListFile99 anop

           rts

GetNextBlk anop

           inc  CurrPage                Move current page pointer up by
           inc  CurrPage                1 block (512 bytes)

           lda  EntPerBlk               Reinitialize entries remaining
           sta  EntRemain               in block.

           lda  #readBuf+4              Put current line pointer back at first
           sta  Ptr1                    entry in block.
           lda  #>readBuf+4
           sta  Ptr1+1

GetBlock   Entry

*          Get directory block from aux memory

           lda  CurrPage
           sta  A1H                     Source starting - high byte
           lda  #$00
           sta  A1L                     Source starting - low byte
           lda  CurrPage
           ina
           sta  A2H                     Source ending   -  high byte
           lda  #$FF
           sta  A2L                     Source ending   - low byte
           lda  #>readBuf
           sta  A4H                     Destination     - high byte
           lda  #readBuf
           sta  A4L                     Destination     - low byte

           clc                          Move from aux to main
           jsr  AuxMove                 Get block

           rts

*  Save volume header info

SaveVolHeader anop

           ldx  #$26                    $27 bytes long (zero based)

SVH01      anop

           lda  readBuf+4,x             Get byte
           sta  VolHeader,x             Save byte
           dex                          Move index
           bpl  SVH01                   Done?

           rts
