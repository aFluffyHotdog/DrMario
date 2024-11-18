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
    
    addi $a0, $zero, 12     # Set x coordinate for starting point
    addi $a1, $zero, 4     # Set y coordinate for starting point
    jal init_pill
    jal init_virus

    #################################################################
    ######### Keyboard Section
    #################################################################
    
    j game_loop
    
    

game_loop:
    
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
	j draw_pill
	
	# 4. Sleep (1/60 second = 166.66... milliseconds
	li $v0, 32
	li $a0, 166
	syscall
	

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
li $a0 , 0              # generate random number between 0 and 3
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
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
add $s4, $t2, $zero     # store block 1's position into $s4
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
    addi $t6, $ra, 0         # store the return address of this function
    addi $t7, $zero, 128      # bottom collision to be used in collision funciton
    jal collision_check
    addi $ra, $t6, 0         # load the return address of this function
    bne $t9, $zero, return   # early return by not rotating position if there is a collision
    
    sw $zero, 0($s4)         # clear first block
    sw $zero, 0($s5)         # clear second block
    addi $s4, $s4, 128      # Shift the y-coordinate of the first pill block by 1 unit below
    addi $s5, $s5, 128      # Shift the y-coordinate of the second pill block by 1 unit below
    jr $ra
    
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


    
    





