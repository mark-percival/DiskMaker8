ProcMouse  Start
           Using Menu1Vars

*
* Processing the mouse
*

* Soft Switches

Off80Store equ  $C000
On80Store  equ  $C001
Read80Store equ $C018
ReadPage2  equ  $C01C
Page1      equ  $C054
Page2      equ  $C055


SaveChar   ds   1                       Saved character at X, Y
X          ds   1                       X position
Y          ds   1                       Y position

TextLine   anop                         Text screen line starting addresses

TextLine00 dc   i'$0400'
TextLine01 dc   i'$0480'
TextLine02 dc   i'$0500'
TextLine03 dc   i'$0580'
TextLine04 dc   i'$0600'
TextLine05 dc   i'$0680'
TextLine06 dc   i'$0700'
TextLine07 dc   i'$0780'
TextLine08 dc   i'$0428'
TextLine09 dc   i'$04A8'
TextLine10 dc   i'$0528'
TextLine11 dc   i'$05A8'
TextLine12 dc   i'$0628'
TextLine13 dc   i'$06A8'
TextLine14 dc   i'$0728'
TextLine15 dc   i'$07A8'
TextLine16 dc   i'$0450'
TextLine17 dc   i'$04D0'
TextLine18 dc   i'$0550'
TextLine19 dc   i'$05D0'
TextLine20 dc   i'$0650'
TextLine21 dc   i'$06D0'
TextLine22 dc   i'$0750'
TextLine23 dc   i'$07D0'

MouseArrow equ  $42                     Mouse arrow screen character
MouseBusy  equ  $43                     Mouse hourglass screen character

* Move mouse cursor

MoveMouse  Entry

           lda  MousePtr+1              Test for mouse
           bne  MoveGo
           rts

MoveGo     anop

           sta  On80Store               Turn on 80Store

           lda  Y                       Get Old mouse Y position

           asl  a                       Multiply by 2 for address indexing
           tax                          Move to index

           lda  TextLine,x              Get low byte of line address
           sta  Ptr1                     and save in Ptr1
           inx
           lda  TextLine,x              Get high byte of line address
           sta  Ptr1+1                   and save in Ptr1+1

* Set up X position

           lda  X

           lsr  a
           tay

           bcs  MainRAM1

* Even column numbers 0, 2, 4, 6, ... in aux RAM

AuxRAM1    anop

           sta  Page2
           bra  RestoreChar

* Odd column numbers 1, 3, 5, 7, ... in main RAM

MainRAM1   anop

           sta  Page1

RestoreChar anop

           lda  SaveChar
           sta  (Ptr1),y

           bra  PlotGo

PlotMouse  Entry

* Set up Y position

           lda  MousePtr+1              Test for mouse
           bne  PlotGo
           rts

PlotGo     anop

           sta  On80Store               Turn on 80Store

           lda  MouseY                  Get Mouse Y position
           sta  Y                       Save it

           asl  a                       Multiply by 2 for address indexing
           tax                          Move to index

           lda  TextLine,x              Get low byte of line address
           sta  Ptr1                     and save in Ptr1
           inx
           lda  TextLine,x              Get high byte of line address
           sta  Ptr1+1                   and save in Ptr1+1

* Set up X position

           lda  MouseX
           sta  X

           lsr  a
           tay

           bcs  MainRAM2

* Even column numbers 0, 2, 4, 6, ... in aux RAM

AuxRAM2    anop

           sta  Page2
           bra  GetChar

* Odd column numbers 1, 3, 5, 7, ... in main RAM

MainRAM2   anop

           sta  Page1

GetChar    anop

           lda  (Ptr1),y
           cmp  #MouseArrow
           beq  DontSave
           cmp  #MouseBusy
           beq  DontSave

           sta  SaveChar

DontSave   anop

           lda  #MouseArrow
           sta  (Ptr1),y

           sta  Page1

           rts

*
* Mouse button down
*

ButtonDown entry

           stz  blnDblClick             Reset double click indicator.
           lda  MouseStat               Button is down but make sure he has also
           bit  #PrevButton             released it and is not holding it down.
           beq  NotHeld

           lda  HoldCnt                 Check to see how long he's held down the
           cmp  #$FF                    mouse button.
           beq  Repeat                  Long enough so he's repeating.

           inc  HoldCnt                 Hasn't held it long enough yet so count
           lda  #$01                    the hold and return.
           jsr  Wait

           rts

HoldCnt    ds   1

NotHeld    anop

           stz  HoldCnt                 Zero out counter upon first button press

Repeat     anop

* Disks button

OnDisksBtn anop

           lda  MouseY                  Check to see if he pressed the Disks
           cmp  #11-1                   button.
           bne  OnOpenBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnOpenBtn
           cmp  #59-1
           bcs  OnOpenBtn

           stz  TabIndex                Move TabIndex to Disks button.
           lda  #TabOnly
           sta  RC

           rts

* Open button

OnOpenBtn  anop

           lda  MouseY                  Check to see if he pressed the Open
           cmp  #14-1                   button.
           bne  OnCloseBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnCloseBtn
           cmp  #59-1
           bcs  OnCloseBtn

           lda  #OpenBtn                Move TabIndex to Open button.
           sta  TabIndex
           lda  #TabOnly
           sta  RC

           rts

* Close button

OnCloseBtn anop

           lda  MouseY                  Check to see if he pressed the Close
           cmp  #16-1                   button.
           bne  OnCancelBtn

           lda  MouseX
           cmp  #49-1
           bcc  OnCancelBtn
           cmp  #59-1
           bcs  OnCancelBtn

           lda  #CloseBtn               Move TabIndex to Close button.
           sta  TabIndex
           lda  #TabOnly
           sta  RC

           rts

* Cancel button

OnCancelBtn anop

           lda  MouseY                  Check to see if he pressed the Cancel
           cmp  #18-1                   button.
           bne  OnFileList

           lda  MouseX
           cmp  #49-1
           bcc  OnFileList
           cmp  #59-1
           bcs  OnFileList

           lda  #CancelBtn              Move TabIndex to Cancel button.
           sta  TabIndex
           lda  #TabOnly
           sta  RC

           rts

*
* Changing Current File Selection
*

OnFileList anop

           lda  MouseY                  Check to see if he click inside the file
           cmp  #11-1                   list box.
           bcc  ScrollDown
           cmp  #19-1
           bcs  ScrollDown

           lda  MouseX
           cmp  #26-1
           bcc  ScrollDown
           cmp  #45-1
           bcs  ScrollDown

           sec
           lda  MouseY                  Calculate the requested line number by
           sbc  #9                      taking the mouse position and subtract
           sta  Requested               9 for a 1-8 line number.

           lda  FileCount+1             Check here to see if the line he is
           bne  LineOk                  asking for exists on the screen.

           lda  Requested
           cmp  FileCount
           bcc  LineOk
           beq  LineOk

           rts                          No, he's clicking on a blank line.

LineOk     anop

           lda  Requested               Good line so check to see if he is
           cmp  SelectLine              double clicking on a already selected
           beq  DoDblClick              line.

           sta  SelectLine              No, so select this line and refresh.

           lda  #NoDirChange
           sta  RC

           rts

DoDblClick anop

           lda  #OpenBtn                Double clicking so set TabIndex to Open
           sta  TabIndex                and try opening it.

           lda  #1
           sta  blnDblClick             Tell MENU1UI that we're double clicking

           lda  #DirChange
           sta  RC

           rts

Requested  ds   1

*
* Scroll down 1 file
*

ScrollDown anop

           lda  MouseY
           cmp  #18-1
           bne  ScrollUp

           lda  MouseX
           cmp  #46-1
           bne  ScrollUp

           lda  SelectLine
           cmp  #8                      At bottom of window?
           beq  SD01                    Yes.

           lda  FileCount+1
           bne  SD02

           lda  FileCount
           cmp  SelectLine
           beq  NoMoreBelow
           bra  SD02

SD01       anop

           lda  LinesBelow+1
           ora  LinesBelow
           beq  NoMoreBelow

SD02       anop

           inc  SelectLine

           lda  #NoDirChange
           sta  RC

NoMoreBelow anop

           rts

ScrollUp   anop

           lda  MouseY
           cmp  #11-1
           bne  OnPathDDL

           lda  MouseX
           cmp  #46-1
           bne  OnPathDDL

           lda  SelectLine
           cmp  #1
           bne  SU01

           lda  LinesAbove+1
           ora  LinesAbove
           beq  NoMoreAbove

SU01       anop

           dec  SelectLine

           lda  #NoDirChange
           sta  RC

NoMoreAbove anop

           rts

OnPathDDL  anop

           lda  Prefix
           beq  PDDLExit

           lda  MouseY
           cmp  #9-1
           bne  OnNowhere

           lda  MouseX
           cmp  #23-1
           bcc  OnNowhere

           cmp  #44-1
           bcs  OnNoWhere

           lda  #VolDirPull
           sta  TabIndex

           jsr  RefreshBtn

           jsr  PathDDL

PDDLExit   anop

           rts

OnNowhere  anop

           rts
*
* Mouse Button Release
*

ButtonUp   entry

AtDisksBtn anop

           lda  MouseY
           cmp  #11-1
           bne  AtOpenBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtOpenBtn
           cmp  #59-1
           bcs  AtOpenBtn

           lda  TabIndex
           bne  AtDisksExit

           lda  #DirChange
           sta  RC

AtDisksExit anop

           rts

AtOpenBtn  anop

           lda  MouseY
           cmp  #14-1
           bne  AtCloseBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtCloseBtn
           cmp  #59-1
           bcs  AtCloseBtn

           lda  TabIndex
           cmp  #OpenBtn
           bne  AtOpenExit

           lda  #DirChange
           sta  RC

AtOpenExit anop

           rts

AtCloseBtn anop

           lda  MouseY
           cmp  #16-1
           bne  AtCancelBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtCancelBtn
           cmp  #59-1
           bcs  AtCancelBtn

           lda  TabIndex
           cmp  #CloseBtn
           bne  AtCloseExit

           lda  #DirChange
           sta  RC

AtCloseExit anop

           rts

AtCancelBtn anop

           lda  MouseY
           cmp  #18-1
           bne  AtNoBtn

           lda  MouseX
           cmp  #49-1
           bcc  AtNoBtn
           cmp  #59-1
           bcs  AtNoBtn

           lda  TabIndex
           cmp  #CancelBtn
           bne  AtCancelExit

           lda  #Quit
           sta  RC

AtCancelExit anop

           rts

AtNoBtn    anop

           rts

           End
