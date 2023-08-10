library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity ex4_4a is
    generic (
        N: natural := 8
    );
    port (
        a, b, c, d: in std_logic_vector(N-1 downto 0);
        sel: in std_logic_vector(1 downto 0);
        x: out std_logic_vector(N-1 downto 0)
    );
end entity ex4_4a;

architecture rtl of ex4_4a is
    component ex4_4 is
        port (
            a, b, c, d: in std_logic;
            sel: in std_logic_vector(1 downto 0);
            x: out std_logic
        );
    end component ex4_4;
begin
    GENERATE_FOR: for i in 0 to N-1 generate
        EX4: ex4_4 port map (
            a => a(i),
            b => b(i),
            c => c(i),
            d => d(i),
            sel => sel,
            x => x(i)
        );
    end generate GENERATE_FOR;
end architecture rtl;