library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity trig_gen is
    port (
        clk: in std_logic;
        S: in integer;
        THRES: in integer;
        TRG: out std_logic
    );
end entity trig_gen;

architecture rtl of trig_gen is
    signal S_prev: integer;
    signal tick: std_logic := '0';
begin
    process(clk, S)
    begin
        tick <= '0';
        if ((S_prev < THRES) and (S > THRES)) or ((S_prev > THRES) and (S < THRES)) then
            tick <= '1';
        end if;
        S_prev <= S;
    end process; 
    TRG <= tick;
end architecture rtl;