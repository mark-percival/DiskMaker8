                  Printer Off
           AbsAddr On
           65C02   On
           Symbol  Off
           InsTime Off

**********************************************
*                                            *
*          Program : DiskMaker 8             *
*          Author  : Mark Percival           *
*          Date    : January 2006            *
*          Version : 1.1                     *
*                                            *
**********************************************

           Keep  DiskMaker8

           List Off

*          Global Variables

           Copy GlobalVars.s

*          Main Line
           Copy Main.s

           Copy Initialize.s
           Copy Ram.In.Out.s
           Copy SystemCheck.s
           Copy Background.s

           Copy Cleanup.s

*          Menu1

           Copy Menu1.s
           Copy Menu1Vars.s
           Copy Menu1UI.s

           Copy PaintMenu1.s
           Copy PrtFileName.s
           Copy LoadDirectory.s
           Copy FileTypes.s
           Copy PathDDL.s

*          Menu2

           Copy Menu2.s
           Copy Menu2Vars.s
           Copy SetImageType.s
           Copy PaintMenu2.s
           Copy LoadDevs.s
           Copy ImageTypeBox.s
           Copy SameSize.s
           Copy Menu2UI.s
           Copy About.s

*          Making the disk image

           Copy ProcessImage.s
           Copy Hyperformat.s

*          Standard MLI Calls

           Copy MLIOnLine.s
           Copy MLIGetPrefix.s
           Copy MLISetPrefix.s
           Copy MLIOpen1.s
           Copy MLISetMark.s
           Copy MLIRead.s
           Copy MLIRead4K.s
           Copy MLIWriteBlock.s
           Copy MLIGetEOF.s
           Copy MLIClose.s
           Copy MLIQuit.s
           Copy MLIError.s

*          Utility Routines

*          Copy Pause.s
           Copy Beep.s
           Copy MessageBox.s
           Copy Divide16Bit.s
           Copy COUT.s

*          Mouse Routines

           Copy Mouse.s
           Copy ProcessMouse.s
