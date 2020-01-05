This LEON design is tailored to the Digilent CMOD A7 35T board
--------------------------------------------------------------

Simulation and synthesis
------------------------

The design currently supports synthesis with Xilinx Vivado (tested with 2019.1).

Program the FPGA:                      make vivado-prog-fpga
Program the PROM:                      make vivado-prog-flash
Synthesise and p&r with Xilinx Vivado: make vivado

Design specifics
----------------

* In order to connect through the DSU UART interface use the second UART of the FT2232H.

* System reset is mapped to BTN0

* The SRAM is accessed asynchronously and has an access time of 8ns.
  Waitstates can be set to minimum.

* The design uses SPIM, Instruction zero is taken from 0x220000. (shared with bitfile)

* The application UART0 is connected: PI01 RX (input FPGA), PIO2 TX (output FPGA)

* Booting from SPI Flash required a quirky workaround: The reset generator emulates
  bouncy reset switch and resets the system twice. (WTF!)

* Building the PROM also builds the a hello world application and wraps it with
  mkprom2 to be placed in the prom.

* Output from GRMON is:

user@box$../../../grmon-eval-3.1.2/linux/bin64/grmon -uart /dev/ttyUSB3 -baud 230400

  GRMON LEON debug monitor v3.1.2 64-bit eval version

  Copyright (C) 2019 Cobham Gaisler - All rights reserved.
  For latest updates, go to http://www.gaisler.com/
  Comments or bug-reports to support@gaisler.com

  using port /dev/ttyUSB3 @ 230400 baud
  GRLIB build version: 4241
  Detected frequency:  75.0 MHz

  Component                            Vendor
  LEON3 SPARC V8 Processor             Cobham Gaisler
  AHB Debug UART                       Cobham Gaisler
  AHB/APB Bridge                       Cobham Gaisler
  LEON3 Debug Support Unit             Cobham Gaisler
  LEON2 Memory Controller              European Space Agency
  SPI Memory Controller                Cobham Gaisler
  Generic UART                         Cobham Gaisler
  Multi-processor Interrupt Ctrl.      Cobham Gaisler
  Modular Timer Unit                   Cobham Gaisler

  Use command 'info sys' to print a detailed report of attached cores

grmon3> info sys
  cpu0      Cobham Gaisler  LEON3 SPARC V8 Processor
            AHB Master 0
  ahbuart0  Cobham Gaisler  AHB Debug UART
            AHB Master 1
            APB: 80000700 - 80000800
            Baudrate 230400, AHB frequency 75.00 MHz
  apbmst0   Cobham Gaisler  AHB/APB Bridge
            AHB: 80000000 - 80100000
  dsu0      Cobham Gaisler  LEON3 Debug Support Unit
            AHB: 90000000 - A0000000
            AHB trace: 128 lines, 32-bit bus
            CPU0:  win 8, itrace 128, V8 mul/div, lddel 1
                   stack pointer 0x4007fff0
                   icache 2 * 8 kB, 16 B/line
                   dcache 2 * 4 kB, 16 B/line
  mctrl0    European Space Agency  LEON2 Memory Controller
            AHB: 40000000 - 80000000
            APB: 80000000 - 80000100
            8-bit static ram: 1 * 512 kbyte @ 0x40000000
  spim0     Cobham Gaisler  SPI Memory Controller
            AHB: FFF70000 - FFF70100
            AHB: 00000000 - 00400000
            IRQ: 7
            SPI memory device read command: 0x0b
  uart0     Cobham Gaisler  Generic UART
            APB: 80000100 - 80000200
            IRQ: 2
            Baudrate 38422, FIFO debug mode available
  irqmp0    Cobham Gaisler  Multi-processor Interrupt Ctrl.
            APB: 80000200 - 80000300
  gptimer0  Cobham Gaisler  Modular Timer Unit
            APB: 80000300 - 80000400
            IRQ: 8
            8-bit scalar, 2 * 32-bit timers, divisor 75

grmon3> load hello.elf
  40000000 .text                     26.0kB /  26.0kB   [===============>] 100%
  40006830 .rodata                    128B              [===============>] 100%
  400068B0 .data                      1.2kB /   1.2kB   [===============>] 100%
  Total size: 27.33kB (255.56kbit/s)
  Entry point 0x40000000
  Image /home/user/projects/fpga_cmod_a7_grlib/grlib-gpl-2019.2-b4241/designs/leon3-digilent-cmoda7-xc7a35t/hello.elf loaded

grmon3> run
  Program exited normally.

grmon3> exit

Exiting GRMON
