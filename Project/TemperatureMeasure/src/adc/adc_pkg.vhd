-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            adc_pkg.vhd
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

package adc_pkg is

    --=========================================== Types ===========================================--
    type adc_config is record
        data_bits:              positive;  -- Number of data bits per frame
        end_reception_state:    positive; 
        clk_div:                positive;
        ratio_must_be_half:     boolean;
        sampling_div:           positive;
        state_bits:             positive;
    end record adc_config;
    

    --========================================== Constants =========================================--
    constant adc_default_config: adc_config := (
        data_bits               =>    8,
        end_reception_state     =>    12,
        clk_div                 =>    125,
        ratio_must_be_half      =>    false,
        sampling_div            =>    40,
        state_bits              =>    4
    );


    --====================================== FREQUENCY_DIVIDER ======================================--
    component adc_frequency_divider is
        generic (
            config: adc_config := adc_default_config
        );
        port (
            clk:           in std_ulogic;
            frequency_out: out std_ulogic
        );
    end component adc_frequency_divider;


    --===================================== FREQUENCY_DIVIDER_LOW ====================================--
    component adc_frequency_divider_low is
        generic (
            config: adc_config := adc_default_config
        );
        port (
            clk:           in std_ulogic;
            frequency_out: out std_ulogic
        );
    end component adc_frequency_divider_low;


    --============================================ COUNTER ============================================--
    component adc_counter is
        generic (
            config: adc_config := adc_default_config
        );
        port (
            clk:           in std_ulogic;
            reset:         in std_ulogic;
            enable:        in std_ulogic;
            count_out:     out std_ulogic_vector(config.state_bits - 1 downto 0);
            overflow:      out std_ulogic
        );
    end component adc_counter;


    --======================================== SHIFT_REGISTER ==========================================--
    component adc_shift_register is
        generic (
            config: adc_config := adc_default_config
        );
        port (
            clk:           in std_ulogic;
            data_in:       in std_ulogic;
            data_out:      out std_ulogic_vector(config.data_bits - 1 downto 0)
        );
    end component adc_shift_register;


    --============================================ ADC_TOP ==============================================--
    component adc_top is
        generic (
            config: adc_config := adc_default_config
        );
        port (
            clk_in:            in std_ulogic;
            adc_data_out_ack:  in std_ulogic;
    
            adc_data_in_ack:   out std_ulogic;
            adc_chip_select:   out std_ulogic;
            adc_clk:           out std_ulogic;
            clk_sampling:      out std_ulogic;
            measured_values_1: out std_ulogic_vector(config.data_bits - 1 downto 0);
            measured_values_2: out std_ulogic_vector(config.data_bits - 1 downto 0)
        );
    end component adc_top;

end package adc_pkg;

package body adc_pkg is
       

end package body adc_pkg;
