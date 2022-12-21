-- Control de la entrada
-- Devuelve la tecla pulsada con su validación
-- Devuelve la el color de la columna pulsada junto con su duración

library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;

entity ctrl_tec is 
port(
    clk           : in std_logic;
    nRst          : in std_logic;
    columna       : in std_logic_vector(3 downto 0);
    tic_1ms       : in std_logic;
    
    fila          : buffer std_logic_vector(3 downto 0);    
    tecla_valida_reg  : buffer std_logic;                 -- Validación de la tecla pulsada (a la vez que tecla)
    tecla         : buffer std_logic_vector(3 downto 0);  -- Valor de la tecla pulsada 
    duracion_pulso: buffer std_logic;                     -- duración de la columna pulsada (a la vez que columna_color)
    flanco_bajada_col: buffer std_logic;
    columna_color : buffer std_logic_vector(1 downto 0)); -- Valor de color correspondiente a la columna pulsada 
end entity;

architecture rtl of ctrl_tec is
  signal colr_1: std_logic_vector(3 downto 0); -- sinc
  signal colr_2: std_logic_vector(3 downto 0); -- sinc
  signal col : std_logic_vector(3 downto 0);   -- sinc
  signal col_no_det : std_logic;               
  signal tecla_p : std_logic;                  -- detecta si se ha pulsado una tecla
  signal reg_tecla : std_logic;      
  signal tecla_valida :  std_logic;
  signal tecla_dec : std_logic_vector(3 downto 0);
  signal duracion_pulso_reg: std_logic;

begin
  
  -- Sincronización y antirrebotes
  sincro: process(clk, nRst)
  begin
    if nRst = '0' then
      colr_1 <= (others => '1');
      colr_2 <= (others => '1');
      col  <= (others => '1');
    elsif clk'event and clk = '1' then
      colr_1 <= columna;
      colr_2 <= colr_1;
      if tic_1ms = '1' then 
        col <= colr_2;
      end if;
    end if;
  end process sincro;
  
   
  -- contador de fila
  cont_fila: process(clk, nRst)
  begin
    if nRst = '0' then
      fila <= "1110";
    elsif clk'event and clk = '1' then
      if tic_1ms = '1' and col_no_det = '1' then 
        fila <= fila(2 downto 0) & fila(3);
      end if;
    end if;
  end process cont_fila; 
  
  -- tecla no pulsada (deteccion directa a partir de las columnas registradas)
  col_no_det <= '1' when colr_2 = "1111" else '0';  
  
  -- Saco la columna pulsada
  columna_color <=    "11" when col = "1110" -- verde
                      else "10" when col = "1011" or col = "1101" -- amarillo
                      else "01" when col = "0111"  -- rojo
                      else "00";
                        
  -- decodificación de la tecla
  decod_tecla: process(fila, col)
  begin
    case(col) is
      when "1110" =>
        case(fila) is
          when "1110" => tecla_dec <= X"1";
          when "1101" => tecla_dec <= X"4";
          when "1011" => tecla_dec <= X"7";
          when others => tecla_dec <= X"A";
        end case;
      when "1101" =>
        case(fila) is
          when "1110" => tecla_dec <= X"2";
          when "1101" => tecla_dec <= X"5";
          when "1011" => tecla_dec <= X"8";
          when others => tecla_dec <= X"0";
        end case; 
      when "1011" =>
        case(fila) is
          when "1110" => tecla_dec <= X"3";
          when "1101" => tecla_dec <= X"6";
          when "1011" => tecla_dec <= X"9";
          when others => tecla_dec <= X"B";
        end case; 
      when others =>
        case(fila) is
          when "1110" => tecla_dec <= X"F";
          when "1101" => tecla_dec <= X"E";
          when "1011" => tecla_dec <= X"D";
          when others => tecla_dec <= X"C";
        end case;  
    end case;
  end process decod_tecla;

-- Registro de tecla
process(clk, nRst)
  begin
    if nRst = '0' then
      tecla <= (others =>'0');
    elsif clk'event and clk = '1' then
      if col_no_det = '0' then
        tecla <= tecla_dec;
      end if;
    end if;
  end process;

-- detección de tecla pulsada (deteccion retrasada a partir de la columna muestreada) 
  tecla_p <= '0' when col = "1111" else '1';
    
-- Registro columna muestreada  
  process(clk, nRst)
  begin
    if nRst = '0' then
      reg_tecla <= '0';
    elsif clk'event and clk = '1' then
      reg_tecla <= tecla_p;
    end if;
  end process;
 
  -- Tecla válida y registro de la tecla válida para que se active al mismo tiempo
  -- que la tecla registrada
 tecla_valida <= not reg_tecla and tecla_p; 
 
  process(clk, nRst)
  begin
    if nRst = '0' then
      tecla_valida_reg <= '0';
    elsif clk'event and clk = '1' then
      tecla_valida_reg <= tecla_valida;
    end if;
  end process;
   
-- Detección de la duracion: 

-- depende de la detección de una columna pulsada (señal activa a la vez que colr2)
duracion_pulso <=  tecla_p;
 
-- detección de flancos de bajada de la DURACION de la columna pulsada
  process(clk, nRst)
  begin
    if nRst = '0' then
      duracion_pulso_reg <= '0';
    elsif clk'event and clk = '1' then
      duracion_pulso_reg <= duracion_pulso;
    end if;
  end process;
  flanco_bajada_col <= not duracion_pulso and duracion_pulso_reg;  -- tic flanco de bajada

end rtl;
