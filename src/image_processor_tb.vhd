library ieee;
use ieee.std_logic_1164.all;
use WORK.image_processor_pack.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use std.env.finish;

entity image_processor_tb is        -- The Testbench entity is empty. No ports.
end entity;

architecture behave of image_processor_tb is    -- This is the architecture of the testbench

    -- constants declaration    
    constant C_CLK_PRD              : time    := 40 ns; -- 50MHz clock period
    constant C_VAL_1SEC             : integer := 3;
    constant C_RESET_ACTIVE_VALUE   : std_logic := '0';


    component image_processor is                -- This is the component declaration.
    generic (
        G_VAL_1SEC    : integer -- In CLK units (1 [sec in ns] / 40 [ns, 1 clock period]) 
    );
    port (
                                -- System Signals --
        CLK 	         : in  std_logic; -- System clock. 50MHz
        RSTn 	         : in  std_logic; -- Active low system reset. Connect to KEY0
                                 -- USER Signals --
        KEY_ROTATE       : in  std_logic;  -- Rotate the image. Rotation direction according to SW_ROTATION_DIR
        SW_ROTATION_DIR  : in  std_logic; -- 0 – Rotate CW, 1 – Rotate CCW.
        SW_IMAGE_ENA     : in  std_logic; -- 0 – Show color bar, 1 – Show image from SRAM.
        SW_MODE          : in  std_logic; -- 0 – Manual mode, 1 – Automatic rotation
                                -- SRAM Signals --
        SRAM_A           : out std_logic_vector(17 downto 0) := (others => '0'); -- SRAM address
        SRAM_D           : in std_logic_vector(15 downto 0) := (others => '0'); -- SRAM data
        SRAM_CEn         : out std_logic;       -- SRAM chip enable. Should be always enabled.
        SRAM_OEn         : out std_logic;       -- SRAM output enable. Should be always enabled.
        SRAM_WEn         : out std_logic;       -- SRAM write enable. Should be always disabled.
        SRAM_UBn         : out std_logic;       -- SRAM upper byte enable. Should be always enabled.
        SRAM_LBn         : out std_logic;       -- SRAM lower byte enable. Should be always enabled. 
                             -- HDMI Signals --                 
        HDMI_TX          : out std_logic_vector(23 downto 0);    -- 24-bit RGB pixel data to the HDMI controller.
        HDMI_TX_VS       : out std_logic;       -- Vertical sync signal to the HDMI controller.
        HDMI_TX_HS       : out std_logic;       -- Horizontal sync signal to the HDMI controller.
        HDMI_TX_DE       : out std_logic;       -- Data enable signal to the HDMI controller.
        HDMI_TX_CLK      : out std_logic;       -- 25MHz clock signal to the HDMI controller.
                                -- 7 Segment signals --
        HEX0             : out std_logic_vector(6 downto 0); -- 7 segment display unity digit
        HEX1             : out std_logic_vector(6 downto 0);    -- 7 segment display tens digit
        HEX2             : out std_logic_vector(6 downto 0);    -- 7 segment display hundreds digit
        HEX3             : out std_logic_vector(6 downto 0)    -- 7 segment display thousands digit
    );
    end component;


    -- signals declaration  
    signal clk_sig              : std_logic := '0';
    signal rst_sig              : std_logic := not C_RESET_ACTIVE_VALUE;
    signal key_rotate_sig       : std_logic := C_BUTTON_NORMAL_STATE;
    signal sw_rotation_dir_sig  : std_logic := '0';
    signal sw_image_ena_sig     : std_logic := '1';
    signal sw_mode_sig          : std_logic := '0';
    signal sram_a_sig           : std_logic_vector(17 downto 0) := (others => '0');
    signal sram_d_sig           : std_logic_vector(15 downto 0) := (others => '0');
    signal sram_cen_sig         : std_logic := '0';
    signal sram_oen_sig         : std_logic := '0';
    signal sram_wen_sig         : std_logic := '1';
    signal sram_ubn_sig         : std_logic := '0';
    signal sram_lbn_sig         : std_logic := '0';

    
    signal hdmi_tx_sig          : std_logic_vector(23 downto 0);
    signal hdmi_vs_sig          : std_logic;
    signal hdmi_hs_sig          : std_logic;
    signal hdmi_de_sig          : std_logic;
    signal hdmi_clk_sig         : std_logic;
    

begin
    
   
    uut: image_processor                    -- This is the component instantiation. uut is the instance name of the component counter_2_digits
    generic map (
        G_VAL_1SEC   => C_VAL_1SEC
    )
    port map (
                           
        CLK 	           => clk_sig,
        RSTn 	           => rst_sig,
                                   
        KEY_ROTATE         => key_rotate_sig,
        SW_ROTATION_DIR    => sw_rotation_dir_sig,
        SW_IMAGE_ENA       => sw_image_ena_sig,
        SW_MODE            => sw_mode_sig,
                    
        SRAM_A             => sram_a_sig,
        SRAM_D             => sram_d_sig,
        SRAM_CEn           => sram_cen_sig,
        SRAM_OEn           => sram_oen_sig,
        SRAM_WEn           => sram_wen_sig,
        SRAM_UBn           => sram_ubn_sig,
        SRAM_LBn           => sram_lbn_sig,                               
        HDMI_TX            => hdmi_tx_sig,
        HDMI_TX_VS         => hdmi_vs_sig,
        HDMI_TX_HS         => hdmi_hs_sig,
        HDMI_TX_DE         => hdmi_de_sig,
        HDMI_TX_CLK        => hdmi_clk_sig,
        
        HEX0 => open,
        HEX1  => open,
        HEX2  => open,
        HEX3  => open
    );



    sram_inst: entity work.sim_sram
    generic map (
        ini_file_name => "mem.bin"
    )
    port map (
        SRAM_ADDR       => sram_a_sig,
        SRAM_DQ         => sram_d_sig,
        SRAM_WE_N       => sram_wen_sig,
        SRAM_OE_N       => sram_oen_sig,
        SRAM_UB_N       => sram_ubn_sig,
        SRAM_LB_N       => sram_lbn_sig,
        SRAM_CE_N       => sram_cen_sig
    );
    

    process
    begin
        wait for 10 us;
        sw_image_ena_sig <= not sw_image_ena_sig after 50 ms;
        key_rotate_sig <= not key_rotate_sig; -- Press button
        wait for C_CLK_PRD;
        key_rotate_sig <= not key_rotate_sig; -- Release button


    end process;


 
    clk_sig <= not clk_sig after C_CLK_PRD / 2;     -- clk_sig toggles every C_CLK_PRD/2 ns

end architecture;
