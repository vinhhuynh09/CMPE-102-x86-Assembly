comment @
***********************************************************************
* Name: Vinh Huynh
* Assignment: CMPE 102 Project 1
* Course: CMPE 102. Spring Semester 2023
* Date: March 03, 2023
*
* Description:
Write a program that calculates the following expression: total =  (num3 + num4) - (num1 + num2) + 1

Use the following settings:
32-bit processor
protected mode and standard call convention
4096-byte stack
ExitProcess prototype with a parameter
Create an array of 16-bit signed integers: 1000h, 2000h, 3000h, and 4000h.
Define data labels: num1, num2, num3, and num4 which are initialized with 1, 2, 4, and 8, respectively.
Define another uninitialized variable named total.
Add each array element value to each data label and store its sum in that variable.
Calculate the expression using some of the following directives, registers, and instructions: OFFSET, PTR, TYPE, ESI, EAX, AX, EBX, BX, MOV, ADD, SUB, and INC.
Save the result in total.
Place comments in your code where needed.
Run your program and verify the content of EAX for the correct result.
***********************************************************************
@

.386
.model flat, stdcall
.stack 4096

ExitProcess PROTO, dwExitCode:DWORD

.data
;*******************************************************
;		data segment
;*******************************************************
	array SWORD 1000h, 2000h, 3000h, 4000h		; 16 bit signed integers
	num1	SWORD 1h		; initialize num1 to 1h
	num2	SWORD 2h		; initialize num2 to 2h
	num3	SWORD 4h		; initialize num3 to 4h
	num4	SWORD 8h		; initialize num4 to 8h
	total	SWORD ?

.code
;*******************************************************
;		Main 
;*******************************************************

main PROC

	; There are many ways to traverse the array.
	; Below are some different ways.

	mov esi, OFFSET array		; esi points to the first element of the array[0]
	mov ax, [esi]			; ax = content in ESI which is 1000h
	add num1, ax			; num1 = num1 + ax which is 1001h

	add esi, 2			; since data type of array is SWORD which is 16-bit or 2 bytes.
					; adding esi by 2 takes us to the next element of the array[1]
	mov ax, [esi]			; ax = content in ESI which is 2000h
	add num2, ax			; num2 = num2 + ax which is 2002h

	; Here is another way to get array[3]
	mov ax, WORD PTR [array + TYPE array + 2]	; TYPE array = 2 for 2 bytes. ax = array[3] = 3000h
	add num3, ax					; num3 = num3 + ax which is 3004h

	; Here is another way to get to array[4]
	mov ax, [array + 6]			; add 6 bytes starting from first array
	add num4, ax				; num4 = num4 + ax which is 4008h

	; Calculate expression total =  (num3 + num4) - (num1 + num2) + 1
	mov ax, num3
	add ax, num4				; ax = num3 + num4

	mov bx, num1
	add bx, num2				; bx = num1 + num2

	sub ax, bx				; ax = ax - bx. (num3 + num4) - (num1 + num2)
	inc ax					; ax = (num3 + num4) - (num1 + num2) + 1
						; or add ax, 1

	; Finally mov ax to total
	mov total, ax				; total = (num3 + num4) - (num1 + num2) + 1
						; total = 400ah

  INVOKE ExitProcess, 0
main ENDP

END main
