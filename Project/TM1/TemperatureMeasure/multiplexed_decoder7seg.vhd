library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- output frequency = clk_in frequency / ((2 ^ number_displays) * div)
entity multiplexed_decoder7seg is
  generic ( div: natural; number_displays: natural; inverted_out: boolean := false );
  port (
    clk_in: in std_logic;
    input: in std_logic_vector((4*number_displays-1) downto 0);
    a: out std_logic;
    b: out std_logic;
    c: out std_logic;
    d: out std_logic;
    e: out std_logic;
    f: out std_logic;
    g: out std_logic;
    active_display: out std_logic_vector((natural(ceil(log2(real(number_displays))))-1) downto 0)
  );
end entity;

architecture arch of multiplexed_decoder7seg is
  signal clk: std_logic := '0';
  signal display_on: natural range 0 to number_displays := 0;
  signal display_value: std_logic_vector(3 downto 0) := (others => '0');
begin
  clock_divider: entity work.freq_divider
    generic map ( div => div )
    port map (
      clk_in => clk_in,
      clk_out => clk
    );

  process(clk)
  begin
    if rising_edge(clk) then
	  if display_on = number_displays then
        display_on <= 0;
      else
        display_on <= display_on + 1;
      end if;
    end if;
  end process;
  
  display_value <= input((4*display_on-1) downto (4*display_on-4));

  decoder: entity work.decoder7seg
    generic map ( inverted_out => inverted_out )
    port map (
      input => display_value,
      a => a,
      b => b,
      c => c,
      d => d,
      e => e,
      f => f,
      g => g
    );

  active_display <= std_logic_vector(to_unsigned(display_on, active_display'length));
end architecture;