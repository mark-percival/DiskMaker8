* Pause for keystroke

Pause      Start

AReg       equ  $45
XReg       equ  $46
YReg       equ  $47
Status     equ  $48

HTab       equ  $24
keyboard   equ  $C000
strobe     equ  $C010
PrByte     equ  $FDDA
Cout       equ  $FDED
SaveReg    equ  $FF4A
RestoreReg equ  $FF3F
SetVTab    equ  $FC22

           pha                          Save current accumulator
           lda  #$00
           sta  strobe                  Clear keyboard strobe

Loop       Anop

           lda  keyboard                check for keystrike
           bpl  Loop

           lda  #$00
           sta  strobe                  cleae keyboard strobe

           pla                          Restore accumulator

           rts


PReg       ds   1
Address    ds   2

PauseDebug Entry

           php                          Save status register
           sta  AReg                    Save Accumulator
           sty  YReg                    Save Y Register
           stx  XReg                    Save X Register

           pla                          Get status register off stack
           sta  PReg                    Save in memory

           lda  HTab                    Put cursor in column 1.
           beq  NoCR
           lda  #$8D
           jsr  cout

NoCR       anop

           pla                          Get calling entry's address.
           sta  Address
           pla
           sta  Address+1
           pha                          Restore address to stack for Return.
           lda  Address
           pha

           sec                          Subtract 2 to give proper address.
           lda  Address
           sbc  #2
           sta  Address
           lda  Address+1
           sbc  #0
           sta  Address+1

           lda  Address+1               Print address
           jsr  PRByte
           lda  Address
           jsr  PRByte
           lda  #'-'+$80                Print '-'
           jsr  cout
           lda  #' '+$80                Print ' '
           jsr  cout
           lda  #'A'+$80                Print 'A'
           jsr  cout
           lda  #'='+$80                Print '='
           jsr  cout
           lda  AReg                    Get Accumulator value
           jsr  PRByte                  Print it.

           lda  #' '+$80                Print ' '
           jsr  cout
           lda  #'X'+$80                Print 'X'
           jsr  cout
           lda  #'='+$80                Print '='
           jsr  cout
           lda  XReg                    Get X Register
           jsr  PRByte                  Print it.

           lda  #' '+$80                Print ' '
           jsr  cout
           lda  #'Y'+$80                Print 'Y'
           jsr  cout
           lda  #'='+$80                PRint '='
           jsr  cout
           lda  YReg                    Get Y register
           jsr  PRByte                  Print it.

           lda  #$8D                    Print <cr>
           jsr  cout

           jsr  Pause                   Pause for key

           lda  PReg                    Get status register value in accumulator
           pha                          Push accumualtor onto stack.

           ldx  XReg                    Restore X register.
           ldy  YReg                    Restore Y register.
           lda  AReg                    Restore Accumulator.

           plp                          Restore status register.

           rts                          Return

           End
