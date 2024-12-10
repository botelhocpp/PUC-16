LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY PUC16 IS
PORT (
    i_Clk       : IN STD_LOGIC;
    i_Rst       : IN STD_LOGIC;
    i_Buttons   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- /ps2 keyboard
    ps2_data : IN STD_LOGIC;
    ps2_clk : IN STD_LOGIC;
    
    -- /lcd
    lcd_rs : OUT STD_LOGIC;
    lcd_data : OUT t_Nibble;
    lcd_rw : OUT STD_LOGIC;
    lcd_e : OUT STD_LOGIC;
    
    j1 : OUT STD_LOGIC_VECTOR(3 downto 0);
    j2 : OUT STD_LOGIC_VECTOR(3 downto 0)
);
END ENTITY;

ARCHITECTURE Structural OF PUC16 IS
    SIGNAL w_Clk : STD_LOGIC := '0';

    -- Wires
    SIGNAL w_Data_To_Processor          : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_From_Input_Output     : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_From_Memory           : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Address                    : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Data_From_Processor        : t_Reg16 := (OTHERS => '0');
    SIGNAL w_Write_Enable               : STD_LOGIC := '0';
    SIGNAL w_Memory_Write_Enable        : STD_LOGIC := '0';
    SIGNAL w_Input_Output_Write_Enable  : STD_LOGIC := '0';
BEGIN
    e_PROCESSOR: ENTITY WORK.processor
    PORT MAP ( 
        i_Data_In       => w_Data_To_Processor,
        i_Clk           => w_Clk,
        i_Rst           => i_Rst,
        o_Write_Enable  => w_Write_Enable,
        o_Address       => w_Address,
        o_Data_Out      => w_Data_From_Processor
    );
    e_MEMORY: ENTITY WORK.Memory
    PORT MAP ( 
        i_Write_Data    => w_Data_From_Processor,
        i_Address       => w_Address,
        i_Write_Enable  => w_Memory_Write_Enable,
        i_Clk           => w_Clk,
        o_Read_Data     => w_Data_From_Memory
    );
    e_IO_CONTROLLER: ENTITY WORK.InputOutputController
    PORT MAP (
        i_Write_Data    => w_Data_From_Processor,
        i_Address       => w_Address, 
        i_Write_Enable  => w_Input_Output_Write_Enable, 
        i_Clk           => w_Clk, 
        i_Rst           => i_Rst,
        o_Read_Data     => w_Data_From_Input_Output,
        i_Buttons       => i_Buttons,
        o_Leds          => o_Leds, 
		ps2_data        => ps2_data,
		ps2_clk         => ps2_clk,
		lcd_rs          => lcd_rs,
		lcd_data        => lcd_data,
		lcd_rw          => lcd_rw,
		lcd_e           => lcd_e,
		j1              => j1,
		j2              => j2
    );

    w_Memory_Write_Enable <= '1' WHEN (
        w_Write_Enable = '1' AND
        w_Address >= x"0010"
    ) ELSE '0';
    
    w_Input_Output_Write_Enable <= '1' WHEN (
        w_Write_Enable = '1' AND
        w_Address < x"0010"
    ) ELSE '0';

    w_Data_To_Processor <=  w_Data_From_Memory WHEN (w_Address >= x"0010") ELSE 
                            w_Data_From_Input_Output;
    
    e_CLOCK_WIZARD : ENTITY WORK.ClockWizard
    PORT MAP (
        i_Clk => i_Clk,
        reset => '0',
        o_Clk => w_Clk,
        o_Locked => OPEN
    );
END ARCHITECTURE;