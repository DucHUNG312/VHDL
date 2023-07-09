-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            led_decoder.vhd
--
-- @date:            13/06/2023
--
-- @description:     This file contains the implementation of a seven-segment decoder
--                   The decoder converts a 4-bit input value into the corresponding
--                   signals to display the decimal digits 0 to 9 and the hexadecimal
--                   letters A to F on a seven-segment display.  
-- ==================================================================================================================
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ==================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.general_config.all;

entity led_decoder is
    generic (
        config: project_config := default_config
    );
    port (
        data_in: in std_logic_vector(config.data_bits - 1 downto 0);

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

architecture rtl of led_decoder is
    signal bcd_data: std_logic_vector(config.led_bcd_data - 1 downto 0);
    signal decoder_tens: std_logic_vector(config.led_decode_bits - 1 downto 0);
    signal decoder_uints: std_logic_vector(config.led_decode_bits - 1 downto 0);
begin
    led_bin_to_bcd: entity work.led_bin_to_bcd
    port map (
        b => data_in,
		p => bcd_data
    );
	
    with bcd_data(config.led_decode_bits downto config.led_data_bits) select
        decoder_tens  <=    "0111111" when "0000", -- 0
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
                
    with bcd_data(config.led_data_bits - 1 downto 0) select
        decoder_uints <=    "0111111" when "0000", -- 0
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


    a_tens  <= not decoder_tens(0)  when config.led_inverted_out else decoder_tens(0);
    b_tens  <= not decoder_tens(1)  when config.led_inverted_out else decoder_tens(1);
    c_tens  <= not decoder_tens(2)  when config.led_inverted_out else decoder_tens(2);
    d_tens  <= not decoder_tens(3)  when config.led_inverted_out else decoder_tens(3);
    e_tens  <= not decoder_tens(4)  when config.led_inverted_out else decoder_tens(4);
    f_tens  <= not decoder_tens(5)  when config.led_inverted_out else decoder_tens(5);
    g_tens  <= not decoder_tens(6)  when config.led_inverted_out else decoder_tens(6);

    a_uints <= not decoder_uints(0) when config.led_inverted_out else decoder_uints(0);
    b_uints <= not decoder_uints(1) when config.led_inverted_out else decoder_uints(1);
    c_uints <= not decoder_uints(2) when config.led_inverted_out else decoder_uints(2);
    d_uints <= not decoder_uints(3) when config.led_inverted_out else decoder_uints(3);
    e_uints <= not decoder_uints(4) when config.led_inverted_out else decoder_uints(4);
    f_uints <= not decoder_uints(5) when config.led_inverted_out else decoder_uints(5);
    g_uints <= not decoder_uints(6) when config.led_inverted_out else decoder_uints(6);
end architecture rtl;