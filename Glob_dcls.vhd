LIBRARY IEEE; 
use ieee.std_logic_1164.all;
package Glob_dcls is
-- Data types 
	constant word_size : natural := 32;			
	subtype word is std_logic_vector(word_size-1 downto 0); 
	constant half_word_size : natural := 16;			
	subtype half_word is std_logic_vector(half_word_size-1 downto 0); 
	constant Byte_size : natural := 8;
	subtype Byte is std_logic_vector(Byte_size-1 downto 0);
	constant reg_addr_size : natural := 5;
	subtype reg_addr is std_logic_vector(reg_addr_size-1 downto 0);
	constant opcode_size : natural := 6;
	subtype opcode is std_logic_vector(opcode_size-1 downto 0);
	constant offset_size : natural := 16; 
	subtype offset is std_logic_vector(offset_size-1 downto 0);
	constant target_size : natural := 26;
	subtype target is std_logic_vector(target_size-1 downto 0);

	subtype ALU_opcode is std_logic_vector(2 downto 0);
  	subtype RAM_ADDR is integer range 0 to 63;
  	type RAM is array (RAM_ADDR) of word;

-- Constants   

        constant One_word: word := (others=>'1');
        constant Zero_word: word := (others=>'0');
        constant Z_word: word :=    (others=>'Z');
        constant U_word: word :=    (others=>'U');
        
        constant CLK_PERIOD: time := 40 ns;
        constant RD_LATENCY: time := 35 ns;
        constant WR_LATENCY: time := 35 ns;
        
        
-- Components


end Glob_dcls;


