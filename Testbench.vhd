LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Testbench IS
END ENTITY;

ARCHITECTURE Structural OF Testbench IS
    CONSTANT c_CLOCK_50MHZ_PERIOD : TIME := 20ns;

    -- Input/Output Signals
    SIGNAL i_Clk        : STD_LOGIC := '0';
    SIGNAL i_Rst        : STD_LOGIC := '0';
    SIGNAL i_Ps2_Data   : STD_LOGIC := '0';
    SIGNAL i_Ps2_Clk    : STD_LOGIC := '0';
    SIGNAL o_Ssd_1      : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Ssd_2      : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); 
    SIGNAL i_Buttons    : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Lcd_Rs     : STD_LOGIC := '0';
    SIGNAL o_Lcd_Data   : t_Nibble := (OTHERS => '0');
    SIGNAL o_Lcd_Rw     : STD_LOGIC := '0';
    SIGNAL o_Lcd_E      : STD_LOGIC := '0';
BEGIN
    e_PUC16: ENTITY WORK.PUC16
    PORT MAP (
        i_Clk       => i_Clk,
        i_Rst       => i_Rst,
        i_Ps2_Data  => i_Ps2_Data,
        i_Ps2_Clk   => i_Ps2_Clk,
        o_Ssd_1     => o_Ssd_1,
        o_Ssd_2     => o_Ssd_2,
        i_Buttons   => i_Buttons,
        o_Leds      => o_Leds, 
		o_Lcd_Rs    => o_Lcd_Rs,
		o_Lcd_Data  => o_Lcd_Data,
		o_Lcd_Rw    => o_Lcd_Rw,
		o_Lcd_E     => o_Lcd_E
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_50MHZ_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_50MHZ_PERIOD/4;
    i_Buttons <= "0001", "1111" AFTER 40*c_CLOCK_50MHZ_PERIOD;
END ARCHITECTURE;