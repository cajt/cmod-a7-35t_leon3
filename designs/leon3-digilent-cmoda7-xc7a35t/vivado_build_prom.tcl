
write_cfgmem -format bin -interface SPIx1 -size 4 -loadbit "up 0x0 leon3mp.bit" -loaddata "up 0x220000 prom.bin" -force -file combined_prom.bin 
