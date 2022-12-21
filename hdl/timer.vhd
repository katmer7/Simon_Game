-- Módulo de Timer.
-- Realiza la cuenta de 1ms para el teclado de 50% de ciclo de trabajo con una frecuencia de 1000Hz
-- tic 0,2 segundos para la interfaz de salida de 50% de ciclo de trabajo con una frecuencia de 5Hz
-- tic 0,8 segundos para la interfaz de salida de 50% de ciclo de trabajo con una frecuencia de 1,25Hz
-- tic 1 segundo para la interfaz de salida de 50% de ciclo de trabajo con una frecuencia de 1Hz
-- El temporizador cuenta con una señal de reset síncrono prioritaria a la cuenta.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity timer is
  port( 
    clk: in std_logic;
    nRst: in std_logic;
    rst_time: in std_logic;
    tic_1ms: buffer std_logic;           -- para los rebotes y displays
    tic_1s : buffer std_logic;           -- para los display de la puntuacion al temrinar la partida
    tiempo_secuencia: buffer std_logic);
  end entity;
   
   
  architecture rtl of timer is
    signal cnt_tic_1ms: std_logic_vector(15 downto 0);
    signal cnt_tic_1s: std_logic_vector(9 downto 0);
    
    constant cincuenta_mil: natural := 50000;
    constant mil: natural := 1000; 
    
-- Divisor de frecuencia de 250000 cuentas, genera tic 5ms
  begin
    process(clk, nRst)
      begin
        if nRst = '0' then
          cnt_tic_1ms <= (0 => '1', others => '0');
        elsif clk'event and clk = '1' then
          
          if tic_1ms = '1' or rst_time = '1' then
            cnt_tic_1ms <= (0 => '1', others => '0');
          else
            cnt_tic_1ms <= cnt_tic_1ms + 1;
          end if;         
        end if;
   end process;
       
      
  tic_1ms <= '1' when cnt_tic_1ms = cincuenta_mil
                else '0';
                  
 -- Divisor de frecuencia de 1000 cuentas, genera tic 1s   
   process(clk, nRst)
    begin
      if nRst = '0' then
         cnt_tic_1s <= (0 => '1', others => '0');
       elsif clk'event and clk = '1' then
          
          if tic_1s = '1' or rst_time = '1' then
           cnt_tic_1s <= (0 => '1', others => '0');
          elsif tic_1ms = '1' then
           cnt_tic_1s <= cnt_tic_1s + 1;
         end if;         
      end if;
  end process;              
                  
                  
  tic_1s <= '1' when cnt_tic_1s = mil and tic_1ms = '1'
                else '0';     
   
  tiempo_secuencia <= '0' when cnt_tic_1s  <= 200
                          else '1';
     
    
                  
 end rtl;
