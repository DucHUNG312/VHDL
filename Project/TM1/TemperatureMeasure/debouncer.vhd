library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
  generic ( max: natural );
  port (
    clk: in std_logic;
    input: in std_logic;
    output: out std_logic
  );
end entity;

architecture arch of debouncer is
  signal counter: natural range 0 to max := 0;
  signal o: std_logic := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if o /= input then
        if counter = max then
          counter <= 0;
          o <= input;
        else
          counter <= counter + 1;
        end if;
      else
        counter <= 0;
      end if;
    end if;
  end process;
  output <= o;
end architecture;