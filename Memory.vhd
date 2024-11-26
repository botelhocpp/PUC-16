LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Memory IS
GENERIC (
    g_CONTENTS_FILE : STRING := "none"
);
PORT (
    i_Write_Data : IN t_Reg16;
    i_Address : IN t_Reg16;
    i_Write_Enable : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    o_Read_Data : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF Memory IS 
    SIGNAL r_Contents : t_MemoryArray := f_InitMemory(g_CONTENTS_FILE);
BEGIN 
    p_MEMORY_READ_WRITE_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            IF(i_Write_Enable = '1') THEN
                r_Contents(TO_INTEGER(t_UReg16(i_Address))) <= i_Write_Data;
            END IF;
            o_Read_Data <= r_Contents(TO_INTEGER(t_UReg16(i_Address)));
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
