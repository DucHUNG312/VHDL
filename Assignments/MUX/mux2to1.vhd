library ieee;
use ieee.std_logic_1164.all; 

entity mux2to1 is
  port (
	  w0, w1, s : in std_logic;
     f : out std_logic); 
end entity;

architecture behaviour of mux2to1 is 
begin
  process (w0, w1, s)
  begin
    if (s = '0') then
      f <= w0;
    else
      f <= w1;
    end if;
  end process;
end architecture;