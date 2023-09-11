DiskMaker 8
===========

Formerly shareware, now freeware - DiskMaker 8 creates disks from images and images from disks on Apple II computers with the 65C02 (or greater) CPU.

The original v1.1 can be built using either the [ORCA 4.1 assembler](https://juiced.gs/store/opus-ii-software/) or the
[ca65 assembler](https://cc65.github.io/) which is part of the cc65 toolchain.
The [releases](https://github.com/mark-percival/DiskMaker8/releases) page includes bootable, pre-built disk images with DiskMaker 8 on them.

## Program Features

 - GSOS File Manager like user interface allowing user to easily navigate through volumes/directories.
 - Optional Apple mouse support for instant ease of use.
 - Multiple image format conversion capability including:
   - DOS Order (.dsk)
   - ProDOS Order (.po, .hdv)
   - Universal Disk Image (.2mg)
   - DiskCopy 4.2
   - DiskCopy 6
- Supports AppleShare volumes for retrieving image files.
 - Fully supports Disk ][ and SmartPort block devices for writing images.
 - Automatically tells you which devices attached to your system matches the size of the disk image you selected.
 - The ability to override the size matching destination feature allowing you to use mismatching volume sizes such as slot based RAM disks.
 - Automatically formats the destination disk if required.
 - Supports DOS 3.3 volume numbers.
 - Optionally boots directly to your new disk.

## System Requirements

 - A 128K Enhanced Apple IIe, Apple IIc, Apple IIc plus or Apple IIgs.
 - ProDOS 8 v 1.9 or later.
 - At least two ProDOS 8 compatible storage devices for source and target. The source needs to be large enough to contain the disk image for target.

## Version History

### 19 Aug. 2004 - Developer Release 1
Early version that only had the file selection screen implemented, keyboard navigation only.  I sent this to a few friends for feedback.

### 30 Aug. 2004 - Developer Release 2
Same as Dev 1 but by this time I had implemented the mouse interface.

### 10 March 2005 - Developer Release 3
About 90% of the functionality done by this point. Quite a few ways to make it crash but it could create disks.

### 18 March 2005 - Beta 1
A week later I had fixed (what I thought were) my last bugs, removed debugging code and sent it to my beta testers.

### 23 March 2005 - Beta 2
The bug reports came fast and furious and only 5 days later I put out a second beta.

### 23 April 2005 - Beta 3
Sent to only one of my beta testers who found a bug in the 5.25" disk formatting routine.

### 9 Nov. 2005 - Beta 4
Starting to ramp up to my first public release.  Squished a few more bugs.

### 20 Nov. 2005 - Pre-Release version
Added the proper "About" screen and introduced a nasty bug in the process.  Also added a custom screen character printing routine which greatly improved performance.

### 3 Dec. 2005 - Version 1.0
First public release.

### 25 Jan. 2006 - Version 1.1
Major difference was replacing the standard 5.25" disk formatting routine with the quick Hyperformat by Jerry Hewett. 
You can now boot your new disk if you created it in drive 1.  Full support for DOS 3.3 volume numbers.
A few more minor bugs were killed.

