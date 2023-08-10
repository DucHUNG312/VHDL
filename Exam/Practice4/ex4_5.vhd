library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex4_5 is
    generic (
        N: natural := 8
    );
    port (
        a, b: in std_logic_vector(N-1 downto 0);
        opcode: in std_logic_vector(2 downto 0);
        cin: in std_logic;
        y: out std_logic_vector(N-1 downto 0)
    );
end entity ex4_5;

architecture rtl of ex4_5 is 
    signal unsigned_cin : unsigned(0 downto 0) := (others => '0');
    signal signed_cin : signed(0 downto 0) := (others => '0');
begin 
    unsigned_cin <= (others => cin);
    signed_cin <= signed(unsigned_cin);

    with opcode select y <= std_logic_vector(unsigned(a) + unsigned(b)) when "000",
                            std_logic_vector(unsigned(a) - unsigned(b)) when "001",
                            std_logic_vector(unsigned(b) - unsigned(a)) when "010",
                            std_logic_vector(unsigned(a) + unsigned(b) + unsigned_cin) when "011",
                            std_logic_vector(signed(a) + signed(b)) when "100",
                            std_logic_vector(signed(a) - signed(b)) when "101",
                            std_logic_vector(signed(b) - signed(a)) when "110",
                            std_logic_vector(signed(a) + signed(b) + signed_cin) when "111";
end architecture rtl;