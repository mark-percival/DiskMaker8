Menu1UI    Start
           using Menu1Vars

*
*          Menu1 User Interface
*

* AscII Key Values

UpArrow    equ  $8B
DownArrow  equ  $8A
LeftArrow  equ  $88
RightArrow equ  $95
ReturnKey  equ  $8D
TabKey     equ  $89

* File entry offsets

oFileType  equ  $10 - $10
oAuxType   equ  $1F - $20

           stz  RC                      Reset return code
           stz  ClearKbd                Clear keyboard strobe

PollDev    anop

           jsr  PlotMouse

PollDevLoop anop

           lda  Keyboard                Get keypress
           bpl  PollMouse
           jmp  KeyDev

PollMouse  anop

           jsr  ReadMouse               Read mouse
           lsr  MouseX                  Divide by 2 to return to the
           lsr  MouseY                  0 to 79, 0 to 23 range.
           lda  MouseStat               Get mouse status
           bit  #MouseMove              Moved mouse?
           bne  MouseDev1               Yes
           bit  #CurrButton             Button pressed?
           bne  MouseDev2               Yes
           bit  #PrevButton             Button release?
           bne  MouseDev3               Yes

           bra  PollDevLoop

*
* Mouse Movement
*

MouseDev1  anop

           jsr  MoveMouse
           jmp  PollDevLoop

*
* Move Button Pressed
*

MouseDev2  anop

           jsr  ButtonDown
           lda  blnDblClick
           bne  DoOpen                  should be because I'm double clicking.

           lda  RC
           bne  MouseDev2X
           jmp  PollDevLoop

MouseDev2X anop

           jmp  Exit

*
* Mouse Button Release
*

MouseDev3  anop

           jsr  ButtonUp
           lda  RC
           bne  MouseDev3X
           jmp  PollDevLoop

MouseDev3X anop

           lda  TabIndex
           beq  DoDisks
           cmp  #OpenBtn
           beq  DoOpen
           cmp  #CloseBtn
           beq  DoClose
           bra  DoCancel

DoDisks    anop

           jmp  OnLineReq0

DoOpen     anop

           jmp  OpenReq0

DoClose    anop

           jmp  CloseReq0

DoCancel   anop

           jmp  QuitReq0

*
* Keyboard Key Pressed
*

KeyDev     anop

           stz  ClearKbd                Clear keyboard strobe
           sta  KeyPress                Save keypress

*          Test for quiting screen

           lda  AppleKey
           bpl  NextKey01               No Apple Key
           lda  KeyPress
           cmp  #'Q'+$80
           beq  QuitReq
           cmp  #'q'+$80
           beq  QuitReq
           bra  NextKey01

QuitReq    anop

           lda  #CancelBtn              Test here to see if Cancel is the
           cmp  TabIndex                  currently displayed button.
           sta  TabIndex                Change TabIndex here.
           beq  QuitReq0                Yes Cancel is current based on prev test

           jsr  RefreshBtn              Display Cancel as current selected.

QuitReq0   anop

           jsr  AnimateBtn

           lda  #Quit
           sta  RC
           jmp  Exit

*          Test for down / right arrow key.

NextKey01  anop

           lda  KeyPress
           cmp  #DownArrow              Down arrow?
           beq  DownReq
           cmp  #RightArrow             ...or right arrow?
           beq  DownReq
           bra  NextKey02

DownReq    Entry

           lda  SelectLine              Check to see if selected line is at the
           cmp  #8                      bottom of the window.
           beq  AtBottom                Yes it is.

           lda  FileCount+1             No so see if there are more file entries
           bne  IncSelLine              below our selected line.

           lda  FileCount               If FileCount = SelectLine then we're
           cmp  SelectLine              at the bottom of the window with less
           beq  AtBottom                than 8 file entries in the directory.

IncSelLine anop                         Increment selected line

           inc  SelectLine              Move selected line to next position
           lda  #NoDirChange
           sta  RC
           jmp  Exit

AtBottom   anop

           lda  LinesBelow+1            Check to see if we have move lines below
           ora  LinesBelow              this point.  This is a 16 bit number.
           beq  NoMoreBelow

           inc  SelectLine              This should make SelectLine = 9.

NoMoreBelow anop

           lda  #NoDirChange
           sta  RC
           jmp  Exit

*          Test for up / left arrow key.

NextKey02  anop

           lda  KeyPress
           cmp  #UpArrow
           beq  UpReq
           cmp  #LeftArrow
           beq  UpReq
           bra  NextKey03

UpReq      Entry

           lda  SelectLine              Check to see if we're at top of window
           cmp  #1
           beq  AtTop

           dec  SelectLine              Not at top of window so move line up 1
           lda  #NoDirChange
           sta  RC
           jmp  Exit

AtTop      anop

           lda  LinesAbove+1            Check to see if we have lines above
           ora  LinesAbove              this point.
           beq  NoMoreAbove

           dec  SelectLine              This should make SelectLine = 0

NoMoreAbove anop

           lda  #NoDirChange
           sta  RC
           jmp  Exit

NextKey03  anop

*          Test for requesting online drives

           lda  AppleKey
           bpl  NextKey04               No Apple Key
           lda  KeyPress
           cmp  #'D'+$80
           beq  OnlineReq
           cmp  #'d'+$80
           beq  OnlineReq
           bra  NextKey04

OnlineReq  anop

           lda  #DisksBtn               Test here to see if Disks is the
           cmp  TabIndex                  currently displayed button.
           sta  TabIndex                Change TabIndex here.
           beq  OnlineReq0              Yes Disks is current based on prev test

           jsr  RefreshBtn              Display Disks as current selected.

OnlineReq0 anop

           jsr  AnimateBtn

OnlineReq1 anop

           lda  #OpenBtn                Default to Open after call.
           sta  TabIndex

           stz  Prefix
           lda  #DirChange
           sta  RC
           jmp  Exit

NextKey04  anop

*          Test for requesting file open.

           lda  AppleKey
           bpl  NextKey05a              No Apple Key
           lda  KeyPress
           cmp  #'O'+$80
           beq  OpenReq
           cmp  #'o'+$80
           beq  OpenReq

NextKey05a anop

           jmp  NextKey05

OpenReq    anop

           lda  #OpenBtn                Test here to see if Open is the
           cmp  TabIndex                  currently displayed button.
           sta  TabIndex                Change TabIndex here.
           beq  OpenReq0                Yes Open is current based on prev test

           jsr  RefreshBtn              Display Open as current selected.

OpenReq0   anop

           jsr  AnimateBtn              Do button animation.

           lda  LineCount               Are there files listed in this
           bne  OpenReq0a                directory?

           jmp  BadFileName             No, so beep the user to let him know.

OpenReq0a  anop

           lda  Prefix                  Check for null prefix
           bne  OpenReq1

           lda  #1                      Null prefix, put the initial '/' and
           sta  Prefix                  make the length 1.
           lda  #'/'
           sta  Prefix+1

OpenReq1   anop

           lda  SelectPage              Make sure proper page is loaded.
           sta  CurrPage
           jsr  GetBlock

           lda  SelectAddr              Set up pointer to selected file.
           sta  Ptr1
           lda  SelectAddr+1
           sta  Ptr1+1

           lda  (Ptr1)
           and  #$0F
           tay

OpenReq1a  anop

           lda  (Ptr1),y                Search file name for a '?' from an
           cmp  #'?'                    AppleShare volume.
           bne  OpenReq1b
           jmp  BadFileName

OpenReq1b  anop

           dey
           bne  OpenReq1a

           lda  (Ptr1)                  Get file type / length of file.
           bpl  OpenFile                If not a directory, do nothing.

           and  #$0F                    Keep only file name length
           sta  extCnt                  Save file name length
           stz  srcPtr                  Init to zero.

           clc                          Check to make sure new prefix isn't
           lda  Prefix                  longer than 63 characters.
           adc  extCnt
           cmp  #63
           bcs  BadPrefix

           lda  Prefix                  Init destPtr to end of current dir
           sta  destPtr

OpenReq2   anop

           inc  srcPtr                  Bump to next character to read.
           inc  destPtr                 Bump to next empty location.
           ldy  srcPtr                  Get character of directory name.
           lda  (Ptr1),y
           ldy  destPtr                 Add to end of current directory.
           sta  Prefix,y
           dec  extCnt                  Done all characters?
           bne  OpenReq2                No, so do some more

           iny
           lda  #'/'                    Add '/' on to the end.
           sta  Prefix,y
           sty  Prefix                  Fix length of path.

OpenReq99  anop

           lda  #DirChange
           sta  RC
           jmp  Exit

BadPrefix  anop                         New prefix > 63 characters

           jsr  Beep

           lda  #DirError
           sta  MsgPtr
           lda  #>DirError
           sta  MsgPtr+1

           jsr  MsgOk

           lda  #NoDirChange
           sta  RC
           jmp  Exit

BadFileName anop

           jsr  Beep

           lda  #NoDirChange
           sta  RC
           jmp  Exit

*
* Entered non-directory -- save file name in Path
*

OpenFile   anop

           and  #$F0                    Keep file type
           cmp  #$40                    Extended file?
           bcc  OpenFile0               No, process file.

           jsr  Beep                    Beep to indicate extended file.
           lda  #NoDirChange
           sta  RC
           jmp  Exit

OpenFile0  anop

           lda  (Ptr1)                  Get file info again.
           and  #$0F                    Keep file length only
           ldy  #1                      Start index at 1
           tax                          Save length in x
           sta  Path                    Save length to 1st byte in path

OpenFile1  anop

           lda  (Ptr1),y                Get next character
           sta  Path,y                  Save character in path
           iny                          Move to next character
           dex                          Count it saved.
           bne  OpenFile1               More?

           ldy  #oFileType              Save file type
           lda  (Ptr1),y
           sta  FileType

           ldy  #oAuxType               Save file aux type
           lda  (Ptr1),y
           sta  AuxType
           iny
           lda  (Ptr1),y
           sta  AuxType+1

           stz  RC                      Make sure RC is zero
           jmp  Exit

NextKey05  anop

*          Test for requesting file close (up one directory level)

           lda  AppleKey
           bpl  NextKey06               No Apple Key
           lda  KeyPress
           cmp  #'C'+$80
           beq  CloseReq
           cmp  #'c'+$80
           beq  CloseReq
           bra  NextKey06

CloseReq   anop

           lda  #CloseBtn               Test here to see if Close is the
           cmp  TabIndex                  currently displayed button.
           sta  TabIndex                Change TabIndex here.
           beq  CloseReq0               Yes Close is current based on prev test

           jsr  RefreshBtn              Display Close as current selected.

CloseReq0  anop

           jsr  AnimateBtn

           lda  #OpenBtn                Default to Open after call.
           sta  TabIndex

           lda  Prefix                  Get prefix length
           bne  CloseReq00

           jmp  OnlineReq1

CloseReq00 anop

           tay                          Move directory length to index

CloseReq01 anop

           dey                          Move index back once character
           lda  Prefix,y                Get prefix character
           cmp  #'/'                    Is it a backslash?
           bne  CloseReq01              No, continue the search

           sty  Prefix                  Save new prefix length
           cpy  #1                      Are we beyond the root directory?
           bne  CloseReq99              No.
           jmp  OnlineReq1              Yes so make Prefix null to toggle online

CloseReq99 anop

           lda  #DirChange
           sta  RC
           jmp  Exit

NextKey06  anop

*          Test for tab key press.

           lda  KeyPress
           cmp  #TabKey
           beq  TabReq
           bra  NextKey07

TabReq     anop

           lda  OptionKey
           bmi  TabUp

TabDown    anop

           lda  TabIndex                Get current tabindex
           inc  a                       Move it to the next button setting
           cmp  #VolDirPull             Are we on the vol / dir pulldown?
           bne  TD01                    No
           ldx  Prefix                  Is the path empty?
           bne  TD01                    No
           inc  a

TD01       anop

           cmp  #LoopBack               Moved beyond last button?
           bne  TabReq1                 No

           lda  #0                      Yes so reset it back to the beginning.
           bra  TabReq1

TabUp      anop

           lda  TabIndex
           dec  a
           bpl  TabReq1

           lda  #LoopBack-1

TabReq1    anop

           cmp  #VolDirPull
           bne  TU01
           ldx  Prefix
           bne  TU01

           dec  a

TU01       anop

           sta  TabIndex                Save new tabindex setting.

           lda  #TabOnly
           sta  RC
           jmp  Exit

NextKey07  anop

*          Test for return key press.

           lda  KeyPress
           cmp  #ReturnKey
           beq  EnterReq
           cmp  #' '+$80
           beq  EnterReq
           bra  NextKey08

EnterReq   anop

           lda  TabIndex

           cmp  #DisksBtn
           bne  Enter01
           jmp  OnlineReq               Requested Disks command button.

Enter01    anop

           cmp  #OpenBtn
           bne  Enter02
           jmp  OpenReq                 Requested Open command button.

Enter02    anop

           cmp  #CloseBtn
           bne  Enter03
           jmp  CloseReq                Requested Close command button.

Enter03    anop

           cmp  #CancelBtn
           bne  Enter04
           jmp  QuitReq                 Requested Cancel command button.

Enter04    anop

           jsr  PathDDL                 Requested directory pulldown

           jmp  Exit

NextKey08  anop

           jsr  Beep                    Invalid keypress so beep him.

NoBeep     anop

           jmp  PollDevLoop

Exit       anop

           rts

KeyPress   ds   1
extCnt     ds   1
srcPtr     ds   1
destPtr    ds   1

*
* Do button animation on <cr>
*

AnimateBtn anop

           lda  #ButtonText             Save Button text address in Ptr1
           sta  Ptr1
           lda  #>ButtonText
           sta  Ptr1+1

           ldx  TabIndex                Move TabIndex to index
           beq  AnimBtn02               Zero?  No need to adjust address

AnimBtn01  anop

           clc                          Add 9 (Button text length) to Prt1
           lda  Ptr1
           adc  #9
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           dex                          Count it
           bne  AnimBtn01               More to offset

AnimBtn02  anop

           lda  #Normal                 Normal text
           jsr  cout

           jsr  PrtButton               Print button text in normal

           lda  #$FF                    Wait here for a second (or so)
           jsr  Wait

           lda  #Inverse                Inverse text
           jsr  cout

           jsr  PrtButton               Print button text in inverse

           lda  #$FF                    Wait here for a second (or so)
           jsr  Wait

           lda  #Normal                 Return to normal text prio to exit
           jsr  cout

           rts

PrtButton  anop

*
* Print button text
*

           lda  #50-1                   HTab 50
           sta  HTab
           lda  (Ptr1)                  VTab saved in table
           sta  VTab
           jsr  SetVTab                 Set VTab

           ldy  #1                      Starting index
           ldx  #8                      characters to print

PrtButt01  anop

           lda  (Ptr1),y                Get button text character
           jsr  cout                    Print it
           iny                          Move index to next character
           dex                          Count this as printed
           bne  PrtButt01               More?

           rts

DirError   dc   c'ProDOS 8 path name too long.',h'0D'
           dc   c'   Path > 63 characters.',h'00'

           End
