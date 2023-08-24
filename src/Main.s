.segment "CODE"
.org $2000

Main:

;          M a i n

           ldx  #$FF
           txs                        ; Reset stack

           jsr  SystemCheck
           bcs  Exit

           jsr  Initialize

           jsr  Menu1

           jsr  Cleanup

Exit:

           jmp  MLIQuit
