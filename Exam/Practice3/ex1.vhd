library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex1 is
    port (
        a, b: in std_logic_vector(7 downto 0);
        sel: in std_logic_vector(1 downto 0);
        x: out std_logic_vector(7 downto 0)
    );
end entity ex1;

architecture rtl of ex1 is
begin
    process(a, b, sel)
    begin
        if sel = "00" then
            x <= "00000000";
        elsif sel = "01" then
            x <= a;
        elsif sel = "10" then
            x <= b;
        else
            x <= "ZZZZZZZZ";
        end if;
    end process;
end architecture rtl;