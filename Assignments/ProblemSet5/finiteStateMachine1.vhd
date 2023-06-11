library ieee;
use ieee.std_logic_1164.all; 

entity finiteStateMachine1 is
port(
    clk, reset : in std_logic;
    level      : in std_logic;
    Moore_tick : out std_logic 
);
end finiteStateMachine1;

architecture arch of finiteStateMachine1 is 
    type stateMoore_type is (A, B, C); -- 3 states are required for Moore
    signal stateMoore_reg, stateMoore_next : stateMoore_type;
    
begin   
    process(clk, reset)
    begin
        if (reset = '1') then -- go to state zero if reset
            stateMoore_reg <= A;
        elsif (clk'event and clk = '1') then -- otherwise update the states
            stateMoore_reg <= stateMoore_next;
        else
            null;
        end if; 
    end process;
    
    -- Moore Design
    process(stateMoore_reg, level)
begin 
        -- store current state as next
        stateMoore_next <= stateMoore_reg; -- required: when no case statement is satisfied
        
        Moore_tick <= '0'; -- set tick to zero (so that 'tick = 1' is available for 1 cycle only)
        case stateMoore_reg is 
            when A => -- if state is zero, 
                if level = '1' then  -- and level is 1
                    stateMoore_next <= B; -- then go to state B.
                end if; 
            when B => 
                Moore_tick <= '1'; -- set the tick to 1.
                if level = '1' then -- if level is 1, 
                    stateMoore_next <= C; --go to state C,
                end if;
            when C =>
                if level = '0' then -- if level is 0, 
                    stateMoore_next <= A; -- then go to state A.
                end if;
        end case; 
    end process;  
end arch; 