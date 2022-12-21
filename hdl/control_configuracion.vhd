-- Control para el modo de configuración del juego
-- Cuando el sistema realiza el reset asíncrono se encuentra en el modo de inicio de la configuración
-- dependiendo de la tecla pulsada, se puede ir modificar la longitud o mostrar el record,
-- Cuando se salga del modo de configuración de inicia la partida, cuando esta finaliza
-- se puede volver al primer estado de inicio de configuración o se puede iniciar una nueva partida.
-- Desde configuración:
-- Tecla D: longitud
-- Tecla A: juego
-- Tecla F: record
-- Tecla E: ConF 
-- Desde fin partida:
-- Tecla F: juego
-- Tecla E: ConF

 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_configuracion is
  port(clk: in  std_logic;
       nRst: in std_logic;
       fin_partida: in std_logic;                          -- Indica si es fin de partida      
       tecla: in std_logic_vector(3 downto 0);
       tecla_valida_reg: in std_logic;
       reset: in std_logic;                                -- Reset de MODO JUEGO para resetear memoria y longitud
       puntuacion_almacenada: in std_logic_vector(13 downto 0);       -- BINARIO
       flanco_bajada_col: in std_logic;
       
       
       puntuacion_out: buffer std_logic_vector(13 downto 0);        -- BIN
       recor: buffer std_logic_vector(13 downto 0);                 -- BIN
       start: buffer std_logic;                            -- Indica que se puede iniciar una partida
       modo: buffer std_logic;                             -- Indica que se está en el modo ConF 
       lon: buffer std_logic;                              -- Indica que se puede representar por los displays la longitud
       longitud_programada_bin: buffer std_logic_vector(13 downto 0);  -- BIN
       rec: buffer std_logic;                               -- Indica que se puede representar por los displays el record.
       parpadeo_fin: buffer std_logic                       -- Indica que se puede mostrar la puntuacion FINAL
       );
end entity;

architecture rtl of control_configuracion is
  -- Indica si es la primera partida a nivel alto
  signal primera_partida: std_logic;                       
  -- Señales para el conversor BCD to BIN
  signal aux1_bin: std_logic_vector(6 downto 0);
  signal aux2_bin: std_logic_vector(9 downto 0);
  signal longitud_programada: std_logic_vector(15 downto 0);
  -- Automata
  type t_estado is (InicioConF, LongitudConF, rEConF, Partida, finPartida);
  signal estado: t_estado;
  
  
  begin
  -- Procesador de configuración de la partida
  process(clk,nRst)
    begin
      if nRst = '0' then
        estado <= InicioConF;
        primera_partida <= '1';
        start <= '0'; 
      elsif clk'event and clk = '1' then      
        case estado is
          when InicioConF =>
           
            if tecla = "1101" and tecla_valida_reg = '1' then                                -- D
               estado <= LongitudConF;            
            elsif tecla = "1111" and tecla_valida_reg = '1' and primera_partida = '0' then   -- F
                  estado <= rEConF;    
            elsif tecla = "1010"  and flanco_bajada_col = '1' then                           -- A
                  primera_partida <= '0';
                  estado <= Partida;
            end if;
                       
          when LongitudConF =>
           
            if tecla = "1110" and tecla_valida_reg = '1' and longitud_programada /= 0 then   -- E
               estado <= InicioConF;  
            end if;
            
          when rEConF =>
            
            if tecla = "1110" and tecla_valida_reg = '1' then -- E
               estado <= InicioConF;  
            end if;
            
          when Partida =>

            if fin_partida = '1' then 
               start <= '0'; 
               estado <= finPartida;  
            else
               start <= '1';
            end if;  
            
          when finPartida =>
            
            if tecla = "1110" and tecla_valida_reg = '1' then    -- E
               estado <= InicioConF;  
            elsif tecla = "1111" and tecla_valida_reg = '1' then -- F                      
               estado <= Partida;
           end if;
          end case;
        end if;
    end process; 
        
  -- Flags para configuración.
  modo <= '1' when estado = InicioConF
              else '0';
  Lon <= '1' when estado = LongitudConF
              else '0';
  rec <= '1' when estado = rEConF
              else '0'; 
  parpadeo_fin <= '1' when estado = finPartida else
                  '0';               
                
    -- Registro de desplazamiento para el valor de la longitud    
  process(clk, nRst)
  begin
    if nRst = '0' then
      longitud_programada <= "0000000000100000";      -- Binario 32 // 0020
    elsif clk'event and clk = '1' then                     
      
      if reset = '1' then
         longitud_programada <= "0000000000100000";
      elsif Lon = '1' then        
          if tecla = "1011" and tecla_valida_reg = '1' then 
             longitud_programada <= "0000"&longitud_programada(15 downto 4);
          elsif  tecla < 10 and tecla_valida_reg = '1' and longitud_programada(15 downto 12) = "0000" then
             longitud_programada <= longitud_programada(11 downto 0)&tecla;
          end if;
       end if;
     end if;
   end process;  
           
 
  -- Señal para el la puntuación y el record:               
  process(clk, nRst)  
	begin
	  if nRst = '0' then 
	     puntuacion_out <= (others => '0'); 
	     recor <= (others => '0');	     
	  elsif clk'event and clk = '1' then	
      
       if (tecla = "1110" and tecla_valida_reg = '1') and  (tecla = "1111" and tecla_valida_reg = '1') then
           puntuacion_out <= (others => '0');
	     elsif estado = finPartida  then
	           puntuacion_out <= puntuacion_almacenada;
	        if puntuacion_out > recor then
	           recor <= puntuacion_out;
	        end if;	       
	     end if; 
	   end if;
 end process;
 
-- Conversion BCD a BIN de la longitud programada
-- 10*(millares) + centenas
aux1_bin <= (longitud_programada(15 downto 12)& "000") + (longitud_programada(15 downto 12)& '0') + longitud_programada(11 downto 8);
-- 10*[ 10*millares + centenas ] + decenas
aux2_bin <= (aux1_bin & "000") + (aux1_bin & '0') + longitud_programada (7 downto 4);
-- 10*( 10*[ 10*millares + centenas ] + decenas ) + unidades
longitud_programada_bin <= '0'&(aux2_bin & "000") + (aux2_bin & '0') + longitud_programada (3 downto 0);
   
end rtl;
