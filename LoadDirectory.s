LoadDirectory Start
           Using FileTypes

*
*          Load current prefix directory into memory
*

EOF        equ  $4C

*          Directory offsets

oPrevBlock equ  $00
oNextBlock equ  $02
oFileName  equ  $00
oFileType  equ  $10
oFileTypeA equ  $11
oEntLength equ  $23
oEntPerBlk equ  $24
oFileCount equ  $25 -> $26

           lda  #$08
           sta  Destpage                Starting aux page for buffer

           ldx  Prefix                  Get length of current prefix
           stx  Path                    Save in Path for MLIOpen1

           bne  CopyPath                Null prefix?

           jmp  GetVolumes              Yes so get the OnLine volumes.

CopyPath   anop

           lda  Prefix,x                Get Prefix character
           sta  Path,x                  Copy it to Path
           dex                          Copy backwards
           bne  CopyPath                x = 0?  We're done.

           jsr  MLIOpen1                Open directory as file #1

           lda  openRef1
           sta  readRef                 Save reference number
           sta  closeRef

           lda  #$00                    512 bytes
           sta  readRequest             low byte
           lda  #$02                    512 byte
           sta  readRequest+1           high byte

           jsr  MLIRead                 Priming read
           cmp  #EOF
           beq  Exit

           lda  readBuf+oEntLength      Get file directory entry length
           sta  EntLength
           lda  readBuf+oEntPerBlk      Get file entries per block
           sta  EntPerBlk

           stz  FileCount               Zero out file count for this directory.
           stz  FileCount+1

* 40 directory blocks max at this time.  Uses aux memory $0800 - $57FF

           lda  #40                     Max directory blocks this program
           sta  MaxBlocks                will process.

BlockLoop  anop

           jsr  ProcessBlock

*          Check to see if this is the 20th block to be written.
*          If so then force NextBlock to be zero

           lda  MaxBlocks               Get blocks remaining
           cmp  #1                      Is this the last one?
           bne  SaveBlock               No

           lda  #0                      Yes, so zero out oNextBlock
           sta  readBuf+oNextBlock      (2 bytes)
           sta  readBuf+oNextBlock+1

*          Save block to aux memory

SaveBlock  anop

           lda  #readBuf                Set starting source address
           sta  A1L
           lda  #>readBuf
           sta  A1H

           lda  #readBuf+$1FF           Set ending source address
           sta  A2L
           lda  #>readBuf+$1FF
           sta  A2H

           lda  #$00                    Set aux memory starting destination
           sta  A4L
           lda  DestPage
           sta  A4H

           sec                          Move to aux
           jsr  AuxMove

*          Move destination memory pointer up by 512 bytes

           inc  DestPage
           inc  DestPage

           dec  MaxBlocks
           lda  MaxBlocks               Force exit if directory is more than
           beq  Exit                     20 blocks

           jsr  MLIRead
           cmp  #EOF
           bne  BlockLoop

Exit       anop

           jsr  MLIClose

* Save FileCount to it's place in the first block.

           lda  #FileCount              Starting address
           sta  A1L
           lda  #>FileCount
           sta  A1H

           lda  #FileCount+1            Ending address
           sta  A2L
           lda  #>FileCount+1
           sta  A2H

           lda  #oFileCount             Aux memory destination address
           sta  A4L
           lda  #$08
           sta  A4H

           sec
           jsr  AuxMove                 Move it.

           rts

ProcessBlock anop

*
* Convert filetypes in block to ASCII
*

           lda  #readBuf+4              Set ptr1 to first file entry
           sta  ptr1
           lda  #>readBuf+4
           sta  ptr1+1

           lda  EntPerBlk               initialize file counter per block
           sta  EntLeft

FileLoop   anop

           ldy  #oFileName              Get storage type/name length
           lda  (Ptr1),y
           bne  NotDeleted              Skip processing deleted entry.
           jmp  MoveNext

NotDeleted anop

           and  #$E0                    Keep only upper 3 bits
           cmp  #$E0                    Match on $F0 or $E0
           bne  Convert                 No, so convert file type and count it.

           ldx  #3                      Make filetype display for volume headers
           ldy  #oFileTypeA             and directory headers spaces only.
           lda  #' '

SpaceLoop  anop

           sta  (Ptr1),y
           iny
           dex
           bne  SpaceLoop
           jmp  MoveNext

Convert    anop

           inc  FileCount               Count this entry as good.
           bne  FC2
           inc  FileCount+1

FC2        anop

           ldy  #oFileType              Get filetype offset
           lda  (ptr1),y
           sta  FileType                Save filetype

*          Binary searce filetypes table

           lda  #FileTypes
           sta  Bottom                  Set initial bottom pointer
           lda  #>FileTypes
           sta  Bottom+1

           lda  #FileTypesE
           sta  Top                     Set initial top pointer
           lda  #>FileTypesE
           sta  Top+1

SearchLoop anop

*          Calculate mid point in Ptr2

           sec
           lda  Top
           sbc  Bottom                  Ptr2 = Top - Bottom
           sta  Ptr2
           lda  Top+1
           sbc  Bottom+1
           sta  Ptr2+1

           lsr  Ptr2+1                  Ptr2 = Ptr2 / 2
           ror  Ptr2

           lda  Ptr2
           and  #%11111100              Make divisible by 4.
           sta  Ptr2

           bne  CheckMatch              If Ptr2 (midpoint) is zero at
           lda  Ptr2+1                  this point then we are in a no
           bne  CheckMatch              match situation.
           bra  NoMatch

CheckMatch anop

           clc
           lda  Ptr2
           adc  Bottom
           sta  Ptr2                    Add address of bottom to get an
           lda  Ptr2+1                  exact midpoint address.
           adc  Bottom+1
           sta  Ptr2+1

*          Test for hit/miss and continue search

           lda  FileType                Filetype we're looking for.
           cmp  (Ptr2)                  Ptr2 = filetype at midpoint.

           beq  MatchFound              A hit!
           bcc  PtrEquTop               Filetype < table type

*          Move bottom pointer

           lda  Ptr2
           sta  Bottom
           lda  Ptr2+1
           sta  Bottom+1
           bra  SearchLoop              Continue the search

*          Move top pointer

PtrEquTop  anop

           lda  Ptr2
           sta  Top
           lda  Ptr2+1
           sta  Top+1
           bra  SearchLoop              Continue the search

*          Save matching filetype name

MatchFound anop

           ldy  #1                      Offset start
           ldx  #3                      3 characters to save

           clc
           lda  Ptr1                    Set Ptr3 to destination address
           adc  #oFileTypeA             by adding FileType ASCII offset
           sta  Ptr3                    to Ptr1 and saving it in Ptr3.
           lda  Ptr1+1
           adc  #0
           sta  Ptr3+1

MatchLoop  anop

           lda  (Ptr2),y                Get filetype character
           dey                          Backup index by one
           sta  (Ptr3),y                Save filetype character
           iny                          Add one to offset previous dey
           iny                          Move to next character
           dex                          Count character printed
           bne  MatchLoop               More to print?
           bra  MoveNext                No so exit

NoMatch    anop

           ldy  #oFileTypeA             Place to save ASCII version
           lda  #'$'
           sta  (ptr1),y

           lda  FileType
           clc
           lsr  a
           lsr  a
           lsr  a
           lsr  a
           tax
           lda  AsciiTable,x
           iny
           sta  (ptr1),y

           lda  FileType
           and  #$0F
           tax
           lda  AsciiTable,x
           iny
           sta  (ptr1),y

*          Move to next file entry

MoveNext   anop

           lda  ptr1
           clc
           adc  EntLength
           sta  ptr1

           lda  ptr1+1
           adc  #$00
           sta  ptr1+1

           dec  EntLeft
           lda  EntLeft
           beq  ExitToRts
           jmp  FileLoop

ExitToRts  anop

           rts

EntLength  ds   1
EntPerBlk  ds   1
FileCount  ds   2
EntLeft    ds   1
MaxBlocks  ds   1
DestPage   ds   1
FileType   ds   1
Bottom     ds   2
Top        ds   2
AscIITable dc   c'0123456789ABCDEF'

*          No path so get online volumes

GetVolumes anop

           lda  #0
           ldx  #0

ZeroOut1   anop                         Zero out first 256 bytes

           sta  readBuf,x
           inx
           bne  ZeroOut1


ZeroOut2   anop                         Zero out second 256 bytes

           sta  readBuf+$100,x
           inx
           bne  ZeroOut2

           lda  #readBuf+4              Set Ptr1 to destination for phony read
           sta  Ptr1                    block
           lda  #>readBuf+4
           sta  Ptr1+1

           lda  #$27                    Set Entry Length
           sta  readBuf+oEntLength
           sta  EntLength

           lda  #$0D                    Set Entries Per Block
           sta  readBuf+oEntPerBlk
           sta  EntPerBlk

           lda  #0                      Entry counter
           sta  FileCount
           sta  FileCount+1

           lda  #onlineBuf              Ptr2 for scanning online's buffer
           sta  Ptr2
           lda  #>onlineBuf
           sta  Ptr2+1

           lda  #0                      0 in unit number = all online volumes
           sta  onlineUnit

           jsr  MLIOnLine               Get online volumes

           ldx  #14                     14 max online volumes

NextEntry  anop

           lda  (Ptr2)                  Get unit num
           and  #$0F                    Keep only name length
           beq  NextVolume              Invalid volume
           tay                          Y-reg for index in name transfer
           ora  #$F0                    Set it as a volume entry
           sta  (Ptr1)                  Set storage type / length

           inc  FileCount               Count this one.

SaveName   anop

           lda  (Ptr2),y
           sta  (Ptr1),y
           dey
           bne  SaveName

           lda  (Ptr2)                  Save unit number in readBuf for
           ldy  #oFileType               reference
           sta  (Ptr1),y

           and  #$70                    Keep only drive slot info
           clc
           lsr  a                       Move to right nibble.
           lsr  a
           lsr  a
           lsr  a
           tay                          Move to index
           lda  AscIITable,y            Get ASCII character
           ldy  #oFileTypeA              Save Ascii version of slot number.
           sta  (Ptr1),y

           lda  #','                    Comma.
           iny                          Move to next character.
           sta  (Ptr1),y                Save comma.

           lda  (Ptr2)                  Get unit number
           clc
           asl  a                       Move drive # bit to carry
           and  #0                      Clear all bits
           rol  a                       rotate carry into bit 0
           ina                          Add 1 to bit 0
           tay                          Move to index
           lda  AscIITable,y            Get Ascii character
           ldy  #oFileTypeA+2
           sta  (Ptr1),y                Save Ascii version of drive #

           clc                          Move to next destination address.
           lda  Ptr1
           adc  EntLength
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

NextVolume anop

           clc                          Move to next source address
           lda  Ptr2
           adc  #16
           sta  Ptr2
           lda  Ptr2+1
           adc  #0
           sta  Ptr2+1

           dex
           bne  NextEntry               Process next entry

           lda  FileCount               Save Entries counted to buffer.
           ldy  #oFileCount
           sta  readBuf,y

           lda  FileCount+1
           iny
           sta  readBuf,y

*          Save dummy buffer to aux memory

           lda  #readBuf                Set starting source address
           sta  A1L
           lda  #>readBuf
           sta  A1H

           lda  #readBuf+$1FF           Set ending source address
           sta  A2L
           lda  #>readBuf+$1FF
           sta  A2H

           lda  #$00                    Set aux memory starting destination
           sta  A4L
           lda  #$08
           sta  A4H

           sec                          Move to aux
           jsr  AuxMove

           rts

           End
