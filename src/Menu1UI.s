Menu1UI:

; Expected to scope to Menu1Vars.s

;
;          Menu1 User Interface
;

; AscII Key Values

;UpArrow     =   $8B
;DownArrow   =   $8A
;LeftArrow   =   $88
;RightArrow  =   $95
;ReturnKey   =   $8D
;TabKey      =   $89

; File entry offsets

oFileType   =   $10 ;- $10
oAuxType    =   $1F ;- $20

           stz  M1_RC                   ; Reset return code
           stz  ClearKbd                ; Clear keyboard strobe

M1_PollDev:

           jsr  PlotMouse

M1_PollDevLoop:

           lda  Keyboard                ; Get keypress
           bpl  @PollMouse
           jmp  KeyDev

@PollMouse:

           jsr  ReadMouse               ; Read mouse
           lsr  MouseX                  ; Divide by 2 to return to the
           lsr  MouseY                  ; 0 to 79, 0 to 23 range.
           lda  MouseStat               ; Get mouse status
           bit  #MouseMove              ; Moved mouse?
           bne  MouseDev1               ; Yes
           bit  #CurrButton             ; Button pressed?
           bne  MouseDev2               ; Yes
           bit  #PrevButton             ; Button release?
           bne  MouseDev3               ; Yes

           bra  M1_PollDevLoop

;
; Mouse Movement
;

MouseDev1:

           jsr  MoveMouse
           jmp  M1_PollDevLoop

;
; Move Button Pressed
;

MouseDev2:

           jsr  PM_ButtonDown
           lda  blnDblClick
           bne  DoOpen                  ; should be because I'm double clicking.

           lda  M1_RC
           bne  MouseDev2X
           jmp  M1_PollDevLoop

MouseDev2X:

           jmp  M1_Exit

;
; Mouse Button Release
;

MouseDev3:

           jsr  M1_ButtonUp
           lda  M1_RC
           bne  MouseDev3X
           jmp  M1_PollDevLoop

MouseDev3X:

           lda  M1_TabIndex
           beq  DoDisks
           cmp  #OpenBtn
           beq  DoOpen
           cmp  #CloseBtn
           beq  DoClose
           bra  DoCancel

DoDisks:

           jmp  OnLineReq0

DoOpen:

           jmp  OpenReq0

DoClose:

           jmp  CloseReq0

DoCancel:

           jmp  M1_QuitReq0

;
; Keyboard Key Pressed
;

KeyDev:

           stz  ClearKbd                ; Clear keyboard strobe
           sta  M1_KeyPress             ; Save keypress

;          Test for quiting screen

           lda  AppleKey
           bpl  M1_NextKey01            ; No Apple Key
           lda  M1_KeyPress
           cmp  #'Q'+$80
           beq  M1_QuitReq
           cmp  #'q'+$80
           beq  M1_QuitReq
           bra  M1_NextKey01

M1_QuitReq:

           lda  #CancelBtn              ; Test here to see if Cancel is the
           cmp  M1_TabIndex             ;   currently displayed button.
           sta  M1_TabIndex             ; Change M1_TabIndex here.
           beq  M1_QuitReq0             ; Yes Cancel is current based on prev test

           jsr  M1_RefreshBtn           ; Display Cancel as current selected.

M1_QuitReq0:

           jsr  M1_AnimateBtn

           lda  #Quit
           sta  M1_RC
           jmp  M1_Exit

;          Test for down / right arrow key.

M1_NextKey01:

           lda  M1_KeyPress
           cmp  #DownArrow              ; Down arrow?
           beq  DownReq
           cmp  #RightArrow             ; ...or right arrow?
           beq  DownReq
           bra  M1_NextKey02

DownReq:

           lda  SelectLine              ; Check to see if selected line is at the
           cmp  #8                      ; bottom of the window.
           beq  @AtBottom               ; Yes it is.

           lda  M1_FileCount+1          ; No so see if there are more file entries
           bne  @IncSelLine             ; below our selected line.

           lda  M1_FileCount            ; If M1_FileCount = SelectLine then we're
           cmp  SelectLine              ; at the bottom of the window with less
           beq  @AtBottom               ; than 8 file entries in the directory.

@IncSelLine:                            ; Increment selected line

           inc  SelectLine              ; Move selected line to next position
           lda  #NoDirChange
           sta  M1_RC
           jmp  M1_Exit

@AtBottom:

           lda  LinesBelow+1            ; Check to see if we have move lines below
           ora  LinesBelow              ; this point.  This is a 16 bit number.
           beq  @NoMoreBelow

           inc  SelectLine              ; This should make SelectLine = 9.

@NoMoreBelow:

           lda  #NoDirChange
           sta  M1_RC
           jmp  M1_Exit

;          Test for up / left arrow key.

M1_NextKey02:

           lda  M1_KeyPress
           cmp  #UpArrow
           beq  UpReq
           cmp  #LeftArrow
           beq  UpReq
           bra  M1_NextKey03

UpReq:

           lda  SelectLine              ; Check to see if we're at top of window
           cmp  #1
           beq  @AtTop

           dec  SelectLine              ; Not at top of window so move line up 1
           lda  #NoDirChange
           sta  M1_RC
           jmp  M1_Exit

@AtTop:

           lda  LinesAbove+1            ; Check to see if we have lines above
           ora  LinesAbove              ; this point.
           beq  @NoMoreAbove

           dec  SelectLine              ; This should make SelectLine = 0

@NoMoreAbove:

           lda  #NoDirChange
           sta  M1_RC
           jmp  M1_Exit

M1_NextKey03:

;          Test for requesting online drives

           lda  AppleKey
           bpl  M1_NextKey04            ; No Apple Key
           lda  M1_KeyPress
           cmp  #'D'+$80
           beq  OnlineReq
           cmp  #'d'+$80
           beq  OnlineReq
           bra  M1_NextKey04

OnlineReq:

           lda  #DisksBtn               ; Test here to see if Disks is the
           cmp  M1_TabIndex             ;   currently displayed button.
           sta  M1_TabIndex             ; Change M1_TabIndex here.
           beq  OnLineReq0              ; Yes Disks is current based on prev test

           jsr  M1_RefreshBtn           ; Display Disks as current selected.

OnLineReq0:

           jsr  M1_AnimateBtn

OnlineReq1:

           lda  #OpenBtn                ; Default to Open after call.
           sta  M1_TabIndex

           stz  Prefix
           lda  #DirChange
           sta  M1_RC
           jmp  M1_Exit

M1_NextKey04:

;          Test for requesting file open.

           lda  AppleKey
           bpl  M1_NextKey05a           ; No Apple Key
           lda  M1_KeyPress
           cmp  #'O'+$80
           beq  OpenReq
           cmp  #'o'+$80
           beq  OpenReq

M1_NextKey05a:

           jmp  M1_NextKey05

OpenReq:

           lda  #OpenBtn                ; Test here to see if Open is the
           cmp  M1_TabIndex             ;   currently displayed button.
           sta  M1_TabIndex             ; Change M1_TabIndex here.
           beq  OpenReq0                ; Yes Open is current based on prev test

           jsr  M1_RefreshBtn           ; Display Open as current selected.

OpenReq0:

           jsr  M1_AnimateBtn           ; Do button animation.

           lda  M1_LineCount            ; Are there files listed in this
           bne  OpenReq0a               ;  directory?

           jmp  BadFileName             ; No, so beep the user to let him know.

OpenReq0a:

           lda  Prefix                  ; Check for null prefix
           bne  OpenReq1

           lda  #1                      ; Null prefix, put the initial '/' and
           sta  Prefix                  ; make the length 1.
           lda  #'/'
           sta  Prefix+1

OpenReq1:

           lda  SelectPage              ; Make sure proper page is loaded.
           sta  CurrPage
           jsr  GetBlock

           lda  SelectAddr              ; Set up pointer to selected file.
           sta  Ptr1
           lda  SelectAddr+1
           sta  Ptr1+1

           lda  (Ptr1)
           and  #$0F
           tay

OpenReq1a:

           lda  (Ptr1),y                ; Search file name for a '?' from an
           cmp  #'?'                    ; AppleShare volume.
           bne  OpenReq1b
           jmp  BadFileName

OpenReq1b:

           dey
           bne  OpenReq1a

           lda  (Ptr1)                  ; Get file type / length of file.
           bpl  OpenFile                ; If not a directory, do nothing.

           and  #$0F                    ; Keep only file name length
           sta  extCnt                  ; Save file name length
           stz  srcPtr                  ; Init to zero.

           clc                          ; Check to make sure new prefix isn't
           lda  Prefix                  ; longer than 63 characters.
           adc  extCnt
           cmp  #63
           bcs  BadPrefix

           lda  Prefix                  ; Init destPtr to end of current dir
           sta  destPtr

OpenReq2:

           inc  srcPtr                  ; Bump to next character to read.
           inc  destPtr                 ; Bump to next empty location.
           ldy  srcPtr                  ; Get character of directory name.
           lda  (Ptr1),y
           ldy  destPtr                 ; Add to end of current directory.
           sta  Prefix,y
           dec  extCnt                  ; Done all characters?
           bne  OpenReq2                ; No, so do some more

           iny
           lda  #'/'                    ; Add '/' on to the end.
           sta  Prefix,y
           sty  Prefix                  ; Fix length of path.

OpenReq99:

           lda  #DirChange
           sta  M1_RC
           jmp  M1_Exit

BadPrefix:                         ; New prefix > 63 characters

           jsr  Beep

           lda  #<DirError
           sta  MsgPtr
           lda  #>DirError
           sta  MsgPtr+1

           jsr  MsgOk

           lda  #NoDirChange
           sta  M1_RC
           jmp  M1_Exit

BadFileName:

           jsr  Beep

           lda  #NoDirChange
           sta  M1_RC
           jmp  M1_Exit

;
; Entered non-directory -- save file name in Path
;

OpenFile:

           and  #$F0                    ; Keep file type
           cmp  #$40                    ; Extended file?
           bcc  OpenFile0               ; No, process file.

           jsr  Beep                    ; Beep to indicate extended file.
           lda  #NoDirChange
           sta  M1_RC
           jmp  M1_Exit

OpenFile0:

           lda  (Ptr1)                  ; Get file info again.
           and  #$0F                    ; Keep file length only
           ldy  #1                      ; Start index at 1
           tax                          ; Save length in x
           sta  Path                    ; Save length to 1st byte in path

OpenFile1:

           lda  (Ptr1),y                ; Get next character
           sta  Path,y                  ; Save character in path
           iny                          ; Move to next character
           dex                          ; Count it saved.
           bne  OpenFile1               ; More?

           ldy  #oFileType              ; Save file type
           lda  (Ptr1),y
           sta  FileType

           ldy  #oAuxType               ; Save file aux type
           lda  (Ptr1),y
           sta  AuxType
           iny
           lda  (Ptr1),y
           sta  AuxType+1

           stz  M1_RC                   ; Make sure M1_RC is zero
           jmp  M1_Exit

M1_NextKey05:

;          Test for requesting file close (up one directory level)

           lda  AppleKey
           bpl  M1_NextKey06            ; No Apple Key
           lda  M1_KeyPress
           cmp  #'C'+$80
           beq  CloseReq
           cmp  #'c'+$80
           beq  CloseReq
           bra  M1_NextKey06

CloseReq:

           lda  #CloseBtn               ; Test here to see if Close is the
           cmp  M1_TabIndex             ;   currently displayed button.
           sta  M1_TabIndex             ; Change M1_TabIndex here.
           beq  CloseReq0               ; Yes Close is current based on prev test

           jsr  M1_RefreshBtn           ; Display Close as current selected.

CloseReq0:

           jsr  M1_AnimateBtn

           lda  #OpenBtn                ; Default to Open after call.
           sta  M1_TabIndex

           lda  Prefix                  ; Get prefix length
           bne  CloseReq00

           jmp  OnlineReq1

CloseReq00:

           tay                          ; Move directory length to index

CloseReq01:

           dey                          ; Move index back once character
           lda  Prefix,y                ; Get prefix character
           cmp  #'/'                    ; Is it a backslash?
           bne  CloseReq01              ; No, continue the search

           sty  Prefix                  ; Save new prefix length
           cpy  #1                      ; Are we beyond the root directory?
           bne  CloseReq99              ; No.
           jmp  OnlineReq1              ; Yes so make Prefix null to toggle online

CloseReq99:

           lda  #DirChange
           sta  M1_RC
           jmp  M1_Exit

M1_NextKey06:

;          Test for tab key press.

           lda  M1_KeyPress
           cmp  #TabKey
           beq  M1_TabReq
           bra  M1_NextKey07

M1_TabReq:

           lda  OptionKey
           bmi  M1_TabUp

;TabDown:

           lda  M1_TabIndex             ; Get current tabindex
           inc  a                       ; Move it to the next button setting
           cmp  #VolDirPull             ; Are we on the vol / dir pulldown?
           bne  TD01                    ; No
           ldx  Prefix                  ; Is the path empty?
           bne  TD01                    ; No
           inc  a

TD01:

           cmp  #LoopBack               ; Moved beyond last button?
           bne  M1_TabReq1              ; No

           lda  #0                      ; Yes so reset it back to the beginning.
           bra  M1_TabReq1

M1_TabUp:

           lda  M1_TabIndex
           dec  a
           bpl  M1_TabReq1

           lda  #LoopBack-1

M1_TabReq1:

           cmp  #VolDirPull
           bne  TU01
           ldx  Prefix
           bne  TU01

           dec  a

TU01:

           sta  M1_TabIndex                ; Save new tabindex setting.

           lda  #TabOnly
           sta  M1_RC
           jmp  M1_Exit

M1_NextKey07:

;          Test for return key press.

           lda  M1_KeyPress
           cmp  #ReturnKey
           beq  @EnterReq
           cmp  #' '+$80
           beq  @EnterReq
           bra  M1_NextKey08

@EnterReq:

           lda  M1_TabIndex

           cmp  #DisksBtn
           bne  @Enter01
           jmp  OnlineReq               ; Requested Disks command button.

@Enter01:

           cmp  #OpenBtn
           bne  @Enter02
           jmp  OpenReq                 ; Requested Open command button.

@Enter02:

           cmp  #CloseBtn
           bne  @Enter03
           jmp  CloseReq                ; Requested Close command button.

@Enter03:

           cmp  #CancelBtn
           bne  @Enter04
           jmp  M1_QuitReq              ; Requested Cancel command button.

@Enter04:

           jsr  PathDDL                 ; Requested directory pulldown

           jmp  M1_Exit

M1_NextKey08:

           jsr  Beep                    ; Invalid keypress so beep him.

NoBeep:

           jmp  M1_PollDevLoop

M1_Exit:

           rts

M1_KeyPress: .res 1
extCnt:     .res 1
srcPtr:     .res 1
destPtr:    .res 1

;
; Do button animation on <cr>
;

M1_AnimateBtn:

           lda  #<ButtonText            ; Save Button text address in Ptr1
           sta  Ptr1
           lda  #>ButtonText
           sta  Ptr1+1

           ldx  M1_TabIndex             ; Move M1_TabIndex to index
           beq  M1_AnimBtn02            ; Zero?  No need to adjust address

M1_AnimBtn01:

           clc                          ; Add 9 (Button text length) to Prt1
           lda  Ptr1
           adc  #9
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           dex                          ; Count it
           bne  M1_AnimBtn01            ; More to offset

M1_AnimBtn02:

           lda  #Normal                 ; Normal text
           jsr  cout

           jsr  @PrtButton              ; Print button text in normal

           lda  #$FF                    ; Wait here for a second (or so)
           jsr  Wait

           lda  #Inverse                ; Inverse text
           jsr  cout

           jsr  @PrtButton              ; Print button text in inverse

           lda  #$FF                    ; Wait here for a second (or so)
           jsr  Wait

           lda  #Normal                 ; Return to normal text prio to exit
           jsr  cout

           rts

@PrtButton:

;
; Print button text
;

           lda  #50-1                   ; HTab 50
           sta  HTab
           lda  (Ptr1)                  ; VTab saved in table
           sta  VTab
           jsr  SetVTab                 ; Set VTab

           ldy  #1                      ; Starting index
           ldx  #8                      ; characters to print

@PrtButt01:

           lda  (Ptr1),y                ; Get button text character
           jsr  cout                    ; Print it
           iny                          ; Move index to next character
           dex                          ; Count this as printed
           bne  @PrtButt01              ; More?

           rts

DirError:  .byte "ProDOS 8 path name too long.", $0d
           .byte  "   Path > 63 characters.", $00


