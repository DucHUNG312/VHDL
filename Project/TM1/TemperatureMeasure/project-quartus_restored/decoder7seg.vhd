library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder7seg is
  generic( inverted_out: boolean := true );
  port (
    input: in std_logic_vector(7 downto 0);
    
    a_tens: out std_logic;
    b_tens: out std_logic;
    c_tens: out std_logic;
    d_tens: out std_logic;
    e_tens: out std_logic;
    f_tens: out std_logic;
    g_tens: out std_logic;

    a_uints: out std_logic;
    b_uints: out std_logic;
    c_uints: out std_logic;
    d_uints: out std_logic;
    e_uints: out std_logic;
    f_uints: out std_logic;
    g_uints: out std_logic
  );
end entity;

architecture arch of decoder7seg is
	signal input_tens: std_logic_vector(3 downto 0)  := input(7 downto 4);
	signal input_units: std_logic_vector(3 downto 0) := input(3 downto 0);
	signal decoder_tens: std_logic_vector(6 downto 0);
	signal decoder_uints: std_logic_vector(6 downto 0);
begin
  with input_tens select
             -- gfedcba
    decoder_tens  <=  "0111111" when "0000", -- 0
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

	with input_units select
             -- gfedcba
    decoder_uints <=  "0111111" when "0000", -- 0
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

  a_tens <= not decoder_tens(0) when inverted_out else decoder_tens(0);
  b_tens <= not decoder_tens(1) when inverted_out else decoder_tens(1);
  c_tens <= not decoder_tens(2) when inverted_out else decoder_tens(2);
  d_tens <= not decoder_tens(3) when inverted_out else decoder_tens(3);
  e_tens <= not decoder_tens(4) when inverted_out else decoder_tens(4);
  f_tens <= not decoder_tens(5) when inverted_out else decoder_tens(5);
  g_tens <= not decoder_tens(6) when inverted_out else decoder_tens(6);

  a_uints <= not decoder_uints(0) when inverted_out else decoder_uints(0);
  b_uints <= not decoder_uints(1) when inverted_out else decoder_uints(1);
  c_uints <= not decoder_uints(2) when inverted_out else decoder_uints(2);
  d_uints <= not decoder_uints(3) when inverted_out else decoder_uints(3);
  e_uints <= not decoder_uints(4) when inverted_out else decoder_uints(4);
  f_uints <= not decoder_uints(5) when inverted_out else decoder_uints(5);
  g_uints <= not decoder_uints(6) when inverted_out else decoder_uints(6);
end architecture;