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
      input => first_value(7 downto 0),

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

  -- process(dont_transmit)
  --   begin
  --   if rising_edge(dont_transmit) then
  --     channel <= not channel;
  --   end if;
  -- end process;
end architecture;