LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY PUC16 IS
PORT (
    i_Clk       : IN STD_LOGIC;
    i_Rst       : IN STD_LOGIC;
    i_Ps2_Data  : IN STD_LOGIC;
    i_Ps2_Clk   : IN STD_LOGIC;
    o_Ssd_1     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Ssd_2     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
    i_Buttons   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Lcd_Rs    : OUT STD_LOGIC;
    o_Lcd_Data  : OUT t_Nibble;
    o_Lcd_Rw    : OUT STD_LOGIC;
    o_Lcd_E     : OUT STD_LOGIC
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
    e_CLOCK_WIZARD : ENTITY WORK.ClockWizard
    PORT MAP (
        i_Clk => i_Clk,
        reset => i_Rst,
        o_Clk => w_Clk,
        o_Locked => OPEN
    );
    e_PROCESSOR: ENTITY WORK.processor
    PORT MAP ( 
        i_Data       => w_Data_To_Processor,
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
        i_Ps2_Data      => i_Ps2_Data,
        i_Ps2_Clk       => i_Ps2_Clk,
        o_Ssd_1         => o_Ssd_1,
        o_Ssd_2         => o_Ssd_2,
        i_Buttons       => i_Buttons,
        o_Leds          => o_Leds, 
		o_Lcd_Rs        => o_Lcd_Rs,
		o_Lcd_Data      => o_Lcd_Data,
		o_Lcd_Rw        => o_Lcd_Rw,
		o_Lcd_E         => o_Lcd_E
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
END ARCHITECTURE;