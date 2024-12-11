LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Processor IS
PORT ( 
    i_Data       : IN t_Reg16;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    o_Write_Enable  : OUT STD_LOGIC;
    o_Address       : OUT t_Reg16;
    o_Data_Out      : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE Structural OF Processor IS
    SIGNAL w_Flags : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Immediate : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Register_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Load_Flags : STD_LOGIC := '0';
    SIGNAL w_Input_Select : STD_LOGIC := '0';
    SIGNAL w_Address_Select : STD_LOGIC := '0';
    SIGNAL w_Operand_Select : STD_LOGIC := '0';
    SIGNAL w_Read_Reg_1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Read_Reg_2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Write_Reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Operation : t_Operation := op_INVALID;
BEGIN
    e_DATAPATH: ENTITY WORK.Datapath
    PORT MAP(
        i_Data => i_Data,
        i_Immediate => w_Immediate,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        i_Read_Reg_1 => w_Read_Reg_1,
        i_Read_Reg_2 => w_Read_Reg_2,
        i_Write_Reg => w_Write_Reg,
        i_Write_Enable => w_Register_Write_Enable,
        i_Load_Flags => w_Load_Flags,
        i_Input_Select => w_Input_Select,
        i_Address_Select => w_Address_Select,
        i_Operand_Select => w_Operand_Select,
        i_Operation => w_Operation,
        o_Flags => w_Flags,
        o_Address => o_Address,
        o_Data_Out => o_Data_Out
    );
    e_CONTROL_UNIT: ENTITY WORK.ControlUnit
    PORT MAP(
        i_Instruction => i_Data,
        i_Flags => w_Flags,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Read_Reg_1 => w_Read_Reg_1,
        o_Read_Reg_2 => w_Read_Reg_2,
        o_Write_Reg => w_Write_Reg,
        o_Register_Write_Enable => w_Register_Write_Enable,
        o_Memory_Write_Enable => o_Write_Enable,
        o_Load_Flags => w_Load_Flags,
        o_Input_Select => w_Input_Select,
        o_Address_Select => w_Address_Select,
        o_Operand_Select => w_Operand_Select,
        o_Operation => w_Operation,
        o_Immediate => w_Immediate
    );
    
END ARCHITECTURE;
