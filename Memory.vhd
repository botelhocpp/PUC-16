LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Memory IS
PORT (
    i_Write_Data    : IN t_Reg16;
    i_Address       : IN t_Reg16;
    i_Write_Enable  : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    o_Read_Data     : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF Memory IS 
    SIGNAL r_Contents : t_MemoryArray := (        
        16 => "0000000000000111", -- lcd_test.asm:13: main:  mov r0, 7
        17 => "0000000100010000", -- lcd_test.asm:14:        mov r1, low(@msg1)
        18 => "0001000100010000", -- lcd_test.asm:15:        movt r1, high(@msg1)
        19 => "1000000000000001", -- lcd_test.asm:17:        add r0, r0, r1
        20 => "0100001000010000", -- lcd_test.asm:18: wloop: ldr r2, [r1]
        21 => "0000110000000111", -- lcd_test.asm:20: _wait: mov r12, @ldr
        22 => "0100110011000000", -- lcd_test.asm:21:        ldr r12, [r12]
        23 => "1001110011000000", -- lcd_test.asm:22:        mov r12, r12
        24 => "0010001011111100", -- lcd_test.asm:23:        bnz @_wait
        25 => "0000110000000111", -- lcd_test.asm:24:        mov r12, @ldr
        26 => "0101001011000000", -- lcd_test.asm:25:        str r2, [r12]
        27 => "1001000100010001", -- lcd_test.asm:27:        add r1, r1, 1
        28 => "1010001000010000", -- lcd_test.asm:28:        sub r2, r1, r0
        29 => "0010001011110110", -- lcd_test.asm:29:        bnz @wloop
        30 => "0010000011111111", -- lcd_test.asm:31: halt:  b @halt
      4112 => "0000000001110111", -- lcd_test.asm:35: msg1:  .dw "w"
      4113 => "0000000001100101", -- lcd_test.asm:35:        .dw "e"
      4114 => "0000000001101100", -- lcd_test.asm:35:        .dw "l"
      4115 => "0000000001100011", -- lcd_test.asm:35:        .dw "c"
      4116 => "0000000001101111", -- lcd_test.asm:35:        .dw "o"
      4117 => "0000000001101101", -- lcd_test.asm:35:        .dw "m"
      4118 => "0000000001100101", -- lcd_test.asm:35:        .dw "e"
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
