include .config

GRLIB=../..
TOP=leon3mp
BOARD=digilent-cmoda7-xc7a35t
DESIGN=leon3-digilent-cmoda7-xc7a35t
include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
#UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
UCF=$(TOP).ucf
UCF_PLANAHEAD=$(UCF)
XDC=$(TOP).xdc
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=high
XSTOPT=-uc leon3mp.xcf
SYNPOPT="set_option -pipe 1; set_option -retiming 1; set_option -write_apr_constraint 0"

VHDLSYNFILES=config.vhd ahbrom.vhd leon3mp.vhd

VHDLSIMFILES=testbench.vhd
SIMTOP=testbench
#SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
FDCFILE=$(GRLIB)/boards/$(BOARD)/default.fdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean

TECHLIBS = unisim

LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip ihp usbhc spw
DIRSKIP = b1553 pci/pcif leon2 leon2ft crypto satcan pci leon3ft ambatest can \
	usb grusbhc spacewire ascs slink hcan \
	leon4v0 l2cache pwm gr1553b iommu
FILESKIP = grcan.vhd

include $(GRLIB)/bin/Makefile
include $(GRLIB)/software/leon3/Makefile


##################  project specific targets ##########################

hello.elf: ../../software/leon3/hello.c
	sparc-gaisler-elf-gcc  ../../software/leon3/hello.c -o hello.elf

prom.bin: hello.elf
	/opt/mkprom2/mkprom2 -leon3 -freq 75 -ramsize 512 -ramwidth 8 -ramws 1 -baud 38400 -msoft-float -v hello.elf -o prom.out
	sparc-gaisler-elf-objcopy -S -O binary prom.out prom.bin
	rm -f prom.out

combined_prom.bin: prom.bin leon3mp.bit
	vivado -mode batch -source vivado_build_prom.tcl

vivado-prog-flash: combined_prom.bin
	vivado -mode batch -source vivado_program_spi.tcl

clean-local:
	rm -f hello.elf
	rm -f prom.bin
	rm -f main.bin
	rm -f combined_prom.bin
