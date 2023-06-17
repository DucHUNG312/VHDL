-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            seven_segment_decoder.vhd
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
use work.lcd_pkg.all;

entity seven_segment_decoder is
    generic (
        config: seven_segment_config := seven_segment_default_config
    );
    port (
        data_in:    in std_ulogic_vector(config.data_bits - 1 downto 0);
        a:          out std_ulogic;
        b:          out std_ulogic;
        c:          out std_ulogic;
        d:          out std_ulogic;
        e:          out std_ulogic;
        f:          out std_ulogic;
        g:          out std_ulogic
    );
end entity seven_segment_decoder;

architecture rtl of seven_segment_decoder is
    signal decoder: std_ulogic_vector(config.decode_bits - 1 downto 0);
begin
    with data_in select decoder <=  "0111111" when "0000", -- 0
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

    -- Connect IO
    a <= not decoder(0) when config.inverted_out else decoder(0);
    b <= not decoder(1) when config.inverted_out else decoder(1);
    c <= not decoder(2) when config.inverted_out else decoder(2);
    d <= not decoder(3) when config.inverted_out else decoder(3);
    e <= not decoder(4) when config.inverted_out else decoder(4);
    f <= not decoder(5) when config.inverted_out else decoder(5);
    g <= not decoder(6) when config.inverted_out else decoder(6);

end architecture rtl;