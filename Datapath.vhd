LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Datapath IS
PORT ( 
    i_Data : IN t_Reg16;
    i_Immediate : IN t_Reg16;
    
    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;

    i_Read_Reg_1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_Read_Reg_2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_Write_Reg : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_Write_Enable : IN STD_LOGIC;
    i_Load_Flags : IN STD_LOGIC;
    i_Input_Select : IN STD_LOGIC;
    i_Address_Select : IN STD_LOGIC;
    i_Operand_Select : IN STD_LOGIC;   
    i_Operation : IN t_Operation;
    
    o_Flags : OUT t_Reg16;
    o_Address : OUT t_Reg16;
    o_Data_Out : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF Datapath IS
    SIGNAL w_Alu_Flags          : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Input_Mux          : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Register_1_Data    : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Register_2_Data    : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Operand_Mux        : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Alu_Result         : t_Reg16 := (OTHERS => '0');

    SIGNAL w_Flag_Zero          : STD_LOGIC := '0';
    SIGNAL w_Flag_Carry         : STD_LOGIC := '0';
    SIGNAL w_Flag_Negative      : STD_LOGIC := '0';
    SIGNAL w_Flag_Overflow      : STD_LOGIC := '0';
BEGIN
    e_FLAGS_REGISTER: ENTITY WORK.GenericRegister
    PORT MAP (
        i_D => w_Alu_Flags,
        i_Load => i_Load_Flags,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Q => o_Flags
    );
    e_REGISTER_FILE: ENTITY WORK.RegisterFile
    PORT MAP(
        i_Write_Data => w_Input_Mux,
        i_Read_Reg_1 => i_Read_Reg_1,
        i_Read_Reg_2 => i_Read_Reg_2,
        i_Write_Reg => i_Write_Reg,
        i_Write_Enable => i_Write_Enable,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Read_Data_1 => w_Register_1_Data,
        o_Read_Data_2 => w_Register_2_Data
    );
    e_ALU: ENTITY WORK.ArithmeticLogicUnit
    PORT MAP(
        i_Op_1 => w_Register_1_Data,
        i_Op_2 => w_Operand_Mux,
        i_Sel => i_Operation,
        o_Flag_Zero => w_Flag_Zero,
        o_Flag_Carry => w_Flag_Carry,
        o_Flag_Negative => w_Flag_Negative,
        o_Flag_Overflow => w_Flag_Overflow,
        o_Result => w_Alu_Result
    );
    
    o_Data_Out <= w_Register_2_Data;

    -- Wires
    w_Alu_Flags <= (
        c_ZERO_FLAG_INDEX => w_Flag_Zero, 
        c_CARRY_FLAG_INDEX => w_Flag_Carry,
        c_NEGATIVE_FLAG_INDEX => w_Flag_Negative,
        c_OVERFLOW_FLAG_INDEX => w_Flag_Overflow,
        OTHERS => '0'
    );

    -- Muxes
    o_Address <= w_Register_1_Data WHEN (i_Address_Select = '1') ELSE w_Alu_Result;
    w_Input_Mux <= i_Data WHEN (i_Input_Select = '1') ELSE w_Alu_Result;
    w_Operand_Mux <= i_Immediate WHEN (i_Operand_Select = '1') ELSE w_Register_2_Data;
    
END ARCHITECTURE;
