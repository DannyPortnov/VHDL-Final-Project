library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.image_processor_pack.all;

entity timing_generator is
    generic (
        G_RESET_ACTIVE_VALUE        : std_logic := '0'
    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        H_CNT       : out integer range 0 to C_PIXELS_PER_LINE-1  := 0;
        V_CNT       : out integer range 0 to C_PIXELS_PER_FRAME-1 := 0;
        H_SYNC      : out std_logic := '1';
        V_SYNC      : out std_logic := '1';
        VS          : out std_logic := '0'
    );
end entity;

architecture behave of timing_generator is 
    -- Horizontal Timing Constants 
    constant H_visible      : integer:= 640; -- horizontal visible area
    constant H_FP           : integer:= 16;  -- hsync front porch
    constant H_BP           : integer:= 48;  -- hsync back porch
    constant HS_pulse       : integer:= 96;  -- hsync retrace
    -- Vertical Timing Constants
    constant V_visible      : integer:= 480; -- vertical visible area
    constant V_FP           : integer:= 10;  -- vsync front porch
    constant V_BP           : integer:= 33;  -- vsync back porch
    constant VS_pulse       : integer:= 2;   -- vsync retrace


    signal h_cnt_sig		: integer range 0 to C_PIXELS_PER_LINE - 1 	:= 0;	-- This signal counts how much pixles are passed on each line, every 800 pixles cnt_H_pixels = 0.
	signal v_cnt_sig		: integer range 0 to C_PIXELS_PER_FRAME - 1	:= 0; 	-- This signal counts how much lines are passed in pixles units.


    begin


    -- **************************************************************************
    -- ***********************  CHANGE IN TIMING GENERATOR  *********************
    -- ****** H_CNT and V_CNT now count only in the range the visible area ******
    -- ****** If they exceed the visible area, their value will be constant *****
    -- **************************************************************************
    -- **************************************************************************



    process(CLK,RST)
    begin
        if RST = G_RESET_ACTIVE_VALUE then   --reset output 
            h_cnt_sig <= 0;
            v_cnt_sig <= 0;
            H_SYNC <= '1';
            V_SYNC <= '1';
            VS <= '0';

        elsif rising_edge(CLK) then
        -- handle horizontal and vertical counters
            if (h_cnt_sig < C_PIXELS_PER_LINE - 1) then
                h_cnt_sig <= h_cnt_sig + 1;
            elsif (h_cnt_sig = C_PIXELS_PER_LINE - 1) then
                h_cnt_sig <= 0;
                if (v_cnt_sig < C_PIXELS_PER_FRAME - 1) then    
                    v_cnt_sig <= v_cnt_sig + 1;                  
                elsif (v_cnt_sig = C_PIXELS_PER_FRAME - 1) then
                    v_cnt_sig <= 0;
                end if;
            end if;

        -- vertical sync for 480 pixels + update VS
            if ((v_cnt_sig = (V_visible + V_FP - 1)) and (h_cnt_sig = (C_PIXELS_PER_LINE - 1))) then
                VS <= '1';  -- update VS- active high for only 1 clk pulse!
                V_SYNC <= '0'; 
            elsif ((v_cnt_sig = (V_visible + V_FP + VS_pulse - 1)) and (h_cnt_sig = (C_PIXELS_PER_LINE - 1))) then
                V_SYNC <= '1';
            else
                VS <= '0';
            end if; 

        -- horizontal sync for 640 pixels
            if ((h_cnt_sig - HS_pulse - H_BP) >= (H_visible + H_FP - 1) or h_cnt_sig < (HS_pulse - 1)) then
                H_SYNC <= '0';
            elsif ((h_cnt_sig - HS_pulse - H_BP) < (H_visible + H_FP - 1) and h_cnt_sig >= (HS_pulse - 1)) then
                H_SYNC <= '1';
            -- if (h_cnt_sig = (C_PIXELS_PER_LINE - 1) or h_cnt_sig < (HS_pulse - 1)) then
            --     H_SYNC <= '0';
            -- else
            --     H_SYNC <= '1';
            -- elsif (h_cnt_sig = C_PIXELS_PER_LINE - 1) then
            --     H_SYNC <= '1';                
            end if;

    --*********************************************************************************************************
    -- old implementation for vs + vertical sync (with delay of 1 clk for V_SYNC)
    --*********************************************************************************************************
        -- update VS
            -- if ((v_cnt_sig = (V_visible + V_FP - 1)) and (h_cnt_sig = (C_PIXELS_PER_LINE - 1))) then
            --     VS <= '1';  -- update VS- active high for only 1 clk pulse!
            -- else
            --     VS <= '0';
            -- end if; 
        -- vertical sync for 480 pixels
            -- if (v_cnt_sig > (V_visible + V_FP - 1) and v_cnt_sig <= (C_PIXELS_PER_FRAME - V_BP - 1)) then
            --     V_SYNC <= '0';
            -- elsif (v_cnt_sig <= (V_visible + V_FP - 1) or v_cnt_sig > (C_PIXELS_PER_FRAME - V_BP - 1)) then
            --     V_SYNC <= '1';
            -- elsif (v_cnt_sig = C_PIXELS_PER_LINE - 1) then
            --     V_SYNC <= '1';
            -- end if;
    --*********************************************************************************************************
        end if;
    end process;
    H_CNT <= (h_cnt_sig - HS_pulse - H_BP) when (h_cnt_sig >= (HS_pulse + H_BP) and h_cnt_sig <=(C_PIXELS_PER_LINE - H_FP - 1))
                                           else  C_PIXELS_PER_LINE - 1;
    V_CNT <= v_cnt_sig;
    -- V_CNT <= v_cnt_sig when (h_cnt_sig >= (HS_pulse + H_BP) and h_cnt_sig <=(C_PIXELS_PER_LINE - H_FP - 1))
    --                    else C_PIXELS_PER_FRAME - 1;
end architecture;


