library ieee;
use ieee.std_logic_1164.all;

entity timing_generatortb is        -- The Testbench entity is empty. No ports.
end entity;

architecture behave of timing_generatortb is    -- This is the architecture of the testbench

-- constants declaration    
    constant C_CLK_PRD                   : time      := 20 ns;
    constant C_RESET_ACTIVE_VALUE        : std_logic := '0';
    constant C_PIXELS_PER_LINE           : integer   := 800;
    constant C_PIXELS_PER_FRAME          : integer   := 525;

    component timing_generator is                -- This is the component declaration.
    generic (
        G_RESET_ACTIVE_VALUE        : std_logic;
        G_PIXELS_PER_LINE           : integer;
        G_PIXELS_PER_FRAME          : integer;
        -- VISIBLE_PIXELS_PER_LINE     : integer;
        -- VISIBLE_PIXELS_PER_FRAME    : integer;
    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        H_CNT       : out integer range 0 to PIXELS_PER_LINE-1;
        V_CNT       : out integer range 0 to PIXELS_PER_FRAME-1;
        H_SYNC      : out std_logic;
        V_SYNC      : out std_logic;
        VS          : out std_logic
    );
    end component;


-- signals declaration  
    signal clk_sig       : std_logic := '0';
    signal rst_sig       : std_logic := '1';
    
    
begin
   
    uut: timing_generator                    -- This is the component instantiation. uut is the instance name of the component counter_2_digits
    generic map (
        G_RESET_ACTIVE_VALUE => C_RESET_ACTIVE_VALUE,
        G_PIXELS_PER_LINE    => C_PIXELS_PER_LINE,
        G_PIXELS_PER_FRAME   => C_PIXELS_PER_FRAME
    )
    port map (
        RST                => rst_sig, -- The RST input of the uut instance of the timing_generator component is connected to rst_sig signal
        CLK                => clk_sig, -- The CLK input of the uut instance of the timing_generator component is connected to clk_sig signal
    );

    process
    begin
        -- wait for (5*C_TOTAL_PLACES/2)*C_CLK_PRD/2 + C_CLK_PRD/10; --Enough for output to reach 60+11 'minutes'
        -- wait for C_CLK_PRD;
        
    -- --start filling the parking places
    --     CAR_IN_sig <= '1';
    --     CAR_OUT_sig <= '0';
    --     wait for (C_TOTAL_PLACES + 2)*C_CLK_PRD; --check that output doesn't exceeds the lower limit: 0
        
    -- --start emptying the parking places
    --     CAR_IN_sig <= '0';
    --     CAR_OUT_sig <= '1';
    --     wait for (C_TOTAL_PLACES + 2)*C_CLK_PRD; --check that output doesn't exceeds the upper limit: Total Places

    -- --start filling the parking places
    --     CAR_IN_sig <= '1';
    --     CAR_OUT_sig <= '0'; 
    --     wait for (C_TOTAL_PLACES/2)*C_CLK_PRD;

    -- -- reset the system
    --     rst_sig <= not rst_sig;
    --     wait for C_CLK_PRD;
    --     rst_sig <= not rst_sig;
    --     wait for C_CLK_PRD;
        
    -- --start filling the parking places
    --     CAR_IN_sig <= '1';
    --     CAR_OUT_sig <= '0';        
    --     wait for (C_TOTAL_PLACES/5)*C_CLK_PRD;
        
    -- --no change when both in and out equal to '1'
    --     CAR_IN_sig <= '1';
    --     CAR_OUT_sig <= '1';
    --     wait for (C_TOTAL_PLACES/2)*C_CLK_PRD;

    -- --start filling the parking places
    --     CAR_IN_sig <= '1';
    --     CAR_OUT_sig <= '0';        
    --     wait for (C_TOTAL_PLACES/2)*C_CLK_PRD;
    
    -- --start emptying the parking places
    --     CAR_IN_sig <= '0';
    --     CAR_OUT_sig <= '1';
    --     wait for (C_TOTAL_PLACES/2)*C_CLK_PRD;  
        
    -- -- reset the system
    --     rst_sig <= not rst_sig;
    --     wait for C_CLK_PRD;    
	-- end process;
 
    clk_sig <= not clk_sig after C_CLK_PRD / 2;     -- clk_sig toggles every C_CLK_PRD/2 ns

end architecture;
