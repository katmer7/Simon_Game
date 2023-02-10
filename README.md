# Simon_Game

<p align="center">
  <img src="https://user-images.githubusercontent.com/120545621/217704987-fb3788ff-bb1b-4be5-8653-9f0e5b4d089d.png" width="500" height="250"/>
</p>

Short-term memory skill Simon game, is an electronic game of lights in which players must remember random sequences of lights 
and repeat them in the correct order by pressing the corresponding colored pad. The original game is based on colors green, red, blue and yellow.

## Project Description

This project replicates the functionality of Simon game with extra features in Cyclone II FPGA with the addition of a keyboard interface. Due to resource constraints, three colors are considered which are represented with green, red and yellow LEDs.

When the FPGA board is programmed, the initial state is a configuration menu. This menu is accessed with different keys while the corresponding information is displayed in a 4 digit 7-segment display. The menu is the following:

|Configuration Mode <br> (Game has not been started) | Game Over <br> (The player won or lost the game)| 
|    :---     |     :---      |    
| D -> Programmable Sequence Length (Up to 20) | F -> Start Game with Last Configuration | 
| F -> See Record (Highest Score) | E -> Go Back to Configuration Mode |
| E -> Go Back to Configuration Mode If The Player Is In Any Of The Previous Options |
| A -> Start Game |

Once the player starts the game (after pressing A), the first color is shown in one of the three LEDs. The player introduces the color and if this is correct, a new color is randomly generated, showing the previous one with the new added color to the player. Thereby, a sequence of colors is generated as long as the player is guessing  all of them. If the player reaches the maximum value of the sequence or introduces a incorrect color the game is over. 

Design Constraints

- Each color is represented with a numerical value. 1 for Red, 2 for Yellow and 3 for Green.
- Each color is shown during 1 second.
- After introducing the whole sequence, the system is waiting for a "validation" of a new color. Therefore, if the sequence is correct and the game is not over, any key must be pressed so that a new random color can be generated.
- The sequence is stored in a memory RAM.




