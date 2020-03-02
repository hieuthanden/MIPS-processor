-- Student name: Hieu Tran
-- Student ID number: 62729903

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity RegFile is 
  port(
        clk, wr_en                    : in STD_LOGIC;
        rd_addr_1, rd_addr_2, wr_addr : in REG_addr;
        d_in                          : in word; 
        d_out_1, d_out_2              : out word
  );
end RegFile;

architecture RF_arch of RegFile is
-- component declaration
-- signal declaration
    type registerFile is array(0 to 31) of WORD;
    SIGNAL reg: registerFile;
begin
    d_out_1 <= (others => '0') when rd_addr_1 = "00000" else reg(to_integer(unsigned(rd_addr_1)));
    d_out_2 <= (others => '0') when rd_addr_2 = "00000" else reg(to_integer(unsigned(rd_addr_2)));
    RegLogic: PROCESS (clk)
    BEGIN
	IF (Clk = '1' AND Clk'EVENT) THEN
	    IF wr_en = '1' THEN
		IF (wr_addr = "00000") THEN
		    reg(to_integer(unsigned(wr_addr))) <= (others => '0');
		ELSE
		    reg(to_integer(unsigned(wr_addr))) <= d_in;
		END IF;
	    END IF;
	END IF;
    END PROCESS;
end RF_arch;
