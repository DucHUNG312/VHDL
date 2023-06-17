-- ==================================================================================================================
-- @author:          Le Vu Duc Hung
--
-- @license:         MIT
--
-- @copyright:       Copyright (c) 2023
--
-- @maintainer:      Le Vu Duc Hung
--
-- @file:            uart_baud_tb.vhd
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

entity uart_baud_tb is
    generic (
        do_all_tests : boolean     := false;
        config       : uart_config := uart_default_test_config
    );
end entity uart_baud_tb;

architecture sim of uart_baud_tb is
    
    --================================= Constants =====================================--
    constant time_clk     : time     := 1 us;
    constant time_skew    : time     := time_clk / 50;
    constant loop_iter    : integer  := 20; -- number of test loop iteration
    constant do_test_0    : boolean  := true; -- test0: receive single data word

    --================================= Signals =====================================--
    signal clk                       : std_ulogic;
    signal reset                     : std_ulogic;
    signal start                     : std_ulogic; 
    signal busy                      : std_ulogic;
    signal shift_register_load       : std_ulogic;
    signal shift_register_begin      : std_ulogic;
    signal shift_register_middle     : std_ulogic;
    signal shift_register_capture    : std_ulogic;
    signal clk_enable                : std_ulogic := '1';

begin
    BAUD_GEN: uart_baud
    generic map (
        config                 => config
    )
    port map (
        clk                    => clk,
        reset                  => reset,
        start                  => start,

        busy                   => busy,
        shift_register_load    => shift_register_load,
        shift_register_begin   => shift_register_begin,
        shift_register_middle  => shift_register_middle,
        shift_register_capture => shift_register_capture
    );

    SIMULATE : process
        variable good : boolean := true;
    begin
        -- Init
        Report "Init...";
        reset   <=  '1';
        start   <=  '0';
        wait for 5 * time_clk;
        wait until rising_edge(clk); wait for time_skew;
        reset   <=  '0';
        wait until rising_edge(clk); wait for time_skew;


        -- Test0: Single shoot
        if do_all_tests or do_test_0 then
            Report "Test0: Single shoot";
            wait until rising_edge(clk); wait for time_skew;
            start <= '1';
            wait until rising_edge(clk); wait for time_skew;
            start <= '0';
            ------------------------------------------------
            assert (shift_register_load = '1') report "Error: Failed Load TX Shift Register" severity failure;
            if not (shift_register_load = '1') then good := false; end if;
            assert (shift_register_begin = '1') report "Error: Failed Begin TX Shift Register" severity failure;
            if not (shift_register_begin = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            assert (shift_register_begin = '0') report "Error: Failed Begin TX Shift Register" severity failure;
            if not (shift_register_begin = '0') then good := false; end if;
            assert (shift_register_middle = '1') report "Error: Failed Middle TX Shift Register" severity failure;
            if not (shift_register_middle = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            ------------------------------------------------
            assert (shift_register_begin = '1') report "Error: Failed Begin TX Shift Register" severity failure;
            if not (shift_register_begin = '1') then good := false; end if;
            assert (shift_register_middle = '0') report "Error: Failed Middle TX Shift Register" severity failure;
            if not (shift_register_middle = '0') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            assert (shift_register_begin = '0') report "Error: Failed Begin TX Shift Register" severity failure;
            if not (shift_register_begin = '0') then good := false; end if;
            assert (shift_register_middle = '1') report "Error: Failed Middle TX Shift Register" severity failure;
            if not (shift_register_middle = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            ------------------------------------------------
            assert (shift_register_begin = '1') report "Error: Failed Begin TX Shift Register" severity failure;
            if not (shift_register_begin = '1') then good := false; end if;
            assert (shift_register_middle = '0') report "Error: Failed Middle TX Shift Register" severity failure;
            if not (shift_register_middle = '0') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            assert (shift_register_begin = '0') report "Error: Failed Begin TX Shift Register" severity failure;
            if not (shift_register_begin = '0') then good := false; end if;
            assert (shift_register_middle = '1') report "Error: Failed Middle TX Shift Register" severity failure;
            if not (shift_register_middle = '1') then good := false; end if;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            wait until rising_edge(clk); wait for time_skew;
            ------------------------------------------------
            assert (shift_register_begin = '0') report "Error: Failed Begin TX Shift Register" severity failure;
            if not (shift_register_begin = '0') then good := false; end if;
            assert (shift_register_middle = '0') report "Error: Failed Middle TX Shift Register" severity failure;
            if not (shift_register_middle = '0') then good := false; end if;
            ------------------------------------------------
            assert (busy'stable((2 * config.clk_div - 1) * time_clk)) report "Error: Busy unexpected toggled" severity failure;
            if not (busy'stable((2 * config.clk_div - 1) * time_clk)) then good := false; end if;
            assert (busy = '1') report "Error: Needs to be busy" severity failure;
            if not (busy = '1') then good := false; end if;
            while (busy = '1') loop
                wait until rising_edge(clk); wait for time_skew;
            end loop;
        end if;
        
        -- Report
        Report "End TB...";     -- sim finished
                if (good) then
                    Report "Test SUCCESSFUL";
                else
                    Report "Test FAILED" severity failure;
                end if;
                wait until falling_edge(clk); wait for time_skew;
                clk_enable <= '0';
                wait;           -- stop process continuous run


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