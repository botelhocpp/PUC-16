LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY SsdDriver IS
PORT (
    i_Value : IN t_Byte;
    i_Clk   : IN STD_LOGIC;
    i_Rst   : IN STD_LOGIC;
    o_Ssd_1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Ssd_2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE RTL OF SsdDriver IS
    SIGNAL w_Clk    : STD_LOGIC := '0';
    SIGNAL w_Ssd_1  : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL w_Ssd_2  : STD_LOGIC_VECTOR(6 DOWNTO 0);

    FUNCTION f_HexToSsd(i_Hex : t_Nibble) RETURN STD_LOGIC_VECTOR IS
        VARIABLE v_Ssd : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        CASE TO_INTEGER(UNSIGNED(i_Hex)) IS
            WHEN 0 => v_Ssd  := "0111111";
            WHEN 1 => v_Ssd  := "0000110";
            WHEN 2 => v_Ssd  := "1011011";
            WHEN 3 => v_Ssd  := "1001111";
            WHEN 4 => v_Ssd  := "1100110"; 
            WHEN 5 => v_Ssd  := "1101101";
            WHEN 6 => v_Ssd  := "1111101";
            WHEN 7 => v_Ssd  := "0000111";
            WHEN 8 => v_Ssd  := "1111111";
            WHEN 9 => v_Ssd  := "1100111";
            WHEN 10 => v_Ssd := "1110111";
            WHEN 11 => v_Ssd := "1111100";
            WHEN 12 => v_Ssd := "0111001";
            WHEN 13 => v_Ssd := "1011110";
            WHEN 14 => v_Ssd := "1111001";
            WHEN 15 => v_Ssd := "1110001";
        END CASE;
        
        RETURN v_Ssd;
    END FUNCTION;
BEGIN
    e_PRESCALER: ENTITY WORK.Prescaler
    PORT MAP (
        i_Clk => i_Clk,
        i_Rst => i_Rst,
        o_Clk => w_Clk
    );

    -- Select display
    o_Ssd_2(3) <= w_Clk;

    -- Decode hex to SSD
    w_Ssd_1 <= f_HexToSsd(i_Value(7 DOWNTO 4));
    w_Ssd_2 <= f_HexToSsd(i_Value(3 DOWNTO 0));
    
    -- Control SSD
    o_Ssd_1(0) <= w_Ssd_1(0) WHEN (w_Clk = '0') ELSE w_Ssd_2(0);
    o_Ssd_1(1) <= w_Ssd_1(1) WHEN (w_Clk = '0') ELSE w_Ssd_2(1);
    o_Ssd_1(2) <= w_Ssd_1(2) WHEN (w_Clk = '0') ELSE w_Ssd_2(2);
    o_Ssd_1(3) <= w_Ssd_1(3) WHEN (w_Clk = '0') ELSE w_Ssd_2(3);
    o_Ssd_2(0) <= w_Ssd_1(4) WHEN (w_Clk = '0') ELSE w_Ssd_2(4);
    o_Ssd_2(1) <= w_Ssd_1(5) WHEN (w_Clk = '0') ELSE w_Ssd_2(5);
    o_Ssd_2(2) <= w_Ssd_1(6) WHEN (w_Clk = '0') ELSE w_Ssd_2(6);
END ARCHITECTURE;
 