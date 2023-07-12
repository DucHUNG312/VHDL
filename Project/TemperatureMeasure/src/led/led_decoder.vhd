library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity led_decoder is
  generic( 
    inverted_out: boolean := true 
  );
  port (
    input: in std_logic_vector(7 downto 0);

    a_hundreds: out std_logic;
    b_hundreds: out std_logic;
    c_hundreds: out std_logic;
    d_hundreds: out std_logic;
    e_hundreds: out std_logic;
    f_hundreds: out std_logic;
    g_hundreds: out std_logic;
    
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
end entity led_decoder;

architecture arch of led_decoder is
	signal bcd_data: std_logic_vector(9 downto 0);
	signal decoder_hundreds: std_logic_vector(6 downto 0);
  signal decoder_tens: std_logic_vector(6 downto 0);
  signal decoder_uints: std_logic_vector(6 downto 0);
begin
   bin_to_bcd: entity work.led_bin_to_bcd
    port map (
      data_in => input,
      data_bcd_out => bcd_data
    );
	 
	 with bcd_data(9 downto 8) select
      decoder_hundreds  <=  "0111111" when "00", -- 0
									          "0000110" when "01", -- 1
									          "1011011" when "10", -- 2
									          "1001111" when "11"; -- 3
									      
	
    with bcd_data(7 downto 4) select
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
                        "1111111" when others;
            
    with bcd_data(3 downto 0) select
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
                        "1111111" when others;
	
	  a_hundreds  <= not decoder_hundreds(0)  when inverted_out else decoder_hundreds(0);
    b_hundreds  <= not decoder_hundreds(1)  when inverted_out else decoder_hundreds(1);
    c_hundreds  <= not decoder_hundreds(2)  when inverted_out else decoder_hundreds(2);
    d_hundreds  <= not decoder_hundreds(3)  when inverted_out else decoder_hundreds(3);
    e_hundreds  <= not decoder_hundreds(4)  when inverted_out else decoder_hundreds(4);
    f_hundreds  <= not decoder_hundreds(5)  when inverted_out else decoder_hundreds(5);
    g_hundreds  <= not decoder_hundreds(6)  when inverted_out else decoder_hundreds(6);


    a_tens  <= not decoder_tens(0)  when inverted_out else decoder_tens(0);
    b_tens  <= not decoder_tens(1)  when inverted_out else decoder_tens(1);
    c_tens  <= not decoder_tens(2)  when inverted_out else decoder_tens(2);
    d_tens  <= not decoder_tens(3)  when inverted_out else decoder_tens(3);
    e_tens  <= not decoder_tens(4)  when inverted_out else decoder_tens(4);
    f_tens  <= not decoder_tens(5)  when inverted_out else decoder_tens(5);
    g_tens  <= not decoder_tens(6)  when inverted_out else decoder_tens(6);

    a_uints <= not decoder_uints(0) when inverted_out else decoder_uints(0);
    b_uints <= not decoder_uints(1) when inverted_out else decoder_uints(1);
    c_uints <= not decoder_uints(2) when inverted_out else decoder_uints(2);
    d_uints <= not decoder_uints(3) when inverted_out else decoder_uints(3);
    e_uints <= not decoder_uints(4) when inverted_out else decoder_uints(4);
    f_uints <= not decoder_uints(5) when inverted_out else decoder_uints(5);
    g_uints <= not decoder_uints(6) when inverted_out else decoder_uints(6);
end architecture;