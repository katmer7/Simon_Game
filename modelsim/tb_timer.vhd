-- Tb para el modelo de Timer

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_timer is
  end entity;  

 architecture tb of tb_timer is
   signal clk:  std_logic;
   signal nRst:  std_logic;
   signal rst_time: std_logic;
   signal tic_1ms: std_logic;
   signal tic_1s : std_logic;
   constant T_CLK: time := 20 ns;
 
 begin
   dut: entity Work.timer(rtl)
   port map( clk => clk,
             nRst => nRst,
             rst_time => rst_time,
             tic_1ms => tic_1ms,
             tic_1s => tic_1s
   );



reloj : process
  begin
     clk <= '0';
     wait for T_CLK/2;
     clk <= '1';
     wait for T_CLK/2;
end process ; 
 

process
  begin
  -- Funcionamiento asíncrono  
  nRst <= '0';  
  rst_time <= '0';   
  
  wait until clk'event and clk ='1';   
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';  
  
  -- Funcionamiento síncrono
  nRst <= '1';  
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  
  wait for T_CLK*5;                     -- Esperamos 1 ms
  
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  
  wait for T_CLK*5*10;                -- Esperamos 1s
  
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  
  wait for T_CLK*5*10;              -- Esperamos 2s
  
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';
  wait until clk'event and clk ='1';    
  
   assert false
   report "done"
   severity failure;
   
 end process;
 
 end tb;
