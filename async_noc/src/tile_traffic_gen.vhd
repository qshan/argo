-------------------------------------------------------------------------------
-- Title      : tile
-- Project    : 
-------------------------------------------------------------------------------
-- File	      : fake_tile.vhd
-- Author     : Christoph Müller  <eit-cpm@zeffa.eit.lth.se>
-- Company    : 
-- Created    : 2014-01-16
-- Last update: 2014-02-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2014-01-16  1.0	eit-cpm Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_defs.all;
use work.ocp.all;
use work.noc_interface.all;
use work.tile_package.all;

entity tile is
  
  port (
    clk		: in  std_logic;
    reset	: in  std_logic;
    settings	: in  tile_settings;
    north_in_f	: in  channel_forward;
    north_in_b	: out channel_backward;
    east_in_f	: in  channel_forward;
    east_in_b	: out channel_backward;
    south_in_f	: in  channel_forward;
    south_in_b	: out channel_backward;
    west_in_f	: in  channel_forward;
    west_in_b	: out channel_backward;
    north_out_f : out channel_forward;
    north_out_b : in  channel_backward;
    east_out_f	: out channel_forward;
    east_out_b	: in  channel_backward;
    south_out_f : out channel_forward;
    south_out_b : in  channel_backward;
    west_out_f	: out channel_forward;
    west_out_b	: in  channel_backward);

end tile;

architecture traffic_generator_tile of tile is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component router
    port (
      preset	     : in  std_logic;
      north_in_f     : in  channel_forward;
      north_in_b     : out channel_backward;
      east_in_f	     : in  channel_forward;
      east_in_b	     : out channel_backward;
      south_in_f     : in  channel_forward;
      south_in_b     : out channel_backward;
      west_in_f	     : in  channel_forward;
      west_in_b	     : out channel_backward;
      resource_in_f  : in  channel_forward;
      resource_in_b  : out channel_backward;
      north_out_f    : out channel_forward;
      north_out_b    : in  channel_backward;
      east_out_f     : out channel_forward;
      east_out_b     : in  channel_backward;
      south_out_f    : out channel_forward;
      south_out_b    : in  channel_backward;
      west_out_f     : out channel_forward;
      west_out_b     : in  channel_backward;
      resource_out_f : out channel_forward;
      resource_out_b : in  channel_backward);
  end component;

  component nAdapter is
    port (
      -- General
      na_clk   : in  std_logic;
      na_reset : in  std_logic;
      -- Processor Ports
      -- DMA Configuration Port - OCP
      proc_in  : in  ocp_io_m;
      proc_out : out ocp_io_s;
      -- SPM Data Port - OCP?
      spm_in   : in  spm_slave;
      spm_out  : out spm_master;
      -- Network Ports
      -- Incoming Port
      pkt_in   : in  link_t;
      -- Outgoing Port
      pkt_out  : out link_t
      );
  end component;

  component bram_tdp is

    generic (
      DATA : integer := 32;
      ADDR : integer := 14
      );

    port (
-- Port A
      a_clk  : in  std_logic;
      a_wr   : in  std_logic;
      a_addr : in  std_logic_vector(ADDR-1 downto 0);
      a_din  : in  std_logic_vector(DATA-1 downto 0);
      a_dout : out std_logic_vector(DATA-1 downto 0);

-- Port B
      b_clk  : in  std_logic;
      b_wr   : in  std_logic;
      b_addr : in  std_logic_vector(ADDR-1 downto 0);
      b_din  : in  std_logic_vector(DATA-1 downto 0);
      b_dout : out std_logic_vector(DATA-1 downto 0)
      );

  end component;

  component traffic_generator is
    port (
      clk, reset : in  std_logic;
      spm_master : out spm_master;
      spm_slave	 : in  spm_slave;
      p_master	 : out ocp_io_m;
      p_slave	 : in  ocp_io_s;
      settings	 : in  tile_settings);
  end component traffic_generator;

  -----------------------------------------------------------------------------
  -- Signal declarations
  -----------------------------------------------------------------------------

  signal p_spm_master : spm_master;
  signal p_spm_slave  : spm_slave;

  signal n_spm_master : spm_master;
  signal n_spm_slave  : spm_slave;

  signal p_master : ocp_io_m;
  signal p_slave  : ocp_io_s;

  signal ip_to_net_f : channel_forward;
  signal ip_to_net_b : channel_backward;
  signal net_to_ip_f : channel_forward;
  signal net_to_ip_b : channel_backward;

  signal ip_to_net_link : link_t;
  signal net_to_ip_link : link_t;

  signal fifo_to_net_f : channel_forward;
  signal fifo_to_net_b : channel_backward;
  signal net_to_fifo_f : channel_forward;
  signal net_to_fifo_b : channel_backward;

  signal half_clk      : std_logic := '0';
  signal del_half_clk0 : std_logic;

begin  -- fake_tile

  na : nAdapter
    port map (
      -- Clock & Reset
      na_clk   => clk,
      na_reset => reset,
      -- Processor Interface (Traffic generator)
      proc_in  => p_master,
      proc_out => p_slave,
      -- SPM Interface
      spm_in   => n_spm_slave,
      spm_out  => n_spm_master,
      -- In & Outgoing Ports
      pkt_in   => net_to_ip_link,
      pkt_out  => ip_to_net_link);


  r : router
    port map (
      preset	     => reset,
      north_in_f     => north_in_f,
      north_in_b     => north_in_b,
      east_in_f	     => east_in_f,
      east_in_b	     => east_in_b,
      south_in_f     => south_in_f,
      south_in_b     => south_in_b,
      west_in_f	     => west_in_f,
      west_in_b	     => west_in_b,
      resource_in_f  => fifo_to_net_f,
      resource_in_b  => fifo_to_net_b,
      north_out_f    => north_out_f,
      north_out_b    => north_out_b,
      east_out_f     => east_out_f,
      east_out_b     => east_out_b,
      south_out_f    => south_out_f,
      south_out_b    => south_out_b,
      west_out_f     => west_out_f,
      west_out_b     => west_out_b,
      resource_out_f => net_to_fifo_f,
      resource_out_b => net_to_fifo_b);

  input_fifo : entity work.fifo(rtl)
    generic map (
      N				 => 0,	-- 1
      TOKEN			 => EMPTY_BUBBLE,
      GENERATE_REQUEST_DELAY	 => 1,	-- 1
      GENERATE_ACKNOWLEDGE_DELAY => 1,	-- 1
      GATING_ENABLED		 => 0
      )
    port map (
      preset	=> reset,
      left_in	=> ip_to_net_f,
      left_out	=> ip_to_net_b,
      right_out => fifo_to_net_f,
      right_in	=> fifo_to_net_b
      );

  output_fifo : entity work.fifo(rtl)
    generic map (
      N				 => 0,	-- 2
      TOKEN			 => VALID_TOKEN,
      GENERATE_REQUEST_DELAY	 => 1,	-- 1
      GENERATE_ACKNOWLEDGE_DELAY => 1,	-- 1
      GATING_ENABLED		 => 0
      )
    port map (
      preset	=> reset,
      left_in	=> net_to_fifo_f,
      left_out	=> net_to_fifo_b,
      right_out => net_to_ip_f,
      right_in	=> net_to_ip_b
      );

  -- High SPM instance
  spm_h : bram_tdp
    generic map (DATA => DATA_WIDTH, ADDR => SPM_ADDR_WIDTH)
    port map (a_clk  => clk,
	      a_wr   => p_spm_master.MCmd(0),
	      a_addr => p_spm_master.MAddr(SPM_ADDR_WIDTH-1 downto 0),
	      a_din  => p_spm_master.MData(63 downto 32),
	      a_dout => p_spm_slave.SData(63 downto 32),
	      b_clk  => clk,
	      b_wr   => n_spm_master.MCmd(0),
	      b_addr => n_spm_master.MAddr(SPM_ADDR_WIDTH-1 downto 0),
	      b_din  => n_spm_master.MData(63 downto 32),
	      b_dout => n_spm_slave.SData(63 downto 32));

  -- Low SPM instance
  spm_l : bram_tdp
    generic map (DATA => DATA_WIDTH, ADDR => SPM_ADDR_WIDTH)
    port map (a_clk  => clk,
	      a_wr   => p_spm_master.MCmd(0),
	      a_addr => p_spm_master.MAddr(SPM_ADDR_WIDTH-1 downto 0),
	      a_din  => p_spm_master.MData(31 downto 0),
	      a_dout => p_spm_slave.SData(31 downto 0),
	      b_clk  => clk,
	      b_wr   => n_spm_master.MCmd(0),
	      b_addr => n_spm_master.MAddr(SPM_ADDR_WIDTH-1 downto 0),
	      b_din  => n_spm_master.MData(31 downto 0),
	      b_dout => n_spm_slave.SData(31 downto 0));

  traffic_generator_1 : entity work.traffic_generator
    port map (
      clk	 => clk,
      reset	 => reset,
      spm_master => p_spm_master,
      spm_slave	 => p_spm_slave,
      p_master	 => p_master,
      p_slave	 => p_slave,
      settings	 => settings);

  -- generate
  half_clk_gen : process (clk, reset)
  begin
    if reset = '1' then
      half_clk <= '0';
    elsif falling_edge(clk) then
      half_clk <= not half_clk;
    end if;
  end process half_clk_gen;

  del_half_clk0	   <= not half_clk;
--del_half_clk1 <= not del_half_clk0;
  ip_to_net_f.req  <= not del_half_clk0 after 2 ns;
  ip_to_net_f.data <= ip_to_net_link;


-- <= ip_to_net_b.ack;
-- <= net_to_ip_f.req;
  net_to_ip_link  <= net_to_ip_f.data;
  net_to_ip_b.ack <= not del_half_clk0 after 2 ns;


end traffic_generator_tile;