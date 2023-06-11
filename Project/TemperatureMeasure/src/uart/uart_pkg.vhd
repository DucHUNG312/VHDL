-- =============================================================================
-- AUTHORS:   Le Vu Duc Hung
--
-- FILE:      uart_pkg.vhd
-- =============================================================================
-- MIT License
-- Copyright (c) 2023 Le Vu Duc Hung
--
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package uart_pkg is
    
    --================================= Constants =================================--
    constant uart_8N1:        STD_ULOGIC_VECTOR(7 downto 0) := "10000100"; -- 132
    constant crt_use_parity:  INTEGER := 0;
    constant crt_even_parity: INTEGER := 1;
    
    --================================= Types =====================================--
    type uart_generics is record
        clock_frequency:    POSITIVE; -- clock frequency
        delay:              TIME; -- gate delay for simulation purposes
        asynchronous_reset: BOOLEAN; -- use asynchronous reset if true
    end record;
    
    --================================= Functions ===================================--
    function parity(slv: STD_ULOGIC_VECTOR; even: BOOLEAN)     return STD_ULOGIC;
    function parity(slv: STD_ULOGIC_VECTOR; even: STD_ULOGIC)  return STD_ULOGIC;
    function crt_stop_bits(crt: STD_ULOGIC_VECTOR(7 downto 0)) return INTEGER;
    function crt_data_bits(crt: STD_ULOGIC_VECTOR(7 downto 0)) return INTEGER;
    
    --================================= UART_TX ===================================--
    component uart_tx is
        generic(
            g:       uart_generics;
            N:       POSITIVE;
            format:  STD_ULOGIC_VECTOR(7 downto 0) := uart_8N1;
            use_cfg: BOOLEAN
        );
        port(
            clk:    in STD_ULOGIC;
            rst:    in STD_ULOGIC;
            baud:   in STD_ULOGIC;
            ctr:    in STD_ULOGIC_VECTOR(format'range);
            ctr_we: in STD_ULOGIC;
            we:     in STD_ULOGIC;
            di:     in STD_ULOGIC_VECTOR(N-1 downto 0);
            
            cr:     out STD_ULOGIC;
            tx:     out STD_ULOGIC;
            ok:     out STD_ULOGIC
        );
    end component;
    
    --================================= UART_RX ===================================--
    component uart_rx is
        generic(
            g:       uart_generics;
            N:       POSITIVE;
            D:       POSITIVE;
            format:  STD_ULOGIC_VECTOR(7 downto 0) := uart_8N1;
            use_cfg: BOOLEAN
        );
        port(
            clk:    in STD_ULOGIC;
            rst:    in STD_ULOGIC;
            baud:   in STD_ULOGIC;
            sample: in STD_ULOGIC;
            ctr:    in STD_ULOGIC_VECTOR(format'range);
            ctr_we: in STD_ULOGIC;
            rx:     in STD_ULOGIC;
            
            cr:     out STD_ULOGIC;
            failed: out STD_ULOGIC_VECTOR(1 downto 0);
            we:     out STD_ULOGIC;
            do:     out STD_ULOGIC_VECTOR(N-1 downto 0)
        );
    end component;
    
    --================================= UART_FIFO ===================================--
    component uart_fifo is
        generic (
            g:           uart_generics;
            data_width:  POSITIVE;
            fifo_depth:  POSITIVE;
            read_first:  BOOLEAN := true);
        port (
            clk: in STD_ULOGIC;
            rst: in STD_ULOGIC;
            di:  in STD_ULOGIC_VECTOR(data_width - 1 downto 0);
            we:  in STD_ULOGIC;
            re:  in STD_ULOGIC;
            do:  out STD_ULOGIC_VECTOR(data_width - 1 downto 0);

            -- Optional
            full:  out STD_ULOGIC := '0';
            empty: out STD_ULOGIC := '1');
    end component;
    
    --================================= UART_BAUD ===================================--
    component uart_baud is -- Generates a pulse at the sample rate and baud
        generic(
            g:    uart_generics;
            init: INTEGER;
            N:    POSITIVE := 16;
            D:    POSITIVE := 3
        );
        port(
            clk:    in STD_ULOGIC;
            reset:  in STD_ULOGIC;
            we:     in STD_ULOGIC;
            cnt:    in STD_ULOGIC_VECTOR(N-1 downto 0);
            cr:     in STD_ULOGIC := '0';
            sample: out STD_ULOGIC;
            baud:   out STD_ULOGIC
        );
    end component;
    
    --================================= UART_TOP ===================================--
    component uart_top is
        generic (
            clock_frequency:    POSITIVE; -- clock frequency of module clock
            delay:              TIME;     -- gate delay for simulation purposes
            asynchronous_reset: BOOLEAN;  -- use asynchronous reset if true
            baud:               POSITIVE := 115200;
            format:             STD_ULOGIC_VECTOR(7 downto 0) := uart_8N1;
            fifo_depth:         NATURAL := 0;
            use_cfg:            BOOLEAN := false;
            use_tx:             BOOLEAN := true;
            use_rx:             BOOLEAN := true
        );
        port (
            clk:             in STD_ULOGIC;
            rst:             in STD_ULOGIC;
            tx_fifo_we:      in STD_ULOGIC;
            tx_fifo_data:    in STD_ULOGIC_VECTOR(7 downto 0);
            rx:              in STD_ULOGIC;
            rx_fifo_re:      in STD_ULOGIC;
            reg:             in STD_ULOGIC_VECTOR(15 downto 0);
            clock_reg_tx_we: in STD_ULOGIC;
            clock_reg_rx_we: in STD_ULOGIC;
            control_reg_we:  in STD_ULOGIC;

            tx:              out STD_ULOGIC;
            tx_fifo_full:    out STD_ULOGIC;
            tx_fifo_empty:   out STD_ULOGIC;
            rx_fifo_full:    out STD_ULOGIC;
            rx_fifo_empty:   out STD_ULOGIC;
            rx_fifo_data:    out STD_ULOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    --================================= UART_TB ===================================--
    component uart_tb is
        generic(g: uart_generics);
    end component;
    
end package uart_pkg;




package body uart_pkg is
    
    function parity(slv: STD_ULOGIC_VECTOR; even: BOOLEAN) return STD_ULOGIC is
        variable z: STD_ULOGIC := '0';
    begin
        if NOT even then
            z := '1';
        end if;
        for i in slv'range loop
            z := z XOR slv(i);
        end loop;
        return z;
    end function parity;
    
    
    function parity(slv: STD_ULOGIC_VECTOR; even: STD_ULOGIC)  return STD_ULOGIC is
        variable z: BOOLEAN := false;
    begin
        if even = '1' then
            z := true;
        end if;
        return parity(slv, z);
    end function parity;
    
    
    function crt_stop_bits(crt: STD_ULOGIC_VECTOR(7 downto 0)) return INTEGER is
        variable ii: STD_ULOGIC_VECTOR(1 downto 0);
    begin
        ii := crt(3 downto 2);
        return to_integer(UNSIGNED(ii));
    end function crt_stop_bits;
    
    
    function crt_data_bits(crt: STD_ULOGIC_VECTOR(7 downto 0)) return INTEGER is
        variable ii: STD_ULOGIC_VECTOR(3 downto 0);
    begin
        ii := crt(7 downto 4);
        return to_integer(UNSIGNED(ii));
    end function crt_data_bits;

end package body uart_pkg;















