Cleanup:

           lda  #0                    ; Turn mouse off.
           jsr  SetMouse

           jsr  RamIn                 ; Restore /RAM drive

           rts
