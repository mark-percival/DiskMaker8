;
; Menu2 user interface
;

Menu2UI:

           stz  RC_M2                ; Reset return code
           stz  ClearKbd

@PollDev:

           jsr  PlotMouse             ; Put mouse cursor on screen

@M2PollDevLoop:

           lda  Keyboard              ; Get keypress
           bpl  @PollMouse            ; No keypress, check mouse
           jmp  @KeyDev

@PollMouse:

           jsr  ReadMouse             ; Read mouse
           lsr  MouseX                ; Put x and y mouse coordinates into
           lsr  MouseY                ;  0 to 79 and 0 to 23 range.
           lda  MouseStat             ; Mouse status
           bit  #MouseMove            ; Mouse moved?
           bne  @MouseDev1            ; Yes, process cursor movement
           bit  #CurrButton           ; Button pressed?
           bne  @MouseDev2            ; Yes, process button pressed.
           bit  #PrevButton           ; Button release?
           bne  @MouseDev3            ; Yes, process button release.

           bra  @M2PollDevLoop        ; Check keyboard and mouse again.

;
; Process mouse movement
;

@MouseDev1:

           jsr  MoveMouse
           jmp  @M2PollDevLoop

;
; Process button pressed
;

@MouseDev2:

           jmp  @ButtonDown

;
; Process mouse button release
;

@MouseDev3:

           jmp  @ButtonUp

;
; Process keyboard key press
;

@KeyDev:

           stz  ClearKbd              ; Clear keyboard strobe
           sta  @M2KeyPress

; Text for quiting screen

           lda  AppleKey
           bpl  @NextKey01
           lda  @M2KeyPress
           cmp  #'Q'+$80
           beq  @QuitReq
           cmp  #'q'+$80
           beq  @QuitReq
           cmp  #'B'+$80
           beq  @QuitReq
           cmp  #'b'+$80
           beq  @QuitReq
           bra  @NextKey01

@QuitReq:

           lda  #SkipBtn              ; Test here to see of Skip is the
           cmp  TabIndex_M2           ;  current displayed button.
           sta  TabIndex_M2
           beq  @QuitReq0
           jsr  Refresh2Btn           ; Display Skip as current selected.

@QuitReq0:

           jsr  @AnimateBtn

           lda  #Quit2
           sta  RC_M2
           jmp  @Exit

; Down / right arrow keypress logic

@NextKey01:

           lda  @M2KeyPress
           cmp  #DownArrow            ; Down arrow?
           beq  @DownReq2
           cmp  #RightArrow           ; ...or right arrow?
           beq  @DownReq2
           bra  @NextKey02

@DownReq2:

           lda  SelLine_M2
           cmp  #5                    ; At bottom of window?
           beq  @AtBottom

           lda  DevEntCnt_M2           ; If total number of devices = our current
           cmp  SelLine_M2             ;  line number then no more entries.
           beq  @AtBottom

@M2IncSelLine:

           inc  SelLine_M2
           lda  #UpdDevLst
           sta  RC_M2
           jmp  @Exit

@AtBottom:

           lda  Below_M2
           beq  @NoMoreBelow

           inc  SelLine_M2             ; Should make SelLine_M2 = 6

@NoMoreBelow:

           lda  #UpdDevLst
           sta  RC_M2
           jmp  @Exit

@NextKey02:

; Up / left arrow keypress

           lda  @M2KeyPress
           cmp  #UpArrow
           beq  @UpReq2
           cmp  #LeftArrow
           beq  @UpReq2
           bra  @NextKey03

@UpReq2:

           lda  SelLine_M2
           cmp  #1
           beq  @AtTop

           dec  SelLine_M2
           lda  #UpdDevLst
           sta  RC_M2
           jmp  @Exit

@AtTop:

           lda  Above_M2
           beq  @NoMoreAbove

           dec  SelLine_M2             ; Should make SelLine_M2 = 0

@NoMoreAbove:

           lda  #UpdDevLst
           sta  RC_M2
           jmp  @Exit

@NextKey03:

; About screen request

           lda  AppleKey
           bpl  @NextKey04
           lda  @M2KeyPress
           cmp  #'A'+$80
           beq  @AboutReq
           cmp  #'a'+$80
           beq  @AboutReq
           bra  @NextKey04

@AboutReq:

           lda  #AboutBtn
           cmp  TabIndex_M2
           sta  TabIndex_M2
           beq  @AboutReq0

           jsr  Refresh2Btn

@AboutReq0:

           jsr  @AnimateBtn

@AboutReq1:

           lda  #SkipBtn
           sta  TabIndex_M2

;          lda  #@AboutMsg
;          sta  MsgPtr
;          lda  #>@AboutMsg
;          sta  MsgPtr+1
;
;          jsr  MsgOk

           jsr  About

           lda  #Nothing
           sta  RC_M2
           jmp  @Exit

@AboutMsg: asccr "       Diskmaker 8"
           ascz  "(c) 2005 by Mark Percival"

@NextKey04:

; Make disk request

           lda  AppleKey
           bpl  @NextKey05
           lda  @M2KeyPress
           cmp  #'M'+$80
           beq  @MakeReq1
           cmp  #'m'+$80
           beq  @MakeReq1
           bra  @NextKey05

@MakeReq1:

           lda  #MakeBtn
           cmp  TabIndex_M2
           sta  TabIndex_M2
           beq  @MakeReq10

           jsr  Refresh2Btn

@MakeReq10:

           jsr  @AnimateBtn

           lda  DevEntCnt_M2          ; Check to see if there are devices listed
           bne  @MakeReq11            ;  on the screen.

           jsr  Beep                  ; Nope, so beep him and exit.

           lda  #Nothing
           sta  RC_M2
           jmp  @Exit

@MakeReq11:

           lda  #SkipBtn
           sta  TabIndex_M2

           lda  #MakingDisk
           sta  RC_M2
           jmp  @Exit

@NextKey05:

; Tab key routine

           lda  @M2KeyPress
           cmp  #TabKey
           beq  @TabReq
           bra  @NextKey06

@TabReq:

           lda  OptionKey
           bmi  @TabUp

@TabDown:

           lda  TabIndex_M2
           inc  a
           cmp  #LoopBack2
           bne  @TabReq1

           lda  #0
           bra  @TabReq1

@TabUp:

           lda  TabIndex_M2
           dec  a
           bpl  @TabReq1

           lda  #LoopBack2-1

@TabReq1:

           sta  TabIndex_M2

           lda  #Nothing
           sta  RC_M2
           jmp  @Exit

@NextKey06:

; Process <cr>

           lda   @M2KeyPress
           cmp  #ReturnKey
           beq  @M2EnterReq
           cmp  #' '+$80
           beq  @M2EnterReq
           bra  @NextKey07

@M2EnterReq:

           lda  TabIndex_M2

           cmp  #AboutBtn
           bne  @Enter01
           jmp  @AboutReq

@Enter01:

           cmp  #SkipBtn
           bne  @Enter02
           jmp  @QuitReq

@Enter02:

           cmp  #MakeBtn
           bne  @Enter03
           jmp  @MakeReq1

@Enter03:

           cmp  #ImgTypeBox
           bne  @Enter04
           jsr  SelImgType
           jsr  GetImgSize

           lda  blnSize_M2            ; Is same-size on?
           bne  @Enter03
           jmp  @M2PollDevLoop        ; No, so just get next keystroke.

@Enter03a:

           lda  #ReloadDevs           ; Same size on and he changed type so
           sta  RC_M2                ; refresh device display.
           jmp  @Exit

@Enter04:

           cmp  #SameSize
           bne  @Enter05
           jsr  ToggleSize
           lda  #ReloadDevs
           sta  RC_M2
           jmp  @Exit

@Enter05:

@NextKey07:

           jsr  Beep
           jmp  @M2PollDevLoop

@Exit:

           rts

@M2KeyPress:  .byte   $00

;
; Do button animation on <cr>
;

@AnimateBtn:

           lda  #<M2BtnText
           sta  Ptr1
           lda  #>M2BtnText
           sta  Ptr1+1

           ldx  TabIndex_M2
           beq  @AnimBtn02

@AnimBtn01:

           clc
           lda  Ptr1
           adc  #12
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           dex
           bne  @AnimBtn01

@AnimBtn02:

           lda  #Normal
           jsr  cout_mark

           jsr  @PrtButton

           lda  #$FF
           jsr  Wait

           lda  #Inverse
           jsr  cout_mark

           jsr  @PrtButton

           lda  #$FF
           jsr  Wait

           lda  #Normal
           jsr  cout_mark

           rts

;
; Print button text
;

@PrtButton:

           lda  #51-1
           sta  HTab
           lda  (Ptr1)
           sta  VTab
           jsr  SetVTab

           ldy  #1
           ldx  #11

@PrtButt01:

           lda  (Ptr1),y
           jsr  cout_mark
           iny
           dex
           bne  @PrtButt01

           rts

;
; Process mouse button press
;

@ButtonDown:

           lda  MouseStat             ; Button is down but make sure he has also
           bit  #PrevButton           ; released it and is not holding it down.
           beq  @BD00

           lda  @HoldCnt              ; Check to see how long he's held down the
           cmp  #$FF                  ; mouse button.
           beq  @Repeat               ; Long enough so he's repeating.

           inc  @HoldCnt              ; Hasn't held it long enough to be
           lda  #$01                  ; considered repeating so count the hold
           jsr  Wait

           jmp  @M2PollDevLoop

@HoldCnt:   .byte   $00               ;    Count how long he's holding the button

@BD00:

           stz  @HoldCnt              ; Zero out counter on first button press.

@Repeat:

; Test for About button click

           lda  MouseY
           cmp  #11-1
           bne  @BD01

           lda  MouseX
           cmp  #50-1
           bcc  @BD01

           cmp  #62
           bcs  @BD01

           lda  #AboutBtn
           sta  TabIndex_M2

           lda  #Nothing
           sta  RC_M2
           rts

@BD01:

; Test for Skip button click

           lda  MouseY
           cmp  #13-1
           bne  @BD02

           lda  MouseX
           cmp  #50-1
           bcc  @BD02

           cmp  #62
           bcs  @BD02

           lda  #SkipBtn
           sta  TabIndex_M2

           lda  #Nothing
           sta  RC_M2
           rts

@BD02:

; Test for Make Disks button click

           lda  MouseY
           cmp  #15-1
           bne  @BD03

           lda  MouseX
           cmp  #50-1
           bcc  @BD03

           cmp  #62
           bcs  @BD03

           lda  #MakeBtn
           sta  TabIndex_M2

           lda  #Nothing
           sta  RC_M2
           rts

@BD03:

; Test for Image Type box click

           lda  MouseY
           cmp  #17-1
           bne  @BD04

           lda  MouseX
           cmp  #19-1
           bcc  @BD04

           cmp  #38
           bcs  @BD04

           lda  #ImgTypeBox
           sta  TabIndex_M2

           jsr  Refresh2Btn
           jsr  SelImgType
           jsr  GetImgSize

           lda  blnSize_M2            ; Is same-size on?
           bne  @BD03a
           jmp  @M2PollDevLoop        ; No, so just get next keystroke.

@BD03a:

           lda  #ReloadDevs           ; Same size on and he changed type so
           sta  RC_M2                ; refresh device display.
           rts

@BD04:

; Test for Same-size disks checkbox click

           lda  MouseY
           cmp  #17-1
           bne  @BD05

           lda  MouseX
           cmp  #42-1
           bcc  @BD05

           cmp  #63
           bcs  @BD05

           lda  #SameSize
           sta  TabIndex_M2

           lda  #Nothing
           sta  RC_M2
           rts

@BD05:

; Text for scroll list box up

           lda  MouseY
           cmp  #11-1
           bne  @BD06

           lda  MouseX
           cmp  #46-1
           bne  @BD06

           jmp  @UpReq2

@BD06:

; Test for scroll list box down

           lda  MouseY
           cmp  #15-1
           bne  @BD07

           lda  MouseX
           cmp  #46-1
           bne  @BD07

           jmp  @DownReq2

@BD07:

; Look for a click on a device inside of list box

           lda  MouseY
           cmp  #11-1
           bcc  @BD09

           cmp  #15
           bcs  @BD09

           lda  MouseX
           cmp  #19-1
           bcc  @BD09

           cmp  #44
           bcs  @BD09

           sec
           lda  MouseY
           sbc  #9
           cmp  SelLine_M2            ; Did he click the same line twice?
           beq  @BD08                 ; Yes so execute double click logic

           sta  SelLine_M2            ; No so change selected line pointer.

           lda  #UpdDevLst
           sta  RC_M2
           rts

@BD08:                                ; Double clicked line

           lda  #MakeBtn              ; Change command to Make Disks
           sta  TabIndex_M2

           jmp  @M2EnterReq           ; Pretend that he pressed Enter key

@BD09:

           jsr  Beep
           jmp  @M2PollDevLoop

           rts
;
; Process mouse button release
;

@ButtonUp:

; Test for About button click

           lda  MouseY
           cmp  #11-1
           bne  @BU01

           lda  MouseX
           cmp  #50-1
           bcc  @BU01

           cmp  #62
           bcs  @BU01

           lda  TabIndex_M2
           cmp  #AboutBtn
           bne  @BU01

           jmp  @M2EnterReq

@BU01:

; Test for Skip button click

           lda  MouseY
           cmp  #13-1
           bne  @BU02

           lda  MouseX
           cmp  #50-1
           bcc  @BU02

           cmp  #62
           bcs  @BU02

           lda  TabIndex_M2
           cmp  #SkipBtn
           bne  @BU02

           jmp  @M2EnterReq

@BU02:

; Test for Make Disks button click

           lda  MouseY
           cmp  #15-1
           bne  @BU03

           lda  MouseX
           cmp  #50-1
           bcc  @BU03

           cmp  #62
           bcs  @BU03

           lda  TabIndex_M2
           cmp  #MakeBtn
           bne  @BU03

           jmp  @M2EnterReq

@BU03:

; Test for Same-size disks checkbox click

           lda  MouseY
           cmp  #17-1
           bne  @BU04

           lda  MouseX
           cmp  #42-1
           bcc  @BU04

           cmp  #63
           bcs  @BU04

           lda  TabIndex_M2
           cmp  #SameSize
           bne  @BU04

           jmp  @M2EnterReq

@BU04:

           jmp  @M2PollDevLoop
