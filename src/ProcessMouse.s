ProcMouse:
           ; Expected to scope to Menu1Vars.s

;
; Processing the mouse
;

; Soft Switches

;Off80Store  =   $C000
;On80Store   =   $C001
;Read80Store  =  $C018
;ReadPage2   =   $C01C
;Page1       =   $C054
;Page2       =   $C055


SaveChar:   .res 1                      ; Saved character at X, Y
X_mouse:    .res 1                      ; X position
Y_mouse:    .res 1                      ; Y position

PM_TextLine:                            ; Text screen line starting addresses

PM_TextLine00: .addr $0400
PM_TextLine01: .addr $0480
PM_TextLine02: .addr $0500
PM_TextLine03: .addr $0580
PM_TextLine04: .addr $0600
PM_TextLine05: .addr $0680
PM_TextLine06: .addr $0700
PM_TextLine07: .addr $0780
PM_TextLine08: .addr $0428
PM_TextLine09: .addr $04A8
PM_TextLine10: .addr $0528
PM_TextLine11: .addr $05A8
PM_TextLine12: .addr $0628
PM_TextLine13: .addr $06A8
PM_TextLine14: .addr $0728
PM_TextLine15: .addr $07A8
PM_TextLine16: .addr $0450
PM_TextLine17: .addr $04D0
PM_TextLine18: .addr $0550
PM_TextLine19: .addr $05D0
PM_TextLine20: .addr $0650
PM_TextLine21: .addr $06D0
PM_TextLine22: .addr $0750
PM_TextLine23: .addr $07D0

MouseArrow  =   $42                     ; Mouse arrow screen character
MouseBusy   =   $43                     ; Mouse hourglass screen character

; Move mouse cursor

MoveMouse:

           lda  MousePtr+1              ; Test for mouse
           bne  MoveGo
           rts

MoveGo:

           sta  On80Store               ; Turn on 80Store

           lda  Y_mouse                 ; Get Old mouse Y position

           asl  a                       ; Multiply by 2 for address indexing
           tax                          ; Move to index

           lda  PM_TextLine,x           ; Get low byte of line address
           sta  Ptr1                    ;  and save in Ptr1
           inx
           lda  PM_TextLine,x           ; Get high byte of line address
           sta  Ptr1+1                  ;  and save in Ptr1+1

; Set up X position

           lda  X_mouse

           lsr  a
           tay

           bcs  MainRAM1

; Even column numbers 0, 2, 4, 6, ... in aux RAM

AuxRAM1:

           sta  Page2
           bra  RestoreChar

; Odd column numbers 1, 3, 5, 7, ... in main RAM

MainRAM1:

           sta  Page1

RestoreChar:

           lda  SaveChar
           sta  (Ptr1),y

           bra  PlotGo

PlotMouse:

; Set up Y position

           lda  MousePtr+1              ; Test for mouse
           bne  PlotGo
           rts

PlotGo:

           sta  On80Store               ; Turn on 80Store

           lda  MouseY                  ; Get Mouse Y position
           sta  Y_mouse                 ; Save it

           asl  a                       ; Multiply by 2 for address indexing
           tax                          ; Move to index

           lda  PM_TextLine,x           ; Get low byte of line address
           sta  Ptr1                    ;  and save in Ptr1
           inx
           lda  PM_TextLine,x           ; Get high byte of line address
           sta  Ptr1+1                  ;  and save in Ptr1+1

; Set up X position

           lda  MouseX
           sta  X_mouse

           lsr  a
           tay

           bcs  @MainRAM2

; Even column numbers 0, 2, 4, 6, ... in aux RAM

;AuxRAM2:

           sta  Page2
           bra  @GetChar

; Odd column numbers 1, 3, 5, 7, ... in main RAM

@MainRAM2:

           sta  Page1

@GetChar:

           lda  (Ptr1),y
           cmp  #MouseArrow
           beq  DontSave
           cmp  #MouseBusy
           beq  DontSave

           sta  SaveChar

DontSave:

           lda  #MouseArrow
           sta  (Ptr1),y

           sta  Page1

           rts

;
; Mouse button down
;

PM_ButtonDown:

           stz  blnDblClick             ; Reset double click indicator.
           lda  MouseStat               ; Button is down but make sure he has also
           bit  #PrevButton             ; released it and is not holding it down.
           beq  PM_NotHeld

           lda  PM_HoldCnt              ; Check to see how long he's held down the
           cmp  #$FF                    ; mouse button.
           beq  PM_Repeat                  ; Long enough so he's repeating.

           inc  PM_HoldCnt              ; Hasn't held it long enough yet so count
           lda  #$01                    ; the hold and return.
           jsr  Wait

           rts

PM_HoldCnt:    .res 1

PM_NotHeld:

           stz  PM_HoldCnt              ; Zero out counter upon first button press

PM_Repeat:

; Disks button

OnDisksBtn:

           lda  MouseY                  ; Check to see if he pressed the Disks
           cmp  #11-1                   ; button.
           bne  OnOpenBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnOpenBtn
           cmp  #59-1
           bcs  OnOpenBtn

           stz  M1_TabIndex             ; Move M1_TabIndex to Disks button.
           lda  #TabOnly
           sta  M1_RC

           rts

; Open button

OnOpenBtn:

           lda  MouseY                  ; Check to see if he pressed the Open
           cmp  #14-1                   ; button.
           bne  OnCloseBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnCloseBtn
           cmp  #59-1
           bcs  OnCloseBtn

           lda  #OpenBtn                ; Move M1_TabIndex to Open button.
           sta  M1_TabIndex
           lda  #TabOnly
           sta  M1_RC

           rts

; Close button

OnCloseBtn:

           lda  MouseY                  ; Check to see if he pressed the Close
           cmp  #16-1                   ; button.
           bne  OnCancelBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnCancelBtn
           cmp  #59-1
           bcs  OnCancelBtn

           lda  #CloseBtn               ; Move M1_TabIndex to Close button.
           sta  M1_TabIndex
           lda  #TabOnly
           sta  M1_RC

           rts

; Cancel button

OnCancelBtn:

           lda  MouseY                  ; Check to see if he pressed the Cancel
           cmp  #18-1                   ; button.
           bne  OnFileList

           lda  MouseX
           cmp  #49-1
           bcc  OnFileList
           cmp  #59-1
           bcs  OnFileList

           lda  #CancelBtn              ; Move M1_TabIndex to Cancel button.
           sta  M1_TabIndex
           lda  #TabOnly
           sta  M1_RC

           rts

;
; Changing Current File Selection
;

OnFileList:

           lda  MouseY                  ; Check to see if he click inside the file
           cmp  #11-1                   ; list box.
           bcc  PM_ScrollDown
           cmp  #19-1
           bcs  PM_ScrollDown

           lda  MouseX
           cmp  #26-1
           bcc  PM_ScrollDown
           cmp  #45-1
           bcs  PM_ScrollDown

           sec
           lda  MouseY                  ; Calculate the requested line number by
           sbc  #9                      ; taking the mouse position and subtract
           sta  Requested               ; 9 for a 1-8 line number.

           lda  M1_FileCount+1          ; Check here to see if the line he is
           bne  LineOk                  ; asking for exists on the screen.

           lda  Requested
           cmp  M1_FileCount
           bcc  LineOk
           beq  LineOk

           rts                          ; No, he's clicking on a blank line.

LineOk:

           lda  Requested               ; Good line so check to see if he is
           cmp  SelectLine              ; double clicking on a already selected
           beq  DoDblClick              ; line.

           sta  SelectLine              ; No, so select this line and refresh.

           lda  #NoDirChange
           sta  M1_RC

           rts

DoDblClick:

           lda  #OpenBtn                ; Double clicking so set M1_TabIndex to Open
           sta  M1_TabIndex             ; and try opening it.

           lda  #1
           sta  blnDblClick             ; Tell MENU1UI that we're double clicking

           lda  #DirChange
           sta  M1_RC

           rts

Requested: .res 1

;
; Scroll down 1 file
;

PM_ScrollDown:

           lda  MouseY
           cmp  #18-1
           bne  PM_ScrollUp

           lda  MouseX
           cmp  #46-1
           bne  PM_ScrollUp

           lda  SelectLine
           cmp  #8                      ; At bottom of window?
           beq  @SD01                   ; Yes.

           lda  M1_FileCount+1
           bne  @SD02

           lda  M1_FileCount
           cmp  SelectLine
           beq  @NoMoreBelow
           bra  @SD02

@SD01:

           lda  LinesBelow+1
           ora  LinesBelow
           beq  @NoMoreBelow

@SD02:

           inc  SelectLine

           lda  #NoDirChange
           sta  M1_RC

@NoMoreBelow:

           rts

PM_ScrollUp:

           lda  MouseY
           cmp  #11-1
           bne  OnPathDDL

           lda  MouseX
           cmp  #46-1
           bne  OnPathDDL

           lda  SelectLine
           cmp  #1
           bne  @SU01

           lda  LinesAbove+1
           ora  LinesAbove
           beq  @NoMoreAbove

@SU01:

           dec  SelectLine

           lda  #NoDirChange
           sta  M1_RC

@NoMoreAbove:

           rts

OnPathDDL:

           lda  Prefix
           beq  PDDLExit

           lda  MouseY
           cmp  #9-1
           bne  OnNowhere

           lda  MouseX
           cmp  #23-1
           bcc  OnNowhere

           cmp  #44-1
           bcs  OnNowhere

           lda  #VolDirPull
           sta  M1_TabIndex

           jsr  M1_RefreshBtn

           jsr  PathDDL

PDDLExit:

           rts

OnNowhere:

           rts
;
; Mouse Button Release
;

M1_ButtonUp:

AtDisksBtn:

           lda  MouseY
           cmp  #11-1
           bne  AtOpenBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtOpenBtn
           cmp  #59-1
           bcs  AtOpenBtn

           lda  M1_TabIndex
           bne  AtDisksExit

           lda  #DirChange
           sta  M1_RC

AtDisksExit:

           rts

AtOpenBtn:

           lda  MouseY
           cmp  #14-1
           bne  AtCloseBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtCloseBtn
           cmp  #59-1
           bcs  AtCloseBtn

           lda  M1_TabIndex
           cmp  #OpenBtn
           bne  AtOpenExit

           lda  #DirChange
           sta  M1_RC

AtOpenExit:

           rts

AtCloseBtn:

           lda  MouseY
           cmp  #16-1
           bne  AtCancelBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtCancelBtn
           cmp  #59-1
           bcs  AtCancelBtn

           lda  M1_TabIndex
           cmp  #CloseBtn
           bne  AtCloseExit

           lda  #DirChange
           sta  M1_RC

AtCloseExit:

           rts

AtCancelBtn:

           lda  MouseY
           cmp  #18-1
           bne  AtNoBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtNoBtn
           cmp  #59-1
           bcs  AtNoBtn

           lda  M1_TabIndex
           cmp  #CancelBtn
           bne  AtCancelExit

           lda  #Quit
           sta  M1_RC

AtCancelExit:

           rts

AtNoBtn:

           rts


