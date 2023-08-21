Main       Start

*          M a i n

           ldx  #$FF
           txs                          Reset stack

           jsr  SystemCheck
           bcs  Exit

           jsr  Initialize

           jsr  Menu1

           jsr  Cleanup

Exit       anop

           jmp  MLIQuit

           End
