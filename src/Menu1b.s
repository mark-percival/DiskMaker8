CurrentDir:

           lda  Prefix                  ; No prefix so don't print current
           bne  PrtVolume               ; volume / directory.

;          Headers for volume listing

           lda  #Normal
           jsr  cout

           lda  #22-1                   ; Start at HTab 22
           sta  HTab
           lda  #7-1
           sta  VTab
           jsr  SetVTab

           ldx  #M1_Line7TextE-M1_Line7Text
           lda  #' '+$80

CurDir01:

           jsr  cout
           dex
           bne  CurDir01

           lda  #8-1
           sta  VTab
           jsr  SetVTab
           lda  #23-1
           sta  HTab

           lda  #' '+$80
           jsr  cout

           lda  #22-1
           sta  HTab
           lda  #9-1
           sta  VTab
           jsr  SetVTab

           ldx  #M1_Line9TextE-M1_Line9Text
           ldy  #0

CurDir02:

           lda  M1_Line9Text,y
           jsr  cout
           iny
           dex
           bne  CurDir02

           lda  #10-1
           sta  VTab
           jsr  SetVTab

           lda  #23-1
           sta  HTab

           lda  #'_'+$80
           jsr  cout

           rts

PrtVolume:

;          Headers for directory / file listing

           lda  #Normal
           jsr  cout

           lda  #22-1                   ; Start at HTab 22
           sta  HTab
           lda  #7-1
           sta  VTab
           jsr  SetVTab

           ldx  #M1_Line7TextE-M1_Line7Text
           ldy  #0

CurDir03:

           lda  M1_Line7Text,y
           jsr  cout
           iny
           dex
           bne  CurDir03

CurDir04:

           lda  #MouseText
           jsr  cout

           lda  #8-1                    ; Start building down arrow box
           sta  VTab
           lda  #23-1
           sta  HTab

           jsr  SetVTab

           lda  #'_'+$80
           jsr  cout

           lda  #9-1
           sta  VTab
           jsr  SetVTab

           lda  #22-1
           sta  HTab

           lda  #'Z'
           jsr  cout

           lda  #'Q'
           jsr  cout

           lda  #'_'
           jsr  cout

           lda  #10-1
           sta  VTab
           jsr  SetVTab

           lda  #23-1
           sta  HTab

           lda  #'\'
           jsr  cout

           lda  #9-1
           sta  VTab
           lda  #25-1
           sta  HTab

           jsr  SetVTab

           lda  #<VolHeader             ; Pointer to volume/directory name
           sta  Ptr1
           lda  #>VolHeader
           sta  Ptr1+1

           jsr  PrtFileName             ; Print volume/directory name

           rts

;          Msb  On

M1_Line7Text:

           asc "Select a disk image to convert:"

M1_Line7TextE:

M1_Line9Text:

           asc "Available disks:       "

M1_Line9TextE:

;          Msb  Off

;
; Move directory first file pointers to next file entry
;

M1_ScrollDown:

           lda  #8
           sta  SelectLine

           clc
           lda  LinesAbove              ; Add 1 to lines above.
           adc  #1
           sta  LinesAbove
           lda  LinesAbove+1
           adc  #0
           sta  LinesAbove+1

           sec
           lda  LinesBelow              ; Subtract 1 from lines below
           sbc  #1
           sta  LinesBelow
           lda  LinesBelow+1
           sbc  #0
           sta  LinesBelow+1

FindFstEnt:

           jsr  NextFstEnt

           lda  FirstAddr
           sta  Ptr1
           lda  FirstAddr+1
           sta  Ptr1+1

           lda  (Ptr1)
           beq  FindFstEnt              ; Deleted entry

           rts

NextFstEnt:                         ; Move first entry to next entry.

           dec  FstEntCnt
           lda  FstEntCnt

           bne  FstNextBlk

;  No more entries in this directory block; get next.

           lda  #<(readBuf+4)
           sta  FirstAddr
           lda  #>(readBuf+4)
           sta  FirstAddr+1

           inc  FirstPage
           inc  FirstPage

           lda  M1_EntPerBlk
           sta  FstEntCnt

           bra  FstGetBlk

FstNextBlk:

; Move First Address pointer to next entry.

           clc
           lda  FirstAddr
           adc  M1_EntLength
           sta  FirstAddr
           lda  FirstAddr+1
           adc  #0
           sta  FirstAddr+1

FstGetBlk:

           lda  FirstPage
           sta  CurrPage
           jsr  GetBlock

           rts


;
; Move directory first file pointer to previous file
;

M1_ScrollUp:

           lda  #1
           sta  SelectLine

           sec
           lda  LinesAbove              ; Subtract 1 from lines above
           sbc  #1
           sta  LinesAbove
           lda  LinesAbove+1
           sbc  #0
           sta  LinesAbove+1

           clc
           lda  LinesBelow              ; Add 1 to lines below
           adc  #1
           sta  LinesBelow
           lda  LinesBelow+1
           adc  #0
           sta  LinesBelow+1

FindPrevEnt:

           jsr  PrevFstEntry

           lda  FirstAddr
           sta  Ptr1
           lda  FirstAddr+1
           sta  Ptr1+1

           lda  (Ptr1)
           beq  FindPrevEnt             ; Deleted entry

           rts

PrevFstEntry:

           lda  FstEntCnt
           cmp  M1_EntPerBlk
           bne  FstPrevBlk

; No more entries in this block; get previous.

           lda  #<(readBuf+4+($27*$0C))
           sta  FirstAddr
           lda  #>(readBuf+4+($27*$0C))
           sta  FirstAddr+1

           dec  FirstPage
           dec  FirstPage

           lda  #1
           sta  FstEntCnt
           bra  FstGetPrev

FstPrevBlk:

           inc  FstEntCnt

; Move First Address pointer to previous entry.

           sec
           lda  FirstAddr
           sbc  M1_EntLength
           sta  FirstAddr
           lda  FirstAddr+1
           sbc  #0
           sta  FirstAddr+1

FstGetPrev:

           lda  FirstPage
           sta  CurrPage
           jsr  GetBlock

           rts

;
; Refresh command buttons display based on M1_TabIndex setting
;

M1_RefreshBtn:

           lda  #Normal                 ; Make sure inverse text is off.
           jsr  cout
           lda  #StdText                ; MouseText off.
           jsr  cout

           lda  #<ButtonText            ; Set button text address up in Ptr1
           sta  Ptr1
           lda  #>ButtonText
           sta  Ptr1+1

           ldx  #0                      ; Set to current button tab index.

M1_Refresh01:

           cpx  M1_TabIndex                ; Is this our active button?
           bne  M1_Refresh02            ; No so print it in Normal

           lda  #Inverse                ; Yes so change mode to Inverse (selected)
           jsr  cout

M1_Refresh02:

           phx                          ; Save current tab button index on stack

           lda  #50-1
           sta  HTab                    ; HTab 50
           lda  (Ptr1)                  ; Retrieve VTab
           sta  VTab
           jsr  SetVTab                 ; Set VTab

           ldy  #1                      ; Starting position index
           ldx  #8                      ; Text length index

M1_Refresh03:

           lda  (Ptr1),y                ; Get character
           jsr  cout                    ; Print it
           iny                          ; Increment to next character
           dex                          ; count it
           bne  M1_Refresh03            ; More?

           lda  #Normal                 ; No more so reset Normal text.
           jsr  cout

           plx                          ; Get tabindex from stack
           inx                          ; Move to next tab index
           cpx  #4                      ; 4 buttons updated?
           beq  M1_Refresh04            ; Yes so exit.

           clc                          ; No so add 9 to Ptr1 to setup next
           lda  Ptr1                    ; print
           adc  #9
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1
           bra  M1_Refresh01            ; Go back and print next button.

M1_Refresh04:

           cpx  M1_TabIndex             ; M1_TabIndex = 5?
           bne  M1_Refresh05            ; No so print vol / dir name normal text

           lda  #Inverse                ; Yes so print inverse text
           sta  TextMode

M1_Refresh05:

           jsr  CurrentDir              ; Print volume/directory name

M1_Refresh99:

           rts
