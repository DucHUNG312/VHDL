-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            lcd_pck.vhd
--
-- @date:            13/06/2023
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

package lcd_pkg is
    
    --=========================================== Types ===========================================--
    type seven_segment_config is record
        data_bits:              positive;  -- Number of data bits per frame
        decode_bits:            positive; 
        inverted_out:           boolean; 
    end record seven_segment_config;
 

    --========================================== Constants =========================================--
    constant seven_segment_default_config: seven_segment_config := (
        data_bits               =>    4,
        decode_bits             =>    7,
        inverted_out            =>    false 
    );
    
    --===================================== SEVEN_SEGMENT_DECODER ===================================--
    component seven_segment_decoder is
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
    end component seven_segment_decoder;
    
end package lcd_pkg;

package body lcd_pkg is
    
    
end package body lcd_pkg;