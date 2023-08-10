library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ex5_2 is
    port (
        x: in std_logic;
        reset: in std_logic;
        clk: in std_logic;
        y: out std_logic
    );
end entity ex5_2;

architecture rtl of ex5_2 is 
    type stateMoore_type is (A, B, C);
    signal stateMoore_reg, stateMoore_next : stateMoore_type;
    signal count: integer range 0 to 16 := 0;
    signal can_change_state: std_logic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            stateMoore_reg <= A;
        elsif rising_edge(clk) then
            stateMoore_reg <= stateMoore_next;
        end if;
    end process; 

    process(x, stateMoore_reg)
    begin
        stateMoore_next <= stateMoore_reg;
        y <= '0';
        case stateMoore_reg is 
        when A => 
            count <= 0;
            can_change_state <= '0';
            if x = '1' then 
                stateMoore_next <= B;
            end if; 
        when B => 
            count <= count + 1;
            if count = 10 then
                stateMoore_next <= C;
            elsif x = '0' then
                can_change_state <= '1';
            elsif x = '1' and can_change_state = '1' then
                stateMoore_next <= C;
            end if;
        when C =>
            y <= '1';
            if x = '0' then 
                stateMoore_next <= A;
            end if;
        end case;
    end process;
end architecture rtl;