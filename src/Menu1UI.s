Menu1UI:

;
;          Menu1 User Interface
;

; File entry offsets

oFileType  =  $10 ; - $10
oAuxType   =  $1F ; - $20

           stz  RC_M1                 ; Reset return code
           stz  ClearKbd              ; Clear keyboard strobe

M1PollDev:

           jsr  PlotMouse

M1PollDevLoop:

           lda  Keyboard              ; Get keypress
           bpl  M1PollMouse
           jmp  KeyDev

M1PollMouse:

           jsr  ReadMouse             ; Read mouse
           lsr  MouseX                ; Divide by 2 to return to the
           lsr  MouseY                ; 0 to 79, 0 to 23 range.
           lda  MouseStat             ; Get mouse status
           bit  #MouseMove            ; Moved mouse?
           bne  MouseDev1             ; Yes
           bit  #CurrButton           ; Button pressed?
           bne  MouseDev2             ; Yes
           bit  #PrevButton           ; Button release?
           bne  MouseDev3             ; Yes

           bra  M1PollDevLoop

;
; Mouse Movement
;

MouseDev1:

           jsr  MoveMouse
           jmp  M1PollDevLoop

;
; Move Button Pressed
;

MouseDev2:

           jsr  PMButtonDown
           lda  blnDblClick_M1
           bne  DoOpen                ; should be because I'm double clicking.

           lda  RC_M1
           bne  MouseDev2X
           jmp  M1PollDevLoop

MouseDev2X:

           jmp  M1Exit

;
; Mouse Button Release
;

MouseDev3:

           jsr  PMButtonUp
           lda  RC_M1
           bne  MouseDev3X
           jmp  M1PollDevLoop

MouseDev3X:

           lda  TabIndex_M1
           beq  DoDisks
           cmp  #OpenBtn
           beq  DoOpen
           cmp  #CloseBtn
           beq  DoClose
           bra  DoCancel

DoDisks:

           jmp  OnlineReq0

DoOpen:

           jmp  OpenReq0

DoClose:

           jmp  CloseReq0

DoCancel:

           jmp  QuitReq0

;
; Keyboard Key Pressed
;

KeyDev:

           stz  ClearKbd              ; Clear keyboard strobe
           sta  KeyPress              ; Save keypress

;          Test for quiting screen

           lda  AppleKey
           bpl  NextKey01             ; No Apple Key
           lda  KeyPress
           cmp  #'Q'+$80
           beq  QuitReq
           cmp  #'q'+$80
           beq  QuitReq
           bra  NextKey01

QuitReq:

           lda  #CancelBtn            ; Test here to see if Cancel is the
           cmp  TabIndex_M1           ;   currently displayed button.
           sta  TabIndex_M1           ; Change TabIndex_M1 here.
           beq  QuitReq0              ; Yes Cancel is current based on prev test

           jsr  MBRefreshBtn          ; Display Cancel as current selected.

QuitReq0:

           jsr  AnimateBtn

           lda  #Quit
           sta  RC_M1
           jmp  M1Exit

;          Test for down / right arrow key.

NextKey01:

           lda  KeyPress
           cmp  #DownArrow            ; Down arrow?
           beq  DownReq
           cmp  #RightArrow           ; ...or right arrow?
           beq  DownReq
           bra  NextKey02

DownReq:

           lda  SelectLine_M1         ; Check to see if selected line is at the
           cmp  #8                    ; bottom of the window.
           beq  AtBottom              ; Yes it is.

           lda  FileCount_M1+1        ; No so see if there are more file entries
           bne  IncSelLine            ; below our selected line.

           lda  FileCount_M1          ; If FileCount_M1 = SelectLine_M1 then we're
           cmp  SelectLine_M1         ; at the bottom of the window with less
           beq  AtBottom              ; than 8 file entries in the directory.

IncSelLine:                           ; Increment selected line

           inc  SelectLine_M1         ; Move selected line to next position
           lda  #NoDirChange
           sta  RC_M1
           jmp  M1Exit

AtBottom:

           lda  LinesBelow_M1+1       ; Check to see if we have move lines below
           ora  LinesBelow_M1         ; this point.  This is a 16 bit number.
           beq  @NoMoreBelow

           inc  SelectLine_M1         ; This should make SelectLine_M1 = 9.

@NoMoreBelow:

           lda  #NoDirChange
           sta  RC_M1
           jmp  M1Exit

;          Test for up / left arrow key.

NextKey02:

           lda  KeyPress
           cmp  #UpArrow
           beq  UpReq
           cmp  #LeftArrow
           beq  UpReq
           bra  NextKey03

UpReq:

           lda  SelectLine_M1         ; Check to see if we're at top of window
           cmp  #1
           beq  AtTop

           dec  SelectLine_M1         ; Not at top of window so move line up 1
           lda  #NoDirChange
           sta  RC_M1
           jmp  M1Exit

AtTop:

           lda  LinesAbove_M1+1       ; Check to see if we have lines above
           ora  LinesAbove_M1         ; this point.
           beq  NoMoreAbove

           dec  SelectLine_M1         ; This should make SelectLine_M1 = 0

NoMoreAbove:

           lda  #NoDirChange
           sta  RC_M1
           jmp  M1Exit

NextKey03:

;          Test for requesting online drives

           lda  AppleKey
           bpl  NextKey04             ; No Apple Key
           lda  KeyPress
           cmp  #'D'+$80
           beq  OnlineReq
           cmp  #'d'+$80
           beq  OnlineReq
           bra  NextKey04

OnlineReq:

           lda  #DisksBtn             ; Test here to see if Disks is the
           cmp  TabIndex_M1           ;   currently displayed button.
           sta  TabIndex_M1           ; Change TabIndex_M1 here.
           beq  OnlineReq0            ; Yes Disks is current based on prev test

           jsr  MBRefreshBtn          ; Display Disks as current selected.

OnlineReq0:

           jsr  AnimateBtn

OnlineReq1:

           lda  #OpenBtn              ; Default to Open after call.
           sta  TabIndex_M1

           stz  Prefix
           lda  #DirChange
           sta  RC_M1
           jmp  M1Exit

NextKey04:

;          Test for requesting file open.

           lda  AppleKey
           bpl  NextKey05a            ; No Apple Key
           lda  KeyPress
           cmp  #'O'+$80
           beq  OpenReq
           cmp  #'o'+$80
           beq  OpenReq

NextKey05a:

           jmp  NextKey05

OpenReq:

           lda  #OpenBtn              ; Test here to see if Open is the
           cmp  TabIndex_M1           ;   currently displayed button.
           sta  TabIndex_M1           ; Change TabIndex_M1 here.
           beq  OpenReq0              ; Yes Open is current based on prev test

           jsr  MBRefreshBtn          ; Display Open as current selected.

OpenReq0:

           jsr  AnimateBtn            ; Do button animation.

           lda  LineCount_M1           ; Are there files listed in this
           bne  OpenReq0a             ;  directory?

           jmp  BadFileName           ; No, so beep the user to let him know.

OpenReq0a:

           lda  Prefix                ; Check for null prefix
           bne  OpenReq1

           lda  #1                    ; Null prefix, put the initial '/' and
           sta  Prefix                ; make the length 1.
           lda  #'/'
           sta  Prefix+1

OpenReq1:

           lda  SelectPage_M1         ; Make sure proper page is loaded.
           sta  CurrPage_M1
           jsr  GetBlock

           lda  SelectAddr_M1         ; Set up pointer to selected file.
           sta  Ptr1
           lda  SelectAddr_M1+1
           sta  Ptr1+1

           lda  (Ptr1)
           and  #$0F
           tay

OpenReq1a:

           lda  (Ptr1),y              ; Search file name for a '?' from an
           cmp  #'?'                  ; AppleShare volume.
           bne  OpenReq1b
           jmp  BadFileName

OpenReq1b:

           dey
           bne  OpenReq1a

           lda  (Ptr1)                ; Get file type / length of file.
           bpl  OpenFile              ; If not a directory, do nothing.

           and  #$0F                  ; Keep only file name length
           sta  extCnt                ; Save file name length
           stz  srcPtr                ; Init to zero.

           clc                        ; Check to make sure new prefix isn't
           lda  Prefix                ; longer than 63 characters.
           adc  extCnt
           cmp  #63
           bcs  BadPrefix

           lda  Prefix                ; Init destPtr to end of current dir
           sta  destPtr

OpenReq2:

           inc  srcPtr                ; Bump to next character to read.
           inc  destPtr               ; Bump to next empty location.
           ldy  srcPtr                ; Get character of directory name.
           lda  (Ptr1),y
           ldy  destPtr               ; Add to end of current directory.
           sta  Prefix,y
           dec  extCnt                ; Done all characters?
           bne  OpenReq2              ; No, so do some more

           iny
           lda  #'/'                  ; Add '/' on to the end.
           sta  Prefix,y
           sty  Prefix                ; Fix length of path.

OpenReq99:

           lda  #DirChange
           sta  RC_M1
           jmp  M1Exit

BadPrefix:                            ; New prefix > 63 characters

           jsr  Beep

           lda  #<DirError
           sta  MsgPtr
           lda  #>DirError
           sta  MsgPtr+1

           jsr  MBMsgOk

           lda  #NoDirChange
           sta  RC_M1
           jmp  M1Exit

BadFileName:

           jsr  Beep

           lda  #NoDirChange
           sta  RC_M1
           jmp  M1Exit

;
; Entered non-directory -- save file name in Path
;

OpenFile:

           and  #$F0                  ; Keep file type
           cmp  #$40                  ; Extended file?
           bcc  OpenFile0             ; No, process file.

           jsr  Beep                  ; Beep to indicate extended file.
           lda  #NoDirChange
           sta  RC_M1
           jmp  M1Exit

OpenFile0:

           lda  (Ptr1)                ; Get file info again.
           and  #$0F                  ; Keep file length only
           ldy  #1                    ; Start index at 1
           tax                        ; Save length in x
           sta  Path                  ; Save length to 1st byte in path

OpenFile1:

           lda  (Ptr1),y              ; Get next character
           sta  Path,y                ; Save character in path
           iny                        ; Move to next character
           dex                        ; Count it saved.
           bne  OpenFile1             ; More?

           ldy  #oFileType            ; Save file type
           lda  (Ptr1),y
           sta  FileType

           ldy  #oAuxType             ; Save file aux type
           lda  (Ptr1),y
           sta  AuxType
           iny
           lda  (Ptr1),y
           sta  AuxType+1

           stz  RC_M1                 ; Make sure RC_M1 is zero
           jmp  M1Exit

NextKey05:

;          Test for requesting file close (up one directory level)

           lda  AppleKey
           bpl  NextKey06             ; No Apple Key
           lda  KeyPress
           cmp  #'C'+$80
           beq  CloseReq
           cmp  #'c'+$80
           beq  CloseReq
           bra  NextKey06

CloseReq:

           lda  #CloseBtn             ; Test here to see if Close is the
           cmp  TabIndex_M1           ;   currently displayed button.
           sta  TabIndex_M1           ; Change TabIndex_M1 here.
           beq  CloseReq0             ; Yes Close is current based on prev test

           jsr  MBRefreshBtn          ; Display Close as current selected.

CloseReq0:

           jsr  AnimateBtn

           lda  #OpenBtn              ; Default to Open after call.
           sta  TabIndex_M1

           lda  Prefix                ; Get prefix length
           bne  CloseReq00

           jmp  OnlineReq1

CloseReq00:

           tay                        ; Move directory length to index

CloseReq01:

           dey                        ; Move index back once character
           lda  Prefix,y              ; Get prefix character
           cmp  #'/'                  ; Is it a backslash?
           bne  CloseReq01            ; No, continue the search

           sty  Prefix                ; Save new prefix length
           cpy  #1                    ; Are we beyond the root directory?
           bne  CloseReq99            ; No.
           jmp  OnlineReq1            ; Yes so make Prefix null to toggle online

CloseReq99:

           lda  #DirChange
           sta  RC_M1
           jmp  M1Exit

NextKey06:

;          Test for tab key press.

           lda  KeyPress
           cmp  #TabKey
           beq  TabReq
           bra  NextKey07

TabReq:

           lda  OptionKey
           bmi  TabUp

TabDown:

           lda  TabIndex_M1           ; Get current tabindex
           inc  a                     ; Move it to the next button setting
           cmp  #VolDirPull           ; Are we on the vol / dir pulldown?
           bne  TD01                  ; No
           ldx  Prefix                ; Is the path empty?
           bne  TD01                  ; No
           inc  a

TD01:

           cmp  #LoopBack             ; Moved beyond last button?
           bne  TabReq1               ; No

           lda  #0                    ; Yes so reset it back to the beginning.
           bra  TabReq1

TabUp:

           lda  TabIndex_M1
           dec  a
           bpl  TabReq1

           lda  #LoopBack-1

TabReq1:

           cmp  #VolDirPull
           bne  TU01
           ldx  Prefix
           bne  TU01

           dec  a

TU01:

           sta  TabIndex_M1           ; Save new tabindex setting.

           lda  #TabOnly
           sta  RC_M1
           jmp  M1Exit

NextKey07:

;          Test for return key press.

           lda  KeyPress
           cmp  #ReturnKey
           beq  EnterReq
           cmp  #' '+$80
           beq  EnterReq
           bra  NextKey08

EnterReq:

           lda  TabIndex_M1

           cmp  #DisksBtn
           bne  Enter01
           jmp  OnlineReq             ; Requested Disks command button.

Enter01:

           cmp  #OpenBtn
           bne  Enter02
           jmp  OpenReq               ; Requested Open command button.

Enter02:

           cmp  #CloseBtn
           bne  Enter03
           jmp  CloseReq              ; Requested Close command button.

Enter03:

           cmp  #CancelBtn
           bne  Enter04
           jmp  QuitReq               ; Requested Cancel command button.

Enter04:

           jsr  PathDDL               ; Requested directory pulldown

           jmp  M1Exit

NextKey08:

           jsr  Beep                  ; Invalid keypress so beep him.

NoBeep:

           jmp  M1PollDevLoop

M1Exit:

           rts

KeyPress:  .byte   $00
extCnt:    .byte   $00
srcPtr:    .byte   $00
destPtr:   .byte   $00

;
; Do button animation on <cr>
;

AnimateBtn:

           lda  #<ButtonText           ; Save Button text address in Ptr1
           sta  Ptr1
           lda  #>ButtonText
           sta  Ptr1+1

           ldx  TabIndex_M1           ; Move TabIndex_M1 to index
           beq  AnimBtn02             ; Zero?  No need to adjust address

AnimBtn01:

           clc                        ; Add 9 (Button text length) to Prt1
           lda  Ptr1
           adc  #9
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           dex                        ; Count it
           bne  AnimBtn01             ; More to offset

AnimBtn02:

           lda  #Normal               ; Normal text
           jsr  cout_mark

           jsr  PrtButton             ; Print button text in normal

           lda  #$FF                  ; Wait here for a second (or so)
           jsr  Wait

           lda  #Inverse              ; Inverse text
           jsr  cout_mark

           jsr  PrtButton             ; Print button text in inverse

           lda  #$FF                  ; Wait here for a second (or so)
           jsr  Wait

           lda  #Normal               ; Return to normal text prio to exit
           jsr  cout_mark

           rts

PrtButton:

;
; Print button text
;

           lda  #50-1                 ; HTab 50
           sta  HTab
           lda  (Ptr1)                ; VTab saved in table
           sta  VTab
           jsr  SetVTab               ; Set VTab

           ldy  #1                    ; Starting index
           ldx  #8                    ; characters to print

PrtButt01:

           lda  (Ptr1),y              ; Get button text character
           jsr  cout_mark             ; Print it
           iny                        ; Move index to next character
           dex                        ; Count this as printed
           bne  PrtButt01             ; More?

           rts

DirError:  asccr "ProDOS 8 path name too long."
           ascz "   Path > 63 characters."
