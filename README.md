# CSC258-MIPS-MushroomTrouble
Final project for CSC258 using MIPS assembly language

Most features of this game are based on [Centipede](https://en.wikipedia.org/wiki/Centipede_(video_game)).

## How to run this game?
1.  Follow instructions at [this page](http://courses.missouristate.edu/kenvollmar/mars/download.htm) to download MARS (MIPS Assembler and Runtime Simulator).
2.  Open the source code file *shooting_game.asm* in MARS (File -> Open -> shooting_game.asm)
3.  Open the Bitmap Display in MARS (Tools -> Bitmap Display -> *set the configurations as following* -> Connect to MIPS) 

<img width="306" alt="set_bitmap_display" src="https://user-images.githubusercontent.com/85339193/131686337-e5036155-ccd0-4517-aa4d-d0d04b754657.png">


4.  Open the Keyboard and Display MMIO Simulator in MARS (Tools -> Keyboard and Display MMIO Simulator -> Connect to MIPS)
5.  Assemble and run the game in MARS

## How to play this game?
1.	To win, the shooter at the bottom needs to shoot off all the mushrooms before the centipede collides with the shooter (or reaches the end). 
2.	Control the shooter by typing the following keys in the Keyboard and Display MMIO Simulator: J – left, K – right, X – shoot.
3.	To adjust the difficulty, you can change the number of mushrooms by changing the data related to mushrooms, for example, you can change mushroomNum from 15 to 10 like the following. 

![change_mushroom_number](https://user-images.githubusercontent.com/85339193/131692619-734a669f-b4e9-4f05-8c30-e9a3bda06529.gif)

## Demo of the game
The number of the mushroom is set to 2 for this demo.
- case win

![demo_win](https://user-images.githubusercontent.com/85339193/131703160-0a941f7b-592a-40e1-9f6b-963723cdba80.gif)

- case lose (collides with the shooter)

![demo_lose_collide_with_shooter](https://user-images.githubusercontent.com/85339193/131699563-2d373442-7f8d-4f16-85b3-188a71adc290.gif)

- case lose (reaches the end)

![demo_lose_reach_the_end](https://user-images.githubusercontent.com/85339193/131699590-1c8e4cfe-088d-404b-adb5-5259a4266373.gif)






