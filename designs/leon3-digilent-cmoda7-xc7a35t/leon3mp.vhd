------------------------------------------------------------------------------
--  LEON3 Demonstration design
--  Copyright (C) 2013 Aeroflex Gaisler
------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2014, Aeroflex Gaisler
--  Copyright (C) 2015 - 2019, Cobham Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
use techmap.allclkgen.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.spi.all;
use gaisler.net.all;
use gaisler.jtag.all;
--pragma translate_off
use gaisler.sim.all;
library unisim;
use unisim.BUFG;
use unisim.MMCME2_BASE;
use unisim.STARTUPE2;
use unisim.vcomponents.all;
--pragma translate_on
library unisim;
use unisim.vcomponents.all;
library esa;
use esa.memoryctrl.all;
use work.config.all;

entity leon3mp is
  generic (
    fabtech  : integer := CFG_FABTECH;
    memtech  : integer := CFG_MEMTECH;
    padtech  : integer := CFG_PADTECH;
    clktech  : integer := CFG_CLKTECH;
    disas    : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart  : integer := CFG_DUART;     -- Print UART on console
    pclow    : integer := CFG_PCLOW
    );
  port (
    -- SRAM Interface
    RamOE           : out   std_ulogic;
    RamWE           : out   std_ulogic;
    RamCE           : out   std_ulogic;
    address         : out   std_logic_vector(18 downto 0);
    data            : inout std_logic_vector(7 downto 0);

    -- SPI NOR Flash Interface
    QspiCSn         : out   std_ulogic;
    QspiDB          : inout std_logic_vector(3 downto 0);

    -- Buttons & LEDs
    btnCpuReset     : in    std_ulogic;
    btn             : in    std_logic_vector(0 downto 0);
    led             : out   std_logic_vector(1 downto 0);

    -- 12 pin connectors
    --ja              : inout std_logic_vector(7 downto 0);

    -- DSU UART interface
    RsRx            : in    std_logic;
    RsTx            : out   std_logic;

    -- UART interface
    rx1i            : in    std_logic;
    tx1o            : out   std_logic;

    clk             : in    std_ulogic
  );
end;

architecture rtl of leon3mp is

 component STARTUPE2
 generic (
    PROG_USR : string := "FALSE";
    SIM_CCLK_FREQ : real := 0.0
  );
  port (
    CFGCLK               : out std_ulogic;
    CFGMCLK              : out std_ulogic;
    EOS                  : out std_ulogic;
    PREQ                 : out std_ulogic;
    CLK                  : in std_ulogic;
    GSR                  : in std_ulogic;
    GTS                  : in std_ulogic;
    KEYCLEARB            : in std_ulogic;
    PACK                 : in std_ulogic;
    USRCCLKO             : in std_ulogic;
    USRCCLKTS            : in std_ulogic;
    USRDONEO             : in std_ulogic;
    USRDONETS            : in std_ulogic );
  end component;

  component BUFG
  port (
    O : out std_logic;
    I : in std_logic);
  end component;

  signal CLKFBOUT      : std_logic;
  signal CLKFBIN       : std_logic;

  signal vcc : std_logic;
  signal gnd : std_logic;

  signal memi : memory_in_type;
  signal memo : memory_out_type;
  signal wpo  : wprot_out_type;

  signal gpioi : gpio_in_type;
  signal gpioo : gpio_out_type;

  signal apbi  : apb_slv_in_type;
  signal apbo  : apb_slv_out_vector := (others => apb_none);
  signal ahbsi : ahb_slv_in_type;
  signal ahbso : ahb_slv_out_vector := (others => ahbs_none);
  signal ahbmi : ahb_mst_in_type;
  signal ahbmo : ahb_mst_out_vector := (others => ahbm_none);

  signal u1i, dui : uart_in_type;
  signal u1o, duo : uart_out_type;

  signal irqi : irq_in_vector(0 to CFG_NCPU-1);
  signal irqo : irq_out_vector(0 to CFG_NCPU-1);

  signal dbgi : l3_debug_in_vector(0 to CFG_NCPU-1);
  signal dbgo : l3_debug_out_vector(0 to CFG_NCPU-1);

  signal dsui : dsu_in_type;
  signal dsuo : dsu_out_type;
  signal ndsuact : std_ulogic;

  signal ethi : eth_in_type;
  signal etho : eth_out_type;

  signal gpti : gptimer_in_type;

  signal spii : spi_in_type;
  signal spio : spi_out_type;
  signal slvsel : std_logic_vector(CFG_SPICTRL_SLVS-1 downto 0);

  signal spmi : spimctrl_in_type;
  signal spmo : spimctrl_out_type;

  signal clkm, clkml, clkm_fb  : std_ulogic;
  signal tck, tms, tdi, tdo : std_ulogic;
  signal lock               : std_logic;

  -- RS232 APB Uart
  signal rxd1 : std_logic;
  signal txd1 : std_logic;

  attribute keep                     : boolean;
  attribute syn_keep                 : boolean;
  attribute syn_preserve             : boolean;
  attribute syn_keep of lock         : signal is true;
  attribute syn_keep of clkml        : signal is true;
  attribute syn_keep of clkm         : signal is true;
  attribute syn_preserve of clkml    : signal is true;
  attribute syn_preserve of clkm     : signal is true;
  attribute keep of lock             : signal is true;
  attribute keep of clkml            : signal is true;
  attribute keep of clkm             : signal is true;

  constant BOARD_FREQ : integer := 12000;   -- CLK input frequency in KHz
  constant CPU_FREQ   : integer := 75000;   -- cpu frequency in KHz

  signal reset_sr : std_logic_vector(5 downto 0) := (others => '0');
  signal reset_cnt : integer range 0 to 150_000 := 0;
  signal rstn : std_ulogic := '0';

begin
  vcc <= '1';
  gnd <= '0';

----------------------------------------------------------------------
---  Reset and Clock generation  -------------------------------------
----------------------------------------------------------------------
  resetgen: process(clkm) begin
    if rising_edge(clkm) then
      -- using synchronize reset input
      reset_sr <= reset_sr(reset_sr'length - 2 downto 0) & (lock and (not btnCpuReset));

      -- shakey reset, to emulate bouncy switch contects ..
      if (reset_sr(reset_sr'length - 1) = '1') then
        if (reset_cnt < 150_000) then
          reset_cnt <= reset_cnt + 1;
        end if;
        if (reset_cnt = 100_000) then
          rstn <= '1';
        end if;
        if (reset_cnt = 101_000) then
          rstn <= '0';
        end if;
        if (reset_cnt = 150_000) then
          rstn <= '1';
        end if;
      else
        reset_cnt <= 0;
        rstn <= '0';
      end if;
    end if;
  end process;

  clk_gen_mmcm: unisim.vcomponents.MMCME2_BASE
       generic map (
          STARTUP_WAIT         => FALSE,
          DIVCLK_DIVIDE        => 1,
          CLKFBOUT_MULT_F      => 50.0,
          CLKFBOUT_PHASE       => 0.000,
          CLKOUT0_DIVIDE_F     => 8.0,
          CLKOUT0_PHASE        => 0.000,
          CLKOUT0_DUTY_CYCLE   => 0.500,
          CLKIN1_PERIOD        => 83.33,
          REF_JITTER1          => 0.0)
       port map (
          CLKFBOUT            => clkm_fb,
          CLKOUT0             => clkm,
          CLKFBIN             => clkm_fb,
          CLKIN1              => clk,
          LOCKED              => lock,
          PWRDWN              => '0',
          RST                 => '0');

----------------------------------------------------------------------
---  AHB CONTROLLER --------------------------------------------------
----------------------------------------------------------------------
  ahb0 : ahbctrl
    generic map (defmast => CFG_DEFMST, split => CFG_SPLIT,
                 rrobin  => CFG_RROBIN, ioaddr => CFG_AHBIO, ioen => 1,
                 nahbm => CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+CFG_GRETH,
                 nahbs => 8)
    port map (rstn, clkm, ahbmi, ahbmo, ahbsi, ahbso);

----------------------------------------------------------------------
---  LEON3 processor and DSU -----------------------------------------
----------------------------------------------------------------------
  -- LEON3 processor
  leon3gen : if CFG_LEON3 = 1 generate
    cpu : for i in 0 to CFG_NCPU-1 generate
      u0 : leon3s
        generic map (i, fabtech, memtech, CFG_NWIN, CFG_DSU, CFG_FPU, CFG_V8,
                     0, CFG_MAC, pclow, CFG_NOTAG, CFG_NWP, CFG_ICEN, CFG_IREPL, CFG_ISETS, CFG_ILINE,
                     CFG_ISETSZ, CFG_ILOCK, CFG_DCEN, CFG_DREPL, CFG_DSETS, CFG_DLINE, CFG_DSETSZ,
                     CFG_DLOCK, CFG_DSNOOP, CFG_ILRAMEN, CFG_ILRAMSZ, CFG_ILRAMADDR, CFG_DLRAMEN,
                     CFG_DLRAMSZ, CFG_DLRAMADDR, CFG_MMUEN, CFG_ITLBNUM, CFG_DTLBNUM, CFG_TLB_TYPE, CFG_TLB_REP,
                     CFG_LDDEL, disas, CFG_ITBSZ, CFG_PWD, CFG_SVT, CFG_RSTADDR,
                     CFG_NCPU-1, CFG_DFIXED, CFG_SCAN, CFG_MMU_PAGE, CFG_BP, CFG_NP_ASI, CFG_WRPSR)
        port map (clkm, rstn, ahbmi, ahbmo(i), ahbsi, ahbso, irqi(i), irqo(i), dbgi(i), dbgo(i));
    end generate;

    -- LEON3 Debug Support Unit
    dsugen : if CFG_DSU = 1 generate
      dsu0 : dsu3
        generic map (hindex => 2, haddr => 16#900#, hmask => 16#F00#, ahbpf => CFG_AHBPF,
                     ncpu   => CFG_NCPU, tbits => 30, tech => memtech, irq => 0, kbytes => CFG_ATBSZ)
        port map (rstn, clkm, ahbmi, ahbsi, ahbso(2), dbgo, dbgi, dsui, dsuo);

      dsui.enable <= '1';

    end generate;
  end generate;
  nodsu : if CFG_DSU = 0 generate
    ahbso(2) <= ahbs_none; dsuo.tstop <= '0'; dsuo.active <= '0';
  end generate;

  -- Debug UART
  dcomgen : if CFG_AHB_UART = 1 generate
    dcom0 : ahbuart
      generic map (hindex => CFG_NCPU, pindex => 4, paddr => 7)
      port map (rstn, clkm, dui, duo, apbi, apbo(4), ahbmi, ahbmo(CFG_NCPU));
    dsurx_pad : inpad generic map (tech  => padtech) port map (RsRx, dui.rxd);
    dsutx_pad : outpad generic map (tech => padtech) port map (RsTx, duo.txd);
    led(0) <= not dui.rxd;
    led(1) <= not duo.txd;
  end generate;
  nouah : if CFG_AHB_UART = 0 generate apbo(4) <= apb_none; end generate;

  ahbjtaggen0 :if CFG_AHB_JTAG = 1 generate
    ahbjtag0 : ahbjtag generic map(tech => fabtech, hindex => CFG_NCPU+CFG_AHB_UART)
      port map(rstn, clkm, tck, tms, tdi, tdo, ahbmi, ahbmo(CFG_NCPU+CFG_AHB_UART),
               open, open, open, open, open, open, open, gnd);
  end generate;

----------------------------------------------------------------------
---  Memory controllers ----------------------------------------------
----------------------------------------------------------------------
  mg2 : if CFG_MCTRL_LEON2 = 1 generate        -- LEON2 memory controller
    sr1 : mctrl generic map (hindex => 5, pindex => 0, paddr => 0, rommask => 0,
        iomask => 0, ram8 => CFG_MCTRL_RAM8BIT, ram16 => CFG_MCTRL_RAM16BIT,srbanks=>1)
      port map (rstn, clkm, memi, memo, ahbsi, ahbso(5), apbi, apbo(0), wpo, open);
  end generate;

  memi.brdyn  <= '1';
  memi.bexcn  <= '1';
  memi.writen <= '1';
  memi.wrn    <= "1111";
  memi.bwidth <= "01";

  mg0 : if (CFG_MCTRL_LEON2 = 0) generate
    apbo(0) <= apb_none;
    ahbso(5) <= ahbs_none;
    memo.bdrive(0) <= '1';
  end generate;

  mgpads : if (CFG_MCTRL_LEON2 /= 0) generate
    addr_pad : outpadv generic map (tech => padtech, width => 19)
      port map (address, memo.address(18 downto 0));
    oen_pad : outpad generic map (tech => padtech)
      port map (RamOE, memo.oen);
    cs_pad : outpad generic map (tech => padtech)
      port map (RamCE, memo.ramsn(0));
    we_pad : outpad generic map (tech => padtech)
      port map (RamWE, memo.writen);
  end generate;

  bdr : iopadv generic map (tech => padtech, width => 8)
    port map (data(7 downto 0), memo.data(31 downto 24),
              memo.bdrive(0), memi.data(31 downto 24));

----------------------------------------------------------------------
---  SPI Memory controller -------------------------------------------
----------------------------------------------------------------------
  -- The first ~2.2MB are used for loading the FPGA.
  -- Offset: 0x220000
  spimctrl1 : spimctrl
  generic map (hindex => 7, hirq => 7,
    faddr => 16#000#, fmask => 16#ffc#,
    ioaddr => 16#700#, iomask => 16#fff#,
    spliten => CFG_SPLIT, sdcard => 0, readcmd => 16#0B#,
    dummybyte => 1, dualoutput => 0,
    scaler => 3, altscaler => 3, offset=>16#220000#)
  port map (rstn, clkm, ahbsi, ahbso(7), spmi, spmo);

  spi_mosi_pad : outpad generic map (tech => padtech)
    port map (QspiDB(0), spmo.mosi);
  spi_miso_pad : inpad generic map (tech => padtech)
    port map (QspiDB(1), spmi.miso);
  spi_QspiDB_2_pad : outpad generic map (tech => padtech)
    port map (QspiDB(2), '1');
  spi_QspiDB_3_pad : outpad generic map (tech => padtech)
    port map (QspiDB(3), '1');
  spi_slvsel0_pad : outpad generic map (tech => padtech)
    port map (QspiCSn, spmo.csn);

  -- MACRO for assigning the SPI output clock
  spicclk: STARTUPE2
  port map (--CFGCLK => open, CFGMCLK => open, EOS => open, PREQ => open,
    CLK => '0', GSR => '0', GTS => '0', KEYCLEARB => '0', PACK => '0',
    USRCCLKO =>  spmo.sck, USRCCLKTS => '0', USRDONEO => '1', USRDONETS => '0' );

----------------------------------------------------------------------
---  APB Bridge and various periherals -------------------------------
----------------------------------------------------------------------
  -- APB Bridge
  apb0 : apbctrl
    generic map (hindex => 1, haddr => CFG_APBADDR)
    port map (rstn, clkm, ahbsi, ahbso(1), apbi, apbo);

  -- Interrupt controller
  irqctrl : if CFG_IRQ3_ENABLE /= 0 generate
    irqctrl0 : irqmp
      generic map (pindex => 2, paddr => 2, ncpu => CFG_NCPU)
      port map (rstn, clkm, apbi, apbo(2), irqo, irqi);
  end generate;
  irq3 : if CFG_IRQ3_ENABLE = 0 generate
    x : for i in 0 to CFG_NCPU-1 generate
      irqi(i).irl <= "0000";
    end generate;
    apbo(2) <= apb_none;
  end generate;

  -- Time Unit
  gpt : if CFG_GPT_ENABLE /= 0 generate
    timer0 : gptimer
      generic map (pindex => 3, paddr => 3, pirq => CFG_GPT_IRQ,
                   sepirq => CFG_GPT_SEPIRQ, sbits => CFG_GPT_SW,
                   ntimers => CFG_GPT_NTIM, nbits  => CFG_GPT_TW)
      port map (rstn, clkm, apbi, apbo(3), gpti, open);
    gpti <= gpti_dhalt_drive(dsuo.tstop);
  end generate;
  notim : if CFG_GPT_ENABLE = 0 generate apbo(3) <= apb_none; end generate;

  ua1 : if CFG_UART1_ENABLE /= 0 generate
    uart1 : apbuart                     -- UART 1
      generic map (pindex   => 1, paddr => 1, pirq => 2, console => dbguart, fifosize => CFG_UART1_FIFO)
      port map (rstn, clkm, apbi, apbo(1), u1i, u1o);
    u1i.rxd    <= rxd1;
    u1i.ctsn   <= '0';
    u1i.extclk <= '0';
    txd1       <= u1o.txd;
    serrx_pad : inpad generic map (tech  => padtech) port map (rx1i, rxd1);
    sertx_pad : outpad generic map (tech => padtech) port map (tx1o, txd1);
  end generate;
  noua0 : if CFG_UART1_ENABLE = 0 generate apbo(1) <= apb_none; end generate;

  nospi: if CFG_SPICTRL_ENABLE = 0 and CFG_SPIMCTRL = 0 generate
    apbo(7) <= apb_none;
  end generate;

-----------------------------------------------------------------------
---  AHB ROM ----------------------------------------------------------
-----------------------------------------------------------------------
ahbso(6) <= ahbs_none;

-----------------------------------------------------------------------
---  AHB RAM ----------------------------------------------------------
-----------------------------------------------------------------------
  ahbramgen : if CFG_AHBRAMEN = 1 generate
    ahbram0 : ahbram
      generic map (hindex => 3, haddr => CFG_AHBRADDR, tech => CFG_MEMTECH,
                   kbytes => CFG_AHBRSZ, pipe => CFG_AHBRPIPE)
      port map (rstn, clkm, ahbsi, ahbso(3));
  end generate;
  nram : if CFG_AHBRAMEN = 0 generate ahbso(3) <= ahbs_none; end generate;

-----------------------------------------------------------------------
--  Test report module, only used for simulation ----------------------
-----------------------------------------------------------------------
--pragma translate_off
  test0 : ahbrep generic map (hindex => 4, haddr => 16#200#)
    port map (rstn, clkm, ahbsi, ahbso(4));
--pragma translate_on

-----------------------------------------------------------------------
---  Drive unused bus elements  ---------------------------------------
-----------------------------------------------------------------------
  nam1 : for i in (CFG_NCPU+CFG_AHB_UART+CFG_AHB_JTAG+1) to NAHBMST-1 generate
    ahbmo(i) <= ahbm_none;
  end generate;

-----------------------------------------------------------------------
---  Boot message  ----------------------------------------------------
-----------------------------------------------------------------------
-- pragma translate_off
  x : report_design
    generic map (
      msg1 => "LEON3 Demonstration design for Digilent CMOD-A7 35T board",
      fabtech => tech_table(fabtech), memtech => tech_table(memtech),
      mdel => 1
      );
-- pragma translate_on

end rtl;
