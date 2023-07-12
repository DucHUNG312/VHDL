library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frequency_divider is
  generic (
    div: natural
  );
  port (
    clk_in: in std_logic;
    clk_out: out std_logic
  );
end entity;

architecture rtl of frequency_divider is
  constant max: natural := div - 1;
  constant half: natural := max / 2;
  signal counter: natural range 0 to max := 0;
  signal rise_square_wave: std_logic := '0';
begin
  process(clk_in)
  begin
    if rising_edge(clk_in) then
      if counter = max then
        counter <= 0;
      else
        counter <= counter + 1;
      end if;
      if counter > half then
        rise_square_wave <= '1';
      else
        rise_square_wave <= '0';
      end if;
    end if;
  end process;
  
  clk_out <= rise_square_wave;
end architecture rtl;