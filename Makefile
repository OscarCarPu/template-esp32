.PHONY: build flash stop

build:
	. ~/export-esp.sh && cargo +esp build-devkit

flash:
	. ~/export-esp.sh && cargo +esp run-devkit

stop:
	espflash erase-flash -p /dev/ttyUSB0
