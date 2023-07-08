-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            general_config.vhd
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

package general_config is

    --=========================================== Types ===========================================--
    subtype stop_type   is natural range 1 to 2;
    type parity_type    is (none, mark, space, odd, even);
    type parity_length  is array (parity_type) of natural range 0 to 1;

    type project_config is record
        data_bits:                  positive;  -- Number of data bits per frame
        ratio_must_be_half:         boolean;
        adc_end_reception_state:    positive; 
        adc_clk_div:                positive;
        pwm_clk_div:                positive;
        uart_clk_div:               positive;
        adc_state_bits:             positive;
		led_data_bits:              positive;
        led_decode_bits:            positive; 
        led_inverted_out:           boolean;
        uart_parity:                parity_type;
        uart_stop_bits:             stop_type;
    end record project_config;

    --========================================== Constants =========================================--
    constant default_config: project_config := (
        data_bits                   => 8,
        ratio_must_be_half          => false,
        adc_end_reception_state     => 12, 
        adc_clk_div                 => 125,
        pwm_clk_div                 => 19,
        uart_clk_div                => 2604, -- 19200 bps
        adc_state_bits              => 4,
        led_data_bits               => 4,
        led_decode_bits             => 7,
        led_inverted_out            => true,
        uart_parity                 => none,
        uart_stop_bits              => 1
    );

    --====================================== FREQUENCY_DIVIDER ======================================--
    component adc_frequency_divider is
        generic (
            config: project_config := default_config
        );
        port (
            clk:           in std_ulogic;
            frequency_out: out std_ulogic
        );
    end component adc_frequency_divider;

    component pwm_frequency_divider is
        generic (
            config: project_config := default_config
        );
        port (
            clk:           in std_ulogic;
            frequency_out: out std_ulogic
        );
    end component pwm_frequency_divider;

    component uart_baud_generator is
        generic (
            config: project_config := default_config
        );
        port (
            clk:           in std_ulogic;
            frequency_out: out std_ulogic
        );
    end component uart_baud_generator;

    --============================================ COUNTER ============================================--
    component adc_counter is
        generic (
            config: project_config := default_config
        );
        port (
            clk:           in std_ulogic;
            reset:         in std_ulogic;
            enable:        in std_ulogic;
            count_out:     out std_ulogic_vector(config.adc_state_bits - 1 downto 0);
            overflow:      out std_ulogic
        );
    end component adc_counter;


    --======================================== SHIFT_REGISTER ==========================================--
    component adc_shift_register is
        generic (
            config: project_config := default_config
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
            config: project_config := default_config
        );
        port (
            clk_in:                 in std_ulogic;
            adc_data_out:           in std_ulogic;
    
            adc_data_in:            out std_ulogic;
            adc_chip_select:        out std_ulogic;
            adc_clk:                out std_ulogic;
            measured_values_1:      out std_ulogic_vector(config.data_bits - 1 downto 0);
            measured_values_2:      out std_ulogic_vector(config.data_bits - 1 downto 0)
        );
    end component adc_top;

     --===================================== SEVEN_SEGMENT_DECODER ===================================--
    component seven_segment_decoder is
        generic (
            config: project_config := default_config
        );
        port (
            data_in:    in  std_ulogic_vector(config.led_data_bits - 1 downto 0);
            a:          out std_ulogic;
            b:          out std_ulogic;
            c:          out std_ulogic;
            d:          out std_ulogic;
            e:          out std_ulogic;
            f:          out std_ulogic;
            g:          out std_ulogic
        );
    end component seven_segment_decoder;

    --============================================= PWM =============================================--
    component pwm is
        generic (
            config: project_config := default_config
        );
        port (
            clk_in:   in  std_ulogic;
            ratio:    in  std_ulogic_vector(config.data_bits - 1 downto 0);
            wave_out: out std_ulogic
        );
    end component pwm;

    --============================================= UART =============================================--
    component uart_top is
        generic (
            config: project_config := default_config
        );
        port (
            clk_in:                  in  std_logic;
            transmit:                in  std_logic;
            data_in:                 in  std_logic_vector((config.data_bits-1) downto 0);
            tx:                      out std_logic;
            busy:                    out std_logic
        );
    end component uart_top;

end package general_config;

package body general_config is    

end package body general_config;
