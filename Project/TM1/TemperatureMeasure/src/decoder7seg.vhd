library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder7seg is
  generic( inverted_out: boolean := false );
  port (
    input: in std_logic_vector(3 downto 0);
    a: out std_logic;
    b: out std_logic;
    c: out std_logic;
    d: out std_logic;
    e: out std_logic;
    f: out std_logic;
    g: out std_logic
  );
end entity;

architecture arch of decoder7seg is
  signal decoder: std_logic_vector(6 downto 0);
begin
  with input select
             -- gfedcba
    decoder <= "0111111" when "0000", -- 0
               "0000110" when "0001", -- 1
               "1011011" when "0010", -- 2
               "1001111" when "0011", -- 3
               "1100110" when "0100", -- 4
               "1101101" when "0101", -- 5
               "1111101" when "0110", -- 6
               "0000111" when "0111", -- 7
               "1111111" when "1000", -- 8
               "1100111" when "1001", -- 9
               "1110111" when "1010", -- A
               "1111100" when "1011", -- B
               "0111001" when "1100", -- C
               "1011110" when "1101", -- D
               "1111001" when "1110", -- E
               "1110001" when others; -- F
  a <= not decoder(0) when inverted_out else decoder(0);
  b <= not decoder(1) when inverted_out else decoder(1);
  c <= not decoder(2) when inverted_out else decoder(2);
  d <= not decoder(3) when inverted_out else decoder(3);
  e <= not decoder(4) when inverted_out else decoder(4);
  f <= not decoder(5) when inverted_out else decoder(5);
  g <= not decoder(6) when inverted_out else decoder(6);
end architecture;