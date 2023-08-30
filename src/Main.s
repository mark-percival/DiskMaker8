.segment "CODE"
.org $2000

Main:

;          M a i n

           ldx  #$FF
           txs                        ; Reset stack

           jsr  SystemCheck
           bcs  MainExit

           jsr  Initialize

           jsr  Menu1

           jsr  Cleanup

MainExit:

           jmp  MLIQuit
