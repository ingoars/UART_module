---------------------------------------------------------------
-- Paquete con las definiciones de los tamaños de la memoria --
---------------------------------------------------------------
package JPU16_MEM_SIZE_DEFS is
   constant nBits_DirProg: integer := 9;
   constant nBits_DirDatos: integer := 10;
end JPU16_MEM_SIZE_DEFS;

---------------------------------------
-- Entidad de la memoria de programa --
---------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.JPU16_MEM_SIZE_DEFS.all;

entity JPU16_PROG_MEM is
   generic (nBits_BusProg: integer := 26);
   Port (SysClk:    in  STD_LOGIC;
         SysHold:   in  STD_LOGIC;
         CicloInst: in  STD_LOGIC;
         Direccion: in  STD_LOGIC_VECTOR (nBits_DirProg - 1 downto 0);
         DatoProg:  out STD_LOGIC_VECTOR (nBits_BusProg - 1 downto 0) := (others => '0'));
end JPU16_PROG_MEM;

architecture Funcionamiento of JPU16_PROG_MEM is
   type PROG_DATA is array (2**nBits_DirProg-1 downto 0) of
      STD_LOGIC_VECTOR (nBits_BusProg-1 downto 0);

   constant MemoriaProg: PROG_DATA := (
      0 => B"111010_0000_0000000000110000",
      1 => B"001110_0000_0000000000000000",
      2 => B"010100_0000_0000000000000101",
      3 => B"100010_0000_0000000000000001",
      4 => B"001010_0000_0000000000111010",
      5 => B"010010_0000_1111111111111100",
      6 => B"010000_0000_1111111111111010",
      7 => B"111010_1111_0000000100000000",
      8 => B"111010_1110_0000000000000000",
      9 => B"101010_1110_0000000000000001",
      10 => B"010010_0010_1111111111111111",
      11 => B"101010_1111_0000000000000001",
      12 => B"010010_0010_1111111111111100",
      13 => B"011000_0000_0000000000000000",
      others => B"000000_0000_0000000000000000"
   );
begin
   process (SysClk)
   begin
      if rising_edge(SysClk) then
         if CicloInst = '0' and SysHold = '0' then
            DatoProg  <= MemoriaProg(conv_integer(Direccion));
         end if;
      end if;
   end process;
end Funcionamiento;

-------------------------------
-- Entidad de la memoria RAM --
-------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.JPU16_MEM_SIZE_DEFS.ALL;

entity JPU16_RAM is
   generic (nBits_BusDatos: integer := 16);
   port (SysClk:    in  STD_LOGIC;
         SysHold:   in  STD_LOGIC;
         Ren:       in  STD_LOGIC;
         Wen:       in  STD_LOGIC;
         Direccion: in  STD_LOGIC_VECTOR (nBits_DirDatos-1 downto 0);
         DatoEnt:   in  STD_LOGIC_VECTOR (nBits_BusDatos-1 downto 0);
         DatoSal:   out STD_LOGIC_VECTOR (nBits_BusDatos-1 downto 0) := (others => '0'));
end JPU16_RAM;

architecture Funcionamiento of JPU16_RAM is
   type RAM_DATA is array (2**nBits_DirDatos-1 downto 0) of
      STD_LOGIC_VECTOR (nBits_BusDatos-1 downto 0);

   signal MemoriaRam: RAM_DATA := (
      others => X"0000"
   );
begin
   process (SysClk)
   begin
      if rising_edge(SysClk) then
         if SysHold = '0' and (Ren = '1' or Wen = '1') then
            if Wen = '1' then
               MemoriaRam(conv_integer(Direccion)) <= DatoEnt;
            end if;
            DatoSal <= MemoriaRam(conv_integer(Direccion));
         end if;
      end if;
   end process;
end Funcionamiento;