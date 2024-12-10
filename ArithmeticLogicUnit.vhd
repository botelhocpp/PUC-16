LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ArithmeticLogicUnit IS
PORT(
    i_Op_1 : IN t_Reg16;
    i_Op_2 : IN t_Reg16;
    i_Sel : IN t_Operation;
    o_Flag_Zero : OUT STD_LOGIC;
    o_Flag_Carry : OUT STD_LOGIC;
    o_Flag_Negative : OUT STD_LOGIC;
    o_Flag_Overflow : OUT STD_LOGIC;
    o_Result : OUT t_Reg16
);
END ENTITY;

ARCHITECTURE RTL OF ArithmeticLogicUnit IS
    SUBTYPE t_UReg17 IS UNSIGNED(c_WORD_SIZE DOWNTO 0);
    -- SUBTYPE t_SReg17 IS SIGNED(c_WORD_SIZE DOWNTO 0);

    CONSTANT c_ZERO : t_UReg17 := (OTHERS => '0');
    
    SIGNAL w_Result : t_UReg17 := (OTHERS => '0');
    SIGNAL w_Op_1 : t_UReg17 := (OTHERS => '0');
    SIGNAL w_Op_2 : t_UReg17 := (OTHERS => '0');
BEGIN
    w_Op_1 <= RESIZE(t_UReg16(i_Op_1), c_WORD_SIZE + 1);
    w_Op_2 <= RESIZE(t_UReg16(i_Op_2), c_WORD_SIZE + 1);

    WITH i_Sel SELECT
        w_Result <= (w_Op_1 + w_Op_2)                           WHEN op_ADD | op_ADD_I | op_B | op_LDR | op_STR | op_POP,
                    (w_Op_1 - w_Op_2)                           WHEN op_SUB | op_SUB_I | op_PUSH,
                    (SHIFT_LEFT(w_Op_1, 1))                     WHEN op_SHFT_L,
                    (SHIFT_RIGHT(w_Op_1, 1))                    WHEN op_SHFT_R,
                    (w_Op_1 AND w_Op_2)                         WHEN op_AND,
                    (w_Op_1 OR w_Op_2)                          WHEN op_OR,
                    (w_Op_1 XOR w_Op_2)                         WHEN op_XOR,
                    (w_Op_2)                                    WHEN op_MOV | op_JMP,
                    (w_Op_2(8 DOWNTO 0) & w_Op_1(7 DOWNTO 0))   WHEN op_MOVT,
                    (OTHERS => '0')                             WHEN op_INVALID;

    o_Result <= t_Reg16(w_Result(c_WORD_SIZE - 1 DOWNTO 0));

	o_Flag_Zero <= '1' WHEN (w_Result = c_ZERO) ELSE '0';
    o_Flag_Negative <= w_Result(c_WORD_SIZE - 1);
	
    p_GENERATE_CARRY_FLAG:
    PROCESS(w_Op_1, w_Op_2, w_Result, i_Sel)
    BEGIN
        IF(i_Sel = op_SUB OR i_Sel = op_SUB_I) THEN
            IF(w_Op_1 >= w_Op_2) THEN
                o_Flag_Carry <= '1';
            ELSE
                o_Flag_Carry <= '0';
            END IF;
        ELSE
            o_Flag_Carry <= w_Result(c_WORD_SIZE);
        END IF;
    END PROCESS p_GENERATE_CARRY_FLAG;
    
    p_GENERATE_OVERFLOW_FLAG:
    PROCESS(w_Op_1, w_Op_2, w_Result, i_Sel)
    BEGIN
        IF i_Sel = op_SUB THEN
            IF(
                w_Op_1(c_WORD_SIZE - 1) /= w_Op_2(c_WORD_SIZE - 1) AND 
                w_Result(c_WORD_SIZE - 1) /= w_Op_1(c_WORD_SIZE - 1)
            ) THEN
                o_Flag_Overflow <= '1';
            ELSE
                o_Flag_Overflow <= '0';
            END IF;
        ELSE
            IF(
                w_Op_1(c_WORD_SIZE - 1) = w_Op_2(c_WORD_SIZE - 1) AND 
                w_Result(c_WORD_SIZE - 1) /= w_Op_1(c_WORD_SIZE - 1)
            ) THEN
                o_Flag_Overflow <= '1';
            ELSE
                o_Flag_Overflow <= '0';
            END IF;
        END IF;
    END PROCESS p_GENERATE_OVERFLOW_FLAG;
END ARCHITECTURE;
