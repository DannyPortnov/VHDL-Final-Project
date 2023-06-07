library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- use ieee.fixed_pkg.all;

package image_processor_pack is
    constant C_PIXELS_PER_LINE		: integer := 800;
	constant C_PIXELS_PER_FRAME		: integer := 525;
    constant MAX_BITS       :  integer := 255;
    constant G_PIXELS_NUM   :  integer := 64;
    constant G_BITS_NUM :  integer := 6;
    constant R_B_CONV_PARAM :  real    := 8.225806452;
    constant G_CONV_PARAM   :  real    := 4.047619048;

    constant C_RESET_ACTIVE_VALUE : std_logic := '0';
    constant C_BUTTON_NORMAL_STATE : std_logic := '1';
    constant C_PRESS_TIMOUT_VAL : integer := 200;
    constant C_TIME_BETWEEN_PULSES : integer := 100;

    constant VISIBLE_PIXELS_PER_LINE : integer := 640;
    constant VISIBLE_PIXELS_PER_FRAME : integer := 480;
    constant IMAGE_WIDTH    : integer := 512;
    constant IMAGE_HEIGHT   : integer := 512;
    constant IMAGE_H_OFFSET : integer := (VISIBLE_PIXELS_PER_LINE - IMAGE_WIDTH) / 2;
    constant IMAGE_V_OFFSET : integer := (IMAGE_HEIGHT - VISIBLE_PIXELS_PER_FRAME) / 2;

    constant IMAGE_H_START  : integer := IMAGE_H_OFFSET;
    constant IMAGE_H_END    : integer := VISIBLE_PIXELS_PER_LINE - IMAGE_H_OFFSET - 1;
    -- constant IMAGE_H_START  : integer := 0;
    -- constant IMAGE_H_END    : integer := IMAGE_WIDTH - 1;
    constant IMAGE_V_START  : integer := 0;
    constant IMAGE_V_END    : integer := VISIBLE_PIXELS_PER_FRAME - 1;
    -- constant IMAGE_V_START  : integer := IMAGE_V_OFFSET;
    -- constant IMAGE_V_END    : integer := IMAGE_HEIGHT - IMAGE_V_OFFSET - 1;
    
    --constant C_VAL_1SEC : integer := 25000000;

    -- function that converts color from L<=8 bit to 8 bit representation
    -- function convert_to_eight_bit (color_data : integer range 0 to G_PIXELS_NUM;
    --                                bits_num   : integer range 0 to G_BITS_NUM) return std_logic_vector;
    function color_convert (P_in: std_logic_vector) return std_logic_vector;
                                   
    -- function that converts BCD to 7 segment representation
    function bcd_to_7seg (BCD_IN: integer range 0 to 9) return std_logic_vector;
    -- function that divides two integers
    function divide(dividend: integer; divisor: integer) return integer;
    -- function that returns nth digit of a number, starting from 1
    function get_nth_digit(num: integer; n: integer) return integer;
end package;


package body image_processor_pack is   
    
    -- -- function convert_to_eight_bit (color_data : integer range 0 to G_PIXELS_NUM)    return std_logic_vector is
    -- function convert_to_eight_bit (color_data : integer range 0 to G_PIXELS_NUM;
    --                                bits_num   : integer range 0 to G_BITS_NUM) return std_logic_vector is    
    --     variable color_conv : std_logic_vector(7 downto 0);

    -- begin
    --     -- To Niv: variables are assigned values using the variable assignment operator :=, not the signal assignment operator <=.
    --     color_conv := std_logic_vector(to_unsigned(integer(floor(real(color_data)*(real(MAX_BITS)/real((2**bits_num - 1))))) , color_conv'length)); 
    --     -- if (color_data < R_B_PIXELS_NUM) and (color_data >= 0) then
    --     --     color_conv := std_logic_vector(to_unsigned(integer(floor(real(color_data)*(real(255)/real(R_B_CONV_PARAM)))) , color_conv'length)); 
        
    --     -- elsif (color_data >= R_B_PIXELS_NUM) and (color_data < G_PIXELS_NUM) then
    --     --     color_conv := std_logic_vector(to_unsigned(color_data * integer(floor(real(255)/real(G_CONV_PARAM))) , color_conv'length)); 
    --     -- end if;
    --     return (color_conv);
    -- end convert_to_eight_bit;
    
    function color_convert (P_in: std_logic_vector) return std_logic_vector is
        constant P_in_to_int : integer range 0 to G_PIXELS_NUM := to_integer(unsigned(P_in));
        constant P_in_length : integer range 0 to P_in'length := P_in'length;
        -- constant P_in_to_real : real range real(0) to real(G_PIXELS_NUM) := real(to_integer(unsigned(P_in)));
        -- constant P_in_length : integer range 0 to P_in'length := P_in'length;
        -- constant conv_mul    : real range real(0) to  real(G_PIXELS_NUM) := real(MAX_BITS)/real(2**(P_in_length) - 1);
        -- constant color_conv_int : integer range 0 to G_PIXELS_NUM  := integer(floor(conv_mul*P_in_to_real));

        variable color_conv : std_logic_vector(7 downto 0);
        
    begin
        -- P_in_to_int := to_integer(unsigned(P_in));
        -- color_conv := std_logic_vector(to_unsigned(color_conv_int) , color_conv'length); 
        color_conv := std_logic_vector(to_unsigned((P_in_to_int*(MAX_BITS/(2**(P_in_length) - 1))), color_conv'length)); 
      
        return (color_conv);
    end color_convert;

    -- function color_convert(P_in: std_logic_vector) return std_logic_vector is
    --     constant P_in_to_real : real range 0 to real(G_PIXELS_NUM) := real(to_integer(unsigned(P_in)));
    --     constant P_in_length : integer range 0 to P_in'length := P_in'length;
    --     constant conv_mul    : real range 0 to  real(G_PIXELS_NUM) := real(MAX_BITS)/(2**(P_in_length) - 1);
    --     constant color_conv_int : integer range 0 to G_PIXELS_NUM  := integer(floor(conv_mul*P_in_to_real));

    --     variable color_conv : std_logic_vector(7 downto 0);
    
    --     -- Define fixed-point parameters
    --     constant FRACTIONAL_BITS : integer := 8; -- Number of fractional bits
    --     subtype fixed_point_type is integer range -2**(P_in'length-1-FRACTIONAL_BITS) to 2**(P_in'length-1-FRACTIONAL_BITS)-1;
    --     constant MAX_BITS : fixed_point_type := 255; -- Maximum value for 8-bit color
    --     constant SCALE_FACTOR : fixed_point_type := MAX_BITS / (2**P_in_length - 1);
    --     variable fixed_point_val : fixed_point_type;
    -- begin
    --     -- Convert P_in to fixed-point representation
    --     fixed_point_val := P_in_to_int;
    
    --     -- Perform fixed-point arithmetic for color conversion
    --     fixed_point_val := fixed_point_val * SCALE_FACTOR;
    
    --     -- Convert fixed-point value to integer
    --     color_conv := std_logic_vector(to_unsigned(fixed_point_val, color_conv'length));
    
    --     return color_conv;
    -- end color_convert;
    
    


    function bcd_to_7seg (BCD_IN: integer range 0 to 9) return std_logic_vector is
    begin
        case BCD_IN is
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when others => return "0010000";
        end case;
    end function;

    function divide(dividend: integer; divisor: integer) return integer is
        variable quotient: integer := 0;
        variable remainder: integer := dividend;
    begin
        while remainder >= divisor loop
            remainder := remainder - divisor;
            quotient := quotient + 1;
        end loop;
        return quotient;
    end divide;

    function get_nth_digit(num: integer; n: integer) return integer is 
        variable remaining_num  : integer := num;
        variable digit          : integer := 0;
        variable i              : integer := 1;
        variable pow10          : integer := 1;
    begin
        while i <= n loop
            pow10 := pow10 * 10;
            i := i + 1;
        end loop;
        while remaining_num >= pow10 loop
            remaining_num := remaining_num - pow10;
        end loop;
        while remaining_num >= 10 loop
            remaining_num := remaining_num - 10;
            digit := digit + 1;
        end loop;
        if (digit > 9) then
            digit := get_nth_digit(digit, 2);
        end if;
        return digit;
    end get_nth_digit;
    



end package body;



