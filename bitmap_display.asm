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
li $t1, 0xaaaaaa        # Set color of line (yellow)
lw $t0, ADDR_DSPL       # Store display address into $t0
# Setup




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
jal draw_random_color
addi $a0, $zero, 12     # Set x coordinate for starting point
addi $a1, $zero, 3     # Set y coordinate for starting point
jal draw_random_color

li $v0, 10                  # terminate the program gracefully
syscall

draw_horizontal_line:   # params: a0, a1, a2 (x, y, len) messes with: a0, a1, a2, t2, t3

sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
add $t2, $t0, $a0       # add the X offset to $t0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $t0, store in $t2
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
add $t2, $t0, $a0       # add the X offset to $t0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $t0, store in $t2
sll $a2, $a2, 7         # calculate the amount of bytes we'll go through ( 2^7 = 128 * rows )
add $t3, $t2, $a2       # add this offset to $t2 then store in $t3 to figure out when to stop drawing
vertical_line_start:
sw $t1, 0($t2)          # draw yellow at current location
addi $t2, $t2, 128      # move current location by 1 pixel (4 bytes)
beq $t2, $t3, vertical_line_end  # break out of look if we've drawn all the pixels in the line
j vertical_line_start   # jump back to start of loop


vertical_line_end:
jr $ra

draw_random_color:      # params: a0, a1 (x, y) messes with: t3, t4, t5, v0, a0, a1
sll $a0, $a0, 2         # shift the X value by 2 bits (multiplying it by 4 to get to the next column)
sll $a1, $a1, 7         # shift the Y value by 7 bits (multiplying it by 128 to get to the row we wanted :D)
add $t2, $t0, $a0       # add the X offset to $t0, store in $t2
add $t2, $t2, $a1       # add the Y offset to $t0, store in $t2
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
jr $ra
draw_red:
sw $t4, 0($t2)
jr $ra
draw_blue:
sw $t5, 0($t2)
jr $ra
