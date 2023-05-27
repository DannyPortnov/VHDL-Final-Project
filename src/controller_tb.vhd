library ieee;
use ieee.std_logic_1164.all;

entity controller_tb is        -- The Testbench entity is empty. No ports.
end entity;

architecture behave of controller_tb is    -- This is the architecture of the testbench

-- constants declaration    
    constant C_CLK_PRD              : time      := 40 ns; -- 25 MHz clock
    constant C_RESET_ACTIVE_VALUE   : std_logic := '0';   -- Determines the RST input polarity. 
    constant C_VAL_1SEC             : integer   := 3; --  amount of clock periods

    component controller is
    generic (
        G_RESET_ACTIVE_VALUE : std_logic;
        G_VAL_1SEC : integer
    );
    port (
        RST             : in std_logic;
        CLK             : in std_logic;
        ROTATE          : in std_logic;
        ROTATION_DIR    : in std_logic;
        VS              : in std_logic;
        MODE            : in std_logic;
        ANGLE           : out integer range 0 to 3;
        HEX0            : out std_logic_vector(6 downto 0);
        HEX1            : out std_logic_vector(6 downto 0);
        HEX2            : out std_logic_vector(6 downto 0);
        HEX3            : out std_logic_vector(6 downto 0)
    );
    end component;

-- signals declaration  
    signal clk_sig          : std_logic := '0';
    signal rst_sig          : std_logic := not C_RESET_ACTIVE_VALUE;
    signal rotate_sig       : std_logic := '0';
    signal rotation_dir_sig : std_logic := '0';
    signal vs_sig           : std_logic := '0';
    signal mode_sig         : std_logic := '0';
    signal angle_sig        : integer range 0 to 3;
    signal hex0_sig         : std_logic_vector(6 downto 0);
    signal hex1_sig         : std_logic_vector(6 downto 0);
    signal hex2_sig         : std_logic_vector(6 downto 0);
    signal hex3_sig         : std_logic_vector(6 downto 0);
    
begin
   
    uut: controller                    -- This is the component instantiation. dut is the instance name of the component pulse_generator
    generic map (
        G_RESET_ACTIVE_VALUE    => C_RESET_ACTIVE_VALUE,  
        G_VAL_1SEC              => C_VAL_1SEC
    )
    port map (
        RST => rst_sig,
        CLK => clk_sig,
        ROTATE => rotate_sig,
        ROTATION_DIR => rotation_dir_sig,
        VS => vs_sig,
        MODE => mode_sig,
        ANGLE => angle_sig,
        HEX0 => hex0_sig,
        HEX1 => hex1_sig,
        HEX2 => hex2_sig,
        HEX3 => hex3_sig
    );

    process
    begin
        wait for C_CLK_PRD;

        -- Test 1:automatic mode, vs enabled, rotate CW
        mode_sig <= '1';
        vs_sig <= '1';

        wait for 3 * (C_VAL_1SEC + 2) * C_CLK_PRD;-- Test all angles
        rotate_sig <= not rotate_sig; -- Shouldn't affect rotation in automatic mode
        wait for 2 * (C_VAL_1SEC + 2) * C_CLK_PRD;

        rst_sig <= not rst_sig; -- reset
        wait for C_CLK_PRD/2;
        rst_sig <= not rst_sig;

        -- Test 2:automatic mode, vs enabled, rotate CCW
        rotation_dir_sig <= not rotation_dir_sig;
        wait for 3 * (C_VAL_1SEC + 2) * C_CLK_PRD;-- Test all angles
        rotate_sig <= not rotate_sig; -- Shouldn't affect rotation in automatic mode
        wait for 2 * (C_VAL_1SEC + 2) * C_CLK_PRD;

        rst_sig <= not rst_sig; -- reset
        wait for C_CLK_PRD/2;
        rst_sig <= not rst_sig;

        -- Test 3:manual mode, rotate CW
        mode_sig <= not mode_sig;
        rotate_sig <= '1';
        wait for 3 * C_CLK_PRD;-- Test all angles
        vs_sig <= not vs_sig; -- Shouldn't affect rotation in manual mode
        wait for 3 * C_CLK_PRD;

        rst_sig <= not rst_sig; -- reset
        wait for C_CLK_PRD/2;
        rst_sig <= not rst_sig;

        -- Test 4:manual mode, rotate CCW
        rotation_dir_sig <= not rotation_dir_sig;
        wait for 6 * C_CLK_PRD;-- Test all angles

        rst_sig <= not rst_sig; -- reset
        wait for C_CLK_PRD/2;
        rst_sig <= not rst_sig;

        -- Test 5:automatic mode, vs disabled midway
        mode_sig <= not mode_sig;

        wait for 2 * C_VAL_1SEC * C_CLK_PRD; 
        vs_sig <= not vs_sig;
        wait for 3 * C_VAL_1SEC * C_CLK_PRD; -- See that angle stops changing after disabling vs

        rst_sig <= not rst_sig; -- reset
        wait for C_CLK_PRD/2;
        rst_sig <= not rst_sig;

        -- Test 6:manual mode, rotate both ways
        mode_sig <= not mode_sig;
        
        wait for 4 * C_CLK_PRD; -- Test all angles
        rotation_dir_sig <= not rotation_dir_sig;
        wait for 3  * C_CLK_PRD;

        --assert angle_sig = 1 report "Test failed: expected angle_sig = 1 but got " & integer'image(angle_sig) severity error;

        wait;
    end process;
    

    
    clk_sig <= not clk_sig after C_CLK_PRD / 2;     -- clk_sig toggles every C_CLK_PRD/2 ns

end architecture;

