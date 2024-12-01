LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Memory IS
PORT (
    i_Write_Data : IN t_Reg16;
    i_Address : IN t_Reg16;
    i_Write_Enable : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    o_Read_Data : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF Memory IS 
    SIGNAL r_Contents : t_MemoryArray := (
        16 => "0000000000000000", -- simple.asm:1: main: mov r0, 0
        17 => "1001000000000001", -- simple.asm:2: loop: add r0, r0, 1
        18 => "0010000011111110", -- simple.asm:3: b @loop
        OTHERS => (OTHERS => '0')
    );
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 2**c_WORD_SIZE - 1 := 0;
BEGIN 
    w_Address <= TO_INTEGER(t_UReg16(i_Address));
    
    p_MEMORY_READ_WRITE_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            IF(w_Address < c_MEMORY_SIZE) THEN
                IF(i_Write_Enable = '1') THEN
                    r_Contents(w_Address) <= i_Write_Data;
                END IF;
                
                o_Read_Data <= r_Contents(w_Address);
            END IF;
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
