library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package image_processor_pack is
    constant G_PIXELS_NUM   : integer := 64;
    constant R_B_PIXELS_NUM :  integer := 32;
    constant R_B_CONV_PARAM :  real    := 8.225806452;
    constant G_CONV_PARAM   :  real    := 4.047619048;
    -- function that converts color from L<=8 bit to 8 bit representation
    -- To Niv: the type of a function’s arguments and return value
    -- must be specified using a type mark (std_logic_vector), not a subtype indication (std_logic_vector(7 downto 0)). 
    function convert_to_eight_bit (clr_data : integer range 0 to G_PIXELS_NUM) return std_logic_vector;
    -- function that converts BCD to 7 segment representation
    function bcd_to_7seg (BCD_IN: integer range 0 to 9) return std_logic_vector;
    -- function that divides two integers
    function divide(dividend: integer; divisor: integer) return integer;
    -- function that returns nth digit of a number, starting from 1
    function get_nth_digit(num: integer; n: integer) return integer;
end package;


package body image_processor_pack is   
    
    function convert_to_eight_bit (clr_data : integer range 0 to G_PIXELS_NUM)    return std_logic_vector is
        
        variable clr_conv : std_logic_vector(7 downto 0);

    begin
        -- To Niv: variables are assigned values using the variable assignment operator :=, not the signal assignment operator <=.
        if (clr_data < R_B_PIXELS_NUM) and (clr_data >= 0) then
            clr_conv := std_logic_vector(to_unsigned(clr_data * integer(floor(real(255)/real(R_B_CONV_PARAM))) , clr_conv'length)); 
        
        elsif (clr_data >= R_B_PIXELS_NUM) and (clr_data < G_PIXELS_NUM) then
            clr_conv := std_logic_vector(to_unsigned(clr_data * integer(floor(real(255)/real(G_CONV_PARAM))) , clr_conv'length)); 
        end if;
        return (clr_conv);
    end convert_to_eight_bit;
    
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
        variable remaining_num: integer := num;
        variable digit: integer := 0;
        variable i: integer := 1;
        variable pow10: integer := 1;
    begin
        while i < n loop
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
        return digit;
    end get_nth_digit;
    



end package body;



