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
    CONSTANT c_ZERO : t_Reg16 := (OTHERS => '0');
    
    SIGNAL w_Result : t_Reg16 := (OTHERS => '0');
BEGIN
    WITH i_Sel SELECT
        w_Result <= (t_Reg16(t_SReg16(i_Op_1) + t_SReg16(i_Op_2)))  WHEN op_ADD | op_ADD_I | op_B | op_LDR | op_STR | op_POP,
                    (t_Reg16(t_SReg16(i_Op_1) - t_SReg16(i_Op_2)))  WHEN op_SUB | op_SUB_I | op_PUSH,
                    (i_Op_1 AND i_Op_2)                             WHEN op_AND,
                    (i_Op_1 OR i_Op_2)                              WHEN op_OR,
                    (i_Op_1 XOR i_Op_2)                             WHEN op_XOR,
                    (t_Reg16(SHIFT_LEFT(t_UReg16(i_Op_1), 1)))      WHEN op_SHFT_L,
                    (t_Reg16(SHIFT_RIGHT(t_UReg16(i_Op_1), 1)))     WHEN op_SHFT_R,
                    (i_Op_2)                                        WHEN op_MOV | op_MOVT | op_JMP,
                    (OTHERS => '0')                                 WHEN op_INVALID;

    o_Result <= w_Result;

	o_Flag_Zero <= '1' WHEN (w_Result = c_ZERO) ELSE '0';
	o_Flag_Carry <= '1' WHEN (i_Op_1 < i_Op_2) ELSE '0';
    o_Flag_Negative <= '1' WHEN (w_Result(c_WORD_SIZE - 1) = '1') ELSE '0';
    
    p_GENERATE_OVERFLOW_FLAG:
    PROCESS(i_Op_1, i_Op_2, w_Result, i_Sel)
    BEGIN
        IF i_Sel = op_SUB THEN
            IF(
                i_Op_1(c_WORD_SIZE - 1) /= i_Op_2(c_WORD_SIZE - 1) AND 
                w_Result(c_WORD_SIZE - 1) /= i_Op_1(c_WORD_SIZE - 1)
            ) THEN
                o_Flag_Overflow <= '1';
            ELSE
                o_Flag_Overflow <= '0';
            END IF;
        ELSE
            IF(
                i_Op_1(c_WORD_SIZE - 1) = i_Op_2(c_WORD_SIZE - 1) AND 
                w_Result(c_WORD_SIZE - 1) /= i_Op_1(c_WORD_SIZE - 1)
            ) THEN
                o_Flag_Overflow <= '1';
            ELSE
                o_Flag_Overflow <= '0';
            END IF;
        END IF;
    END PROCESS p_GENERATE_OVERFLOW_FLAG;
END ARCHITECTURE;
