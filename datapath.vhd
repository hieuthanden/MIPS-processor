-- Student name: your name goes here
-- Student ID number: your student id # goes here

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity datapath is
  
  port (
    clk        : in  std_logic;
    reset_N    : in  std_logic;
    
    PCUpdate   : in  std_logic;         -- write_enable of PC

    IorD       : in  std_logic;         -- Address selection for memory (PC vs. store address)
    MemRead    : in  std_logic;		-- read_enable for memory
    MemWrite   : in  std_logic;		-- write_enable for memory

    IRWrite    : in  std_logic;         -- write_enable for Instruction Register
    MemtoReg   : in  std_logic_vector(1 downto 0);  -- selects ALU or MEMORY or PC to write to register file.
    RegDst     : in  std_logic_vector(1 downto 0);  -- selects rt, rd, or "31" as destination of operation
    RegWrite   : in  std_logic;         -- Register File write-enable
    ALUSrcA    : in  std_logic;         -- selects source of A port of ALU
    ALUSrcB    : in  std_logic_vector(1 downto 0);  -- selects source of B port of ALU
    
    ALUControl : in  ALU_opcode;	-- receives ALU opcode from the controller
    PCSource   : in  std_logic_vector(1 downto 0);  -- selects source of PC


    
    opcode_out : out opcode;		-- send opcode to controller
    func_out   : out opcode;		-- send func field to controller
    zero       : out std_logic;          -- send zero to controller (cond. branch)

    -- addition output for test only
    pc_out     : out word;
    mem_out : out word;
    ins_rs_out : out reg_addr;
    ins_rt_out : out reg_addr;
    ins_offset_out : out offset;
    A_out      : out word;
    B_out      : out word;
    ALUout_out : out word

    );	
end datapath;


architecture datapath_arch of datapath is
-- component declaration
    component ALU is
	PORT( op_code  : in ALU_opcode;
        in0, in1 : in word;	
        C	 : in std_logic_vector(4 downto 0);  -- shift amount	
        ALUout   : out word;
        Zero     : out std_logic);
    end component;

    component RegFile is 
  	port(
        clk, wr_en                    : in STD_LOGIC;
        rd_addr_1, rd_addr_2, wr_addr : in REG_addr;
        d_in                          : in word; 
        d_out_1, d_out_2              : out word);
    end component;

    component mem IS
   	PORT (MemRead	: IN std_logic;
	 MemWrite	: IN std_logic;
	 d_in		: IN   word;		 
	 address	: IN   word;
	 d_out		: OUT  word 
	 );
    end component;


-- component specification

-- signal declaration
    SIGNAL pc_in, pc, ALUout_mux1, mux1_memory, memory_out, mdr_mux3, mux3_regFile,
	   RF_A, RF_B, signExtend_out, shiftLeft_mux5, A_mux4, B_mux5, mux4_ALU, mux5_ALU, ALU_ALUout: word;
    SIGNAL rs_out, rt_out, mux2_regFile : reg_addr;
    SIGNAL offset_out: offset;
    SIGNAL J_26: STD_LOGIC_VECTOR (25 downto 0);
    SIGNAL J_28: STD_LOGIC_VECTOR (27 downto 0);
    SIGNAL J_32: STD_LOGIC_VECTOR (31 downto 0);


begin
    
    J_26(15 downto 0) <= offset_out;
    J_26(20 downto 16) <= rt_out;
    J_26(25 downto 21) <= rs_out;
    J_28 (27 downto 2) <= J_26 (25 downto 0);
    J_28 (1 downto 0) <= "00";
    J_32(27 downto 0) <= J_28;
    J_32(31 downto 28) <= pc(31 downto 28);
    shiftLeft_mux5 (31 downto 2) <= signExtend_out (29 downto 0);
    shiftLeft_mux5 (1 downto 0) <= "00";
    func_out <= offset_out(5 downto 0);

    -- connect testing outputs
    pc_out <= pc;
    mem_out <= memory_out;
    ins_rs_out <= rs_out;
    ins_rt_out <= rt_out;
    ins_offset_out <= offset_out;
    A_out <= A_mux4;
    B_out <= B_mux5;
    ALUout_out <= ALUout_mux1;

   
    PCunit: Process (reset_N, clk)
	BEGIN
	if ( reset_N = '0') then
	    PC <= (others => '0');
	elsif (rising_edge(clk)) then
	    if (PCUpdate = '1') then
	    	pc <= pc_in;
	    end if;
        end if;
    END PROCESS;

    IRunit: Process (clk)
    BEGIN
	if (rising_edge(clk)) then
	    if (iRwrite = '1') then
	        opcode_out <= memory_out(31 downto 26);
	        rs_out <= memory_out(25 downto 21);
	        rt_out <= memory_out(20 downto 16);
	        offset_out <= memory_out(15 downto 0);
	    end if;
	end if;
    end process;
    
    A_unit: Process (clk)
    BEGIN
	if rising_edge(clk) then
	     A_mux4 <= RF_A;
	end if;
    end PROCESS;

    B_unit: Process (clk)
    BEGIN
	if rising_edge(clk) then
	     B_mux5 <= RF_B;
	end if;
    end PROCESS;

    ALUout: Process (clk)
    BEGIN
	if rising_edge(clk) then
	     ALUout_mux1 <= ALU_ALUout;
	end if;
    end PROCESS;

    MDRunit: Process (clk)
        BEGIN
	if rising_edge(clk) then
	     mdr_mux3 <= memory_out;
	end if;
    end PROCESS;

    Mux1: Process (IorD, pc, ALUout_mux1)
	BEGIN
	    if (IorD = '0') then 
		mux1_memory <= pc;
	    else
		mux1_memory <= ALUout_mux1;
	    end if;
    end PROCESS;

    Mux2: Process (RegDst, rt_out, offset_out)
	BEGIN
	    if (RegDst = "00") then
	        mux2_regFile <= rt_out;
	    elsif (RegDst = "01") then
		mux2_regFile <= offset_out(15 downto 11);
	    elsif (RegDst = "10") then
		mux2_regFile <= "11111" ;
	    else
		mux2_regFile <=	"00000";
	    end if;
    end process;

    Mux3: Process (MemtoReg, ALUout_mux1, mdr_mux3, pc)
	BEGIN
	    if (MemtoReg = "00") then
	        mux3_regFile<= ALUout_mux1;
	    elsif (MemtoReg = "01") then
		mux3_regFile <= mdr_mux3;
	    elsif (MemtoReg = "10") then
		mux3_regFile <= pc ;
	    else
		mux3_regFile <=	"00000000000000000000000000000000";
	    end if;
    end process;

    Mux4: Process (ALUSrcA, pc, A_mux4)
    BEGIN
	    if (ALUSrcA = '0') then 
		mux4_ALU <= pc;
	    else
		mux4_ALU <= A_mux4;
	    end if;
    end PROCESS;
	
    Mux5: Process (ALUSrcB, B_mux5, signExtend_out, shiftLeft_mux5)
    BEGIN
	    if (ALUSrcB = "00") then
	        mux5_ALU <= B_mux5;
	    elsif (ALUSrcB = "01") then
		mux5_ALU <= "00000000000000000000000000000100";
	    elsif (ALUSrcB = "10") then
	 	mux5_ALU <= signExtend_out;
	    else
		mux5_ALU <= shiftLeft_mux5;
	    end if;
    end process;
 
    Mux6: process (PCSource, ALU_ALUout, ALUout_mux1, J_32)
    BEGIN
	    if (PCSource = "00") then
	        pc_in <= ALU_ALUout;
	    elsif (PCSource = "01") then
		pc_in <= ALUout_mux1;
	    elsif (PCSource = "10") then
	 	pc_in <= J_32;
	    else
		pc_in <= (others => '0');
	    end if;
    end process;

    SignExtend: PROCESS (offset_out)
    BEGIN
	signExtend_out(15 downto 0) <= offset_out(15 downto 0);
	if (offset_out(15) = '1') then
	    signExtend_out(31 downto 16) <= "1111111111111111";
	else
	    signExtend_out(31 downto 16) <= "0000000000000000";
	end if;
    END PROCESS;

    MemoryUnit: mem PORT MAP (MemRead => MemRead, MemWrite => MemWrite, 
	 		      d_in => B_mux5, address => mux1_memory, d_out => memory_out);
    RFunit: RegFile PORT MAP (clk => clk,  wr_en => RegWrite,
			      rd_addr_1 => rs_out, rd_addr_2 => rt_out, wr_addr => mux2_regFile, d_in => mux3_regFile,
        		      d_out_1 => RF_A, d_out_2 => RF_B);
    ALUunit: ALU PORT MAP ( op_code => ALUControl, in0 => mux4_ALU, in1 => mux5_ALU, C => offset_out(10 downto 6),
        		    ALUout => ALU_ALUout, Zero => zero);
  
end datapath_arch;
