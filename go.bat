@REM
@REM Build for DiskMaker8 under Windows
@REM
@REM Requires:
@REM  * cc65 toolchain in the path
@REM  * AppleCommander (command line version) in the path
cd src

@REM Build it all
ca65 --cpu 65C02 DiskMaker8.s -l ..\DiskMaker8.lst

@REM Link it up
ld65 -o ..\DiskMaker8 DiskMaker8.o -m ..\DiskMaker8.map -C DiskMaker8.cfg
cd ..

@REM Put it on disk images
copy DiskMaker8Base.dsk DiskMaker8.dsk
copy DiskMaker8Base.po DiskMaker8.po
type DiskMaker8 | ac -p DiskMaker8.dsk DiskMaker8 SYS 0x2000
type DiskMaker8 | ac -p DiskMaker8.po DiskMaker8 SYS 0x2000
