LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ControlUnit IS
PORT (    
    i_Instruction : IN t_Reg16;
    i_Flags : IN t_Reg16;

    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;

    o_Read_Reg_1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Read_Reg_2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Write_Reg : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Register_Write_Enable : OUT STD_LOGIC;
    o_Memory_Write_Enable : OUT STD_LOGIC;
    o_Load_Flags : OUT STD_LOGIC;
    o_Input_Select : OUT STD_LOGIC;
    o_Address_Select : OUT STD_LOGIC;
    o_Operand_Select : OUT STD_LOGIC;   
    o_Operation : OUT t_Operation;

    o_Immediate : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF ControlUnit IS
    SIGNAL w_Operation : t_Operation := op_INVALID;
BEGIN
    -- Internal Signals
    w_Operation <= f_DecodeInstruction(i_Instruction);

    -- Control Signals
    o_Read_Reg_1 <= i_Instruction() WHEN() ELSE;
    o_Read_Reg_2 <= i_Instruction() WHEN() ELSE;
    o_Write_Reg <= i_Instruction() WHEN() ELSE;
    o_Register_Write_Enable <= i_Instruction() WHEN() ELSE;
    o_Memory_Write_Enable <= i_Instruction() WHEN() ELSE;
    o_Load_Flags <= i_Instruction() WHEN() ELSE;
    o_Input_Select <= i_Instruction() WHEN() ELSE;
    o_Address_Select <= i_Instruction() WHEN() ELSE;
    o_Operand_Select <= i_Instruction() WHEN() ELSE;  

    WITH w_Operation SELECT  
        o_Immediate <=  i_Instruction(7 DOWNTO 4)   WHEN op_MOV | op_MOVT,
                        i_Instruction(7 DOWNTO 0)   WHEN op_B,
                        i_Instruction(11 DOWNTO 0)  WHEN op_JMP,
                        i_Instruction(7 DOWNTO 4)   WHEN op_LDR | op_STR;

    o_Operation <= w_Operation;
END ARCHITECTURE;
