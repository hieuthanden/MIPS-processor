-- Student name: your name goes here
-- Student ID number: your student id # goes here

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity CPU is
  
  port (
    clk     : in std_logic;
    reset_N : in std_logic);            -- active-low signal for reset

end CPU;

architecture CPU_arch of CPU is
-- component declaration
	
	-- Datapath (from Lab 5)
    component datapath is
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
    	zero       : out std_logic;	-- send zero to controller (cond. branch)
    	pc_out     : out word;
    	mem_out : out word;
    	ins_rs_out : out reg_addr;
    	ins_rt_out : out reg_addr;
    	ins_offset_out : out offset;
    	A_out      : out word;
    	B_out      : out word;
    	ALUout_out : out word);
    end component;

	-- Controller (you just built)
   component control is 
   port(
        clk   	    : IN STD_LOGIC; 
        reset_N	    : IN STD_LOGIC; 
        
        op_code     : IN opcode;     -- declare type for the 6 most significant bits of IR
        funct       : IN opcode;     -- declare type for the 6 least significant bits of IR 
     	zero        : IN STD_LOGIC;
        
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
    end component;

-- component specification

    SIGNAL PCUpdate_s   : std_logic;
    SIGNAL IorD_s       : std_logic;
    SIGNAL MemRead_s   : std_logic;
    SIGNAL MemWrite_s   : std_logic;
    SIGNAL IRWrite_s    : std_logic;            
    SIGNAL MemtoReg_s   : std_logic_vector(1 downto 0);  
    SIGNAL RegDst_s     : std_logic_vector(1 downto 0);  
    SIGNAL RegWrite_s   : std_logic;         
    SIGNAL ALUSrcA_s    : std_logic;         
    SIGNAL ALUSrcB_s    : std_logic_vector(1 downto 0); 
    SIGNAL ALUControl_s : ALU_opcode;	
    SIGNAL PCSource_s   : std_logic_vector(1 downto 0); 
    SIGNAL opcode_s     : opcode;	
    SIGNAL funct_s       : opcode;	
    SIGNAL zero_s       : std_logic;
    SIGNAL pc_out_s     : word;
    SIGNAL mem_out_s    : word;
    SIGNAL ins_rs_out_s : reg_addr;
    SIGNAL ins_rt_out_s : reg_addr;
    SIGNAL ins_offset_out_s : offset;
    SIGNAL A_out_s      : word;
    SIGNAL B_out_s      : word;
    SIGNAL ALUout_out_s : word;

begin

    control_com: control PORT MAP (
	clk => clk,
        reset_N => reset_N,
        op_code => opcode_s ,
        funct => funct_s,
     	zero => zero_s,
     	PCUpdate => PCUpdate_s,
     	IorD => IorD_s,
     	MemRead => MemRead_s,
     	MemWrite => MemWrite_s,
     	IRWrite => IRWrite_s,
     	MemtoReg => MemtoReg_s,
     	RegDst => RegDst_s,
     	RegWrite => RegWrite_s,
     	ALUSrcA => ALUSrcA_s,
     	ALUSrcB => ALUSrcB_s,
     	ALUcontrol => ALUcontrol_s,
     	PCSource => PCSource_s
    );

    datapath_com: datapath PORT MAP (
	clk => clk,
    	reset_N => reset_N,
    	PCUpdate => PCUpdate_s,
     	IorD => IorD_s,
     	MemRead => MemRead_s,
     	MemWrite => MemWrite_s,
     	IRWrite => IRWrite_s,
     	MemtoReg => MemtoReg_s,
     	RegDst => RegDst_s,
     	RegWrite => RegWrite_s,
     	ALUSrcA => ALUSrcA_s,
     	ALUSrcB => ALUSrcB_s,
     	ALUcontrol => ALUcontrol_s,
     	PCSource => PCSource_s,
    	opcode_out => opcode_s ,
    	func_out  => funct_s,
    	zero     => zero_s,
	pc_out => pc_out_s
    );
end CPU_arch;
