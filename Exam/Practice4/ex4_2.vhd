library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex4_2 is
    port (
        x: in std_logic_vector(2 downto 0);
        y: out std_logic_vector(1 downto 0)
    );
end entity ex4_2;

architecture rtl of ex4_2 is
begin
    with x select y <=  "01" when "000",
                        "01" when "001",
                        "00" when "100",
                        "00" when "101",  
                        "10" when "111",
                        "--" when others;
end architecture rtl;