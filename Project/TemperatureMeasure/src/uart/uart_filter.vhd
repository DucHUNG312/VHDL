-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_filter.vhd
--
-- @date:            14/06/2023
--
-- @description:     This file contains the VHDL implementation of a UART filter module. The module synchronizes and 
--                   processes incoming serial data and outputs a filtered and synchronized bit. It includes sync and 
--                   voter stages based on the configuration parameters. The sync stage uses flip-flops to synchronize 
--                   the input data, while the voter stage applies a voting mechanism to determine the final output 
--                   based on the synchronized data.
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
use ieee.std_logic_misc.all;
use ieee.math_real.all;
use work.uart_pkg.all;

entity uart_filter is
    generic (
        config: uart_config := uart_default_config
    );
    port (
        clk:      in std_ulogic; -- clock, rising edge
        reset:    in std_ulogic; -- asynchronous reset
        data_in:  in std_ulogic; -- serial in
        data_out: out std_ulogic -- synced & voted input bit
    );
end entity uart_filter;

architecture rtl of uart_filter is
-- ===============================================================================================================================================
-- |           Signals            |                                          Data Type                                    |         Value        |
-- ===============================================================================================================================================
    signal rs_flipflop_set        :    std_ulogic;                                                                    
    signal rs_flipflop_reset      :    std_ulogic;                                                                        
    signal sync_flipflops         :    std_ulogic_vector(integer(realmax(real(config.sync_stage - 1), 0.0)) downto 0);   
    signal synced                 :    std_ulogic;                                                                        
    signal voted_flipflops        :    std_ulogic_vector(integer(realmax(real(config.voter_stage - 1), 0.0)) downto 0);   
-- ===============================================================================================================================================

begin

    --=========================================== Sync stage ===========================================--
    -- Implemented
    SYNC : if config.sync_stage > 1 generate
        -- FlipFlop
        SYNC_FLIPFLOP : process(clk, reset)
        begin
            if reset = to_stdulogic(config.reset_active) then
                sync_flipflops <= (others => to_stdulogic(config.output_reset));
            elsif rising_edge(clk) then
                sync_flipflops <= sync_flipflops(sync_flipflops'left - 1 downto sync_flipflops'right) & data_in;
            end if;
        end process SYNC_FLIPFLOP;
        -- Output
        synced <= sync_flipflops(sync_flipflops'left);
    end generate SYNC;
    -- Skipped
    SKIP_SYNC : if config.sync_stage <= 1 generate
        synced <= data_in;
    end generate SKIP_SYNC;

    --=========================================== Voter stage ===========================================--
    -- Implemented
    VOTER : if config.voter_stage > 1 generate
        -- FlipFlop
        VOTER_FLIPFLOP : process(clk, reset)
        begin
            if reset = to_stdulogic(config.reset_active) then
                voted_flipflops <= (others => to_stdulogic(config.output_reset));
            elsif rising_edge(clk) then
                voted_flipflops <= voted_flipflops(voted_flipflops'left - 1 downto voted_flipflops'right) & synced;
            end if;
        end process VOTER_FLIPFLOP;
        -- Output
        rs_flipflop_set   <= and_reduce(voted_flipflops);
        rs_flipflop_reset <= nor_reduce(voted_flipflops);
        -- RS FlipFlop
        RS_FLIPFLOP : process(clk, reset)
        begin
            if reset = to_stdulogic(config.reset_active) then
                data_out <= to_stdulogic(config.output_reset);
            elsif rising_edge(clk) then
                if (rs_flipflop_set = '1') and (rs_flipflop_reset = '0') then
                    data_out <= '1';
                elsif (rs_flipflop_set = '0') and (rs_flipflop_reset = '1') then
                    data_out <= '0';
                end if;
            end if;
        end process RS_FLIPFLOP; 
    end generate VOTER;
    -- Skipped
    SKIP_VOTER : if config.voter_stage <= 1 generate
        data_out <= synced;
    end generate SKIP_VOTER;

end architecture rtl;