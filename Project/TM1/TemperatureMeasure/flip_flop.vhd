library ieee;
use ieee.std_logic_1164.all;

-- D type flip flop
entity flip_flop is
  port (
    clk: in std_logic;
	reset: in std_logic;
	enable: in std_logic;
	d: in std_logic;
    output: out std_logic
  );
end entity;

architecture arch of flip_flop is
begin
  process(clk, reset, enable)
  begin
    if reset = '1' then
	  output <= '0';
	elsif rising_edge(clk) and enable = '1' then
	  output <= d;
	end if;
  end process;
end architecture;