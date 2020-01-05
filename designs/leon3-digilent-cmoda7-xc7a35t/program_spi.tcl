# vivado -mode batch -source program_spi.tcl

# cmod a7 35t 
#

open_hw
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets]
open_hw_target

set my_mem_device [lindex [get_cfgmem_parts {n25q32-3.3v-spi-x1_x2_x4}] 0]
set programming_files {combined_prom.bin}
set my_hw_cfgmem [create_hw_cfgmem -hw_device [lindex [get_hw_devices] 0] -mem_dev $my_mem_device]

set_property PROGRAM.ADDRESS_RANGE {use_file} $my_hw_cfgmem
set_property PROGRAM.FILES $programming_files $my_hw_cfgmem
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} $my_hw_cfgmem

program_hw_devices [lindex [get_hw_devices] 0]

set_property PROGRAM.BLANK_CHECK 0 $my_hw_cfgmem
set_property PROGRAM.ERASE 1 $my_hw_cfgmem
set_property PROGRAM.CFG_PROGRAM 1 $my_hw_cfgmem
set_property PROGRAM.VERIFY 1 $my_hw_cfgmem

program_hw_cfgmem -hw_cfgmem $my_hw_cfgmem
