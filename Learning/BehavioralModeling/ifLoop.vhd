library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A loop is created using ‘if’ statement, which counts the number upto input ‘x’.
 
 entity ifLoop is
	generic(N : integer := 3);
	port(
		clk : in std_logic; -- clock: increase count on each clk
		x   : in unsigned(N downto 0);
		z   : out unsigned(N downto 0)
	);
 end ifLoop;
 
 architecture behave of ifLoop is
	signal count : unsigned(N downto 0) := (others => '0'); -- count signal
	type stateType is (continueState, stopState); 
	signal currentState : stateType;
 begin
	process(clk, currentState, count)
	begin
		if(count <= x) then -- check whether count is completed till x
			currentState <= continueState;
		else 
			currentState <= stopState;
		end if;
	end process;
 
	-- if we put `count' in below sensitivity list, 
   -- then below process block will work as infinite loop
	process(clk, currentState)
	begin
		if(currentState = continueState) then
			count <= count + 1; -- increase count by 1 if continueState
		else 
			count <= (others => '0'); -- else set count to zero i.e. for stopState
		end if;
	end process;
	
	z <= count; -- show the count on output
 end behave;