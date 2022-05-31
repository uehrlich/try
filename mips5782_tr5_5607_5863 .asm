                                                                  # exercise 5 from: Daniel Elbaz 346012065
						#		and 	   Uri Erlich     208967976

j exe2

exe1:
.data 
str1: .asciiz "\n ENTER VALUE:"
str2: .asciiz "\n ENTER OP CODE:"
str3: .asciiz "\n THE RESULT IS: "
str4: .asciiz "\n ERROR"
.align 2
.text 
li $s1,'+'
li $s2,'*'
li $s3,'-'
li $s4,'@'
la $a0,str1 #print masage and recieve value
li $v0,4
syscall
li $v0,5
syscall
add $t0,$v0,$zero #$to=$v0
operation: #choose operation 
	la $a0,str2
	li $v0,4
	syscall
	li $v0,12
	syscall
	add $s0,$v0,$zero #$s0=operation kind
	beq $s0,$s1,plus #if +
	beq $s0,$s2,multi #if *
	beq $s0,$s3,minus #if -
	beq $s0,$s4,result #if @
	j error #if other operation
plus:
	la $a0,str1 #recieve enother number and add him to $to
	li $v0,4
	syscall
	li $v0,5
	syscall
	add $t1,$v0,$zero
	add $t0,$t0,$t1
	j operation #return to get the next op code
minus:
	la $a0,str1 #recieve enother number and sub him from $to
	li $v0,4
	syscall
	li $v0,5
	syscall
	add $t1,$v0,$zero
	sub $t0,$t0,$t1
	j operation
result:
	la $a0,str3 #printing the result
	li $v0,4
	syscall
	add $a0,$t0,$zero
	li $v0,1
	syscall
	j end
multi:
	la $a0,str1
	li $v0,4
	syscall
	li $v0,5
	syscall
	add $t1,$v0,$zero
	mult $t0,$t1 
	mfhi $t2 #$t2=hi register
	mflo $t4 #$t4=lo register
	beq $t2,$zero,positive #if hi =0000...00 go to positive
	j negative #else go to negative
continueMult:
	add $t0,$t4,$zero	
	j operation

negative:
	li $t3,-1
	bne $t2,$t3,error #if hi!=-1 error
	slt $t5,$t4,$zero #else if lo<0 continue mult
	li $t6,1
	beq $t5,$t6,continueMult
	j error #else error
positive:
	slt $t5,$t4,$zero #if $t4<0 $t5=1
	li $t6,1 
	beq $t5,$t6,error #if $t5=1 its error
	j continueMult #else, go to continue th mult calc

	
error: #print error end finishing the program
	la $a0,str4
	li $v0,4
	syscall
	j end
end:
	nop
	
	
exe2:
.data
	msg1: .asciiz "\n Enter hex number: "
	msg2: .asciiz "\n input= "
	msg4: .asciiz "\n output= "
	msg3: .asciiz "\n error op code"
.align 2
	number: .space 10  # The number in ASCII

.text
loop_new:

	li	$v0,4
	la	$a0,msg1 #"Enter hex number: 
	syscall
	
##############################################################
# read number in HEX. The letters A-F must be BIG LETTERS
# The result is in $v1
read_hex_number:
	li	$v0,8
	la	$a0,number
	li	$a1,10
	syscall			# Read number as string
	li	$t0,0		# $t0 = The result
	la	$t1,number	# $t1 = pointer to number
	li	$t4,10		# $t4 = ascii code of enter
	li	$t5,'9'		# to check if digit
next:	lb	$t2,0($t1)	# $t2 = next digit
	beq	$t2,$t4,end_input	# if $t2 = enter --> finish
	sll	$t0,$t0,4	# $t0 *= 16
	slt	$t3,$t5,$t2    # check if tav <= '9'
	beq	$t3,$zero,digit
	addi	$t2,$t2,-55	# $t2 = $t2 -'A' + 10	
	j	cont
digit:	addi	$t2,$t2,-48	# $t2 = $t2 - '0'	
cont:	add	$t0,$t0,$t2	# add to sum
	addi	$t1,$t1,1	# increment pointer
	j	next	
end_input:	addi	$v1,$t0,0	# result in $v1	

	#continoue progrm 
	beq $v1,$zero,end1#check if 0 
	
	add $t0,$v1,$zero #$t0 =$v1
	srl $t1,$t0,24 #take 8 bit msb of $t0 into $t1

	#op code
	li $s0,0x31#op0
	li $s1,0x30#op1
	li $s2,0x48#op2
	li $s3,0x74#op3

	beq $t1,$s0,op0
	beq $t1,$s1,op1
	beq $t1,$s2,op2
	beq $t1,$s3,op3

	j error_op_code

#insert "1" in bits 0,1,6,7 . with mask "1" and "or"
op0:
	li $s4,0xc3#inside "1" in bits 0,1,6,7 for mask 
	or $t2,$t0,$s4
	j print
#insert "0" in bits 0,1,6,7	
op1:
	li $s4,0xffffff3c#inside "1" in all the bits  part from 0,1,6,7 for mask 
	and $t2,$t0,$s4 
	j print

#flip the bits from 8-15 with xor with "1"	
op2:
	li $s4,0xff00 #inside "1" in bits 8-15
	xor $t2,$t0,$s4
	j print

op3:
	li $s4,0x00f80000 #insert "1" in bits 20 - 24
	and $s4,$t0,$s4 
	srl $s4,$s4,20 #set right 20 the 5 bits
	sllv $t2,$t0,$s4 #move left the bits acorrding the $s4
	j print

error_op_code:
	#print
	la $a0,msg3
	li $v0,4
	syscall
	j loop_new

print:
	li	$v0,4
	la	$a0,msg2
	syscall
	li	$v0,34		# print in HEX
	add	$a0,$t0,$zero
	syscall
	
	li	$v0,4
	la	$a0,msg4
	syscall
	li	$v0,34		
	add	$a0,$t2,$zero
	syscall
	
	j loop_new
	
end1:
	nop
		
	
