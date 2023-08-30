ProcMouse:

;
; Processing the mouse
; - uses Menu1Vars

SaveChar:  .byte   1                  ; Saved character at X, Y
MousePosX: .byte   1                  ; X position
MousePosY: .byte   1                  ; Y position

MouseArrow =  $42                     ; Mouse arrow screen character
MouseBusy  =  $43                     ; Mouse hourglass screen character

; Move mouse cursor

MoveMouse:

           lda  MousePtr+1            ; Test for mouse
           bne  MoveGo
           rts

MoveGo:

           sta  On80Store             ; Turn on 80Store

           lda  MousePosY                     ; Get Old mouse Y position

           asl  a                     ; Multiply by 2 for address indexing
           tax                        ; Move to index

           lda  TextLine,x            ; Get low byte of line address
           sta  Ptr1                  ;  and save in Ptr1
           inx
           lda  TextLine,x            ; Get high byte of line address
           sta  Ptr1+1                ;  and save in Ptr1+1

; Set up X position

           lda  MousePosX

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

           lda  MousePtr+1            ; Test for mouse
           bne  PlotGo
           rts

PlotGo:

           sta  On80Store             ; Turn on 80Store

           lda  MouseY                ; Get Mouse Y position
           sta  MousePosY             ;         Save it

           asl  a                     ; Multiply by 2 for address indexing
           tax                        ; Move to index

           lda  TextLine,x            ; Get low byte of line address
           sta  Ptr1                  ;  and save in Ptr1
           inx
           lda  TextLine,x            ; Get high byte of line address
           sta  Ptr1+1                ;  and save in Ptr1+1

; Set up X position

           lda  MouseX
           sta  MousePosX

           lsr  a
           tay

           bcs  MainRAM2

; Even column numbers 0, 2, 4, 6, ... in aux RAM

AuxRAM2:

           sta  Page2
           bra  PMGetChar

; Odd column numbers 1, 3, 5, 7, ... in main RAM

MainRAM2:

           sta  Page1

PMGetChar:

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

PMButtonDown:

           stz  blnDblClick_M1        ; Reset double click indicator.
           lda  MouseStat             ; Button is down but make sure he has also
           bit  #PrevButton           ; released it and is not holding it down.
           beq  PMNotHeld

           lda  PMHoldCnt             ; Check to see how long he's held down the
           cmp  #$FF                  ; mouse button.
           beq  PMRepeat              ; Long enough so he's repeating.

           inc  PMHoldCnt             ; Hasn't held it long enough yet so count
           lda  #$01                  ; the hold and return.
           jsr  Wait

           rts

PMHoldCnt:   .byte   $00

PMNotHeld:

           stz  PMHoldCnt             ; Zero out counter upon first button press

PMRepeat:

; Disks button

OnDisksBtn:

           lda  MouseY                ; Check to see if he pressed the Disks
           cmp  #11-1                 ; button.
           bne  OnOpenBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnOpenBtn
           cmp  #59-1
           bcs  OnOpenBtn

           stz  TabIndex_M1              ; Move TabIndex_M1 to Disks button.
           lda  #TabOnly
           sta  RC_M1

           rts

; Open button

OnOpenBtn:

           lda  MouseY                ; Check to see if he pressed the Open
           cmp  #14-1                 ; button.
           bne  OnCloseBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnCloseBtn
           cmp  #59-1
           bcs  OnCloseBtn

           lda  #OpenBtn              ; Move TabIndex_M1 to Open button.
           sta  TabIndex_M1
           lda  #TabOnly
           sta  RC_M1

           rts

; Close button

OnCloseBtn:

           lda  MouseY                ; Check to see if he pressed the Close
           cmp  #16-1                 ; button.
           bne  OnCancelBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnCancelBtn
           cmp  #59-1
           bcs  OnCancelBtn

           lda  #CloseBtn             ; Move TabIndex_M1 to Close button.
           sta  TabIndex_M1
           lda  #TabOnly
           sta  RC_M1

           rts

; Cancel button

OnCancelBtn:

           lda  MouseY                ; Check to see if he pressed the Cancel
           cmp  #18-1                 ; button.
           bne  OnFileList

           lda  MouseX
           cmp  #49-1
           bcc  OnFileList
           cmp  #59-1
           bcs  OnFileList

           lda  #CancelBtn            ; Move TabIndex_M1 to Cancel button.
           sta  TabIndex_M1
           lda  #TabOnly
           sta  RC_M1

           rts

;
; Changing Current File Selection
;

OnFileList:

           lda  MouseY                ; Check to see if he click inside the file
           cmp  #11-1                 ; list box.
           bcc  PMScrollDown
           cmp  #19-1
           bcs  PMScrollDown

           lda  MouseX
           cmp  #26-1
           bcc  PMScrollDown
           cmp  #45-1
           bcs  PMScrollDown

           sec
           lda  MouseY                ; Calculate the requested line number by
           sbc  #9                    ; taking the mouse position and subtract
           sta  Requested             ; 9 for a 1-8 line number.

           lda  FileCount_M1+1        ; Check here to see if the line he is
           bne  LineOk                ; asking for exists on the screen.

           lda  Requested
           cmp  FileCount_M1
           bcc  LineOk
           beq  LineOk

           rts                        ; No, he's clicking on a blank line.

LineOk:

           lda  Requested             ; Good line so check to see if he is
           cmp  SelectLine_M1            ; double clicking on a already selected
           beq  DoDblClick            ; line.

           sta  SelectLine_M1            ; No, so select this line and refresh.

           lda  #NoDirChange
           sta  RC_M1

           rts

DoDblClick:

           lda  #OpenBtn              ; Double clicking so set TabIndex_M1 to Open
           sta  TabIndex_M1              ; and try opening it.

           lda  #1
           sta  blnDblClick_M1        ; Tell MENU1UI that we're double clicking

           lda  #DirChange
           sta  RC_M1

           rts

Requested: .res   1

;
; Scroll down 1 file
;

PMScrollDown:

           lda  MouseY
           cmp  #18-1
           bne  PMScrollUp

           lda  MouseX
           cmp  #46-1
           bne  PMScrollUp

           lda  SelectLine_M1
           cmp  #8                    ; At bottom of window?
           beq  SD01                  ; Yes.

           lda  FileCount_M1+1
           bne  SD02

           lda  FileCount_M1
           cmp  SelectLine_M1
           beq  PMNoMoreBelow
           bra  SD02

SD01:

           lda  LinesBelow_M1+1
           ora  LinesBelow_M1
           beq  PMNoMoreBelow

SD02:

           inc  SelectLine_M1

           lda  #NoDirChange
           sta  RC_M1

PMNoMoreBelow:

           rts

PMScrollUp:

           lda  MouseY
           cmp  #11-1
           bne  OnPathDDL

           lda  MouseX
           cmp  #46-1
           bne  OnPathDDL

           lda  SelectLine_M1
           cmp  #1
           bne  SU01

           lda  LinesAbove_M1+1
           ora  LinesAbove_M1
           beq  PMNoMoreAbove

SU01:

           dec  SelectLine_M1

           lda  #NoDirChange
           sta  RC_M1

PMNoMoreAbove:

           rts

OnPathDDL:

           lda  Prefix
           beq  PDDLExit

           lda  MouseY
           cmp  #9-1
           bne  PMOnNoWhere

           lda  MouseX
           cmp  #23-1
           bcc  PMOnNoWhere

           cmp  #44-1
           bcs  PMOnNoWhere

           lda  #VolDirPull
           sta  TabIndex_M1

           jsr  M1RefreshBtn ; I guess... there are multiple RefreshBtn routines

           jsr  PathDDL

PDDLExit:

           rts

PMOnNoWhere:

           rts
;
; Mouse Button Release
;

PMButtonUp:

AtDisksBtn:

           lda  MouseY
           cmp  #11-1
           bne  AtOpenBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtOpenBtn
           cmp  #59-1
           bcs  AtOpenBtn

           lda  TabIndex_M1
           bne  AtDisksExit

           lda  #DirChange
           sta  RC_M1

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

           lda  TabIndex_M1
           cmp  #OpenBtn
           bne  AtOpenExit

           lda  #DirChange
           sta  RC_M1

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

           lda  TabIndex_M1
           cmp  #CloseBtn
           bne  AtCloseExit

           lda  #DirChange
           sta  RC_M1

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

           lda  TabIndex_M1
           cmp  #CancelBtn
           bne  AtCancelExit

           lda  #Quit
           sta  RC_M1

AtCancelExit:

           rts

AtNoBtn:

           rts
