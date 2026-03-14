.PHONY: build build-supermini flash flash-supermini stop stop-supermini

build:
	. ~/export-esp.sh && cargo +esp build-devkit

build-supermini:
	. ~/export-esp.sh && cargo +esp build-supermini

flash:
	. ~/export-esp.sh && cargo +esp run-devkit

flash-supermini:
	. ~/export-esp.sh && cargo +esp run-supermini

stop:
	espflash erase-flash -p /dev/ttyUSB0

stop-supermini:
	espflash erase-flash -p /dev/ttyACM0
