.section .data
words:
	.quad word0, word1, word2, word3, word4 # Array of word pointers
num_words:
	.quad 5					# Number of words in the array
word0:
	.string "Hello"
word1:
	.string "World"
word2:
	.string "Assembly"
word3:
	.string "Programming"
word4:
	.string "Linux"

.section .bss
	.lcomm buffer, 1	# Buffer to store user input

.section .text
	.globl _start
_start:
	# Main loop
main_loop:
	# Read a character from stdin
	mov $0, %rax		# sys_read
	mov $0, %rdi		# stdin (file descriptor 0)
	lea buffer(%rip), %rsi	# Buffer address
	mov $1, %rdx		# Read 1 byte
	syscall

	# Check for read error or EOF
	cmp $0, %rax
	jle exit_program

	# Get a pseudo-random number using RDTSC
	rdtsc		# Time stamp counter -> EDX:EAX
	shl $32, %rdx	# Shift higher 32 bits
	or %rax, %rdx	# Combine into a 64-bit value in RDX

	# Calculate random index: index = (RDX % num_words)
	mov num_words(%rip), %rbx	# Load num_words into RBX
	mov %rdx, %rax			# Move random number into RAX
	xor %rdx, %rdx			# Clear RDX for division
	div %rbx			# Divide RDX:RAX by RAX; Quotient in RAX, Remainder in RDX

	# Load the address of the selected word
	lea words(%rip), %rsi		# Base address of words array
	mov (%rsi,%rdx,8), %rdi		# Get word pointer: RDI = words[RDX]

	# Calculate the length of the selected word
	call strlen	# Length returned in RAX

	# Write the word to stdout
	mov %rdi, %rsi	# Move message address to %rsi
	mov %rax, %rdx	# Move message length to %rdx
	mov $1, %rdi	# Set %rdi to 1 (stdout file descriptor)
	mov $1, %rax	# Set %rax to 1 (sys_write syscall number)
	syscall

	# Loop back to wait for the next key press
	jmp main_loop

exit_program:
	# Exit the program gracefully
	mov $60, %rax	# sys_exit
	xor %rdi, %rdi	# Exit status 0
	syscall

# strlen: Calculate the length of a null-terminated string
# Input: RDI = address of the string
# Output: RAX = length of the string
strlen:
	xor %rax, %rax	# Initialize length counter to 0
strlen_loop:
	cmpb $0, (%rdi,%rax,1)	# Compare byte at RDI+RAX with 0
	je strlen_done		# If zero (null terminator), end loop
	inc %rax		# Increment length counter
	jmp strlen_loop		# Repeat loop
strlen_done:
	ret			# Return with length in RAX
