;                  Printer Off
;           AbsAddr On
;           65C02   On
;           Symbol  Off
;           InsTime Off

;*********************************************
;                                            *
;          Program : DiskMaker 8             *
;          Author  : Mark Percival           *
;          Date    : January 2006            *
;          Version : 1.1                     *
;                                            *
;*********************************************

;           Keep  DiskMaker8

;           List Off

;          Global Constants

           .include "ORCA2ca65.s"
           .include "GlobalConst.s"

;          Main Line
           .include "Main.s"

           .include "Initialize.s"
           .include "Ram.In.Out.s"
           .include "SystemCheck.s"
           .include "Background.s"

           .include "Cleanup.s"

;          Menu1

           .include "Menu1.s"
;             .include "Menu1a.s"
;             .include "Menu1b.s"
;             .include "Menu1Vars.s"
           .include "Menu1UI.s"

           .include "PaintMenu1.s"
           .include "PrtFileName.s"
           .include "LoadDirectory.s"
           .include "FileTypes.s"
           .include "PathDDL.s"

;          Menu2

           .include "Menu2.s"
           .include "SetImageType.s"
           .include "PaintMenu2.s"
           .include "LoadDevs.s"
           .include "ImageTypeBox.s"
           .include "SameSize.s"
           .include "Menu2UI.s"
           .include "About.s"

;          Making the disk image

           .include "ProcessImage.s"
;             .include "ProcessImage1.s"
;             .include "ProcessImage2.s"
           .include "Hyperformat.s"

;          Standard MLI Calls

           .include "MLIOnLine.s"
           .include "MLIGetPrefix.s"
           .include "MLISetPrefix.s"
           .include "MLIOpen1.s"
           .include "MLISetMark.s"
           .include "MLIRead.s"
           .include "MLIRead4K.s"
           .include "MLIWriteBlock.s"
           .include "MLIGetEOF.s"
           .include "MLIClose.s"
           .include "MLIQuit.s"
           .include "MLIError.s"

;          Utility Routines

;          .include "Pause.s"
           .include "Beep.s"
           .include "MessageBox.s"
;             .include "MessageBox1.s"
;             .include "MessageBox2.s"
           .include "Divide16Bit.s"
           .include "COUT.s"

;          Mouse Routines

           .include "Mouse.s"
           .include "ProcessMouse.s"

;          Global Variable Data

           .include "GlobalVars.s"
           .include "Menu1Vars.s"
           .include "Menu2Vars.s"
