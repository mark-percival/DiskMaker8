; Pause for keystroke

Pause:

AReg       =  $45
XReg       =  $46
YReg       =  $47
Status     =  $48

HTab       =  $24
keyboard   =  $C000
strobe     =  $C010
PrByte     =  $FDDA
cout_monitor =  $FDED
SaveReg    =  $FF4A
RestoreReg =  $FF3F
SetVTab    =  $FC22

           pha                        ; Save current accumulator
           lda  #$00
           sta  strobe                ; Clear keyboard strobe

Loop:

           lda  keyboard              ; check for keystrike
           bpl  Loop

           lda  #$00
           sta  strobe                ; clear keyboard strobe

           pla                        ; Restore accumulator

           rts


PReg:      .res   1
Address:   .res   2

PauseDebug Entry

           php                        ; Save status register
           sta  AReg                  ; Save Accumulator
           sty  YReg                  ; Save Y Register
           stx  XReg                  ; Save X Register

           pla                        ; Get status register off stack
           sta  PReg                  ; Save in memory

           lda  HTab                  ; Put cursor in column 1.
           beq  NoCR
           lda  #$8D
           jsr  cout_monitor

NoCR:

           pla                        ; Get calling entry's address.
           sta  Address
           pla
           sta  Address+1
           pha                        ; Restore address to stack for Return.
           lda  Address
           pha

           sec                        ; Subtract 2 to give proper address.
           lda  Address
           sbc  #2
           sta  Address
           lda  Address+1
           sbc  #0
           sta  Address+1

           lda  Address+1             ; Print address
           jsr  PRByte
           lda  Address
           jsr  PRByte
           lda  #'-'+$80              ; Print '-'
           jsr  cout_monitor
           lda  #' '+$80              ; Print ' '
           jsr  cout_monitor
           lda  #'A'+$80              ; Print 'A'
           jsr  cout_monitor
           lda  #'='+$80              ; Print '='
           jsr  cout_monitor
           lda  AReg                  ; Get Accumulator value
           jsr  PRByte                ; Print it.

           lda  #' '+$80              ; Print ' '
           jsr  cout_monitor
           lda  #'X'+$80              ; Print 'X'
           jsr  cout_monitor
           lda  #'='+$80              ; Print '='
           jsr  cout_monitor
           lda  XReg                  ; Get X Register
           jsr  PRByte                ; Print it.

           lda  #' '+$80              ; Print ' '
           jsr  cout_monitor
           lda  #'Y'+$80              ; Print 'Y'
           jsr  cout_monitor
           lda  #'='+$80              ; PRint '='
           jsr  cout_monitor
           lda  YReg                  ; Get Y register
           jsr  PRByte                ; Print it.

           lda  #$8D                  ; Print <cr>
           jsr  cout_monitor

           jsr  Pause                 ; Pause for key

           lda  PReg                  ; Get status register value in accumulator
           pha                        ; Push accumualtor onto stack.

           ldx  XReg                  ; Restore X register.
           ldy  YReg                  ; Restore Y register.
           lda  AReg                  ; Restore Accumulator.

           plp                        ; Restore status register.

           rts                        ; Return
