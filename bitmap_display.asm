##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000

    .text
	.globl main

main:
# Setup
li $t1, 0xaaaaaa        # Set color of line (yellow)
lw $s0, ADDR_DSPL       # Store display address into $t0


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

addi $a0, $zero, 12      # Set X coordinate for starting point
addi $a1, $zero, 3      # Set Y coordinate for starting point
jal init_pill


# addi $a0, $zero, 12     # Set x coordinate for starting point
# addi $a1, $zero, 4     # Set y coordinate for starting point
# jal draw_random_color
# addi $a0, $zero, 12     # Set x coordinate for starting point
# addi $a1, $zero, 3     # Set y coordinate for starting point
# jal draw_random_color
# addi $a0, $zero, 13     # Set x coordinate for starting point
# addi $a1, $zero, 3     # Set y coordinate for starting point
# jal draw_random_color

li $v0, 10                  # terminate the program gracefully
syscall

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


### Draws the pill at the spawn location and saves the properties of the 2 blocks
# block 1 color is in $s1
# block 2 color is in $s2
# block 1's memory address is in $s3
# block 2's memory address is in $s4
init_pill:      # params: a0, a1 (x, y) messes with: t3, t4, t5, v0, a0, a1, s1, s2, s3, s4
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $s0, $a0       # add the X offset to $s0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $s0, store in $t2
add $s3, $t2, $zero     # store block 1's position into $s3
li $v0 , 42             # let the system know we're randomizing
li $a0 , 0             # generate random number between 0 and 3
li $a1 , 3
syscall                 # store in $a0

li $t3, 0xffff00        # temporary yellow
li $t4, 0xff0000        # temporary red
li $t5, 0x0000ff        # temporary blue


# TODO: Mayyyybe fix how the condition is written here
li $v0 , 1 
li $a1 , 2
beq $a0, $zero, draw_yellow     # draw yellow if a0 = 0
beq $a0, $v0, draw_red          # draw red if a0 = 1
beq $a0, $a1 draw_blue          # draw blue if a0 = 2

draw_yellow:
sw $t3, 0($t2)
li $s1, 0xffff00        #store color into $s1
j init_second_block
draw_red:
sw $t4, 0($t2)
li $s1, 0xff0000        #store color into $s1
j init_second_block
draw_blue:
sw $t5, 0($t2)
li $s1, 0x0000ff        #store color into $s1
j init_second_block

init_second_block:
addi $t2, $t2, 128      # move to the second block
add $s4,  $t2, $zero    # store block 2's position in $s4
li $v0 , 42             # let the system know we're randomizing
li $a0 , 0             # generate random number between 0 and 3
li $a1 , 3
syscall                 # store in $a0

beq $a0, $zero, draw_yellow2     # draw yellow if a0 = 0
beq $a0, $v0, draw_red2          # draw red if a0 = 1
beq $a0, $a1 draw_blue2          # draw blue if a0 = 2
draw_yellow2:
sw $t3, 0($t2)
li $s2, 0xffff00        #store color into $s2
jr $ra
draw_red2:
sw $t4, 0($t2)
li $s2, 0xff0000        #store color into $s2
jr $ra
draw_blue2:
sw $t5, 0($t2)
li $s2, 0x0000ff        #store color into $s2
jr $ra

### Draws the pill at the spawn location and saves the properties of the 2 blocks
# block 1 color is in $s1
# block 2 color is in $s2
# block 1's memory address is in $s3
# block 2's memory address is in $s4
# init_pill:  # params: a0, a1 (x, y) messes with: t3, t4, t5, v0, a0, a1, 

# jal draw_random_color
# add $s1, $zero, $v0         #store first pill's color
#jal draw_random_color

