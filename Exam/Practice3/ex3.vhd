library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex3 is
    port (
        clk: in std_logic;
        a, b, c: in std_logic;
        q: out std_logic
    );
end entity ex3;

architecture rtl of ex3 is
    signal d: std_logic := '0';
begin
    d <= (a and b) or ((b or c) and (b and c));
    process(clk)
    begin
        if rising_edge(clk) then
            q <= d;   
        end if;
    end process;
end architecture rtl;