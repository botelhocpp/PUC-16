LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Testbench IS
END ENTITY;

ARCHITECTURE Structural OF Testbench IS
    CONSTANT c_CLOCK_50MHZ_PERIOD : TIME := 20ns;

    -- Input Signals
    SIGNAL i_Clk        : STD_LOGIC := '0';
    SIGNAL i_Rst        : STD_LOGIC := '0';
    SIGNAL i_Buttons    : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL o_Leds       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');


    -- /ps2 keyboard
    SIGNAL ps2_data : STD_LOGIC := '0';
    SIGNAL ps2_clk : STD_LOGIC := '0';
    
    -- /lcd
    SIGNAL lcd_rs : STD_LOGIC := '0';
    SIGNAL lcd_data : t_Nibble := (OTHERS => '0');
    SIGNAL lcd_rw : STD_LOGIC := '0';
    SIGNAL lcd_e : STD_LOGIC := '0';
     
    SIGNAL j1 : STD_LOGIC_VECTOR(3 downto 0) := (OTHERS => '0');
    SIGNAL j2 : STD_LOGIC_VECTOR(3 downto 0) := (OTHERS => '0');
BEGIN
    e_PUC16: ENTITY WORK.PUC16
    PORT MAP (
        i_Clk       => i_Clk,
        i_Rst       => i_Rst,
        i_Buttons   => i_Buttons,
        o_Leds      => o_Leds,
		ps2_data    => ps2_data,
		ps2_clk     => ps2_clk,
		lcd_rs      => lcd_rs,
		lcd_data    => lcd_data,
		lcd_rw      => lcd_rw,
		lcd_e       => lcd_e,
		j1          => j1,
		j2          => j2
    );
    
    i_Clk <= NOT i_Clk AFTER c_CLOCK_50MHZ_PERIOD/2;
    i_Rst <= '1', '0' AFTER c_CLOCK_50MHZ_PERIOD/4;
    i_Buttons <= "0001", "1111" AFTER 40*c_CLOCK_50MHZ_PERIOD;
END ARCHITECTURE;