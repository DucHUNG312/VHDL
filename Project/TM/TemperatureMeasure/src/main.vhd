-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            main.vhd
--
-- @date:            15/06/2023
-- =============================================================================
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
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.general_config.all;

entity main is
    port (
        clk:                                  in  std_logic;
        reset:                                in  std_logic;
        adc_data_out:                         in  std_logic;
        adc_clk:                              out std_logic;
        adc_chip_select:                      out std_logic;
        adc_data_in:                          out std_logic;

        a_tens:                               out std_logic;
        b_tens:                               out std_logic;
        c_tens:                               out std_logic;
        d_tens:                               out std_logic;
        e_tens:                               out std_logic;
        f_tens:                               out std_logic;
        g_tens:                               out std_logic;

        a_uints:                              out std_logic;
        b_uints:                              out std_logic;
        c_uints:                              out std_logic;
        d_uints:                              out std_logic;
        e_uints:                              out std_logic;
        f_uints:                              out std_logic;
        g_uints:                              out std_logic;

        tx:                                   out std_logic
    );
end entity main;

architecture rtl of main is

-- =====================================================================================================================================================
-- |                    Signals                     |                                 Data Type                                    |       Value       |
-- =====================================================================================================================================================
    signal measured_values_1                        :     std_logic_vector(default_config.data_bits - 1 downto 0)             := (others => 'X');                                                                       
    signal measured_values_2                        :     std_logic_vector(measured_values_1'range)                           := (others => 'X');
    signal data_to_transmit                         :     std_logic_vector(measured_values_1'range)                           := (others => 'X');                               
    signal dont_transmit                            :     std_logic                                                           := '0'; 
    signal channel                                  :     std_logic                                                           := '0'; 
-- =====================================================================================================================================================

begin
    --============================================= ADC INSTANCE =============================================--
    ADC_INST: adc_top 
    generic map (
        config              => default_config
    )
    port map (
        clk_in              => clk,
        adc_data_out        => adc_data_out,

        adc_data_in         => adc_data_in,
        adc_chip_select     => adc_chip_select,
        adc_clk             => adc_clk,
        measured_values_1   => measured_values_1,
        measured_values_2   => measured_values_2
    );

    --============================================= SEVEN SEGMENT DECODER INSTANCE =============================================--
    LED_INST: led_decoder
    generic map (
       config               => default_config
    )
    port map (
        data_in             => measured_values_1(default_config.data_bits - 1 downto 0),

        a_tens              => a_tens,
        b_tens              => b_tens,
        c_tens              => c_tens,
        d_tens              => d_tens,
        e_tens              => e_tens,
        f_tens              => f_tens,
        g_tens              => g_tens,

        a_uints             => a_uints,
        b_uints             => b_uints,
        c_uints             => c_uints,
        d_uints             => d_uints,
        e_uints             => e_uints,
        f_uints             => f_uints,
        g_uints             => g_uints
    );

    --============================================= UART INSTANCE =============================================--

    data_to_transmit <= measured_values_2 when channel = '1' else measured_values_1;

    UART: entity work.uart_top
    generic map (
        config              => default_config
    )
    port map (
      clk_in                => clk,
      transmit              => not dont_transmit,
      data_in               => data_to_transmit,
      tx                    => tx,
      busy                  => dont_transmit
    );
    
    -- process(dont_transmit)
    --   begin
    --   if rising_edge(dont_transmit) then
    --       channel <= not channel;
    --   end if;
    -- end process;

end architecture rtl;