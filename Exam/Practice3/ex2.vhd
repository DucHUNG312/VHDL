library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex2 is
    port (
        a, b, c: in std_logic;
        q: out std_logic
    );
end entity ex2;

architecture rtl of ex2 is
    signal tmp: std_logic := '0';
begin
    tmp <= (a and b) or ((b or c) and (b and c));
    q <= tmp;
end architecture rtl;