;
; Path drop down list, part of Menu 1
;

PathDDL:

           lda  Prefix
           sta  InitPrefix
           bne  HavePrefix

           rts

HavePrefix:

           lda  #TabOnly
           sta  RC
           stz  NumLevels
           lda  #1
           sta  DDLSelLine

           jsr  CalcLevels

           jsr  PDSaveScreen

Loop:

           jsr  ShowDDL
           jsr  DDLUI

           lda  DDLRC
           bne  Loop

           lda  Prefix
           cmp  InitPrefix
           beq  NoChange

           lda  #OpenBtn
           sta  TabIndex

           lda  #DirChange
           sta  RC

NoChange:

           jsr  PDRestScreen

           jsr  PlotMouse

           rts

InitPrefix: .byte  $00
NumLevels: .byte   $00
LevelsPosn: .res   16
DDLSelLine: .byte  $00
DDLRC:     .byte   $00
LastLine:  .byte   $00

CalcLevels:

           ldx  Prefix                ; Get prefix length
           ldy  #$00                  ; Zero LevelPosn index

CL01:

           lda  Prefix,x              ; Get prefix character
           cmp  #'/'                  ; Is it a '/'?
           bne  CL02                  ; No, move to next character

           txa
           sta  LevelsPosn,y          ; Save prefix ending position

           cpx  #1                    ; At root?
           beq  CL03

           cpy  #15                   ; Move than 15 subdirectories?
           beq  CL03

           iny                        ; Increment index

CL02:

           dex                        ; Move to next path character
           bne  CL01                  ; If not zero then loop

CL03:

           sty  NumLevels             ; Save the number of directory levels

           clc
           lda  #10
           adc  NumLevels
           sta  LastLine

           rts

; Display drop down list

ShowDDL:

           lda  #8-1
           sta  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #MouseText
           jsr  cout

           lda  #'Z'
           jsr  cout

           ldx  #20
           lda  #'L'

SDDL01:

           jsr  cout
           dex
           bne  SDDL01

           lda  #'_'
           jsr  cout

           ldx  #0

SDDL02:

           inx

           inc  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           ldy  LevelsPosn,x
           iny

           cpy  #2                    ; At root?
           beq  SDDL03

           lda  #' '+$80
           jsr  cout

           lda  #'X'
           jsr  cout

           lda  #'Y'
           jsr  cout

           bra  SDDL04

SDDL03:

           lda  #'Z'
           jsr  cout

           lda  #'\'
           jsr  cout

           lda  #'^'
           jsr  cout

SDDL04:

           lda  #' '+$80
           jsr  cout

           cpx  DDLSelLine
           bne  SDDL04a

           lda  #StdText
           jsr  cout

           lda  #Inverse
           jsr  cout

SDDL04a:

           phx

           ldx  #15

SDDL05:

           lda  Prefix,y
           cmp  #'/'
           beq  SDDL06
           ora  #$80

           jsr  cout

           iny
           dex
           bne  SDDL05
           bra  SDDL07

SDDL06:

           lda  #' '+$80
           jsr  cout
           dex
           bne  SDDL06

SDDL07:

           lda  #Normal
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'_'
           jsr  cout

           plx
           cpx  NumLevels
           bcs  SDDL07a
           jmp  SDDL02

SDDL07a:

           inx

           lda  NumLevels
           cmp  #15
           beq  SDDL09

           inc  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'['
           jsr  cout
           jsr  cout

           lda  #' '+$80
           jsr  cout

           cpx  DDLSelLine
           bne  SDDL07b

           lda  #StdText
           jsr  cout

           lda  #Inverse
           jsr  cout

SDDL07b:

           lda  #'D'+$80
           jsr  cout
           lda  #'i'+$80
           jsr  cout
           lda  #'s'+$80
           jsr  cout
           lda  #'k'+$80
           jsr  cout
           lda  #'s'+$80
           jsr  cout

           ldx  #10

           lda  #' '+$80

SDDL08:

           jsr  cout
           dex
           bne  SDDL08

           lda  #Normal
           jsr  cout

           lda  #MouseText
           jsr  cout

           lda  #' '+$80
           jsr  cout

           lda  #'_'
           jsr  cout

SDDL09:

           inc  VTab
           lda  #24-1
           sta  HTab

           jsr  SetVTab

           lda  #'Z'
           jsr  cout

           ldx  #20
           lda  #'_'+$80

SDDL10:

           jsr  cout
           dex
           bne  SDDL10

           lda  #'_'
           jsr  cout

           lda  #StdText
           jsr  cout

           rts

; Drop down list user interface.

DDLUI:

           stz  ClearKbd
           stz  DDLRC

@PollDev:

           jsr  PlotMouse

PDPollDevLoop:

           lda  Keyboard
           bpl  @PollMouse
           jmp  PDKeyDev

@PollMouse:

           jsr  ReadMouse
           lsr  MouseX
           lsr  MouseY
           lda  MouseStat
           bit  #MouseMove
           bne  @MouseDev1
           bit  #CurrButton
           bne  @MouseDev2
           bit  #PrevButton
           bne  @MouseDev3

           bra  PDPollDevLoop

; Mouse movement

@MouseDev1:

           jsr  MoveMouse
           jmp  PDPollDevLoop

; Mouse button pressed

@MouseDev2:

           lda  MouseY
           cmp  #8-1
           bcc  @MouseDev3
           cmp  LastLine
           bcs  @MouseDev3

           lda  MouseX
           cmp  #23-1
           bcc  @MouseDev3
           cmp  #46-1
           bcs  @MouseDev3

           jsr  ChangePosn

           jmp  PDPollDevLoop

; Mouse button release

@MouseDev3:

           rts

; Change pointer to a different directory

ChangePosn:

           sec
           lda  MouseY
           sbc  #9-1                  ; First line
           inc  a                     ; Make one based
           bne  NotZero               ; In case he's above the first line
           inc  a

NotZero:

           cmp  NumLevels             ; If he's pointing beyond the last line,
           bcc  InRange               ; set it to the last line.
           beq  InRange

           lda  NumLevels
           cmp  #15
           beq  InRange
           inc  a

InRange:

           cmp  DDLSelLine
           bne  Changed
           rts

Changed:

           sta  DDLSelLine
           jsr  SetPrefix
           jsr  ShowDDL
           jsr  PlotMouse

           rts

PDKeyDev:

           stz  ClearKbd

@NextKey01:

           cmp  #DownArrow
           beq  @DA1
           cmp  #RightArrow
           beq  @DA1
           bra  @NextKey02

@DA1:

           lda  NumLevels
           cmp  #15
           beq  @DA2

           inc  a

@DA2:

           cmp  DDLSelLine
           beq  @DA3

           inc  DDLSelLine

@DA3:

           inc  DDLRC

           rts

@NextKey02:

           cmp  #UpArrow
           beq  @UA1
           cmp  #LeftArrow
           beq  @UA1
           bra  @NextKey03

@UA1:

           lda  DDLSelLine
           cmp  #1
           beq  @UA2

           dec  DDLSelLine

@UA2:

           inc  DDLRC

           rts

@NextKey03:

           cmp  #ReturnKey
           bne  BadKey

           jsr  SetPrefix

           rts

BadKey:

           jsr  Beep
           jmp  PDPollDevLoop


; Set the prefix based upon line number selected.

SetPrefix:

           lda  NumLevels
           cmp  DDLSelLine

           bcs  CR01

           stz  Prefix

           rts

CR01:

           ldx  DDLSelLine
           lda  LevelsPosn-1,x

           sta  Prefix

           rts


; Save / Restore Screen routine.

On80Store  =  $C001
Page1      =  $C054
Page2      =  $C055

SaveRtn:   .byte   $00

StartHTab: .byte   $00
EndHTab:   .byte   $00
StartVTab: .byte   $00
CurrLine:  .byte   $00

;
; PDSaveScreen - save screen data under list box
; PDRestScreen - restore screen data under messagebox
;
; Ptr1 = screen data : Ptr2 = save buffer
;

PDSaveScreen:

           lda  #1
           sta  SaveRtn
           bra  StartRtn

PDRestScreen:

           stz  SaveRtn

StartRtn:

           sta  On80Store             ; Make sure 80STORE is on.

           clc
           lda  #24-1                 ; HTab start
           sta  StartHTab
           adc  #22                   ; # char wide
           sta  EndHTab               ; Ending HTab

           sec
           lda  #8-1                  ; Base VTab
           sta  StartVTab
           sta  CurrLine

           lda  #<MessageBuf          ; Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #15+3                 ; Max # of line + 2 for borders + 1 for
;                                     ;  being zero base.
SSLoop1:

           lda  CurrLine
           asl  a
           tay
           lda  TextLine,y
           sta  Ptr1
           iny
           lda  TextLine,y
           sta  Ptr1+1

           ldy  StartHTab

SSLoop2:

           phy
           tya
           lsr  a
           bcs  FromMain

FromAux:

           sta  Page2
           bra  GetChar

FromMain:

           sta  Page1

GetChar:

           tay
           lda  SaveRtn
           beq  Restore

           lda  (Ptr1),y
           sta  (Ptr2)
           bra  Continue

Restore:

           lda  (Ptr2)
           sta  (Ptr1),y

Continue:

           ply

           inc  Ptr2                  ; Increment save buffer pointer
           bne  NoOF

           inc  Ptr2+1

NoOF:                                 ; No overflow

           iny
           cpy  EndHTab               ; If y <= EndHTab, SSLoop2 to continue
           bcc  SSLoop2               ;  saving this line
           beq  SSLoop2

           inc  CurrLine              ; Move to next line
           dex                        ; Another line?
           bne  SSLoop1

           lda  Page1                 ; Set back to Main for exit.

           rts
