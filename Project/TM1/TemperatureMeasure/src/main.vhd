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

    a: out std_logic;
    b: out std_logic;
    c: out std_logic;
    d: out std_logic;
    e: out std_logic;
    f: out std_logic;
    g: out std_logic;
     
    tx: out std_logic;
     
    led_green: out std_logic;
    led_red: out std_logic
  );
end entity;

architecture arch of main is
  signal first_value: std_logic_vector(7 downto 0) := (others => '0');
  signal second_value: std_logic_vector(first_value'range) := (others => '0');
  signal byte_to_transmit: std_logic_vector(first_value'range) := (others => '0');
  signal dont_transmit: std_logic := '0';
  signal channel: std_logic := '0';
begin
  adc: entity work.adc0832
    generic map ( clk_div => 125, sampling_div => 40 )
    port map (
      clk_in => clk50MHz,
      clk_adc => clk_adc,
      cs_adc => cs_adc,
      do_adc => do_adc,
      di_adc => di_adc,
      measured_value_1 => first_value,
      measured_value_2 => second_value
    );
  
  decoder: entity work.decoder7seg
    port map (
      input => first_value(7 downto 4),
      a => a,
      b => b,
      c => c,
      d => d,
      e => e,
      f => f,
      g => g
    );

  pwm1: entity work.pwm
    generic map ( div => 19, bits => first_value'length )
    port map (
      clk_in => clk50MHz,
      ratio => first_value,
      output => led_green
    );
  
  pwm2: entity work.pwm
    generic map ( div => 19, bits => second_value'length )
    port map (
      clk_in => clk50MHz,
      ratio => second_value,
      output => led_red
    );

  byte_to_transmit <= second_value when channel = '1' else first_value;
  serial: entity work.serial_tx
    generic map (
      div => 2604 -- 19200bps
    )
    port map (
      clk_in => clk50MHz,
      transmit => not dont_transmit,
      data_in => byte_to_transmit,
      tx => tx,
      busy => dont_transmit
    );

  process(dont_transmit)
    begin
    if rising_edge(dont_transmit) then
      channel <= not channel;
    end if;
  end process;
end architecture;