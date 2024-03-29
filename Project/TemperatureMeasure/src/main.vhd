library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
  port (
    clk50MHz: in std_logic;
     
    clk_adc: out std_logic;
    cs_adc: out std_logic;
    di_adc: out std_logic;
    do_adc: in std_logic;

    a_hundreds: out std_logic;
    b_hundreds: out std_logic;
    c_hundreds: out std_logic;
    d_hundreds: out std_logic;
    e_hundreds: out std_logic;
    f_hundreds: out std_logic;
    g_hundreds: out std_logic;

    a_tens: out std_logic;
    b_tens: out std_logic;
    c_tens: out std_logic;
    d_tens: out std_logic;
    e_tens: out std_logic;
    f_tens: out std_logic;
    g_tens: out std_logic;

    a_units: out std_logic;
    b_units: out std_logic;
    c_units: out std_logic;
    d_units: out std_logic;
    e_units: out std_logic;
    f_units: out std_logic;
    g_units: out std_logic;
     
    tx: out std_logic
  );
end entity;

architecture rtl of main is
  signal first_value: std_logic_vector(7 downto 0) := (others => '0');
  signal second_value: std_logic_vector(first_value'range) := (others => '0');
  signal byte_to_transmit: std_logic_vector(first_value'range) := (others => '0');
  signal channel: std_logic := '0';
begin
  adc: entity work.adc_top
    generic map ( 
		clk_div => 125
	 )
    port map (
      clk_in => clk50MHz,
      clk_adc => clk_adc,
      cs_adc => cs_adc,
      do_adc => do_adc,
      di_adc => di_adc,
      measured_value_1 => first_value,
      measured_value_2 => second_value
    );
	 
	 bcd_decoder: entity work.led_decoder
    port map (
      input => first_value(7 downto 0),

      a_hundreds => a_hundreds,
      b_hundreds => b_hundreds,
      c_hundreds => c_hundreds,
      d_hundreds => d_hundreds,
      e_hundreds => e_hundreds,
      f_hundreds => f_hundreds,
      g_hundreds => g_hundreds,

      a_tens => a_tens,
      b_tens => b_tens,
      c_tens => c_tens,
      d_tens => d_tens,
      e_tens => e_tens,
      f_tens => f_tens,
      g_tens => g_tens,

      a_uints => a_units,
      b_uints => b_units,
      c_uints => c_units,
      d_uints => d_units,
      e_uints => e_units,
      f_uints => f_units,
      g_uints => g_units
    );

  byte_to_transmit <= second_value when channel = '1' else first_value;
  serial: entity work.uart_top
    generic map (
      div => 2604 -- 19200bps
    )
    port map (
      clk_in => clk50MHz,
      data_in => byte_to_transmit,
      tx => tx
    );
end architecture rtl;