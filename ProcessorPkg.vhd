LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
USE STD.TEXTIO.ALL;

PACKAGE ProcessorPkg IS
    CONSTANT c_MEMORY_SIZE : INTEGER := 8192;
    CONSTANT c_WORD_SIZE : INTEGER := 16;

    SUBTYPE t_Reg16 IS STD_LOGIC_VECTOR(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_UReg16 IS UNSIGNED(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_SReg16 IS SIGNED(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_Byte IS STD_LOGIC_VECTOR(7 DOWNTO 0);
    SUBTYPE t_Nibble IS STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    TYPE t_MemoryArray IS ARRAY (0 TO c_MEMORY_SIZE - 1) OF t_Byte;
    
    TYPE t_Operation IS (
        e_MOV,
        e_MOVT,
        e_B,
        e_JMP,
        e_LDR,
        e_STR,
        e_PUSH,
        e_POP,
        e_ADD,
        e_SUB,
        e_ADD_I,
        e_SUB_I,
        e_SHFT_L,
        e_SHFT_R,
        e_AND,
        e_OR,
        e_XOR,
        e_INVALID
    );
    
    PURE FUNCTION f_DecodeInstruction(i_Instruction : t_Reg16) RETURN t_Operation;
    PURE FUNCTION f_HexToBin(i_Hex : CHARACTER) RETURN t_Nibble;
    IMPURE FUNCTION f_InitMemory(i_File_Name : STRING) RETURN t_MemoryArray;

END ProcessorPkg;

PACKAGE BODY ProcessorPkg IS
    PURE FUNCTION f_DecodeInstruction(i_Instruction : t_Reg16) RETURN t_Operation IS
        ALIAS a_OPCODE_FIELD IS i_Instruction(15 DOWNTO 12);
        ALIAS a_SHIFT_FIELD IS i_Instruction(3);

        VARIABLE v_Operation : t_Operation := e_INVALID;
    BEGIN
        CASE a_OPCODE_FIELD IS
            WHEN "0000" =>
                v_Operation := e_MOV;
            WHEN "0001" =>
                v_Operation := e_MOVT;
            WHEN "0010" =>
                v_Operation := e_B;
            WHEN "0011" =>
                v_Operation := e_JMP;
            WHEN "0100" =>
                v_Operation := e_LDR;
            WHEN "0101" =>
                v_Operation := e_STR;
            WHEN "0110" =>
                v_Operation := e_PUSH;
            WHEN "0111" =>
                v_Operation := e_POP;
            WHEN "1000" =>
                v_Operation := e_ADD;
            WHEN "1001" =>
                v_Operation := e_ADD_I;
            WHEN "1010" =>
                v_Operation := e_SUB;
            WHEN "1011" =>
                v_Operation := e_SUB_I;
            WHEN "1100" =>
                IF(a_SHIFT_FIELD = '1') THEN
                    v_Operation := e_SHFT_R;
                ELSE
                    v_Operation := e_SHFT_L;
                END IF;
            WHEN "1101" =>
                v_Operation := e_AND;
            WHEN "1110" =>
                v_Operation := e_OR;
            WHEN "1111" =>
                v_Operation := e_XOR;
            WHEN OTHERS =>
                v_Operation := e_INVALID;
        END CASE;
        RETURN v_Operation;
    END f_DecodeInstruction;   
    
    PURE FUNCTION f_HexToBin(i_Hex : CHARACTER) RETURN t_Nibble IS
        VARIABLE v_Bin : t_Nibble := (OTHERS => '0');
    BEGIN
        CASE i_Hex IS
            WHEN '0' => v_Bin := "0000";
            WHEN '1' => v_Bin := "0001";
            WHEN '2' => v_Bin := "0010";
            WHEN '3' => v_Bin := "0011";
            WHEN '4' => v_Bin := "0100";
            WHEN '5' => v_Bin := "0101";
            WHEN '6' => v_Bin := "0110";
            WHEN '7' => v_Bin := "0111";
            WHEN '8' => v_Bin := "1000";
            WHEN '9' => v_Bin := "1001";
            WHEN 'A' | 'a' => v_Bin := "1010";
            WHEN 'B' | 'b' => v_Bin := "1011";
            WHEN 'C' | 'c' => v_Bin := "1100";
            WHEN 'i_D' | 'd' => v_Bin := "1101";
            WHEN 'E' | 'e' => v_Bin := "1110";   
            WHEN 'F' | 'f' => v_Bin := "1111";
            WHEN OTHERS => v_Bin := "0000";     
        END CASE;
        
        RETURN v_Bin;
    END f_HexToBin;
    
    IMPURE FUNCTION f_InitMemory(i_File_Name : STRING) RETURN t_MemoryArray IS
      FILE v_Text_File : TEXT;
      VARIABLE v_Text_Line : LINE;
      VARIABLE v_Contents : t_MemoryArray := (OTHERS => (OTHERS => '0'));
      VARIABLE v_Success : FILE_OPEN_STATUS;
      VARIABLE v_Hex_String : STRING(1 TO 8);
      
      VARIABLE i : INTEGER := 0;
    BEGIN
        FILE_OPEN(v_Success, v_Text_File, i_File_Name, READ_MODE);
        IF (v_Success = OPEN_OK) THEN
          WHILE NOT ENDFILE(v_Text_File) LOOP
            READLINE(v_Text_File, v_Text_Line);
            READ(v_Text_Line, v_Hex_String);
            
            FOR j IN 0 TO 3 LOOP
                 v_Contents(i + 3 - j) := f_HexToBin(v_Hex_String(2*j + 1)) & f_HexToBin(v_Hex_String(2*j + 2));
            END LOOP;
            
            i := i + 4;
          END LOOP;
          
          FOR j IN i TO c_MEMORY_SIZE - 1 LOOP
            v_Contents(j) := (OTHERS => '0');
          END LOOP;
      END IF;
      RETURN v_Contents;
    END FUNCTION;
END ProcessorPkg;
