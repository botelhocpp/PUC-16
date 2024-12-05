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
        -- .text
        16 => X"00F0", -- mov r0, 0xF0
        17 => X"1001", -- movt r0, 0x01
        18 => X"4100", -- ldr r1, [r0, 0]
        19 => X"4201", -- ldr r2, [r0, 1]
        20 => X"8312", -- add r3, r1, r2
        21 => X"A432", -- sub r4, r3, r2
        22 => X"9441", -- add r4, r4, 1
        23 => X"B441", -- sub r4, r4, 1
        24 => X"C440", -- shtf r4, r4, 1
        25 => X"C448", -- shtf r4, r4, -1
        26 => X"A514", -- sub r5, r1, r4
        27 => X"22F4", -- bnz -12
        28 => X"5302", -- str r3, [r0, 2]
        29 => X"60E1", -- push r1
        30 => X"60E2", -- push r2
        31 => X"71E0", -- pop r1
        32 => X"72E0", -- pop r2
        33 => X"3010", -- jmp 16
        
        -- .data
        16#01F0# => x"0001",
        16#01F1# => x"0002",
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
