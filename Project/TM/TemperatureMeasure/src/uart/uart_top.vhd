-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_top.vhd
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
use work.general_config.all;

-- bits per second (bps) = clk_in frequency / div
-- bytes per second = clk_in frequency / (div * (data_bits + stop_bits + parity + 1))
entity uart_top is
  generic (
      config: project_config := default_config
    );
  port (
    clk_in:                  in std_ulogic;
    transmit:                in std_ulogic;
    data_in:                 in std_ulogic_vector((config.data_bits - 1) downto 0);
    tx:                      out std_ulogic;
    busy:                    out std_ulogic
  );
  end entity uart_top;
  
  architecture rtl of uart_top is
    constant parity_length:       parity_length := (0, 1, 1, 1, 1);
    constant last_state:          natural := config.data_bits + config.uart_stop_bits + parity_length(config.uart_parity);
    signal state:                 natural range 0 to last_state   := 0;
    signal clk:                   std_ulogic                                   := '0';
    signal data:                  std_ulogic_vector(data_in'range)             := (others => '0');
    signal parity_bit:            std_ulogic                                   := '0';
  begin
    clock_divider: uart_frequency_divider
    generic map (
        config          => config
    )
    port map (
        clk             => clk_in,
        frequency_out   => clk
    );
  
    process(clk)
    begin  
      if rising_edge(clk) then
        if state = 0 then
          tx <= '1';
          parity_bit <= '0';
          if transmit = '1' then
            state <= state + 1;
            data <= data_in;
          end if;
        elsif state = 1 then
          state <= state + 1;
          tx <= '0'; -- start bit
        elsif state = last_state then
          state <= 0;
          if last_state = config.data_bits + 1 then
            tx <= data(state-2);
            parity_bit <= parity_bit xor data(state-2);
          elsif parity_length(config.uart_parity) = 1 then
            if config.uart_parity = mark then
              tx <= '1';
            elsif config.uart_parity = space then
              tx <= '0';
            elsif config.uart_parity = odd then
              tx <= parity_bit;
            else -- even
              tx <= not parity_bit;
            end if;
          else
            tx <= '1';
          end if;
        elsif parity_length(config.uart_parity) = 1 and state = (config.data_bits + 2) then
          state <= state + 1;
          if config.uart_parity = mark then
            tx <= '1';
          elsif config.uart_parity = space then
            tx <= '0';
          elsif config.uart_parity = odd then
            tx <= parity_bit;
          else -- even
            tx <= not parity_bit;
          end if;
        elsif state > (config.data_bits + 1) then
          state <= state + 1;
          tx <= '1'; -- stop bits
        else -- data bits
          state <= state + 1;
          tx <= data(state-2);
          parity_bit <= parity_bit xor data(state-2);
        end if;
      end if;
    end process;
    
    busy <= '0' when state = 0 else '1';
end architecture rtl;
