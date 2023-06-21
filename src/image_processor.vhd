library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.image_processor_pack.all;

entity image_processor is
generic (
    G_VAL_1SEC    : integer := 25000000 -- In CLK units (1 [sec in ns] / 40 [ns, 1 clock period]) 
);
port (
                            -- System Signals --
	CLK 	    : in  std_logic; -- System clock. 50MHz
	RSTn 	    : in  std_logic; -- Active low system reset. Connect to KEY0
                                -- USER Signals --
    KEY_ROTATE    : in  std_logic;  -- Rotate the image. Rotation direction according to SW_ROTATION_DIR
                                    -- Short press (<2sec) – Rotate 90° CW or CCW according to SW_ROTATION_DIR.
                                    -- Long press (≥2sec) – Rotate 90° CW or CCW according to SW_ROTATION_DIR every 1 sec as long as this key is pressed.
                                    -- Connect to KEY3.
    SW_ROTATION_DIR    : in  std_logic; -- 0 – Rotate CW.
                                        -- 1 – Rotate CCW.
                                        -- Connect to SW2.
    SW_IMAGE_ENA   : in  std_logic; -- 0 – Show color bar.
                                    -- 1 – Show image from SRAM.
                                    -- Connect to SW9.
    SW_MODE   : in  std_logic;  -- 0 – Normal mode
                                -- 1 – Automatic rotation, each 1 sec. Direction according to SW_ROTATION_DIR.
                                -- Connect to SW4.
                            -- SRAM Signals --
    SRAM_A    : out std_logic_vector(17 downto 0) := (others => '0'); -- SRAM address
    SRAM_D    : in std_logic_vector(15 downto 0)  := (others => '0'); -- SRAM data
    SRAM_CEn  : out std_logic := '0'; -- SRAM chip enable. Should be always enabled.
    SRAM_OEn  : out std_logic := '0'; -- SRAM output enable. Should be always enabled.
    SRAM_WEn  : out std_logic := '1'; -- SRAM write enable. Should be always disabled.
    SRAM_UBn  : out std_logic := '0'; -- SRAM upper byte enable. Should be always enabled.
    SRAM_LBn  : out std_logic := '0'; -- SRAM lower byte enable. Should be always enabled. 
                        -- HDMI Signals --                 
    HDMI_TX     : out std_logic_vector(23 downto 0);    -- 24-bit RGB pixel data to the HDMI controller.
                                                        -- HDMI_TX(23:16) – RED data
                                                        -- HDMI_TX(15:8) – GREEN data
                                                        -- HDMI_TX(7:0) – BLUE data
    HDMI_TX_VS  : out std_logic; -- Vertical sync signal to the HDMI controller.
    HDMI_TX_HS  : out std_logic; -- Horizontal sync signal to the HDMI controller.
    HDMI_TX_DE  : out std_logic;    -- Data enable signal to the HDMI controller.
                                      -- Should be 1 while in visible area and 0 during blanking time.
    HDMI_TX_CLK  : out std_logic; -- 25MHz clock signal to the HDMI controller.
                            -- 7 Segment signals --
    HEX0 : out std_logic_vector(6 downto 0); -- 7 segment display unity digit
    HEX1  : out std_logic_vector(6 downto 0);    -- 7 segment display tens digit
    HEX2  : out std_logic_vector(6 downto 0);    -- 7 segment display hundreds digit
    HEX3  : out std_logic_vector(6 downto 0)    -- 7 segment display thousands digit
);
end entity;
architecture behave of image_processor is 
    component timing_generator is                -- This is the component declaration.
    generic (
        G_RESET_ACTIVE_VALUE        : std_logic
    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        H_CNT       : out integer range 0 to C_PIXELS_PER_LINE-1;
        V_CNT       : out integer range 0 to C_PIXELS_PER_FRAME-1;
        H_SYNC      : out std_logic;
        V_SYNC      : out std_logic;
        VS          : out std_logic
    );
    end component;

    component push_button_if is                -- This is the component declaration.
    generic (
        G_RESET_ACTIVE_VALUE    : std_logic;   -- Determines the RST input polarity. 
                                                    -- 0 – the RST input is active low 
                                                    -- 1 – the RST input is active high
        G_BUTTON_NORMAL_STATE   : std_logic;   -- The state of the push button when not pressed 
        G_PRESS_TIMOUT_VAL      : integer; -- Long press value in 10ms units 
        G_TIME_BETWEEN_PULSES   : integer  -- In 10ms units
    );
    port ( 
        RST         : in std_logic;     -- Asynchronous reset. Active value according to G_RESET_ACTIVE_VALUE
        CLK         : in std_logic;     -- System clock 25MHz
        SW_IN       : in std_logic;     -- Push button input
        PRESS_OUT   : out std_logic    -- Outputs active high, 1 CLK duration 
                                        -- pulse when the pushbutton is pressed. 
                                        -- If the button is pressed for more than 
                                        -- 2sec, this port shall output pulses each 
                                        -- 1 sec as long as the button is 
                                        -- pressed.  
    );
    end component;

    component data_generator is                -- This is the component declaration.
    generic (
        G_RESET_ACTIVE_VALUE        : std_logic
    );
    port (
        CLK            : in  std_logic;
        RST            : in  std_logic;
        ANGLE          : in  integer range 0 to 3;
        IMAGE_ENA      : in  std_logic;
        H_CNT          : in  integer range 0 to C_PIXELS_PER_LINE-1;
        V_CNT          : in  integer range 0 to C_PIXELS_PER_FRAME-1;
        SRAM_D         : in  std_logic_vector(15 downto 0);
        SRAM_A         : out std_logic_vector(17 downto 0);
        R_DATA         : out std_logic_vector(7 downto 0);
        G_DATA         : out std_logic_vector(7 downto 0);
        B_DATA         : out std_logic_vector(7 downto 0);    
        DATA_DE        : out std_logic
    );
    end component;

    component controller is                -- This is the component declaration.
    generic (
        G_RESET_ACTIVE_VALUE    : std_logic; -- Determines the RST input polarity. 
                                                    -- 0 – the RST input is active low 
                                                    -- 1 – the RST input is active high
        G_VAL_1SEC              : integer -- In CLK units (1 [sec in ns] / 40 [ns, 1 clock period])
    );
    port ( 
        RST             : in std_logic;     -- Asynchronous reset. Active value according to G_RESET_ACTIVE_VALUE
        CLK             : in std_logic;     -- System clock 25MHz
        ROTATE          : in std_logic;     -- Active high, 1 CLK duration rotate request
        ROTATION_DIR    : in std_logic;     -- 0 – CW rotation direction 
                                            -- 1 – CCW rotation direction
        VS              : in std_logic;     -- Active high 1 CLK duration pulse 
                                            -- indication V_SYNC falling edge. 
        MODE            : in std_logic;     -- 0 – Manual rotation mode 
                                            -- 1 – Automatic rotation mode
        ANGLE           : out integer range 0 to 3;  --The angle of the displayed image
                                                    -- 0 - 0° 
                                                    -- 1 - 90° 
                                                    -- 2 - 180° 
                                                    -- 3 - 270°
        HEX0            : out std_logic_vector(6 downto 0); -- The unity digit of the image angle
        HEX1            : out std_logic_vector(6 downto 0); -- The tens digit of the image angle
        HEX2            : out std_logic_vector(6 downto 0); -- The hundreds digit of the image angle
        HEX3            : out std_logic_vector(6 downto 0) -- Should be OFF
    );
    end component;

    component clock_generator is                -- This is the component declaration.
    port (
		refclk   : in  std_logic; --  refclk.clk
		rst      : in  std_logic; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		locked   : out std_logic         --  locked.export
	);
    end component;

    component stabilizer is
    generic (
        G_RESET_ACTIVE_VALUE    : std_logic --; -- Determines the RST input polarity. 
        -- G_INITIAL_STATE         : std_logic
    );
    port ( 
        D_IN        : in  std_logic;
        CLK         : in  std_logic; 
        RST         : in  std_logic;
        Q_OUT       : out std_logic
    );
    end component;
    
     -- stabilizer signals --
    signal key_rotate_to_sw_in : std_logic;
    signal rotation_to_rotate_dir : std_logic;
    signal ena_to_image_ena : std_logic;
    signal sw_mode_to_mode : std_logic;

     -- clock generator signals --
    signal outclk_0_to_clk : std_logic;
    signal locked_to_rst_sig : std_logic;

    -- Push button interface signals -- 
    signal press_out_to_rotate : std_logic;

    -- Controller signals --
    signal control_angle_to_data_angle : integer range 0 to 3;
    
    -- Timing generator signals --
    signal timing_vs_to_controller_vs : std_logic;
    signal timing_h_cnt_to_data_h_cnt : integer range 0 to C_PIXELS_PER_LINE-1;
    signal timing_v_cnt_to_data_v_cnt : integer range 0 to C_PIXELS_PER_FRAME-1;
    
    -- Data generator signals --
    signal r_data_sig : std_logic_vector(7 downto 0);
    signal g_data_sig : std_logic_vector(7 downto 0);
    signal b_data_sig : std_logic_vector(7 downto 0);
    
    
    signal rst_sig : std_logic;
    signal RST : std_logic;
    
    begin
        
        rst_sig <= locked_to_rst_sig and RSTn;
        RST <= not RSTn;

        enable_stabilizer: stabilizer
        generic map (
            G_RESET_ACTIVE_VALUE      => C_RESET_ACTIVE_VALUE --,
            -- G_INITIAL_STATE           => '0'
        )
        port map (
            D_IN        => SW_IMAGE_ENA,
            CLK         => outclk_0_to_clk,
            RST         => RSTn,
            Q_OUT       => ena_to_image_ena
        );

        direction_stabilizer: stabilizer
        generic map (
            G_RESET_ACTIVE_VALUE      => C_RESET_ACTIVE_VALUE
        )
        port map (
            D_IN        => SW_ROTATION_DIR,
            CLK         => outclk_0_to_clk,
            RST         => RSTn,
            Q_OUT       => rotation_to_rotate_dir
        );

        rotation_stabilizer: stabilizer
        generic map (
            G_RESET_ACTIVE_VALUE      => C_RESET_ACTIVE_VALUE
        )
        port map (
            D_IN        => KEY_ROTATE,
            CLK         => outclk_0_to_clk,
            RST         => RSTn,
            Q_OUT       => key_rotate_to_sw_in
        );

        mode_stabilizer: stabilizer
        generic map (
            G_RESET_ACTIVE_VALUE      => C_RESET_ACTIVE_VALUE
        )
        port map (
            D_IN        => SW_MODE,
            CLK         => outclk_0_to_clk,
            RST         => RSTn,
            Q_OUT       => sw_mode_to_mode
        );

        clock: clock_generator            
        port map (
            refclk   => CLK,
            rst      => RST,
            outclk_0 => outclk_0_to_clk,
            locked   => locked_to_rst_sig
        );

        push_button: push_button_if  
        generic map (
            G_RESET_ACTIVE_VALUE    => C_RESET_ACTIVE_VALUE, 
            G_BUTTON_NORMAL_STATE   => C_BUTTON_NORMAL_STATE, 
            G_PRESS_TIMOUT_VAL      => C_PRESS_TIMOUT_VAL, 
            G_TIME_BETWEEN_PULSES   => C_TIME_BETWEEN_PULSES
        )
        port map ( 
            RST         => rst_sig,    
            CLK         => outclk_0_to_clk,     
            SW_IN       => key_rotate_to_sw_in,    
            PRESS_OUT   => press_out_to_rotate  
        );

        timing: timing_generator  
        generic map (
            G_RESET_ACTIVE_VALUE      => C_RESET_ACTIVE_VALUE
        )
        port map (
            CLK         => outclk_0_to_clk,
            RST         => rst_sig,
            H_CNT       => timing_h_cnt_to_data_h_cnt,
            V_CNT       => timing_v_cnt_to_data_v_cnt,
            H_SYNC      => HDMI_TX_HS,
            V_SYNC      => HDMI_TX_VS,
            VS          => timing_vs_to_controller_vs
        );

        data: data_generator            
        generic map (
            G_RESET_ACTIVE_VALUE        => C_RESET_ACTIVE_VALUE
        )
        port map (
            CLK            => outclk_0_to_clk,
            RST            => rst_sig,
            ANGLE          => control_angle_to_data_angle,
            IMAGE_ENA      => ena_to_image_ena,
            H_CNT          => timing_h_cnt_to_data_h_cnt,
            V_CNT          => timing_v_cnt_to_data_v_cnt,
            SRAM_D         => SRAM_D,
            SRAM_A         => SRAM_A,
            R_DATA         => r_data_sig,
            G_DATA         => g_data_sig,
            B_DATA         => b_data_sig,
            DATA_DE        => HDMI_TX_DE
        );


        ctrl: controller  
        generic map (
            G_RESET_ACTIVE_VALUE    => C_RESET_ACTIVE_VALUE,
            G_VAL_1SEC              => G_VAL_1SEC
        )
        port map ( 
            RST             => rst_sig,
            CLK             => outclk_0_to_clk,
            ROTATE          => press_out_to_rotate,
            ROTATION_DIR    => rotation_to_rotate_dir,                       
            VS              => timing_vs_to_controller_vs,                            
            MODE            => sw_mode_to_mode,
            ANGLE           => control_angle_to_data_angle,
                                                        
            HEX0            => HEX0, -- The ones digit of the image angle
            HEX1            => HEX1, -- The tens digit of the image angle
            HEX2            => HEX2, -- The hundreds digit of the image angle
            HEX3            => HEX3  -- Should be OFF
        );


        HDMI_TX <= r_data_sig & g_data_sig & b_data_sig;
        HDMI_TX_CLK <= outclk_0_to_clk;

end architecture;