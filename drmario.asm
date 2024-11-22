################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################


#######  TODO  #######
# - Game over
# - Pause Screen
# - 



    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
MUSIC:
    .space 28

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    #################################################################
    ######### Display Section
    #################################################################
    # Initialize the game
    lw $s0, ADDR_DSPL       # Store display address into $t0
    li $t1, 0xaaaaaa        # Set color of line (grey)
    
    # Left border
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 24     # Set length of line
    jal draw_vertical_line
    
    # bottom border
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 27      # Set Y coordinate for starting point
    addi $a2, $zero, 16     # Set length of line
    jal draw_horizontal_line
    
    
    # right border
    addi $a0, $zero, 20      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 24     # Set length of line
    jal draw_vertical_line
    
    # top left border
    addi $a0, $zero, 4      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 6     # Set length of line
    jal draw_horizontal_line
    
    # left neck
    addi $a0, $zero, 9      # Set X coordinate for starting point
    addi $a1, $zero, 3      # Set Y coordinate for starting point
    addi $a2, $zero, 1     # Set length of line
    jal draw_vertical_line
    
    # right neck
    addi $a0, $zero, 15      # Set X coordinate for starting point
    addi $a1, $zero, 3      # Set Y coordinate for starting point
    addi $a2, $zero, 1     # Set length of line
    jal draw_vertical_line
    
    # top right border
    addi $a0, $zero, 15      # Set X coordinate for starting point
    addi $a1, $zero, 4      # Set Y coordinate for starting point
    addi $a2, $zero, 6     # Set length of line
    jal draw_horizontal_line
    
    jal init_pill
    jal init_virus
    jal init_virus
    jal init_virus

    #################################################################
    ######### Keyboard Section
    #################################################################
    
    j game_loop
    
    

game_loop:

    li $v0, 32
	li $a0, 16
	syscall
    
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    li 		$v0, 32
	li 		$a0, 1
	syscall
	
	lw $s1, ADDR_KBRD               # $s1 = base address for keyboard
    lw $t8, 0($s1)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    
    
    # 2a. Check for collisions
        
    
	# 2b. Update locations (capsules)
	
	# 3. Draw the screen
	jal draw_pill
	jal initiate_gravity
	# 4. Sleep (1/60 second = 166.66... milliseconds
	
	
	
    # 5. Go back to Step 1
    j game_loop


draw_horizontal_line:   # params: a0, a1, a2 (x, y, len) messes with: a0, a1, a2, t2, t3

sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
sll $a2, $a2, 2         # convert line length to bytes (multiply by 4)
add $t3, $t2, $a2       # add this offset to $t2 then store in $t3 to figure out when to stop drawing

horizontal_line_start:
sw $t1, 0($t2)          # draw yellow at current location
addi $t2, $t2, 4        # move current location by 1 pixel (4 bytes)
beq $t2, $t3, horizontal_line_end  # break out of look if we've drawn all the pixels in the line
j horizontal_line_start # jump back to start of loop

horizontal_line_end:
jr $ra


draw_vertical_line:     # params: a0, a1, a2 (x, y, len) messes with: a0, a1, a2, t2, t3
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
sll $a2, $a2, 7         # calculate the amount of bytes we'll go through ( 2^7 = 128 * rows )
add $t3, $t2, $a2       # add this offset to $t2 then store in $t3 to figure out when to stop drawing


vertical_line_start:
sw $t1, 0($t2)          # draw yellow at current location
addi $t2, $t2, 128      # move current location by 1 pixel (4 bytes)
beq $t2, $t3, vertical_line_end  # break out of look if we've drawn all the pixels in the line
j vertical_line_start   # jump back to start of loop

vertical_line_end:
jr $ra

init_virus:
li $v0 , 42             # randomize X value
li $a0 , 0 
li $a1 , 14
syscall                 # store in $a0
addi $a0, $a0, 5        # Add the X offset, for where the bottle starts
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2


li $v0 , 42             # randomize Y value
li $a0 , 0              # generate random number between 0 and 3
li $a1 , 16             # Add the Y offset, so that the pill only spawns in 3/4 of the bottle
syscall                 # store in $a0
addi $a1, $a0, 10       # Add the Y offset, for where the bottle starts
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2

#### We're going to initiate virus colors a litttttttle bit differently #######1
li $t3, 0xffff01        # temporary yellow
li $t4, 0xff0001        # temporary red
li $t5, 0x0000f1        # temporary blue


li $v0 , 42             # randomize virus color
li $a0 , 0              
li $a1 , 3             
syscall                 # store in $a0
beq $a0, 0, virus_yellow     # draw yellow if a0 = 0
beq $a0, 1, virus_red        # draw red if a0 = 1
beq $a0, 2, virus_blue          # draw blue if a0 = 2
virus_yellow:
sw $t3, 0($t2)
jr $ra
virus_red:
sw $t4, 0($t2)
jr $ra
virus_blue:
sw $t5, 0($t2)
jr $ra

### Draws the pill at the spawn location and saves the properties of the 2 blocks
# block 1 color is in $s2
# block 2 color is in $s3
# block 1's memory address is in $s4
# block 2's memory address is in $s5
init_pill:      # params: a0, a1 (x, y) messes with: t3, t4, t5, v0, a0, a1, s1, s2, s3, s4
addi $a0, $zero, 12     # Set x coordinate for starting point
addi $a1, $zero, 4      # Set y coordinate for starting point
addi $s6, $zero, 0      # Set the rotation state back to zero
    
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
add $s4, $t2, $zero     # store block 1's position into $s4
lw $t9, 0($s4)
bne $t9, $zero, quit
    
li $v0 , 42             # let the system know we're randomizing
li $a0 , 0             # generate random number between 0 and 3
li $a1 , 3
syscall                 # store in $a0

li $t3, 0xffff00        # temporary yellow
li $t4, 0xff0000        # temporary red
li $t5, 0x0000ff        # temporary blue


# TODO: Mayyyybe fix how the condition is written here

beq $a0, 0, draw_yellow     # draw yellow if a0 = 0
beq $a0, 1, draw_red          # draw red if a0 = 1
beq $a0, 2, draw_blue          # draw blue if a0 = 2
jr $ra

draw_yellow:
sw $t3, 0($t2)
li $s2, 0xffff00        #store color into $s2
j init_second_block
draw_red:
sw $t4, 0($t2)
li $s2, 0xff0000        #store color into $s2
j init_second_block
draw_blue:
sw $t5, 0($t2)
li $s2, 0x0000ff        #store color into $s2
j init_second_block

init_second_block:
addi $t2, $t2, 128      # move to the second block
add $s5,  $t2, $zero    # store block 2's position in $s5
li $v0 , 42             # let the system know we're randomizing
li $a0 , 0             # generate random number between 0 and 3
li $a1 , 3
syscall                 # store in $a0

beq $a0, 0, draw_yellow2     # draw yellow if a0 = 0
beq $a0, 1, draw_red2          # draw red if a0 = 1
beq $a0, 2, draw_blue2          # draw blue if a0 = 2

draw_yellow2:
sw $t3, 0($t2)
li $s3, 0xffff00        #store color into $s3
jr $ra
draw_red2:
sw $t4, 0($t2)
li $s3, 0xff0000        #store color into $s3
jr $ra
draw_blue2:
sw $t5, 0($t2)
li $s3, 0x0000ff        #store color into $s3
jr $ra

draw_pill:
sw $s2, 0($s4)          # draw block 1
sw $s3, 0($s5)          # draw block 1
jr $ra


##########################
### Movement and Controls
##########################
keyboard_input:                     # A key is pressed
    lw $a0, 4($s1)                  # Load second word from keyboard
    
    ## Movement and Control Scanner ##
    # Move left 
    beq $a0, 0x77, rotate        # Check if the key W was pressed
    # Move right
    beq $a0, 0x61, move_left     # Check if the key A was pressed
    # Rotate
    beq $a0, 0x73, drop          # Check if the key S was pressed
    # Drop
    beq $a0, 0x64, move_right    # Check if the key D was pressed
    # Quit
    beq $a0, 0x71, quit     # Check if the key Q was pressed

    j game_loop
    
## Functions
move_left:            
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
     
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, -4      # left collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not shifting position if there is a collision
    
    addi $s4, $s4, -4        # Shift the x-coordinate of the first pill block by 1 unit to the left
    addi $s5, $s5, -4        # Shift the x-coordinate of the second pill block by 1 unit to the left
    jr $ra

move_right:
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
    
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, 4      # left collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not shifting position if there is a collision
    
    addi $s4, $s4, 4         # Shift the x-coordinate of the first pill block by 1 unit to the right
    addi $s5, $s5, 4         # Shift the x-coordinate of the second pill block by 1 unit to the right
    jr $ra
    
rotate:
    #### TODO: Insert the beq logic here ####
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
    
    beq $s6, 0, rotate_1
    beq $s6, 1, rotate_2
    beq $s6, 2, rotate_3
    beq $s6, 3, rotate_4
    jr $ra
    
rotate_1:
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, -4      # top collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating if there is a collision
    
    addi $s4, $s4, 124          # rotate from top to left
    addi $s6, $zero, 1          # increment rotation state
    jr $ra
    
rotate_2:
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, 128      # left collision to be used in collision funciton
    jal collision_check
    
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating if there is a collision
    
    addi $s4, $s4, 132        # rotate from left to bottom
    addi $s6, $zero, 2          # increment rotation state
    jr $ra
    
rotate_3:
    
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, 4      # right collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating if there is a collision
    
    addi $s4, $s4, -124        # rotate from bottom to right
    addi $s6, $zero, 3          # increment rotation state
    jr $ra

rotate_4:
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, -128       # top collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating position if there is a collision
    
    addi $s4, $s4, -132       # rotate from right to top
    addi $s6, $zero, 0          # increment rotation state
    jr $ra
    
drop:
    addi $t7, $zero, 128      # bottom collision to be used in collision funciton
    sw $zero, 0($s4)         # clear first block temporarily
    sw $zero, 0($s5)         # clear second block temporarily
    
    addi $t6, $ra, 0          # store the return address of this function
        ### Check if it collides with anything at the bottom
        jal collision_check       # updates $t9 to non zero if it collides from the current location
        beq $t9, $zero, shift_below
        
        ### Check if it collides with anything at the bottom
        jal draw_pill                   # redraw the pill
        # initialise a new pill if it collides with anything below it
        bne $t9, $zero, init_new_pill   # initialize a new pill 
    
    addi $ra, $t6, 0            # load the return address of this function

    shift_below:
        addi $ra, $t6, 0        # load the return address of this function
        addi $s4, $s4, 128      # Shift the y-coordinate of the first pill block by 1 unit below
        addi $s5, $s5, 128      # Shift the y-coordinate of the second pill block by 1 unit below
    jr $ra
    
init_new_pill:
    
    addi $sp, $sp, -4           # save $ra onto stack    
    
    sw $ra, 0($sp)
	jal check_clear_block1
	jal check_clear_block2
	lw $ra, 0($sp)              # restore $ra
    addi $sp, $sp, 4 
    addi $s4, $zero, 0          # Shift the y-coordinate of the first pill block by 1 unit below
    addi $s5, $zero, 0          # Shift the y-coordinate of the second pill block by 1 unit below
    jal init_pill               # initialize a new pill
    
    j game_loop

collision_check:    
    # load some register to specify direction + 4 or +128 for example
    # addi $t7, $t7, 4  # right collision block
    # addi $t7, $t7, -128  # top collision block
    # addi $t7, $t7, 128  # bottom collision block
    
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
    
    add $t9, $s5, $t7         # the collition detection block for the first pill block
    lw $t9, 0($t9)            # load the color value of the collision block
    bne $t9, $zero, return    # early return if anything is there at t9 where block 1 is going
    
    add $t9, $s4, $t7         # the collision detection block for the second pill block
    lw $t9, 0($t9)            # load the color value of the collision block
    
    jr $ra
    
quit:
	li $v0, 10                      # Quit gracefully
	syscall
    
return:
jr $ra

###### Big block for the check and clear stuff ######
check_clear_block1: 
    add $t3, $zero, $s2     #load block 1 color
    andi $t3, $t3, 0xfffff0 # mask block1's to make sure that it reads the same as the virus
    add $t4, $zero, $s4     #load block 1 pos, we'll use this as our read head
    addi $sp, $sp, -4           # initialize reading pointer     
    sw $t4, 0($sp)              # store original position into stack
    addi $t5, $zero, 0            # initialize our counter
    j check_left

check_clear_block2: 
    add $t3, $zero, $s3     #load block 1 color
    andi $t3, $t3, 0xfffff0 # mask block1's to make sure that it reads the same as the virus
    add $t4, $zero, $s5     #load block 1 pos, we'll use this as our read head
    addi $sp, $sp, -4           # initialize reading pointer     
    sw $t4, 0($sp)              # store original position into stack
    addi $t5, $zero, 0            # initialize our counter
    j check_left
      
check_left:
    lw $t6, 0($t4)                  # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, restore_checker1    # while color is still the same as pill it was called on
        addi $t5, $t5, 1                # counter +1 
        addi $t4, $t4, -4               # traverse left
        j check_left                    # keep going left

restore_checker1:
    lw $t4, 0($sp)              # we reset the read head, restoring $t4
    addi $t4, $t4, +4         # traverse right first

check_right:
    lw $t6, 0($t4)              # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, check_transition   # while color is still the same as pill it was called on
        addi $t5, $t5, 1            # counter +1 
        addi $t4, $t4, +4         # traverse down
        j check_right                  # keep going down

check_transition:
    bge $t5, 4, clear_horizontal_prep         # if counter >= 4,
    lw $t4, 0($sp)              # we reset the read head, restoring $t4
    addi $t5, $zero, 0          # reset the counter

check_up:
    lw $t6, 0($t4)              # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, restore_check_head2    # while color is still the same as pill it was called on
        addi $t5, $t5, 1            # counter +1 
        addi $t4, $t4, -128         # traverse up
        j check_up                  # keep going up
    
restore_check_head2:
    lw $t4, 0($sp)              # we reset the read head, restoring $t4
    addi $t4, $t4, +128         # traverse down, since we already checked where we started

check_down:
    lw $t6, 0($t4)              # load color at current point into $t6
    andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
    bne $t3, $t6, check_if_four_vertical   # while color is still the same as pill it was called on
    addi $t5, $t5, 1            # counter +1 
    addi $t4, $t4, +128         # traverse down
    j check_down                  # keep going down

check_if_four_horizontal:
lw $t4, 0($sp)              # we reset the read head, restoring $t4
bge $t5, 4, clear_horizontal_prep         # if counter >= 4,
j check_transition

check_if_four_vertical:
bge $t5, 4, clear_vertical_prep         # if counter >= 4,
j temp_exit




clear_horizontal_prep:
lw $t4, 0($sp)              # we reset the read head, restoring $t4
lw $t6, 0($t4)                  # load color at current point into $t6
clear_left:
    lw $t3, 0($t4)                  # load color at current point into $t3
    bne $t3, $t6, restore_clear1    # while color is still the same as pill it was called on
    sw $zero, 0($t4)                # paint the screen at $t4 black
    ### start the move things above down loop ###
    addi $t5, $t4, 0                        # use $t5 as a pointer for where we are
    # jal move_things_down
        move_things_down:
        lw $t7, -128($t5)                       # use $t7 to store color above
        beq $t7, $zero, continue_clear_left     # while above is not black
        # TODO: check if it's a virus
        sw $t7, 0($t5)                          # write above pixel onto where t5 is
        sw $zero, -128($t5)                     # paint the above area zero.
        addi $t5, $t5, -128                     # traverse up
        j move_things_down
        
        
continue_clear_left:
    addi $t4, $t4, -4               # traverse left
    j clear_left                    # keep going left
    
restore_clear1:
lw $t4, 0($sp)              # we reset the read head, restoring $t4
addi $t4, $t4, 4            # shift head by 1 unit to the right, since we already checked the place we started
#TODO: reset the header

clear_right:
    lw $t3, 0($t4)                  # load color at current point into $t6
    bne $t3, $t6, temp_exit    # while color is still the same as pill it was called on
    sw $zero, 0($t4)                # paint the screen at $t4 black
    ### start the move things above down loop ###
    addi $t5, $t4, 0                        # use $t5 as a pointer for where we are
    # jal move_things_down
        move_things_down2:
        lw $t7, -128($t5)                       # use $t7 to store color above
        beq $t7, $zero, continue_clear_right     # while above is not black
        # TODO: check if it's a virus
        sw $t7, 0($t5)                          # write above pixel onto where t5 is
        sw $zero, -128($t5)                     # paint the above area zero
        addi $t5, $t5, -128                     # traverse up
        j move_things_down2
        
        
continue_clear_right:
    addi $t4, $t4, 4               # traverse right
    j clear_right                  # keep going right
    


clear_vertical_prep:
lw $t4, 0($sp)                  # we reset the read head, restoring $t4
lw $t6, 0($t4)                  # load color at current point into $t6
andi $t6, $t6, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
addi $t5, $zero, 0              # initialize t5 as a counter of how much we've cleared

clear_up:
lw $t3, 0($t4)                  # load color at t4 current point to t3
andi $t3, $t3, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
bne $t3, $t6, restore_clear2    # while color t3 is same as t6 else go to restore clear 2
sw $zero, 0($t4)                # paint the screen at t4 black
addi $t5, $t5, 1                # increment t5 by 1
addi $t4, $t4, -128             # increment t4 by -128 to move further up
j clear_up                      # loop

restore_clear2:
lw $t4, 0($sp)                # we reset the clear head, restoring $t4
addi $t4, $t4, 128            # shift head by 1 unit down, since we already cleared the place we started

clear_down:
lw $t3, 0($t4)                  # load color at t4 current point to t3
andi $t3, $t3, 0xfffff0         # mask the current pixel's color to make sure we don't skip the virus
bne $t3, $t6, temp_exit # while color t3 is same as t6 else go to move things down 3
sw $zero, 0($t4)                # paint the screen at t4 black
addi $t5, $t5, 1                # increment t5 by 1
addi $t4, $t4, 128              # increment t4 by 128 to travel down
j clear_down

finish_clearig:
addi $sp, $sp, 4
jr $ra

temp_exit:
# addi $sp, $sp, 4           # restore stack pointer once we're done checking everrrrry thing 
jr $ra


initiate_gravity:
addi $t3, $s0, 660 # initiate pointer at top left of bottle x = 5, y =5
gravity_loop:
    beq $t3, 0x10008D00 , temp_exit # check if we're beyond bound of bottle o
    lw $t4, 0($t3)  # load color at current point
    beq $zero, $t4, gravity_loop_cont  # if curr not black, if curr is black: go to pointer +4
    # TODO: if curr not virus, else: go to pointer +4
    andi $t7, $t4, 0x0F     # check if current pixel is a virus (the last hex digit is a 1)
    beq $t7, 1, gravity_loop_cont
    beq $t3, $s4, gravity_loop_cont  # don't clear if we're checking the active pill
    beq $t3, $s5, gravity_loop_cont  # don't clear if we're checking the active pill   
    lw $t5, 128($t3) # load color below curr
    bne $t5, $zero, gravity_loop_cont  # increment if down below isn't black
    lw $t5, -4($t3) # load color to the left into t5
    beq $t5, 0, gravity_right_check # if the left is black go to check right
    bne $t5, 0xaaaaaa, gravity_loop_cont # then left should be wall then go to check right, else jump to increment
    gravity_right_check:
    lw $t5, 4($t3)  # load color to the right into t5
    beq $t5, $zero, move_shit_down  # if right is black go to to move shit down, else check if wall
    bne $t5, 0xaaaaaa, gravity_loop_cont # if right is wall go to move shit down
    move_shit_down:
    sw $zero, 0($t3)    # clear current position
    sw $t4, 128($t3) # move curr down + 128
    gravity_loop_cont:
    addi $t3, $t3, 4 # pointer + 4
    j gravity_loop
        

#handling random floating little shits
# if found a block that is free on left, and bottom 
# keep going right
# stop looping when border is reached
# stop looping when black is reached
# stop looping when