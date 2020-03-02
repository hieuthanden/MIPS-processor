-- Student name: your name goes here
-- Student ID number: your student id # goes here

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity control is 
   port(
        clk   	    : IN STD_LOGIC; 
        reset_N	    : IN STD_LOGIC; 
        
        op_code     : IN opcode;     -- declare type for the 6 most significant bits of IR
        funct       : IN opcode;     -- declare type for the 6 least significant bits of IR 
     	zero        : IN STD_LOGIC ;
        
     	PCUpdate    : OUT STD_LOGIC; -- this signal controls whether PC is updated or not
     	IorD        : OUT STD_LOGIC;
     	MemRead     : OUT STD_LOGIC;
     	MemWrite    : OUT STD_LOGIC;

     	IRWrite     : OUT STD_LOGIC;
     	MemtoReg    : OUT STD_LOGIC_VECTOR (1 downto 0); -- the extra bit is for JAL
     	RegDst      : OUT STD_LOGIC_VECTOR (1 downto 0); -- the extra bit is for JAL
     	RegWrite    : OUT STD_LOGIC;
     	ALUSrcA     : OUT STD_LOGIC;
     	ALUSrcB     : OUT STD_LOGIC_VECTOR (1 downto 0);
     	ALUcontrol  : OUT ALU_opcode;
     	PCSource    : OUT STD_LOGIC_VECTOR (1 downto 0)
	);
end control;

architecture control_arch of control is
-- component declaration
	
-- component specification

-- signal declaration
    TYPE Statetype IS
        (S1_Fetch, S2_Decode, S3_lw, S3_sw, S4_lw, S4_sw, S5_lw, S3_R_type, S4_R_type, S3_branch, 
	 S3_Im_type, S4_Im_type, S3_J);
    SIGNAL Currentstate, Nextstate: Statetype;

    SIGNAL PCUcondition : std_logic := '0';
    SIGNAL zero_s, PCwrite : std_logic;


begin
    zero_s <= NOT(zero) when op_code = "000101" else zero;
    PCUpdate <= PCwrite OR (PCUcondition AND zero_s);

    State_Register: PROCESS (clk, reset_N)
    BEGIN
	IF (reset_N = '0') THEN
            Currentstate <= S1_Fetch;
	END IF;
        IF (rising_edge(clk)) THEN
            Currentstate <= Nextstate;
        END IF;
    END PROCESS;

    Control: PROCESS (Currentstate)
    BEGIN
	CASE Currentstate IS
	    WHEN S1_Fetch =>
		RegWrite <='0';
		PCUcondition <= '0';
		-- IR = mem[PC]
		IorD <= '0';
    		MemRead <= '1';
    		MemWrite  <= '0';
		IRWrite <= '1'; 
		-- PC = PC + 4 
    		ALUSrcA <= '0';       
    		ALUSrcB <= "01";
        	ALUControl <= "000";
		PCSource <= "00";
        	PCwrite <= '1';
		-- change state
		Nextstate <= S2_Decode;
	    WHEN S2_Decode =>
		IRWrite <= '0';
		PCwrite <= '0' ;
		MemRead <= '0' ;
		-- ALUout = PC + (sign_extend(IR[15-0]) << 2)
        	ALUSrcA <= '0';
        	ALUSrcB <= "11";
		ALUControl <= "000";
		-- CASE based on opcode
		CASE op_code IS
		    WHEN "000000" =>
		    -- R_type instruction
			Nextstate <= S3_R_type;
		    WHEN "001000" | "001100" | "001101" =>
		    -- Imm instructuon
			Nextstate <= S3_Im_type;
		    WHEN "100011" =>
		    -- Load instruction
			Nextstate <= S3_lw;
		    WHEN "101011" => 
 		    -- Store instructuon
			Nextstate <= S3_sw;
		    WHEN "000100" | "000101" =>
		    -- "branch"
			Nextstate <= S3_branch;
		    WHEN "000010" =>
		    -- jumb instruction
			Nextstate <= S3_J;
		    WHEN OTHERS =>
			Nextstate <= S1_Fetch;
		END CASE;
	    WHEN S3_lw =>
		ALUSrcA <= '1';
        	ALUSrcB <= "10";
		ALUControl <= "000";
		IorD <= '1';
		-- change state
		Nextstate <= S4_lw;
	    WHEN S4_lw =>
		MemRead <= '1';
		-- change state
		Nextstate <= S5_lw;
	    WHEN S5_lw =>
		MemRead <= '0';
		RegDst <= "00";
		MemtoReg <= "01";
		RegWrite <= '1';
		-- change state
		Nextstate <= S1_Fetch;
	    WHEN S3_sw =>
		ALUSrcA <= '1';
        	ALUSrcB <= "10";
		ALUControl <= "000";
		-- change state
		Nextstate <= S4_sw;
	    WHEN S4_sw =>
		IorD <= '1';
		MemWrite  <= '1';
		-- change state
		Nextstate <= S1_Fetch;
	    WHEN S3_R_type =>
		ALUSrcA <= '1';
        	ALUSrcB <= "00"; 
		-- send opcode based on funct
		CASE funct IS
		    WHEN "000000" =>
		    -- shift left
			ALUControl <= "010";
		    WHEN "000010" =>
		    -- shift right
			ALUControl <= "011";
		    WHEN "100000" =>
		    -- add 
			ALUControl <= "000";
		    WHEN "100010" =>
		    -- sub 
			ALUControl <= "001";
		    WHEN "100101" =>
		    -- or
			ALUControl <= "101";
		    WHEN "100100" =>
		    -- and
			ALUControl <= "100";
		    WHEN "100110" =>
		    -- XOR
			ALUControl <= "110";
		    WHEN "100111" =>
		    -- NOR
			ALUControl <= "111";
		    WHEN OTHERS =>
		    -- unknown
			ALUControl <= "UUU";
		END CASE;
		-- change state
		Nextstate <= S4_R_type;
	    WHEN S4_R_type => 
		RegDst <= "01";
		MemtoReg <= "00";
		RegWrite <= '1';
		-- change state
		Nextstate <= S1_Fetch;
	    WHEN S3_branch => 
		ALUSrcA <= '1';
        	ALUSrcB <= "00";
		ALUControl <= "110";
		PCSource <= "01";
		PCUcondition <= '1';
		-- change state
		Nextstate <= S1_Fetch;
	    WHEN S3_Im_type =>
		-- ALUout = A + Imm;
		ALUSrcA <= '1';
        	ALUSrcB <= "10"; 
		if (op_code = "001000") then
		    ALUControl <= "000";
		elsif (op_code = "001100") then 
		    ALUControl <= "100";
		else
		    ALUControl <= "101";
		end if;
		-- change state
		Nextstate <= S4_Im_type;
	    WHEN S4_Im_type =>
		-- REG[IR[15-11] = ALUout
		MemtoReg  <= "00";
		RegDst   <= "00";
		RegWrite <='1';
		-- change state
		Nextstate <= S1_Fetch;
	    WHEN S3_J =>
		PCSource <= "10";
		PCwrite <= '1';
		-- change state
		Nextstate <= S1_Fetch;
	    WHEN OTHERS =>
		Nextstate <= S1_Fetch;
	END CASE;
    END PROCESS;
end control_arch;



