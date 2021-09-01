#####################################################################
#
# CSC258H Winter 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Yiyi Zhang, Student Number: 1006298962
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#####################################################################

.data
	displayAddress:		.word	0x10008000
	
	mushroomLocation:	.space	8 	# mushroomNum * 4
	mushroomLive:		.word	3:2
	mushroomNum:		.word	2
	
	shooterLocation:	.word	1008
	
	dartLocation:		.space	124
	dartNum:		.word	0
	
	centipedeLocation:	.word	9, 8, 7, 6, 5, 4, 3, 2, 1, 0
	centipedeDirection:	.word	1	# heading direction; 1 as right, 0 as left
	centipedeNum:		.word	10
	
	winLocation:		.word	423, 424, 425, 426, 427, 436, 405, 374, 343, 469, 502, 535, 620, 653, 686, 687, 688, 657, 626
	loseLocation:		.word	327, 328, 329, 330, 331, 361, 393, 425, 457, 489, 521, 340, 341, 342, 343, 344, 374, 406, 438
					470, 502, 534, 653, 654, 655, 656, 657, 658
	
	
.text 
main:
	jal init_mushroom_locations
Loop:
	jal disp_mushroom
	jal disp_centipede
	jal disp_shooter
	jal disp_dart
	jal delay
	
	jal check_keystroke 
	jal set_dart_next
	jal set_centipede_next
	jal check_dart_collision

	j Loop	

Exit:
	li $v0, 10		# terminate the program gracefully
	syscall






# function generates <mushroomNum> random locations and saves them to <mushroomLocation>
init_mushroom_locations:
	la $t8, mushroomLocation	# load the address of the array mushroomLocation into $t8
	la $t9, mushroomNum		# load the address of mushroomNum to $t9
	
	lw $t0, 0($t9)	# load mushroomNum to $t0, we use $t0 as is loop variable
	
loop_random_locations:
	# generate a random number in the range 0 - 959 into a0
	li $v0, 42 
	li $a0, 0 
	li $a1, 959
	syscall
	
	addi $a0, $a0, 32	# $a0 stores a random number in the range 32 - 991, so that the mushroom would not appear in first row or the last row
	sw $a0, 0($t8)	# save the $a0 to mushroomLocation
	
	addi $t8, $t8, 4	# update $t8 to next index address of mushroomLocation
	addi $t0, $t0, -1 	# update loop variable
	
	bne $t0, $zero, loop_random_locations	# check loop condition
	
end_loop_random_locations:	
	jr $ra
	
	
	
	
	
	
# function to display mushrooms (mushrooms in different live states have different colours)
disp_mushroom:
	la $t0, mushroomLocation	# load the address of mushroomLocation into $t0
	la $t1, mushroomLive		# load the address of mushroomLive into $t1
	la $t2, mushroomNum		# load the address of mushroomNum into $t2
	lw $t2, 0($t2)			# load mushroomNum to $t2, and $t2 would be the loop variable
	
	beq $t2, $zero, end_game_win	# if the mushroomNum is 0, end the game
	
	li $t3, 0xfffc42	# $t3 stores the colour for mushroom live state 3 (when there are three lives left)
	li $t4, 0xf74fdb	# $t4 stores the colour for mushroom live state 2
	li $t5, 0x7842ff	# $t5 stores the colour for mushroom live state 1
	
	lw $t6, displayAddress	# $ load the base address for display to $t6

loop_draw_mushroom:
	lw $t7, 0($t0)	# load the loaction-inidacting number of current mushroom to $t7
	# calculate the mushroom display address and save to $t7
	sll $t7, $t7, 2	# $7 * 4
	add $t7, $t6, $t7
	
	lw $t8, 0($t1)	# load current mushroom live state to $t8
	# draw (set colour) according to live state of the mushroom
	beq $t8, 3, draw_mushroom_live_state_3
	beq $t8, 2, draw_mushroom_live_state_2
	beq $t8, 1, draw_mushroom_live_state_1

draw_mushroom_live_state_3: 	
	sw $t3, 0($t7)
	j update_draw_mushroom_loop
	
draw_mushroom_live_state_2: 	
	sw $t4, 0($t7)
	j update_draw_mushroom_loop
	
draw_mushroom_live_state_1: 	
	sw $t5, 0($t7)
	j update_draw_mushroom_loop
	
update_draw_mushroom_loop:
	addi $t0, $t0, 4	# update $t0 to next index address of mushroomLocation
	addi $t1, $t1, 4	# update $t1 to next index address of mushroomLive
	addi $t2, $t2, -1 	# update loop variable
	
	bne $t2, $zero, loop_draw_mushroom # check loop condition
	
end_loop_draw_mushroom:
	jr $ra
	
	
	
	

	
# function to display a shooter
disp_shooter:
	la $t0, shooterLocation	# load the address of buglocation from memory
	lw $t1, 0($t0) 	# load the location-indicating value of the shooter to $t1
	lw $t2, displayAddress  # $t2 stores the base address for display
	# calculate the address for shooter and save to $t3
	sll $t1, $t1, 2
	add $t3, $t1, $t2
	
	li $t4, 0xffffff	
	sw $t4, 0($t3)
	
	jr $ra
	
	
	
	
	
	
# function to display a centipede	
disp_centipede:
	la $t0, centipedeLocation	# load the address of centipedeLocation to $t0
	la $t2, centipedeNum		# load the address of centipedeNum to $t2
	lw $t2, 0($t2)	# load centipedeNum to $t2, this would be the loop variable
	lw $t3, displayAddress	# $t3 stores the base address for display
	li $t4, 0x9bb4c2	
	j loop_draw_centipede
	
loop_draw_centipede:
	lw $t5, 0($t0)	# load the loaction-inidacting number of the centipede to $t5
	# calculate and save the centipede display address to $t5
	sll $t5, $t5, 2	
	add $t5, $t3, $t5
	
	sw $t4, 0($t5)	# draw with colour in $t4
	
update_draw_centipede_loop:	
	addi $t0, $t0, 4	# update $t0 to next index address of centipedeLocation
	addi $t2, $t2, -1 	# update the loop varaible
	
	bne $t2, $zero, loop_draw_centipede # check loop condition
	
end_loop_draw_centipede:
	jr $ra






# function to display dart
disp_dart:
	la $t0, dartLocation	# load the address of dartLocation into $t0
	la $t1, dartNum		# load the address of dartNum into $t1
	lw $t1, 0($t1)	# load dartNum to $t1, this would be the loop num
	lw $t2, displayAddress  # $t2 stores the base address for display
	
	beq $t1, 0, end_draw_dart	# if dartNum is 0, skip drawing darts
	
	li $t3, 0xfc796f	# $t3 stores the colour for dart

loop_draw_dart:
	lw $t4, 0($t0)	# load the loaction-inidacting number of the dart to $t4
	# calculate and save the dart display address to $t4
	sll $t4, $t4, 2	
	add $t4, $t2, $t4
	
	sw $t3, 0($t4)	# draw the dart with colour in $t3
	
update_draw_dart_loop:	
	addi $t0, $t0, 4	# update $t0 to next index address of dartLocation
	addi $t1, $t1, -1 	# update the loop variable
	
	bne $t1, $zero, loop_draw_dart # check loop condition
	
end_draw_dart:
	jr $ra
	





# function to detect any keystroke and respond
check_keystroke:
	lw $t8, 0xffff0000
	beq $t8, 1, get_keyboard_input	# if a key is pressed
	addi $t8, $zero, 0
	
	jr $ra
	
# function to get the input key
get_keyboard_input:
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x6A, respond_to_j
	beq $t2, 0x6B, respond_to_k
	beq $t2, 0x78, respond_to_x
	
	jr $ra
	
# Call back function of j key
respond_to_j:
	la $t0, shooterLocation	# load the address of shooterLocation from memory
	lw $t1, 0($t0)		# load shooterLocation to $t1
	
	beq $t1, 992, end_respond_to_j # prevent the shooter from getting out of the canvas
	
restore_background_at_old_shooter_location:
	lw $t2, displayAddress  # $t2 stores the base address for display
	# calculate the shooter display location and save to $t3
	sll $t3,$t1, 2		
	add $t3, $t3, $t2
	
	li $t4, 0x000000	# $t4 stores the background colour
	sw $t4, 0($t3)		# restore the background colour	

update_shooter_location_j:
	addi $t1, $t1, -1	# move the shooter one location to the left
	sw $t1, 0($t0)		# save the changed location value to memory
	
end_respond_to_j:
	jr $ra

# Call back function of k key
respond_to_k:
	la $t0, shooterLocation	# load the address of shooterLocation from memory
	lw $t1, 0($t0)		# load shooterLocation to $t1
	
	beq $t1, 1023, end_respond_to_j # prevent the shooter from getting out of the canvas
	
restore_background_at_old_shooter_location_k:
	lw $t2, displayAddress  # $t2 stores the base address for display
	# calculate the shooter display location and save to $t3
	sll $t3,$t1, 2		
	add $t3, $t3, $t2
	
	li $t4, 0x000000	# $t4 stores the background colour
	sw $t4, 0($t3)		# restore the background colour	

update_shooter_location_k:
	addi $t1, $t1, +1	# move the shooter one location to the right
	sw $t1, 0($t0)		# save the changed location value to memory
	
end_respond_to_k:
	jr $ra

# Call back function of x key
respond_to_x:
	# add the shooterLocation value to end of dartLocation array
	# get shooterLocation value
	la $t0, shooterLocation 
	lw $t0, 0($t0)
	# calculate the memory address for new entry of the dartLocation array
	la $t1, dartLocation
	la $t2, dartNum 
	lw $t3, 0($t2)
	sll $t4, $t3, 2
	add $t5, $t1, $t4
	# save the value to memory
	sw $t0, 0($t5)
	
	# increase dartNum by 1
	addi $t3, $t3, 1 
	sw $t3, 0($t2)
	
	jr $ra
	
	
	
	
	
	
# function that erase the old darts, and set new dart locations
set_dart_next:
	la $t0, dartLocation	# load the address of dartLocation into $t0
	la $t1, dartNum		# load the address of dartNum into $t1
	lw $t1, 0($t1) 		# load dartNum to $t1, this would be the loop variable
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the background colour

	beq $t1, 0, end_loop_update_dart_locations	# if dartNum is 0
	
loop_erase_dart:
	lw $t4, 0($t0)	# load the loaction-inidacting number of the dart to $t4
	
	# save the dart display address to $t4
	sll $t4, $t4, 2	
	add $t4, $t2, $t4
	
	sw $t3, 0($t4)	# erase
	
	addi $t0, $t0, 4	# update $t0 to next index address of dartLocation
	addi $t1, $t1, -1 	# update loop variable
	
	bne $t1, $zero, loop_erase_dart	# check loop condition
	
end_loop_erase_dart:
	la $t0, dartLocation	# reload the address of dartLocation to $t0
	la $t1, dartNum		# reload the address of dartNum to $t1
	lw $t2, 0($t1)		# reload dartNum to $t2, this would be the loop variable

loop_update_dart_locations:
	lw $t3, 0($t0)	# load the loaction-inidacting number of the dart to $t3
	
	addi $t3, $t3, -32 # new location is one row up
	
	# check if the new dart location is out of range (i.e. less than 0)
	slt $t4, $t3, $zero
	beq $t4, 0, if_dart_in_range
	
if_dart_out_of_range:
	
	# move the last value in dartLocation to the current position
	lw $t5, 0($t1) # load dartNum to $t5
	la $t6, dartLocation # load address of dartLocation to $t6
	addi $t7, $t5, -1
	sll $t7, $t7, 2
	add $t7, $t7, $t6 # save to $t7 the address that stores the last value of dartLocation
	lw $t8, 0($t7) # load the last value of dartLocation to $t8
	sw $t8, 0($t0) # save the original last value to the current position
	
	# update dartNum
	addi $t5, $t5, -1
	sw $t5, 0($t1)
	
	addi $t2, $t2, -1 	# update loop variable
	bne $t2, $zero, loop_update_dart_locations # check loop condition
	
	j end_loop_update_dart_locations
	
if_dart_in_range:
	sw $t3, 0($t0)	# set new dart location
	
	addi $t0, $t0, 4	# update $t0 to next index address of dartLocation
	addi $t2, $t2, -1 	# update loop variable
	bne $t2, $zero, loop_update_dart_locations # check loop condition
	
end_loop_update_dart_locations:
	jr $ra
	





# function that erases the tail bit of the centipede (we don't erase all bits since we want the centipede moves smoothly), 
# and set new centipede locations
set_centipede_next:
	la $t0, centipedeLocation	# load the address of centipedeLocation to $t0
	la $t1, centipedeDirection	# load the address of centipedeDirection to $t1
	la $t2, centipedeNum		# load the address of centipedeNum to $t2
	lw $t4, 0($t2) 			# load centipedeNum to $t4
	li $t5, 0x000000		# $t5 stores the background colour
	lw $t6, displayAddress  	# $t6 stores the base address for display
	
erase_the_tail_bit:
	# save the centipede tail bit display address to $t8
	addi $t7, $t4, -1
	sll $t7, $t7, 2	
	add $t7, $t0, $t7
	lw $t8, 0($t7)
	sll $t8, $t8, 2
	add $t8, $t8, $t6
	
	sw $t5, 0($t8)	#erase
	
end_erase_the_tail_bit:
	addi $t7, $t4, -1	# $t7 is loop variable
	
loop_shift_position_values:
	# copy value from previous entry
	# get memory address of current entry
	sll $t8, $t7, 2
	add $t8, $t8, $t0
	# get value of previous entry
	addi $t9, $t8, -4
	lw $t3, 0($t9)
	# save the value to current entry
	sw $t3, 0($t8)
	
	addi $t7, $t7, -1 				# update loop variable
	bne $t7, $zero, loop_shift_position_values	# check loop condition
	
set_next_head_location:
	lw $t7, 0($t1)	# load direction to $t7
	beq $t7, 1, case_right
	
case_left:

check_end_of_the_game_case_wall:
	lw $t7, 0($t0)	# store head location to $t7	
	addi $t8, $zero, 992
	bne $t7, $t8, check_end_of_the_game_case_shooter
	j end_game_lose

check_end_of_the_game_case_shooter:
	lw $t7, 0($t0)		# store head location to $t7
	addi $t7, $t7, -1	# if the shooter is at this location, the cetipede will collide, and it will be the end of the game
	la $t8, shooterLocation
	lw $t8, 0($t8)
	bne $t7, $t8, check_wall_collision_left
	j end_game_lose
	
check_wall_collision_left:
	# check if current value of head location is a muptiple of 32
	lw $t7, 0($t0)	# store head location to $t7	
	addi $t8, $zero, 32
	div $t7, $t8
	mfhi $t9	# get remainder of $t7/32 to $t9
	beq $t9, 0, set_head_case_collide_left

end_check_wall_collision_left:
	lw $t7, 0($t0)		# store head location to $t7
	addi $t7, $t7, -1	# if a mushroom is at this location, the cetipede will collide
	la $t8, mushroomLocation
	la $t9, mushroomNum
	lw $t9, 0($t9)		# load mushroomNum to $t9, this will be the loop variable
	
	beq $t9, $zero, set_head_default_left	#if mushroomNum is 0, skip checking mushroom collision

loop_check_mushroom_collision_left:
	lw $t3, 0($t8)	# load mushroom location
	beq $t3, $t7, set_head_case_collide_left
	
	addi $t9, $t9, -1
	addi $t8, $t8, 4
	bne $t9, $zero, loop_check_mushroom_collision_left
	
set_head_default_left:
	lw $t7, 0($t0)	# store head location to $t7
	addi $t7, $t7, -1
	sw $t7, 0($t0) 
	j end_set_next_head_location
	
set_head_case_collide_left:
	# set centipede direction to 1 (right)
	addi $t7, $zero, 1
	sw $t7, 0($t1)
	
	# set centipede head location
	lw $t8, 0($t0)	# store head location to $t8
	addi $t8, $t8, 32
	sw $t8, 0($t0)

	j end_set_next_head_location
	
case_right:
	
check_wall_collision_right:
	# check if current (value of head location + 1) is a muptiple of 32
	lw $t7, 0($t0)	# store head location to $t7	
	addi $t7, $t7, 1
	addi $t8, $zero, 32
	div $t7, $t8
	mfhi $t9	# get remainder of $t7/32 to $t9
	beq $t9, 0, set_head_case_collide_right

end_check_wall_collision_right:
	lw $t7, 0($t0)		# store head location to $t7
	addi $t7, $t7, 1	# if a mushroom is at this location, the cetipede will collide
	la $t8, mushroomLocation
	la $t9, mushroomNum
	lw $t9, 0($t9)		# load mushroomNum to $t9, this will be the loop variable
	beq $t9, $zero, set_head_default_right	#if mushroomNum is 0, skip checking mushroom collision

loop_check_mushroom_collision_right:
	lw $t3, 0($t8)	# load mushroom location
	beq $t3, $t7, set_head_case_collide_right
	
	addi $t9, $t9, -1
	addi $t8, $t8, 4
	bne $t9, $zero, loop_check_mushroom_collision_right
	
set_head_default_right:
	lw $t7, 0($t0)	# store head location to $t7
	addi $t7, $t7, 1
	sw $t7, 0($t0) 
	j end_set_next_head_location
	
set_head_case_collide_right:
	# set centipede direction to 0 (left)
	addi $t7, $zero, 0
	sw $t7, 0($t1)
	
	# set centipede head location
	lw $t8, 0($t0)	# store head location to $t8
	addi $t8, $t8, 32
	sw $t8, 0($t0)
	
end_set_next_head_location:
	jr $ra	
	
	
	



# function to check dart collision with mushroom and cetipede, and respond accordingly
check_dart_collision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $s0, dartLocation
	la $t0, dartNum
	lw $s1, 0($t0)	# load dartNum to $s1, this will be the loop variable
	
	beq $s1, $zero, end_loop_check_dart_collision
	
loop_check_dart_collision:
	lw $t1, 0($s0)		# get current entry of dartLocation
	
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	jal check_dart_mushroom_collision
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	addi $t3, $zero, 1
	beq $t2, $t3, reduce_mushroom_live
	
	addi $s0, $s0, 4
	addi $s1, $s1, -1
	bne $s1, $zero, loop_check_dart_collision
	j end_loop_check_dart_collision
	
reduce_mushroom_live:
	# get the address of the entry of the mushroomLive that should be reduced
	lw $t4, 0($sp)
	la $t5, mushroomNum
	lw $t5, 0($t5)	# mushroomNum
	sub $t6, $t5, $t4	# offset of mushroomLocation
	sll $t6, $t6, 2
	la $t7, mushroomLive	# address of mushroomLive
	add $t7, $t7, $t6	# address of the entry of the mushroomLive that should be reduced
	
	lw $t8, 0($t7)
	addi $t8, $t8, -1
	beq $t8, $zero, remove_current_mushroom
	addi $sp, $sp, 4
	sw $t8, 0($t7)
	
	j remove_current_dart

remove_current_mushroom:
	# move the last value in mushroomLocation to the current position, and paint original display location with background colour
	# get last value
	la $t4, mushroomNum
	lw $t5, 0($t4)			# load mushroomNum to $t5
	la $t6, mushroomLocation	# load address of mushroomLocation to $t6
	addi $t7, $t5, -1
	sll $t7, $t7, 2
	add $t7, $t7, $t6 # save to $t7 the address that stores the last value of mushroomLocation
	lw $t8, 0($t7) # load the last value of mushroomLocation to $t8
	# get current position address
	lw $t9, 0($sp)
	sub $t9, $t5, $t9
	sll $t9, $t9, 2
	add $t9, $t9, $t6
	# paint the current mushroomLocation with background colour
	lw $t7, 0($t9)
	sll $t7, $t7, 2
	lw $t3, displayAddress
	add $t7, $t7, $t3
	li $t3, 0x000000
	sw $t3, 0($t7)
	# save
	sw $t8, 0($t9) # save the original last value to the current position
	
	# move the last value in mushroomLive to the current position
	# get last value
	la $t6, mushroomLive
	addi $t7, $t5, -1
	sll $t7, $t7, 2
	add $t7, $t7, $t6 # save to $t7 the address that stores the last value of mushroomLive
	lw $t8, 0($t7) # load the last value of mushroomLive to $t8
	# get current postion address
	lw $t9, 0($sp)
	addi $sp, $sp, 4
	sub $t9, $t5, $t9
	sll $t9, $t9, 2
	add $t9, $t9, $t6
	#save
	sw $t8, 0($t9) # save the original last value to the current position
	
	# update mushroomNum
	addi $t5, $t5, -1
	sw $t5, 0($t4)
	
remove_current_dart:
	# move the last value in dartLocation to the current position
	la $t4, dartNum
	lw $t5, 0($t4)		# load dartNum to $t5
	la $t6, dartLocation	# load address of dartLocation to $t6
	addi $t7, $t5, -1
	sll $t7, $t7, 2
	add $t7, $t7, $t6 # save to $t7 the address that stores the last value of dartLocation
	lw $t8, 0($t7) # load the last value of dartLocation to $t8
	sw $t8, 0($t0) # save the original last value to the current position
	
	# update dartNum
	addi $t5, $t5, -1
	sw $t5, 0($t4)
	
	addi $s1, $s1, -1 	# update loop variable
	bne $s1, $zero, loop_check_dart_collision	# check loop condition

end_loop_check_dart_collision:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra






check_dart_mushroom_collision:
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	 
	la $t2, mushroomLocation	# address of mushroomLocation
	la $t3, mushroomNum
	lw $t3, 0($t3)	# mushroomNum, $t3 will be the loop variable
	
	beq $t3, $zero, set_dart_mushroom_collision_false
	
loop_check_dart_mushroom_collision:
	lw $t4, 0($t2)	# current mushroom location
	beq $t4, $t1, set_dart_mushroom_collision_true
	addi $t2, $t2, 4
	addi $t3, $t3, -1
	bne $t3, $zero, loop_check_dart_mushroom_collision
	j set_dart_mushroom_collision_false
	
set_dart_mushroom_collision_true:
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	
	addi $sp, $sp, -4
	addi $t5, $zero, 1
	sw $t5, 0($sp)
	
	j end_check_dart_mushroom_collision
	
set_dart_mushroom_collision_false:
	addi $sp, $sp, -4
	sw $zero, 0($sp)
	
end_check_dart_mushroom_collision:
	jr $ra






# function to draw end game image (win)
end_game_win:
	# paint canvas blue
	addi $t0, $zero, 0	# $t0 will be the loop variable
	addi $t1, $zero, 1024	# loop end when $t0 == $t1
	lw $t2, displayAddress
	li $t3, 0x7842ff	# save colour blue to $t2

loop_paint_canvas_blue:
	sw $t3, 0($t2)
	
	addi $t2, $t2, 4
	addi $t0, $t0, 1
	bne $t0, $t1, loop_paint_canvas_blue
	
end_loop_paint_canvas_blue:
	lw $t2, displayAddress
	la $t4, winLocation
	addi $t5, $zero, 0	# $t5 will be the loop variable
	addi $t6, $zero, 19	# loop end when $t5 == $t6
	li $t7, 0xfffc42	# save colour yellow to $t7
	
loop_draw_win:
	lw $t8, 0($t4)
	sll $t8, $t8, 2
	add $t8, $t2, $t8
	
	sw $t7, 0($t8)
	
	addi $t4, $t4, 4
	addi $t5, $t5, 1
	bne $t5, $t6, loop_draw_win
	
	j Exit
	
	
	
	
	

# function to draw end game image (lose)
end_game_lose:
# paint canvas black
	addi $t0, $zero, 0	# $t0 will be the loop variable
	addi $t1, $zero, 1024	# loop end when $t0 == $t1
	lw $t2, displayAddress
	li $t3, 0x000000	# save colour blue to $t2

loop_paint_canvas_black:
	sw $t3, 0($t2)
	
	addi $t2, $t2, 4
	addi $t0, $t0, 1
	bne $t0, $t1, loop_paint_canvas_black
	
end_loop_paint_canvas_black:
	lw $t2, displayAddress
	la $t4, loseLocation
	addi $t5, $zero, 0	# $t5 will be the loop variable
	addi $t6, $zero, 28	# loop end when $t5 == $t6
	li $t7, 0xfffc42	# save colour yellow to $t7
	
loop_draw_lose:
	lw $t8, 0($t4)
	sll $t8, $t8, 2
	add $t8, $t2, $t8
	
	sw $t7, 0($t8)
	
	addi $t4, $t4, 4
	addi $t5, $t5, 1
	bne $t5, $t6, loop_draw_win
	j Exit






delay:
	li $v0, 32 
	li $a0, 15
	syscall
	
	jr $ra
