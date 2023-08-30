
.PHONY: all
all:
	cd src ; \
	ca65 --cpu 65C02 DiskMaker8.s -l ../DiskMaker8.lst ; \
	ld65 -o ../DiskMaker8 DiskMaker8.o -m ../DiskMaker8.map -C DiskMaker8.cfg

clean:
	-rm src/*.o
	-rm *.lst
	-rm *.map
	-rm DiskMaker8
