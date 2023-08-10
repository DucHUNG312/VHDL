library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex4_3_a is
    port (
        x: in std_logic_vector(9 downto 0);
        y: out std_logic
    );
end entity ex4_3_a;

architecture rtl of ex4_3_a is
    signal x_tmp: std_logic_vector(9 downto 0);
begin
    x_tmp(0) <= '1';
    GENERATE_FOR: for i in 0 to 8 generate
        x_tmp(i + 1) <= x_tmp(i) and x(i);
    end generate GENERATE_FOR;
    y <= x_tmp(9);
end architecture rtl;