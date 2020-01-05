## This file is a general .xdc for the CmodA7 rev. B for use with GRLIB
#

## Clock signal 12 MHz
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_14 Sch=gclk
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports {clk}];

# Test Clock Outputs
# PIO26, R3 in Bank 34, 3.3V
#set_property -dict { PACKAGE_PIN R3   IOSTANDARD LVCMOS33 } [get_ports { clko }];
#set_property -dict { PACKAGE_PIN T3   IOSTANDARD LVCMOS33 } [get_ports { clk2o }];

## UART
# DSU, second UART on FTDI Chip
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { RsRx }];
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { RsTx }];

## UART
# APBUART0, PIO1 RX, PIO2 TX
set_property -dict { PACKAGE_PIN M3   IOSTANDARD LVCMOS33 } [get_ports { rx1i }];
set_property -dict { PACKAGE_PIN L3   IOSTANDARD LVCMOS33 } [get_ports { tx1o }];

## Buttons, active high
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { btnCpuReset }]; #IO_L19N_T3_VREF_16 Sch=btn[0]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L19P_T3_16 Sch=btn[1]

## LEDs
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L12N_T1_MRCC_16 Sch=led[1]
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_L13P_T2_MRCC_16 Sch=led[2]

#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports { led0_b }]; #IO_L14N_T2_SRCC_16 Sch=led0_b
#set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports { led0_g }]; #IO_L13N_T2_MRCC_16 Sch=led0_g
#set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { led0_r }]; #IO_L14P_T2_SRCC_16 Sch=led0_r

## QSPI
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { QspiCSn    }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_cs
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { QspiDB[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { QspiDB[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { QspiDB[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { QspiDB[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]

## SRAM asynch I/F
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { address[0]  }]; #IO_L11P_T1_SRCC_14 Sch=sram- a[0]
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { address[1]  }]; #IO_L11N_T1_SRCC_14 Sch=sram- a[1]
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { address[2]  }]; #IO_L12N_T1_MRCC_14 Sch=sram- a[2]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { address[3]  }]; #IO_L13P_T2_MRCC_14 Sch=sram- a[3]
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { address[4]  }]; #IO_L13N_T2_MRCC_14 Sch=sram- a[4]
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { address[5]  }]; #IO_L14P_T2_SRCC_14 Sch=sram- a[5]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { address[6]  }]; #IO_L14N_T2_SRCC_14 Sch=sram- a[6]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { address[7]  }]; #IO_L16N_T2_A15_D31_14 Sch=sram- a[7]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { address[8]  }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=sram- a[8]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports { address[9]  }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=sram- a[9]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { address[10] }]; #IO_L16P_T2_CSI_B_14 Sch=sram- a[10]
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { address[11] }]; #IO_L17P_T2_A14_D30_14 Sch=sram- a[11]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { address[12] }]; #IO_L17N_T2_A13_D29_14 Sch=sram- a[12]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { address[13] }]; #IO_L18P_T2_A12_D28_14 Sch=sram- a[13]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { address[14] }]; #IO_L18N_T2_A11_D27_14 Sch=sram- a[14]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { address[15] }]; #IO_L19P_T3_A10_D26_14 Sch=sram- a[15]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { address[16] }]; #IO_L20P_T3_A08_D24_14 Sch=sram- a[16]
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports { address[17] }]; #IO_L20N_T3_A07_D23_14 Sch=sram- a[17]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { address[18] }]; #IO_L21P_T3_DQS_14 Sch=sram- a[18]
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { data[0]   }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=sram-dq[0]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { data[1]   }]; #IO_L22P_T3_A05_D21_14 Sch=sram-dq[1]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { data[2]   }]; #IO_L22N_T3_A04_D20_14 Sch=sram-dq[2]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { data[3]   }]; #IO_L23P_T3_A03_D19_14 Sch=sram-dq[3]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { data[4]   }]; #IO_L23N_T3_A02_D18_14 Sch=sram-dq[4]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { data[5]   }]; #IO_L24P_T3_A01_D17_14 Sch=sram-dq[5]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { data[6]   }]; #IO_L24N_T3_A00_D16_14 Sch=sram-dq[6]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { data[7]   }]; #IO_25_14 Sch=sram-dq[7]
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { RamOE     }]; #IO_L10P_T1_D14_14 Sch=sram-oe
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { RamWE     }]; #IO_L10N_T1_D15_14 Sch=sram-we
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports { RamCE     }]; #IO_L9N_T1_DQS_D13_14 Sch=sram-ce
