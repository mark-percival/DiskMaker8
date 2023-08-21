Initialize Start

           jsr  RamOut                  Remove slot 3, drive 2 /RAM drive

           jsr  FindMouse               See if Apple mouse card installed

           lda  #$01                    Mouse mode enabled, no interrupts
           jsr  SetMouse

           jsr  InitMouse

           stz  LowClamp                Set X axis
           stz  LowClamp+1              0 low value for x axis
           lda  #79
           sta  HighClamp               79 high value for x axis
           stz  HighClamp+1
           lda  #0
           asl  HighClamp               Multilpy high clamp by 2 to extend range
           jsr  ClampMouse              from 0-79 to 0-158 to aid mouse control.

           stz  LowClamp                Set Y axis
           stz  LowClamp+1              0 low value for y axis
           lda  #23
           sta  HighClamp               23 high value for y axiz
           stz  HighClamp+1
           lda  #1
           asl  HighClamp               Multiply high cmap by 2 to extend range
           jsr  ClampMouse              from 0-23 to 0-46 to aid mouse control.

           lda  #$01                    Mouse mode enabled, no interrupts
           jsr  SetMouse

           jsr  ReadMouse               Priming read
           lsr  MouseX                  Divide by 2 to return to the
           lsr  MouseY                  0 to 79, 0 to 23 range.

           jsr  SetBackGrnd             Set basic program background

           jsr  MLIGetPrefix            Get default prefix

           jsr  Network                 See if network volumes are present.

           lda  Entries
           sta  NetDevCnt
           beq  NoNetwork

           jsr  NetUnitNo

NoNetwork  anop

           rts

* Save Appleshare volume data

Network    lda  #$04                    Require at least ProDOS 8 1.4
           cmp  $BFFF                   KVERSION (ProDOS 8 version)
           beq  MoreNetwork             Have to check further
           lda  #$01                    Simulate bad command error
           bcs  Error                   If 3 or less, no possibility of network
           bcc  NetCall

MoreNetwork lda $BF02                   High byte of the MLI entry point
           and  #$0F                    Strip off the low nibble
           cmp  #$C0                    Is the entry point in the $Cn00 space?
           beq  NetCall                 Yes, so try AppleTalk
           lda  #$01
           sec
           bcs  Error                   Simulate bad command error

NetCall    jsr  $BF00                   ProDOS MLI
           dc   h'42'                   AppleTalk command number
           dc   a'ParamAddr'            Address of Parameter table
           bcs  Error

           rts

Error      stz  Entries

           rts

ParamAddr  dc   h'00'                   Async Flag (0 means synchronous only)
           dc   h'2F'                   command for FIListSessions
ResultCode dc   h'00 00'                AppleTalk result code returned here
           dc   i'448'                  Length of the buffer supplied
           dc   a'readBuf'              Low word of pointer to buffer
           dc   h'00 00'                high work of pointer to buffer
Entries    dc   h'00'                   Number of entries returned


NetUnitNo  anop

           ldx  #$00                    Number of entries to process
           ldy  #$01                    Unitno offset

           lda  #readBuf                Setup pointer to buffer.
           sta  Ptr1
           lda  #>readBuf+1
           sta  Ptr1+1

Loop1      lda  (Ptr1),y
           and  #$F0                    Keep only high nibble
           sta  NetDevs,x

           clc                          Move to next entry address.
           lda  Ptr1
           adc  #32                     32 byte entry length
           sta  Ptr1
           lda  Ptr1+1
           adc  #0
           sta  Ptr1+1

           inx
           cpx  Entries
           bcc  Loop1

           lda  #$00

Loop2      sta  NetDevs,x               Zero out remaining table entries.
           inx
           cpx  #15
           bcc  Loop2

           rts

           End
