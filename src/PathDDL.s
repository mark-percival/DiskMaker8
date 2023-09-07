 ;
; Path drop down list
;

PathDDL:

           ; Expected to scope to Menu1Vars.s

           lda  Prefix
           sta  InitPrefix
           bne  HavePrefix

           rts

HavePrefix:

           lda  #TabOnly
           sta  DDLRC
           stz  NumLevels
           lda  #1
           sta  PD_SelLine

           jsr  CalcLevels

           jsr  PD_SaveScreen

Loop:

           jsr  ShowDDL
           jsr  DDLUI

           lda  DDLRC
           bne  Loop

           lda  Prefix
           cmp  InitPrefix
           beq  NoChange

           lda  #OpenBtn
           sta  M1_TabIndex

           lda  #DirChange
           sta  DDLRC

NoChange:

           jsr  PD_RestScreen

           jsr  PlotMouse

           rts

InitPrefix: .res 1
NumLevels:  .res 1
LevelsPosn: .res 16
PD_SelLine: .res 1
DDLRC:      .res 1
PD_LastLine: .res 1

CalcLevels:

           ldx  Prefix                  ; Get prefix length
           ldy  #$00                    ; Zero LevelPosn index

CL01:

           lda  Prefix,x                ; Get prefix character
           cmp  #'/'                    ; Is it a '/'?
           bne  CL02                    ; No, move to next character

           txa
           sta  LevelsPosn,y            ; Save prefix ending position

           cpx  #1                      ; At root?
           beq  CL03

           cpy  #15                     ; Move than 15 subdirectories?
           beq  CL03

           iny                          ; Increment index

CL02:

           dex                          ; Move to next path character
           bne  CL01                    ; If not zero then loop

CL03:

           sty  NumLevels               ; Save the number of directory levels

           clc
           lda  #10
           adc  NumLevels
           sta  PD_LastLine

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

           cpy  #2                      ; At root?
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

           cpx  PD_SelLine
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

           cpx  PD_SelLine
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

PD_PollDev:

           jsr  PlotMouse

PD_PollDevLoop:

           lda  Keyboard
           bpl  @PollMouse
           jmp  PD_KeyDev

@PollMouse:

           jsr  ReadMouse
           lsr  MouseX
           lsr  MouseY
           lda  MouseStat
           bit  #MouseMove
           bne  PD_MouseDev1
           bit  #CurrButton
           bne  PD_MouseDev2
           bit  #PrevButton
           bne  PD_MouseDev3

           bra  PD_PollDevLoop

; Mouse movement

PD_MouseDev1:

           jsr  MoveMouse
           jmp  PD_PollDevLoop

; Mouse button pressed

PD_MouseDev2:

           lda  MouseY
           cmp  #8-1
           bcc  PD_MouseDev3
           cmp  PD_LastLine
           bcs  PD_MouseDev3

           lda  MouseX
           cmp  #23-1
           bcc  PD_MouseDev3
           cmp  #46-1
           bcs  PD_MouseDev3

           jsr  ChangePosn

           jmp  PD_PollDevLoop

; Mouse button release

PD_MouseDev3:

           rts

; Change pointer to a different directory

ChangePosn:

           sec
           lda  MouseY
           sbc  #9-1                    ; First line
           inc  a                       ; Make one based
           bne  @NotZero                ; In case he's above the first line
           inc  a

@NotZero:

           cmp  NumLevels               ; If he's pointing beyond the last line,
           bcc  InRange                 ; set it to the last line.
           beq  InRange

           lda  NumLevels
           cmp  #15
           beq  InRange
           inc  a

InRange:

           cmp  PD_SelLine
           bne  @Changed
           rts

@Changed:

           sta  PD_SelLine
           jsr  SetPrefix
           jsr  ShowDDL
           jsr  PlotMouse

           rts


; Keyboard routine

;UpArrow     =   $8B
;DownArrow   =   $8A
;LeftArrow   =   $88
;RightArrow  =   $95
;ReturnKey   =   $8D
;TabKey      =   $89

PD_KeyDev:

           stz  ClearKbd

PD_NextKey01:

           cmp  #DownArrow
           beq  @DA1
           cmp  #RightArrow
           beq  @DA1
           bra  PD_NextKey02

@DA1:

           lda  NumLevels
           cmp  #15
           beq  @DA2

           inc  a

@DA2:

           cmp  PD_SelLine
           beq  DA3

           inc  PD_SelLine

DA3:

           inc  DDLRC

           rts

PD_NextKey02:

           cmp  #UpArrow
           beq  @UA1
           cmp  #LeftArrow
           beq  @UA1
           bra  PD_NextKey03

@UA1:

           lda  PD_SelLine
           cmp  #1
           beq  @UA2

           dec  PD_SelLine

@UA2:

           inc  DDLRC

           rts

PD_NextKey03:

           cmp  #ReturnKey
           bne  @BadKey

           jsr  SetPrefix

           rts

@BadKey:

           jsr  Beep
           jmp  PD_PollDevLoop


; Set the prefix based upon line number selected.

SetPrefix:

           lda  NumLevels
           cmp  PD_SelLine

           bcs  CR01

           stz  Prefix

           rts

CR01:

           ldx  PD_SelLine
           lda  LevelsPosn-1,x

           sta  Prefix

           rts


; Save / Restore Screen routine.

PD_TextLine:                         ; Text screen line starting addresses

PD_TextLine00: .addr $0400
PD_TextLine01: .addr $0480
PD_TextLine02: .addr $0500
PD_TextLine03: .addr $0580
PD_TextLine04: .addr $0600
PD_TextLine05: .addr $0680
PD_TextLine06: .addr $0700
PD_TextLine07: .addr $0780
PD_TextLine08: .addr $0428
PD_TextLine09: .addr $04A8
PD_TextLine10: .addr $0528
PD_TextLine11: .addr $05A8
PD_TextLine12: .addr $0628
PD_TextLine13: .addr $06A8
PD_TextLine14: .addr $0728
PD_TextLine15: .addr $07A8
PD_TextLine16: .addr $0450
PD_TextLine17: .addr $04D0
PD_TextLine18: .addr $0550
PD_TextLine19: .addr $05D0
PD_TextLine20: .addr $0650
PD_TextLine21: .addr $06D0
PD_TextLine22: .addr $0750
PD_TextLine23: .addr $07D0

;On80Store   =   $C001
;Page1       =   $C054
;Page2       =   $C055

PD_SaveRtn:    .res 1

PD_StartHTab: .res 1
PD_EndHTab:   .res 1
PD_StartVTab: .res 1
PD_CurrLine:   .res 1

;
; PD_SaveScreen - save screen data under list box
; PD_RestScreen - restore screen data under messagebox
;
; Ptr1 = screen data : Ptr2 = save buffer
;

PD_SaveScreen:

           lda  #1
           sta  PD_SaveRtn
           bra  PD_StartRtn

PD_RestScreen:

           stz  PD_SaveRtn

PD_StartRtn:

           sta  On80Store               ; Make sure 80STORE is on.

           clc
           lda  #24-1                   ; HTab start
           sta  PD_StartHTab
           adc  #22                     ; # char wide
           sta  PD_EndHTab              ; Ending HTab

           sec
           lda  #8-1                    ; Base VTab
           sta  PD_StartVTab
           sta  PD_CurrLine

           lda  #<MessageBuf            ; Set save buffer address
           sta  Ptr2
           lda  #>MessageBuf
           sta  Ptr2+1

           ldx  #15+3                   ; Max # of line + 2 for borders + 1 for
;                                       ;  being zero base.
PD_SSLoop1:

           lda  PD_CurrLine
           asl  a
           tay
           lda  PD_TextLine,y
           sta  Ptr1
           iny
           lda  PD_TextLine,y
           sta  Ptr1+1

           ldy  PD_StartHTab

PD_SSLoop2:

           phy
           tya
           lsr  a
           bcs  @FromMain

;FromAux:

           sta  Page2
           bra  @GetChar

@FromMain:

           sta  Page1

@GetChar:

           tay
           lda  PD_SaveRtn
           beq  @Restore

           lda  (Ptr1),y
           sta  (Ptr2)
           bra  @Continue

@Restore:

           lda  (Ptr2)
           sta  (Ptr1),y

@Continue:

           ply

           inc  Ptr2                    ; Increment save buffer pointer
           bne  @NoOF

           inc  Ptr2+1

@NoOF:                                  ; No overflow

           iny
           cpy  PD_EndHTab              ; If y <= PD_EndHTab, PD_SSLoop2 to continue
           bcc  PD_SSLoop2              ;  saving this line
           beq  PD_SSLoop2

           inc  PD_CurrLine             ; Move to next line
           dex                          ; Another line?
           bne  PD_SSLoop1

           lda  Page1                   ; Set back to Main for exit.

           rts


