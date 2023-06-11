-- Created by   :   Le Vu Duc Hung
-- Date         :   7-Jun-23

library ieee;
use ieee.std_logic_1164.all; 

entity finiteStateMachine is
port(
    clk, reset : in std_logic;
    level      : in std_logic;
    Moore_tick : out std_logic 
);
end finiteStateMachine;

architecture arch of finiteStateMachine is 
    type stateMoore_type is (A, B, C); -- 3 states are required for Moore
    signal stateMoore_reg, stateMoore_next : stateMoore_type;
    signal counter : integer range 0 to 10 := 0; -- Counter for state B
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
						  counter <= 0; -- Reset the counter
                end if; 
            when B => 
                Moore_tick <= '1'; -- set the tick to 1.
                if level = '1' then -- if level is 1, 
						  if counter = 10 then
								stateMoore_next <= C; --go to state C,
								counter <= 0;
							else
								counter <= counter + 1;
							end if;
					  elsif level = '0' then -- if level is 0,
                     stateMoore_next <= C; -- go to state C directly.
                     counter <= 0; -- Reset the counter
                 end if;
                 Moore_tick <= '1'; -- set the tick to 1.
            when C =>
                if level = '0' then -- if level is 0, 
                    stateMoore_next <= A; -- then go to state A.
						  counter <= 0;
                end if;
        end case; 
    end process;  
end arch; 