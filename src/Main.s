Main:

;          M a i n

           ldx  #$FF
           txs                          ; Reset stack

           jsr  SystemCheck
           bcs  Main_Exit

           jsr  I_Initialize

           jsr  Menu1

           jsr  Cleanup

Main_Exit:

           jmp  MLIQuit


