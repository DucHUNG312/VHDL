library ieee; 
use ieee.std_logic_1164.all;

entity signal_variable is 
	port (
		clk   : in std_logic;
		dout1 : out std_logic
	);
end signal_variable;

architecture arch of signal_variable is 
	signal a, b, c : std_logic := '0';
begin

-- Remember :
-- If a ‘signal’ is updated inside the process and then assigned to other signal or ports etc., 
-- then ‘old value’ of the signal will be assigned. The updated value will appear in next clock cycle.
-- Whereas, if a ‘variable’ is updated inside the process and then assigned to other signal or ports etc. then ‘updated value’ will be assigned.
-- Further, we will use ‘variables’ only for the ‘testbenches’ (not for the synthesis).
-- Lastly, avoid update and assignment of signals within the same process block. This can be done by defining two different signals 
-- for updating and assignments. In these chapters, suffix ‘_reg’ and ‘_next’ are used for assignment and updating the signal respectively.
	 
	 process(clk)  -- process with signals only
    begin 
        if (clk'event and clk='1') then
            a <= '1';
            b <= a;  -- b will be '1' in next clock cycle
        end if;
    end process; 
    
    process(clk)  -- process with variable
        variable v : std_logic := '0';
    begin 
        if (clk'event and clk='1') then
            v := '1';
            c <= v;  -- c will be '1' immidiately
        end if;
    end process;
	
	dout1 <= c; -- signal can be used anywhere in the code
	-- error : variable can not be used outside it's process block
	--  dout1 <= v; 
end arch;