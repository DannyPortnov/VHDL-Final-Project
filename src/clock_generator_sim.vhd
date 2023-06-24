library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_generator is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		locked   : out std_logic         --  locked.export
	);
end entity clock_generator;

architecture rtl of clock_generator is


	signal clk_sig		: std_logic := '0';
	signal locked_int	: std_logic := '0';

begin	
	
	locked_int <= '0' when rst = '1' else '1' after 10 us;
	
	process
	begin

		if locked_int = '1' then
			wait until rising_edge(refclk);
			clk_sig <= not clk_sig;
		else
			clk_sig <= '0';
			wait until locked_int = '1';
		end if;

	end process;
	
	outclk_0 <= clk_sig when locked_int = '1' else 'X';
	
	process
	begin
		locked <= '0';
		wait until locked_int  = '1';
		wait for 100 ns;
		wait until rising_edge(clk_sig);
		locked <= '1';
		wait until locked_int = '0';
		locked <= '0';
	end process;
		
end architecture;