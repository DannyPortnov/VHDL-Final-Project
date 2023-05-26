library ieee;
use ieee.std_logic_1164.all;

entity push_button_if_tb is        -- The Testbench entity is empty. No ports.
end entity;

architecture behave of push_button_if_tb is    -- This is the architecture of the testbench

-- constants declaration    
	constant C_PULSES               : integer := 2;
    constant C_CLK_PRD              : time := 40 ns; -- 25 MHz clock
    constant C_RESET_ACTIVE_VALUE   : std_logic := 0,   -- Determines the RST input polarity. 
    constant C_BUTTON_NORMAL_STATE  : std_logic := 0,   -- The state of the push button when not pressed 
    constant C_PRESS_TIMOUT_VAL     : integer   := 200, -- Long press value in 10ms units 
    constant C_TIME_BETWEEN_PULSES  : integer   := 100  -- In 10ms units
    constant C_CLK_PERIODS_IN_10MS : integer := 250000; --  10,000,000 [10ms in ns] / 40 [ns, 1 clock period] = 250,000 (amount of clock periods occuring in 10ms) 

    component push_button_if is                -- This is the component declaration.
    generic (
        G_RESET_ACTIVE_VALUE    : std_logic,   -- Determines the RST input polarity. 
        G_BUTTON_NORMAL_STATE   : std_logic,   -- The state of the push button when not pressed 
        G_PRESS_TIMOUT_VAL      : integer, -- Long press value in 10ms units 
        G_TIME_BETWEEN_PULSES   : integer  -- In 10ms units
    );

    port ( 
        RST         : in std_logic;     -- Asynchronous reset. Active value according to G_RESET_ACTIVE_VALUE
        CLK         : in std_logic;     -- System clock 25MHz
        SW_IN       : in std_logic;     -- Push button input
        PRESS_OUT   : out std_logic;    
    );
    end component;

-- signals declaration  
    signal clk_sig      : std_logic := '0';
    signal rst_sig      : std_logic := not C_RESET_ACTIVE_VALUE;
    signal sw_in_sig    : std_logic := G_BUTTON_NORMAL_STATE;
    
begin
   
    uut: push_button_if                    -- This is the component instantiation. dut is the instance name of the component pulse_generator
    generic map (
        G_RESET_ACTIVE_VALUE    => C_RESET_ACTIVE_VALUE, 
        G_BUTTON_NORMAL_STATE   => C_BUTTON_NORMAL_STATE, 
        G_PRESS_TIMOUT_VAL      => C_PRESS_TIMOUT_VAL, 
        G_TIME_BETWEEN_PULSES   => C_PRESS_TIMOUT_VAL
    )
    port map (
        RST         => rst_sig, -- The RST input of the dut instance of the pulse generator component is connected to rst_sig signal
        CLK         => clk_sig, -- The CLK input of the dut instance of the pulse generator component is connected to clk_sig signal
        SW_IN       => sw_in_sig, -- The SW_IN input of the dut instance of the pulse generator component is connected to sw_in_sig signal
        PRESS_OUT   => open     -- outputs can be left opened
    );

    process 
    begin
        -- Check pressing for less than C_PRESS_TIMOUT_VAL
        wait for C_CLK_PRD/10; -- Wait for 1/10 of the clock period
        sw_in_sig <= not sw_in_sig; -- Press the button
        wait for C_CLK_PRD; -- Wait for 1 clock period
        sw_in_sig <= not sw_in_sig; -- Stop pressing

        -- Check reset
        wait for C_CLK_PRD/10; -- Wait for 1/10 of the clock period
        sw_in_sig <= not sw_in_sig; -- Press the button
        wait for C_CLK_PRD/10;
        rst_sig <= not rst_sig; -- Check rst interrupting the pulse
        wait for C_CLK_PRD/10;
        rst_sig <= not rst_sig; -- Return rst to normal
        sw_in_sig <= not sw_in_sig; -- Stop pressing


        -- Check pressing for more than C_PRESS_TIMOUT_VAL
        wait for C_CLK_PRD/10; -- Wait for 1/10 of the clock period
        sw_in_sig <= not sw_in_sig; -- Press
        wait for 10 ms * C_PRESS_TIMOUT_VAL; -- Press long enough to reach timeout
        wait for 10 ms * C_TIME_BETWEEN_PULSES * C_PULSES; -- Continue pressing to see period pulse 
        rst_sig <= not rst_sig; -- Check rst interrupting the counting
        wait for C_CLK_PRD/10;
        rst_sig <= not rst_sig; -- Return rst to normal
        wait for 10 ms * C_PRESS_TIMOUT_VAL; -- Check timeout again
        wait for 10 ms * C_TIME_BETWEEN_PULSES * C_PULSES; 

	end process;
    
    clk_sig <= not clk_sig after C_CLK_PRD / 2;     -- clk_sig toggles every C_CLK_PRD/2 ns

end architecture;
