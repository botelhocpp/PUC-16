LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY RegisterFile IS
PORT ( 
    i_Write_Data : IN t_Reg16;
    i_Read_Reg_1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_Read_Reg_2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_Write_Reg : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    i_Write_Enable : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    o_Read_Data_1 : OUT t_Reg16;
    o_Read_Data_2 : OUT t_Reg16 
);
END ENTITY;

ARCHITECTURE RTL OF RegisterFile IS
    TYPE t_RegisterArray IS ARRAY (0 TO c_WORD_SIZE - 1) OF t_Reg16;
    
    SIGNAL r_Registers : t_RegisterArray;
    SIGNAL w_Load_Registers : t_Reg16;
BEGIN
    gen_GENERATE_REGS:
    FOR i IN 0 TO c_WORD_SIZE - 1 GENERATE
        w_Load_Registers(i) <= '1' WHEN (TO_INTEGER(UNSIGNED(i_Write_Reg)) = i AND i_Write_Enable = '1') ELSE '0';
        
        e_GP_REGISTER: ENTITY WORK.GenericRegister
        PORT MAP (
            i_D     => i_Write_Data,
            i_Load  => w_Load_Registers(i),
            i_Clk   => i_Clk,
            i_Rst   => i_Rst,
            o_Q     => r_Registers(i)
        );
    END GENERATE gen_GENERATE_REGS;

    o_Read_Data_1 <= r_Registers(TO_INTEGER(UNSIGNED(i_Read_Reg_1)));  
    o_Read_Data_2 <= r_Registers(TO_INTEGER(UNSIGNED(i_Read_Reg_2)));    
END behavioral;
