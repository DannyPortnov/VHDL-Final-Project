library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.image_processor_pack.all;

entity data_generator is
    generic (
        G_RESET_ACTIVE_VALUE        : std_logic := '0'
    );
    port (
        CLK            : in  std_logic;
        RST            : in  std_logic;
        ANGLE          : in  integer range 0 to 3;
        IMAGE_ENA      : in  std_logic;
        H_CNT          : in  integer range 0 to C_PIXELS_PER_LINE-1;
        V_CNT          : in  integer range 0 to C_PIXELS_PER_FRAME-1;
        SRAM_D         : in  std_logic_vector(15 downto 0) := (others => '0');
        SRAM_A         : out std_logic_vector(17 downto 0) := (others => '0');
        R_DATA         : out std_logic_vector(7 downto 0)  := (others => '0');
        G_DATA         : out std_logic_vector(7 downto 0)  := (others => '0');
        B_DATA         : out std_logic_vector(7 downto 0)  := (others => '0');
        DATA_DE        : out std_logic
    );
end entity;

architecture behave of data_generator is 
    -- Constants declarations:

    -- Constants for each degree value:
    constant zero_deg                    : integer := 0;
    constant ninety_deg                  : integer := 1;
    constant hundred_eighty_deg          : integer := 2;
    constant two_hunderd_seventy_deg     : integer := 3;
    -- Constants for Color Bar (color's representation with integers):
    constant Red           : integer := 0;
    constant Green         : integer := 1;
    constant Black         : integer := 2;
    constant Yellow        : integer := 3; 
    constant Blue          : integer := 4;
    constant Magenta       : integer := 5;
    constant Cyan          : integer := 6;
    constant White         : integer := 7;
    -- length of a color segment
    constant SEGMENT_WIDTH : integer := VISIBLE_PIXELS_PER_LINE / 8;  -- Equal width for each color segment

    -- Signal declarations:

    -- Signals for color bar
    -- signal color_counter    : integer range 0 to VISIBLE_PIXELS_PER_LINE-1;
    signal color_index      : integer range 0 to 7;
    -- Signal for saving the last angle that was recieved
    signal last_angle       : integer range 0 to 3;
    -- Signal for saving the last IMAGE ENABLE that was recieved
    signal last_image_ena   : std_logic;
    -- Signal for creating dea the last IMAGE ENABLE that was recieved
    signal data_ena_sig     : std_logic;
    -- signal new_angle        : integer range 0 to 3;

    

begin

    -- angle is updated only when we FINISH creating the image
    -- last_angle <= ANGLE when ((H_CNT = C_PIXELS_PER_LINE-1) and (V_CNT = C_PIXELS_PER_FRAME-1));
    -- Image Enable is updated only when we FINISH creating the image
    -- last_image_ena <= IMAGE_ENA when ((H_CNT = 0) and (V_CNT = 0));
    
    -- **************************************************************************
    -- ***********************  CHANGE IN TIMING GENERATOR  *********************
    -- ****** H_CNT and V_CNT now count only in the range the visible area ******
    -- **************************************************************************
    -- **************************************************************************
    process( CLK )
    begin
        if rising_edge(CLK) then
            if (H_CNT = C_PIXELS_PER_LINE-1) and (V_CNT = C_PIXELS_PER_FRAME-1) then
                last_angle <= ANGLE;
            end if;
            if (H_CNT = 0) and (V_CNT = 0) then
                last_image_ena <= IMAGE_ENA;
            end if;
        end if;
    end process; 

    process(CLK,RST)
    begin
        --reset output
        if RST = G_RESET_ACTIVE_VALUE then    
            -- color_counter <= 0;
            color_index <= 0;
            data_ena_sig <= '0';
        
        elsif rising_edge(CLK) then
            
            -- Check if the pixel is within the visible area
            if (H_CNT < VISIBLE_PIXELS_PER_LINE) and (V_CNT < VISIBLE_PIXELS_PER_FRAME) then
                -- the pixel is inside the visible area
                data_ena_sig <= '1';
                DATA_DE <= data_ena_sig;
                -- image from the memory is displayed 
                if last_image_ena = '1' then
                    -- draw the image in the center of the screen- Apply the starting coordinates offset
                    if ((H_CNT >= IMAGE_H_START - 2) and (H_CNT <= IMAGE_H_END - 2))
                        and ((V_CNT >= IMAGE_V_START) and (V_CNT <= IMAGE_V_END)) then  -- IMAGE_V_STRAT=0, IMAGE_V_END = 479
                    -- Determine the rotated coordinates based on the selected rotation angle
                        case last_angle is
                            when zero_deg =>
                                -- Access the corresponding pixel from SRAM using the rotated coordinates
                                SRAM_A <= std_logic_vector(to_unsigned((V_CNT + IMAGE_V_OFFSET) * IMAGE_WIDTH + (H_CNT + 2) - IMAGE_H_OFFSET, SRAM_A'length));

                            when ninety_deg =>
                                -- Access the corresponding pixel from SRAM using the rotated coordinates
                                SRAM_A <= std_logic_vector(to_unsigned(((H_CNT + 2) - IMAGE_H_OFFSET) * IMAGE_WIDTH + (IMAGE_HEIGHT - 1) - V_CNT - IMAGE_V_OFFSET, SRAM_A'length));

                            when hundred_eighty_deg =>
                                -- Access the corresponding pixel from SRAM using the rotated coordinates
                                SRAM_A <= std_logic_vector(to_unsigned(((IMAGE_HEIGHT - 1) - V_CNT - IMAGE_V_OFFSET) * IMAGE_WIDTH + ((IMAGE_WIDTH - 1) - (H_CNT + 2) + IMAGE_H_OFFSET), SRAM_A'length));
                                                                
                            when two_hunderd_seventy_deg =>
                                -- Access the corresponding pixel from SRAM using the rotated coordinates
                                SRAM_A <= std_logic_vector(to_unsigned(((IMAGE_WIDTH - 1) - (H_CNT + 2) + IMAGE_H_OFFSET) * IMAGE_WIDTH - (V_CNT + IMAGE_V_OFFSET), SRAM_A'length));
                -- NOTE: I wrote (H_CNT + 1) instead of H_CNT in order to get the address and data from the sram 1 pixel earlier
                --       than the last imlepentation in git history 
                        end case;
                        
                        R_DATA <= color_convert(SRAM_D(4 downto 0));
                        G_DATA <= color_convert(SRAM_D(10 downto 5));
                        B_DATA <= color_convert(SRAM_D(15 downto 11));
                        -- R_DATA <= convert_to_eight_bit(to_integer(unsigned(SRAM_D(4 downto 0))), SRAM_D(4 downto 0)'length);
                        -- G_DATA <= convert_to_eight_bit(to_integer(unsigned(SRAM_D(10 downto 5))), SRAM_D(10 downto 5)'length);
                        -- B_DATA <= convert_to_eight_bit(to_integer(unsigned(SRAM_D(15 downto 11))), SRAM_D(15 downto 11)'length);
                    

                    -- draw a black pixel if we exceed the image coordinates
                    else
                        -- data_ena_sig <= '0';
                        -- DATA_DE <= data_ena_sig;
                        R_DATA <= (others => '0');
                        G_DATA <= (others => '0');
                        B_DATA <= (others => '0');
                    end if;
                    
                        
            -- color bar is displayed
                elsif last_image_ena = '0' then
                    DATA_DE <= '1';
                    -- color_counter <= H_CNT;
                -- Assign color based on the color_index and color_counter = H_CNT
                    if (H_CNT >= SEGMENT_WIDTH * color_index) and (H_CNT < SEGMENT_WIDTH * (color_index + 1)) then
                        case color_index is
                            when Red =>  
                                R_DATA <= "11111111";
                                G_DATA <= "00000000";
                                B_DATA <= "00000000";
                            when Green => 
                                R_DATA <= "00000000";
                                G_DATA <= "11111111";
                                B_DATA <= "00000000";
                            when Black => 
                                R_DATA <= "00000000";
                                G_DATA <= "00000000";
                                B_DATA <= "00000000";
                            when Yellow => 
                                R_DATA <= "11111111";
                                G_DATA <= "11111111";
                                B_DATA <= "00000000";
                            when Blue =>   
                                R_DATA <= "00000000";
                                G_DATA <= "00000000";
                                B_DATA <= "11111111";
                            when Magenta =>  
                                R_DATA <= "11111111";
                                G_DATA <= "00000000";
                                B_DATA <= "11111111";
                            when Cyan =>  
                                R_DATA <= "00000000";
                                G_DATA <= "11111111";
                                B_DATA <= "11111111";
                            when White => 
                                R_DATA <= "11111111";
                                G_DATA <= "11111111";
                                B_DATA <= "11111111";
                        end case; 
                    -- else
                    --     -- The pixel is not in the current color segment -> blank
                    --     R_DATA <= (others => '0');
                    --     G_DATA <= (others => '0');
                    --     B_DATA <= (others => '0');
                    end if;
                end if;
                
                -- -- Increment color_counter
                -- if color_counter < VISIBLE_PIXELS_PER_LINE - 1 then
                --     color_counter <= color_counter + 1;
                -- else
                --     color_counter <= 0;
                --     -- Increment color_index
                --     if color_index < 7 then
                --         color_index <= color_index + 1;
                --     else
                --         color_index <= 0;
                --     end if;
                -- end if;
                
                -- Update color_index
                if H_CNT = (SEGMENT_WIDTH * (color_index + 1) - 1) then
                    if color_index < 7 then
                        color_index <= color_index + 1;
                    else
                        color_index <= 0;
                    end if;
                end if;

            else
            -- the pixel is not in the visible area -> blank
                DATA_DE <= '0';     
                R_DATA <= (others => '0');
                G_DATA <= (others => '0');
                B_DATA <= (others => '0');
            end if;

        -- DATA_DE <= data_ena_sig;

        end if;
    end process;
end architecture;



