
AC_JAR ?= lib/AppleCommander/AppleCommander-1.3.5.13-ac.jar

.PHONY: all
all:
	cd src ; \
	ca65 --cpu 65C02 DiskMaker8.s -l ../DiskMaker8.lst ; \
	ld65 -o ../DiskMaker8 DiskMaker8.o -m ../DiskMaker8.map -C DiskMaker8.cfg
	@cp DiskMaker8Base.dsk DiskMaker8.dsk
	@cp DiskMaker8Base.po DiskMaker8.po
	cat DiskMaker8 | java -jar ${AC_JAR} -p DiskMaker8.dsk DiskMaker8 SYS 0x2000
	cat DiskMaker8 | java -jar ${AC_JAR} -p DiskMaker8.po DiskMaker8 SYS 0x2000

clean:
	-rm src/*.o
	-rm *.lst
	-rm *.map
	-rm DiskMaker8
