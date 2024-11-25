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
        w_Result <= (t_Reg16(t_SReg16(i_Op_1) + t_SReg16(i_Op_2)))  WHEN e_ADD | e_ADD_I | e_B | e_LDR | e_STR | e_POP,
                    (t_Reg16(t_SReg16(i_Op_1) - t_SReg16(i_Op_2)))  WHEN e_SUB | e_SUB_I | e_PUSH,
                    (i_Op_1 AND i_Op_2)                             WHEN e_AND,
                    (i_Op_1 OR i_Op_2)                              WHEN e_OR,
                    (i_Op_1 XOR i_Op_2)                             WHEN e_XOR,
                    (t_Reg16(SHIFT_LEFT(t_UReg16(i_Op_1), 1)))      WHEN e_SHFT_L,
                    (t_Reg16(SHIFT_RIGHT(t_UReg16(i_Op_1), 1)))     WHEN e_SHFT_R,
                    (i_Op_2)                                        WHEN e_MOV | e_MOVT | e_JMP,
                    (OTHERS => '0')                                 WHEN e_INVALID

    o_Result <= w_Result;

	o_Flag_Zero <= '1' WHEN (w_Result = c_ZERO) ELSE '0';
	o_Flag_Carry <= '1' WHEN (i_Op_1 < i_Op_2) ELSE '0';
    o_Flag_Negative <= '1' WHEN (w_Result(c_WORD_SIZE - 1) = '1') ELSE '0';
    
    p_GENERATE_OVERFLOW_FLAG:
    PROCESS(i_Op_A, i_Op_B, i_Sel)
    BEGIN
        IF i_Sel = e_SUB THEN
            o_Flag_Overflow <= '1' WHEN (i_Op_A(c_WORD_SIZE - 1) /= i_Op_B(c_WORD_SIZE - 1)) AND (w_Result(c_WORD_SIZE - 1) /= i_Op_A(c_WORD_SIZE - 1)) ELSE '0';
        ELSE
            o_Flag_Overflow <= '1' WHEN (i_Op_A(c_WORD_SIZE - 1) = i_Op_B(c_WORD_SIZE - 1)) AND (w_Result(c_WORD_SIZE - 1) /= i_Op_A(c_WORD_SIZE - 1)) ELSE '0';
        END IF;
    END PROCESS p_GENERATE_OVERFLOW_FLAG;
END ARCHITECTURE;
