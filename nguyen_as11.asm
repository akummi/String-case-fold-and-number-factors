#; Author: Avery Nguyen
#; Section: Section 1002
#; Date Last Modified: 4/21/21
#; Program Description: This program will demonstrate unserstanding of functions and system service calls in mips assembly.


.data
# SYSTEM SERVICES
SYSTEM_PRINT_INTEGER = 1
SYSTEM_PRINT_FLOAT = 2
SYSTEM_PRINT_DOUBLE = 3
SYSTEM_PRINT_STRING = 4
SYSTEM_PRINT_CHARACTER = 11
SYSTEM_READ_INTEGER = 5
SYSTEM_READ_FLOAT = 6
SYSTEM_READ_DOUBLE = 7
SYSTEM_READ_STRING = 8
SYSTEM_READ_CHARACTER = 12
SYSTEM_EXIT = 10
NULL = 0

# MESSAGES
msguserinputstr: .asciiz "Enter a message: " 
msguserinputint: .asciiz "Enter a number: " 
msgstringlength: .asciiz "String Length: " 
msgcasefold: .asciiz "Casefolded Message: "
msgprintfactors: .asciiz "Positive factors: " 
msgzero: .asciiz "All Positive Integers" 
msgspacer: .asciiz "**************************************\n" 

# VARIABLES
BUFFER_LENGTH = 31
stringBuffer: .space BUFFER_LENGTH
stringl: .space 4 
.text
.globl main
.ent main
main:
#PROMPT USER STRING INPUT

	li $v0, SYSTEM_PRINT_STRING
	la $a0, msguserinputstr
	syscall
	
    li $v0, SYSTEM_READ_STRING
	la $a0, stringBuffer
	li $a1, BUFFER_LENGTH
	syscall

	li $v0, SYSTEM_PRINT_CHARACTER
	li $a0, '\n'
	syscall

    li $v0, SYSTEM_PRINT_STRING
    la $a0, stringBuffer 
    syscall 

#CALL STRINGLENGTH FUNCTION

    la $a0, stringBuffer
    jal stringLength

    move $t1, $v0
   
#PRINT STRING LENGTH 
	li $v0, SYSTEM_PRINT_STRING
	la $a0, msgstringlength
	syscall

	li $v0, SYSTEM_PRINT_INTEGER
	move $a0, $t1  
	syscall

	li $v0, SYSTEM_PRINT_CHARACTER
	li $a0, '\n'
	syscall

#CALL CASEFOLD 
    la $a0, stringBuffer
    jal casefold 

#PRINT CASEFOLD 
	li $v0, SYSTEM_PRINT_STRING
	la $a0, msgcasefold
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, stringBuffer
	syscall

#PRINT SPACING 
	li $v0, SYSTEM_PRINT_CHARACTER
	li $a0, '\n'
	syscall

    li $v0, SYSTEM_PRINT_CHARACTER
	li $a0, '\n'
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, msgspacer
	syscall

    li $v0, SYSTEM_PRINT_STRING
	la $a0, msgspacer
	syscall

	li $v0, SYSTEM_PRINT_CHARACTER
	li $a0, '\n'
	syscall

#PROMPT USER INT INPUT 
    li $v0, SYSTEM_PRINT_STRING
	la $a0, msguserinputint
	syscall
	
	li $v0, SYSTEM_READ_INTEGER
	syscall
	move $s0, $v0
   

#PRINT POSITIVE FACTORS 
    li $v0, SYSTEM_PRINT_STRING
	la $a0, msgprintfactors
	syscall

    move $a0, $s0 

    jal printfactors

endofprogram: 

    li $v0, SYSTEM_EXIT
    syscall
    .end main        

# ****************************
# FUNCTION 1 
# ****************************
# Description: This function returns the length of a string not including the null 

# Arguments: 
# $a0 - Null terminated string 
# Returns length in $v0 

.globl stringLength
.ent stringLength
stringLength: 
    li $v0, 0 

    stringlengthloop:
    lb $t1, 0($a0) #loads value of char 

    beq $t1, NULL, stringLengthdone
    
    add $a0, $a0, 1 #moves to the next char 
    add $v0, $v0, 1 
    j stringlengthloop

stringLengthdone: 

    jr $ra 
.end stringLength

# ****************************
# FUNCTION 2 
# ****************************
# Description: This function takes a NULL terminated string and changes all of the lowercase letters to uppercase

# Arguments: 
# $a0 - Null terminated string 
# Returns the same string casefolded 

.globl casefold 
.ent casefold 
casefold: 
    #SAVE $ra REGSITER
	subu $sp, $sp, 8
	sw $ra, ($sp)
	sw $s1, 4($sp)

    #saves array a0 
    move $s1, $a0 

    jal stringLength

    li $t1, 0 #sets counter to 0 

    casefoldloop: 
    lb $t2, 0($s1) #loads char 

    bltu $t2, 97, notlowercase
    bgtu $t2, 122, notlowercase

    #makes lowercase uppercase
    sub $t2, $t2, 32
    sb $t2, 0($s1) 

    beq $v0, $t1, casefolddone #checks counter

    add $s1, $s1, 1 #moves to next char 
    add $t1, $t1, 1 #increments counter 

    j casefoldloop
    
    notlowercase: 
    beq $v0, $t1, casefolddone #checks counter

    add $s1, $s1, 1 #moves to next char 
    add $t1, $t1, 1 #increments counter 

   
    j casefoldloop
casefolddone:

    #REPLACE $ra REGISTER
	lw $ra, ($sp)
	lw $s1, 4($sp)
	addu $sp, $sp, 8
    jr $ra 
    .end casefold 

# ****************************
# FUNCTION 3 
# ****************************
# Description: This function takes an int and prints all of its positive factors 

# Arguments: 
# $a0 - integer 
# Returns nothing, but prints values in the function 

.globl printfactors 
.ent printfactors
printfactors:
    move $s1, $a0 
    li $t1, 1 #sets counter to 1

#checks argument 0 
    beq $s1, 0, argumentzero

#checks for negative argument 
    bge $s1, 0, printfactorsloop

    mul $s1, $s1, -1 #makes negative positive 

    printfactorsloop: 
    rem $t2, $s1, $t1 
    beq $t2, 0, printfactor

    li $t2, 0 #resets remainder 

    beq $s1, $t1, printfactorsdone 
    add $t1, $t1, 1 
    j printfactorsloop

printfactor: 
    
#PRINTS A SINGLE FACTOR 
    li $v0, SYSTEM_PRINT_INTEGER
	move $a0, $t1  
	syscall

    beq $s1, $t1, printfactorsdone 

#PRINTS ', ' IF NOT FINAL FACTOR 
    li $v0, SYSTEM_PRINT_CHARACTER
	li $a0, ','
	syscall

    li $v0, SYSTEM_PRINT_CHARACTER
	li $a0, ' '
	syscall

    add $t1, $t1, 1 
    j printfactorsloop

argumentzero: 
#PRINTS MESSAGE FOR 0 
	li $v0, SYSTEM_PRINT_STRING
	la $a0, msgzero
	syscall

printfactorsdone:

    jr $ra 
    .end printfactors     