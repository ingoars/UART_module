library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.JPU16_PACK.ALL;
use WORK.UART_module_pack.ALL;

entity TopLevel is
   port (clk: in STD_LOGIC;
         TX: out STD_LOGIC;
         RX: in STD_LOGIC);
end TopLevel;

architecture Behavior of TopLevel is
   signal BusEntrada: JPU16_INPUT_BUS;
   signal BusSalida: JPU16_OUTPUT_BUS;
   signal BusDirecciones: JPU16_IO_ADDR_BUS;
   signal BusRD: STD_LOGIC;
   signal BusWR: STD_LOGIC;

begin
   Procesador1: JPU16
   port map(SysClk => clk,
            Reset => '0',
            SysHold => '0',
            Int => '0',
            IO_Din(0) => BusEntrada,
            IO_Dout => BusSalida,
            IO_Addr => BusDirecciones,
            IO_RD => BusRD,
            IO_WR => BusWR);

   Periferico1: UART_module
   port map(CLK => clk,
            Tx => TX,
            Din => BusSalida(7 downto 0),
            Rx => RX,
            Dout => BusEntrada(7 downto 0),
            Trig => BusWR);
end Behavior;