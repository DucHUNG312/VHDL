-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_filter_tb.vhd
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
use ieee.math_real.all;
use work.uart_pkg.all;
use work.uart_pkg_tb.all;

entity uart_filter_tb is
    generic (
        do_all_tests : boolean     := false;
        config       : uart_config := uart_default_test_config
    );
end entity uart_filter_tb;

architecture sim of uart_filter_tb is

    --================================= Constants =====================================--
    constant time_clk     : time     := 1 us;
    constant time_skew    : time     := time_clk / 50;
    constant loop_iter    : integer  := 5;    -- number of test loop iteration
    constant do_test_0    : boolean  := true; -- test0: Switch to one/zero
    constant do_test_1    : boolean  := true; -- test1: Switch to one and apply noisy signal
    constant do_test_2    : boolean  := true; -- test2: Switch to zero and apply noisy signal
    
    --================================= Signals =====================================--
    signal clk:         std_ulogic;
    signal reset:       std_ulogic;
    signal data_in:     std_ulogic;
    signal data_out:    std_ulogic;
    signal clk_enable:  std_ulogic := '1';
begin

    FILTER_TEST: uart_filter 
        generic map (
            config   => config
        )
        port map (
            clk      => clk,     -- clock, rising edge
            reset    => reset,   -- asynchronous reset
            data_in  => data_in, -- serial in
            data_out => data_out -- synced & voted input bit
        );

    SIMULATE : process
        variable good: boolean := true;
    begin
        -- Init
        Report "Init...";
        reset     <=  '1';
        data_in   <=  '0';
        wait for 5 * time_clk;
        wait until rising_edge(clk); wait for time_skew;
        reset   <=  '0';
        wait until rising_edge(clk); wait for time_skew;

        -- Test0: Switch to one/zero
        if do_all_tests or do_test_0 then
            Report "Test0: Switch to one/zero";
            wait until rising_edge(clk); wait for time_skew;
            data_in <= '1';
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            data_in <= '1';
            wait until rising_edge(clk); wait for time_skew;  -- 2 stages sync chain
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            assert (data_out = '1') report "data_out needs to be 1" severity failure;
            if not (data_out = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            assert (data_out = '1') report "data_out needs to be 1" severity failure;
            if not (data_out = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            assert (data_out = '1') report "data_out needs to be 1" severity failure;
            if not (data_out = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            assert (data_out = '1') report "data_out needs to be 1" severity failure;
            if not (data_out = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            assert (data_out = '1') report "data_out needs to be 1" severity failure;
            if not (data_out = '1') then good := false; end if;
            wait for 10 * time_clk;
        end if;

        -- Test1: Switch to one and apply noisy signal
        if do_all_tests or do_test_1 then
            Report "Test1: Switch to one and apply noisy signal";
            wait until rising_edge(clk); wait for time_skew;
            data_in <= '1';
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            data_in <= '0';
            wait until rising_edge(clk); wait for time_skew; 
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            assert (data_out = '1') report "data_out accidentally toggled" severity failure;
            if not (data_out = '1') then good := false; end if;
            for i in 0 to loop_iter - 1 loop
                data_in <= '1';
                assert (data_out = '1') report "data_out accidentally toggled" severity failure;
                if not (data_out = '1') then good := false; end if;
                wait until rising_edge(clk); wait for time_skew;
                data_in <= '0';
                assert (data_out = '1') report "data_out accidentally toggled" severity failure;
                if not (data_out = '1') then good := false; end if;
                wait until rising_edge(clk); wait for time_skew;
            end loop;
            wait for 10 * time_clk;
        end if;

        -- Test2: Switch to zero and apply noisy signal
        if do_all_tests or do_test_2 then
            Report "Test1: Switch to zero and apply noisy signal";
            wait until rising_edge(clk); wait for time_skew;
            data_in <= '0';
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            data_in <= '0';
            wait until rising_edge(clk); wait for time_skew; 
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            assert (data_out = '0') report "data_out accidentally toggled" severity failure;
            if not (data_out = '0') then good := false; end if;
            for i in 0 to loop_iter - 1 loop
                data_in <= '1';
                assert (data_out = '0') report "data_out accidentally toggled" severity failure;
                if not (data_out = '0') then good := false; end if;
                wait until rising_edge(clk); wait for time_skew;
                data_in <= '0';
                assert (data_out = '0') report "data_out accidentally toggled" severity failure;
                if not (data_out = '0') then good := false; end if;
                wait until rising_edge(clk); wait for time_skew;
            end loop;
            wait for 10 * time_clk;
        end if;

        Report "End TB...";     -- sim finished
        if (good) then
            Report "Test SUCCESSFUL";
        else
            Report "Test FAILED" severity failure;
        end if;
        wait until falling_edge(clk); wait for time_skew;
        clk_enable <= '0';
        wait;     

    end process SIMULATE; 

    P_CLK : process
    variable v_clk : std_ulogic := '0';
    begin
        while (clk_enable = '1') loop
            clk <= v_clk;
            v_clk := not v_clk;
            wait for time_clk/2;
        end loop;
        wait;
    end process P_CLK; 
    
end architecture sim;