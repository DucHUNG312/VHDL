-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            pwm_pkg.vhd
--
-- @date:            14/06/2023
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

package pwm_pkg is

    --=========================================== Types ===========================================--
    type pwm_config is record
        clk_div:              positive;  
        ratio_must_be_half:   boolean;
        data_bits:            positive; 

    end record pwm_config;
 

    --========================================== Constants =========================================--
    constant pwm_default_config: pwm_config := (
        clk_div               =>    19,
        ratio_must_be_half    =>    false,
        data_bits             =>    8
    );

    --====================================== FREQUENCY_DIVIDER ======================================--
    component pwm_frequency_divider is
        generic (
            config: pwm_config := pwm_default_config
        );
        port (
            clk:           in std_ulogic;
            frequency_out: out std_ulogic
        );
    end component pwm_frequency_divider;

    --============================================= PWM =============================================--
    component pwm is
        generic (
            config: pwm_config := pwm_default_config
        );
        port (
            clk_in:   in std_ulogic;
            ratio:    in std_ulogic(config.data_bits - 1 downto 0);
            wave_out: out std_ulogic;
        );
    end component pwm;
    
    
end package pwm_pkg;

package body pwm_pkg is
    
    
    
end package body pwm_pkg;
