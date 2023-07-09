library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc0831 is
  generic (
    clk_div: natural;     -- first clock divider
    sampling_div: natural -- second clock divider (must be greater than 11)
  );
  port (
    do_adc: in std_logic;
    clk_in: in std_logic;
    clk_adc: out std_logic;
    cs_adc: out std_logic;
    measured_value: out std_logic_vector(7 downto 0)
  );
end entity;

architecture arch of adc0831 is
  constant end_rec_state: natural := 10;
  signal clk: std_logic := '0';
  signal clk_sampling: std_logic := '0';
  signal state: std_logic_vector(3 downto 0) := (others => '0');
  signal end_reception: std_logic := '0';
  signal shifting_byte: std_logic_vector(measured_value'range) := (others => '0');
begin
  clock_divider: entity work.freq_divider
    generic map ( div => clk_div )
    port map (
      clk_in => clk_in,
      clk_out => clk
    );
  sampling_divider: entity work.freq_divider_low
    generic map ( div => sampling_div )
    port map (
      clk_in => clk,
      clk_out => clk_sampling
    );
  
  counter: entity work.counter
    generic map ( bits => state'length )
    port map (
      clk => clk,
      enable => not end_reception,
      reset => clk_sampling,
      q => state
    );
  
  shift_register: entity work.shift_register
    generic map ( bits => shifting_byte'length )
    port map (
      clk => clk,
      input => do_adc,
      output => shifting_byte
    );
  
  end_reception <= '1' when (unsigned(state) = to_unsigned(end_rec_state, state'length)) else '0';
  process(end_reception)
  begin
    if rising_edge(end_reception) then
       measured_value <= shifting_byte;
    end if;
  end process;
  
  clk_adc <= clk;
  cs_adc <= clk_sampling;
end architecture;