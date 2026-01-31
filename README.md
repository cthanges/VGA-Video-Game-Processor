# VGA Video Game Processor
## Summary
The objective of this project is to create a simple video game processor (SVGP) and display it on a VGA monitor. This SVGP consists of Pong, which is achieved by using VHDL within the Xilinx ISE CAD environment to provide instructions for the game's controls, display, and movement. Specifically, the players are controlled by using the LED switches on the Xilinx Spartan-3E FPGA board, the display shown on the VGA monitor is set by taking the horizontal and vertical synchronization signals into consideration, and the ball’s behaviour is determined by how the player or border hits the ball. 

## System Specifications
The SVGP should provide:
- Static video frame
    - The game field must be in green while having white borders, as shown in Figure 1

<p align="center">
  <img src="Images/Static SVGP Video Frame.png" width="350">
</p>
<p align="center">
Figure 1: Static SVGP video frame with dynamic elements - ‘ball’ and ‘player’.
</p>

- Dynamic elements
    - A yellow ball that can ‘fly’ across the field between the borders, reflecting from the borders and the players
    - Players in blue and pink that can move up and down, which is controlled by the switches on the board accordingly

- Behaviour
    - When the ball hits the border or the player, the ball’s trajectory changes as of ±90° based on the direction of the hit
        - Ex. the ball moves from down to up when hitting the bottom border
    - When the ball reaches either goal, its colour changes to red and disappears while passing the video-frame
        - The ball reappears as yellow once again in the center of the field

## Device Description/Design
### Symbol Diagram
<p align="center">
  <img src="Images/Symbol Diagram.png" width="450">
</p>
<p align="center">
Figure 2: Symbol Diagram.
</p>

This symbol diagram consists of inputs and outputs based on the VGA Interface. Specifically, the inputs consist of the input clock signal and the onboard switches, whereas the outputs are dedicated to the pixel clock for the video DAC, the synchronization signals ‘H’ and ‘V,’ and the red, green, and blue channels.

### VGA Specifications
All horizontal (line) time periods are specified in multiples of the VGA pixel clock, which is 25 MHz for a 60 Hz refresh rate. All vertical (frame) time periods are specified in multiples of VGA lines.

<div align="center">

| **Parameter**       | **Clock Cycles**   |
|:-------------------:|:------------------:|
| Complete Line       | 800                |
| Front Porch         | 16                 |
| Synch Pulse         | 96                 |
| Back Porch          | 48                 |
| Active Image Area   | 640                |

</div>
<p align="center">
Figure 3: Table for VGA Horizontal Parameters.
</p>

<div align="center">

| **Parameter**       | **Clock Cycles**   |
|:-------------------:|:------------------:|
| Complete Line       | 525                |
| Front Porch         | 10                 |
| Synch Pulse         | 2                  |
| Back Porch          | 33                 |
| Active Image Area   | 480                |

</div>
<p align="center">
Figure 4: Table for VGA Vertical Parameters.
</p>

### Block Diagrams
<p align="center">
  <img src="Images/Process Block Diagram.png" width="450">
</p>
<p align="center">
Figure 5: Block Diagram for the Process.
</p>

This block diagram shows the pathway taken to represent how the board's cycle is updated. This loop occurs until the game is over, at which point the game stops processing further updates.

<p align="center">
  <img src="Images/Player Switches Block Diagram.png" width="450">
</p>
<p align="center">
Figure 6: Block Diagram for Switches to Player Movement.
</p>

This block diagram represents the process for determining whether the player moves. Essentially, the player moves in the direction controlled by the switch until it reaches the barrier, at which point it cannot move further.

<p align="center">
  <img src="Images/Ball Position Block Diagram.png" width="450">
</p>
<p align="center">
Figure 7: Block Diagram for Ball movement/position changes.
</p>

This block diagram represents the pathway taken for changes in the game for certain scenarios. The clock motions the ball, and some output occurs depending on the end result. The loop occurs since the ball is always in motion.