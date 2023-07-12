library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_counter is
  generic ( 
    bits: natural 
  );
  port (
    clk:       in std_logic;
    enable:    in std_logic;
    reset:     in std_logic;
    count_out: out std_logic_vector((bits-1) downto 0)
  );
end entity;

architecture rtl of adc_counter is
  signal count: unsigned(count_out'range) := (others => '0');
begin
  process(clk, enable, reset)
  begin
    if reset = '1' then
      count <= (others => '0');
    elsif rising_edge(clk) and enable = '1' then
      count <= count + 1;
    end if;
  end process;
  
  count_out <= std_logic_vector(count);
end architecture rtl;