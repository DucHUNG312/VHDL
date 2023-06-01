library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myPackage.all;

-- Adding Package to current design example

entity myPackageCall is
	port(
		clk          :       std_logic;
		x            : in    unsigned(2 downto 0);
		count        : out   unsigned(2 downto 0);
		num1, num2   : in    signed(3 downto 0);
		sumConstant  : out   signed(3 downto 0);
		sumProcedure : inout signed(3 downto 0)
	);

end myPackageCall;

architecture arch of myPackageCall is
	signal q            : signed(3 downto 0);
	-- stateType is defined in package
	signal currentState : stateType;
begin
    -- S is defined in package
	sumConstant <= num1 + S;
	
	-- sum2num procedure is defined in package
	sum2num(num1, num2, sumProcedure);
	
	-- if loop begin
	-- f is defined in package
	process(clk, currentState, f)
	begin
		if (f <= x) then
			currentState <= continueState;
		else
			currentState <= stopState;
		end if;
	end process;
	
	process(clk, currentState)
	begin
		if (currentState = continueState) then
			f <= f + 1;
		else
			f <= (others => '0');
		end if;
	end process;
	
	count <= f;
end arch;

