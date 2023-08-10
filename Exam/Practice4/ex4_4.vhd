library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex4_4 is
    port (
        a, b, c, d: in std_logic;
        sel: in std_logic_vector(1 downto 0);
        x: out std_logic
    );
end entity ex4_4;

architecture rtl of ex4_4 is
begin
    with sel select x <=  a when "00",
                          b when "01",
                          c when "10",
                          d when "11";
end architecture rtl;