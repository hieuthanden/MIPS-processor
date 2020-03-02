-- Student name: Hieu Tran
-- Student ID number: 62729903

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE ieee.Numeric_Std.ALL;
use work.Glob_dcls.all;

entity ALU is 
  PORT( op_code  : in ALU_opcode;
        in0, in1 : in word;	
        C	 : in std_logic_vector(4 downto 0);  -- shift amount	
        ALUout   : out word;
        Zero     : out std_logic
  );
end ALU;

architecture ALU_arch of ALU is
-- signal declaration
    SIGNAL temp_out: word;

BEGIN
    ALUlogic: PROCESS (op_code, in0, in1, c, temp_out)
	BEGIN
	    CASE op_code IS
		WHEN "000" => 
		    temp_out <= std_logic_vector(signed(in0) +  signed(in1));
		WHEN "001" =>
		    temp_out <= std_logic_vector(signed(in0) -  signed(in1));
		WHEN "010" =>
		    temp_out <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(c))));
		WHEN "011" =>
		    temp_out <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(c))));
		WHEN "100" =>
		    temp_out <= in0 AND in1;
		WHEN "101" =>
		    temp_out <= in0 OR in1;
		WHEN "110" =>
		    temp_out <= in0 XOR in1;
		WHEN OTHERS => 
		    temp_out <= in0 NOR in1;
	    END CASE;
	    ALUout <= temp_out;
	    if (temp_out = "00000000000000000000000000000000") then
		Zero <= '1';
	    else
		Zero <= '0';
	    end if;
    END PROCESS;

end ALU_arch;
