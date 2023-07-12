library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_shift_register is
  generic ( 
    bits: natural 
  );
  port (
    clk: in std_logic;
    input: in std_logic;
    output: out std_logic_vector((bits-1) downto 0)
  );
end entity;

architecture rtl of adc_shift_register is
  signal data: std_logic_vector(output'range) := (others => '0');
begin
  process(clk)
  begin
    if rising_edge(clk) then
      for i in 1 to data'high loop
        data(i) <= data(i-1);
      end loop;
      data(0) <= input;
    end if;
  end process;
  output <= data;
end architecture rtl;