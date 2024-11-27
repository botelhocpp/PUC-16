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
    TYPE t_InstructionCycle IS (
        s_FETCH_1,
        s_FETCH_2,
        s_EXECUTE,
        s_WRITE_BACK
    );
    SIGNAL r_Current_State : t_InstructionCycle := s_FETCH_1;

    -- Aliases
    ALIAS a_ZERO_FLAG IS i_Flags(c_ZERO_FLAG_INDEX);
    ALIAS a_CARRY_FLAG IS i_Flags(c_CARRY_FLAG_INDEX);
    ALIAS a_NEGATIVE_FLAG IS i_Flags(c_NEGATIVE_FLAG_INDEX);
    ALIAS a_OVERFLOW_FLAG IS i_Flags(c_OVERFLOW_FLAG_INDEX);

    -- Wires
    SIGNAL w_Operation : t_Operation := op_INVALID;
    SIGNAL w_Read_Reg_1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Read_Reg_2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Write_Reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Register_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Memory_Write_Enable : STD_LOGIC := '0';
    SIGNAL w_Load_Flags : STD_LOGIC := '0';
    SIGNAL w_Input_Select : STD_LOGIC := '0';
    SIGNAL w_Address_Select : STD_LOGIC := '0';
    SIGNAL w_Operand_Select : STD_LOGIC := '0';   
    SIGNAL w_Load_Cir : STD_LOGIC := '0';   
    SIGNAL w_Immediate : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Instruction : t_Reg16 := (OTHERS => '0');
BEGIN
    e_CIR_REGISTER: ENTITY WORK.GenericRegister
    PORT MAP (
        i_D => i_Instruction,
        i_Load => w_Load_Cir,
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Q => w_Instruction
    );

    -- Map Control Signals
    o_Read_Reg_1 <= w_Read_Reg_1;
    o_Read_Reg_2 <= w_Read_Reg_2;
    o_Write_Reg <= w_Write_Reg;
    o_Register_Write_Enable <= w_Register_Write_Enable;
    o_Memory_Write_Enable <= w_Memory_Write_Enable;
    o_Load_Flags <= w_Load_Flags;
    o_Input_Select <= w_Input_Select;
    o_Address_Select <= w_Address_Select;
    o_Operand_Select <= w_Operand_Select;
    o_Operation <= w_Operation;
    o_Immediate <= w_Immediate;

    p_INSTRUCTION_CYCLE_NEXT_STATE:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
        ELSIF(RISING_EDGE(i_Clk)) THEN
            CASE r_Current_State IS
                WHEN s_FETCH_1 =>
                    r_Current_State <= s_FETCH_2;

                WHEN s_FETCH_2 =>
                    r_Current_State <= s_EXECUTE;
                    
                WHEN s_EXECUTE =>
                    IF(w_Operation = op_LDR OR w_Operation = op_POP) THEN
                        r_Current_State <= s_WRITE_BACK;
                    ELSE
                        r_Current_State <= s_FETCH_1;
                    END IF;
                
                WHEN s_WRITE_BACK =>
                    r_Current_State <= s_FETCH_1;
                
            END CASE;
        END IF;
    END PROCESS p_INSTRUCTION_CYCLE_NEXT_STATE;

    p_INSTRUCTION_CYCLE_GENERATE_SIGNALS:
    PROCESS(i_Flags, r_Current_State, w_Instruction, w_Operation)
        VARIABLE v_Condition : t_Condition := cond_INVALID;
    BEGIN
        -- Default values (inclined to ALU operations)
        w_Operation <= f_DecodeInstruction(w_Instruction);
        w_Write_Reg <= w_Instruction(11 DOWNTO 8);
        w_Read_Reg_1 <= w_Instruction(7 DOWNTO 4);
        w_Read_Reg_2 <= w_Instruction(3 DOWNTO 0);
        w_Register_Write_Enable <= '0';
        w_Memory_Write_Enable <= '0';
        w_Load_Flags <= '0';
        w_Input_Select <= '0';
        w_Address_Select <= '0';
        w_Operand_Select <= '0';  
        w_Load_Cir <= '0';

        -- Set immediate
        CASE w_Operation IS
            WHEN op_MOV | op_MOVT =>    w_Immediate <= t_Reg16(RESIZE(t_UReg16(w_Instruction(7 DOWNTO 0)), 16));
            WHEN op_B =>                w_Immediate <= t_Reg16(RESIZE(t_SReg16(w_Instruction(7 DOWNTO 0)), 16));
            WHEN op_JMP =>              w_Immediate <= t_Reg16(RESIZE(t_UReg16(w_Instruction(11 DOWNTO 0)), 16));
            WHEN op_LDR | op_STR =>     w_Immediate <= t_Reg16(RESIZE(t_SReg16(w_Instruction(3 DOWNTO 0)), 16));
            WHEN op_PUSH | op_POP =>    w_Immediate <= x"0001";
            WHEN op_ADD_I | op_SUB_I => w_Immediate <= t_Reg16(RESIZE(t_UReg16(w_Instruction(3 DOWNTO 0)), 16));
            WHEN OTHERS =>              w_Immediate <= (OTHERS => '0');
        END CASE;

        -- Set state specific signals
        CASE r_Current_State IS
            WHEN s_FETCH_1 =>
                w_Operation <= op_ADD;
                w_Write_Reg <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Write_Reg'LENGTH));
                w_Read_Reg_1 <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Read_Reg_1'LENGTH));
                w_Immediate <= x"0001";
                w_Register_Write_Enable <= '1';
                w_Address_Select <= '1';
                w_Operand_Select <= '1';

            WHEN s_FETCH_2 =>
                w_Load_Cir <= '1';
            
            WHEN s_EXECUTE =>      
                -- Register Write Enable
                IF(w_Operation = op_B) THEN
                    v_Condition := f_DecodeCondition(w_Instruction(11 DOWNTO 8));
                    
                    IF(
                        (v_Condition = cond_AL) OR
                        (v_Condition = cond_Z AND a_ZERO_FLAG = '1') OR
                        (v_Condition = cond_NZ AND a_ZERO_FLAG = '0') OR
                        (v_Condition = cond_CS AND a_CARRY_FLAG = '1') OR
                        (v_Condition = cond_CC AND a_CARRY_FLAG = '0') OR
                        (v_Condition = cond_LT AND a_OVERFLOW_FLAG /= a_NEGATIVE_FLAG) OR
                        (v_Condition = cond_GE AND a_OVERFLOW_FLAG = a_NEGATIVE_FLAG)
                    ) THEN
                        w_Register_Write_Enable <= '1';
                    END IF;

                ELSIF(w_Operation /= op_STR) THEN
                    w_Register_Write_Enable <= '1';
                END IF;
                      
                -- Memory Write Enable   
                IF(w_Operation = op_STR OR w_Operation = op_PUSH) THEN   
                    w_Memory_Write_Enable <= '1';
                END IF;
                
                -- Load Flags
                CASE w_Operation IS
                    WHEN op_ADD | op_SUB | op_ADD_I | op_SUB_I | op_SHFT_L | op_SHFT_R | op_AND | op_OR | op_XOR =>
                        w_Load_Flags <= '1';
                    WHEN OTHERS =>
                END CASE;

                -- Destiny Register Select
                IF(w_Operation = op_JMP OR w_Operation = op_B) THEN
                    w_Write_Reg <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_PC_INDEX, w_Write_Reg'LENGTH)); 
                ELSIF(w_Operation = op_PUSH OR w_Operation = op_POP) THEN
                    w_Write_Reg <= STD_LOGIC_VECTOR(TO_UNSIGNED(c_REGISTER_SP_INDEX, w_Write_Reg'LENGTH)); 
                END IF;
                      
                -- Memory Address Select   
                IF(w_Operation = op_PUSH) THEN   
                    w_Address_Select <= '1';
                END IF;
                      
                -- ALU Operand Select   
                CASE w_Operation IS
                    WHEN op_B | op_JMP | op_LDR | op_STR | op_PUSH | op_POP | op_ADD_I | op_SUB_I =>
                        w_Operand_Select <= '1';
                    WHEN OTHERS =>
                END CASE;

            WHEN s_WRITE_BACK =>
                w_Input_Select <= '1';
                w_Register_Write_Enable <= '1';
        END CASE;
    END PROCESS p_INSTRUCTION_CYCLE_GENERATE_SIGNALS;
END ARCHITECTURE;
