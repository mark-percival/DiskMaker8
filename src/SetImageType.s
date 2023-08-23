;
; Set default disk image type
;

SetImgType:

; First check file type / auxtype
;
; $E0 / $0005 = DiskCopy 4.2
; $E0 / $0130 = Universal Disk Image
; $E0 / $0120 = DiskCopy 6
; $E0 / $0121 = ProDOS order image

           lda  #Type_PO              ; Default type
           sta  ImageType

           lda  FileType
           cmp  #$E0
           beq  Next00
           jmp  TryExtension

Next00:

           lda  AuxType+1             ; Check for DiskCopy 4.2 type
           bne  Next01
           lda  AuxType
           cmp  #$05
           bne  Next01

           lda  #Type_DC
           sta  ImageType
           jmp  TryExtension

Next01:

           lda  AuxType+1             ; Check for Universal Disk Image
           cmp  #$01
           bne  Next02
           lda  AuxType
           cmp  #$30
           bne  Next02

           lda  #Type_2IMG
           sta  ImageType
           jmp  TryExtension

Next02:

           lda  AuxType+1             ; Check for DiskCopy 6
           cmp  #$01
           bne  Next03
           lda  AuxType
           cmp  #$20
           bne  Next03

           lda  #Type_DC6
           sta  ImageType
           jmp  TryExtension

Next03:

           lda  AuxType+1             ; Check for ProDOS order image
           cmp  #$01
           bne  Next04
           lda  AuxType
           cmp  #$21
           bne  Next04

           lda  #Type_PO
           sta  ImageType
           jmp  TryExtension

Next04:

;
; Next check file extension.
;
; .dc, .img  = DiskCopy 4.2
; .dc6, .dmg = DiskCopy 6
; .2mg       = Universal Disk Image
; .po        = ProDOS Order Disk Image
; .do, .dsk  = DOS Order Disk Image

TryExtension:

           lda  Path
           sta  FileLen
           tax

@NextChar:

           lda  Path,x
           cmp  #'.'
           beq  FoundPeriod
           dex
           bne  @NextChar

           jmp  CheckHeader           ; Falls to here if no extension.

FoundPeriod:

           inx                        ; Move 1 past period
           stx  ExtStart
           cpx  FileLen
           bne  OkExt
           jmp  CheckHeader           ; Period at end of filename.

OkExt:

           sec
           lda  FileLen
           sbc  ExtStart
           inc  a
           sta  ExtLen
           cmp  #2                    ; An extension length of 2?
           bne  TryIMG

           ldx  ExtStart
           lda  Path,x
           cmp  #'D'
           bne  TryIMG
           inx
           lda  Path,x
           cmp  #'C'
           bne  TryIMG

           lda  #Type_DC
           sta  ImageType
           jmp  CheckHeader

TryIMG:

           lda  ExtLen
           cmp  #3                    ; An extension length of 2?
           bne  TryDC6

           ldx  ExtStart
           lda  Path,x
           cmp  #'I'
           bne  TryDC6
           inx
           lda  Path,x
           cmp  #'M'
           bne  TryDC6
           inx
           lda  Path,x
           cmp  #'G'
           bne  TryDC6

           lda  #Type_DC
           sta  ImageType
           jmp  CheckHeader

TryDC6:

           lda  ExtLen
           cmp  #3                    ; An extension length of 2?
           bne  TryDMG

           ldx  ExtStart
           lda  Path,x
           cmp  #'D'
           bne  TryDMG
           inx
           lda  Path,x
           cmp  #'C'
           bne  TryDMG
           inx
           lda  Path,x
           cmp  #'6'
           bne  TryDMG

           lda  #Type_DC6
           sta  ImageType
           jmp  CheckHeader

TryDMG:

           lda  ExtLen
           cmp  #3                    ; An extension length of 2?
           bne  Try2MG

           ldx  ExtStart
           lda  Path,x
           cmp  #'D'
           bne  Try2MG
           inx
           lda  Path,x
           cmp  #'M'
           bne  Try2MG
           inx
           lda  Path,x
           cmp  #'G'
           bne  Try2MG

           lda  #Type_DC6
           sta  ImageType
           jmp  CheckHeader

Try2MG:

           lda  ExtLen
           cmp  #3                    ; An extension length of 2?
           bne  TryPO

           ldx  ExtStart
           lda  Path,x
           cmp  #'2'
           bne  TryPO
           inx
           lda  Path,x
           cmp  #'M'
           bne  TryPO
           inx
           lda  Path,x
           cmp  #'G'
           bne  TryPO

           lda  #Type_2IMG
           sta  ImageType
           jmp  CheckHeader

TryPO:

           lda  ExtLen
           cmp  #2                    ; An extension length of 2?
           bne  TryDSK

           ldx  ExtStart
           lda  Path,x
           cmp  #'P'
           bne  TryDSK
           inx
           lda  Path,x
           cmp  #'O'
           bne  TryDSK

           lda  #Type_PO
           sta  ImageType
           jmp  CheckHeader


TryDSK:

           lda  ExtLen
           cmp  #3                    ; An extension length of 2?
           bne  TryDO

           ldx  ExtStart
           lda  Path,x
           cmp  #'D'
           bne  TryDO
           inx
           lda  Path,x
           cmp  #'S'
           bne  TryDO
           inx
           lda  Path,x
           cmp  #'K'
           bne  TryDO

           lda  #Type_DO
           sta  ImageType
           jmp  CheckHeader

TryDO:

           lda  ExtLen
           cmp  #2                    ; An extension length of 2?
           bne  TryUnk

           ldx  ExtStart
           lda  Path,x
           cmp  #'D'
           bne  TryUnk
           inx
           lda  Path,x
           cmp  #'O'
           bne  TryUnk

           lda  #Type_DO
           sta  ImageType
           jmp  CheckHeader

TryUnk:                               ; Unknown extension

CheckHeader:                          ; Check file header

           jsr  MLIOpen1

           lda  openRef1
           sta  readRef
           sta  closeRef

           lda  #4
           sta  readRequest
           stz  readRequest+1

           jsr  MLIRead

           jsr  MLIClose

Try2IMG:

           lda  readBuf
           cmp  #'2'
           bne  TryGMI2

           lda  readBuf+1
           cmp  #'I'
           bne  ExitRtn

           lda  readBuf+2
           cmp  #'M'
           bne  ExitRtn

           lda  readBuf+3
           cmp  #'G'
           bne  ExitRtn

           lda  #Type_2IMG
           sta  ImageType
           bra  ExitRtn

TryGMI2:

           lda  readBuf
           cmp  #'G'
           bne  ExitRtn

           lda  readBuf+1
           cmp  #'M'
           bne  ExitRtn

           lda  readBuf+2
           cmp  #'I'
           bne  ExitRtn

           lda  readBuf+3
           cmp  #'2'
           bne  ExitRtn

           lda  #Type_2IMG
           sta  ImageType

ExitRtn:

           rts

FileLen:   .byte   $00
ExtStart:  .byte   $00
ExtLen:    .byte   $00
