comment @
***********************************************************************
* Name: Vinh Huynh
* Assignment: CMPE 102 Project 2
* Course: CMPE 102 Section 4. Spring Semester 2023
* Instructor: Professor Loc Lam
* Date: April 1, 2023
*
* Description:
Write a program that reads an integer which is an index of one array and copies elements of that array to another array. 
Your program output should be similar to the sample run/output below.

•	Declare two arrays which have five 8-bit elements each.
•	Define a 8-bit data label named startIndex.
•	Read an integer from the keyboard and save it in the data label defined above.
•	Create the following procedures in the program:
	o	main - Gets user input and calls other procedures
	o	displayTitle - Prints this project title
	o	copyArray - Copies elements from one array to another
	o	showArray - Displays array contents on the console
	o	endProgram - Prints the termination message
•	Use LOOP, JMP, and conditional jump instructions in the program.
•	Use indexed addressing to copy one array to another array starting from the entered index.
•	Use the following operators and directives in the program: PTR, LENGTHOF, $, ALIGN, and OFFSET.
•	Use the following arrays for your test program: {1, 2, 3, 4, 5} and {0, 0, 0, 0, 0}.
•	Use the Irvine32 library for this solution program.

***********************************************************************
@

include Irvine32.inc

.386
; .model flat, stdcall		; comment out because of "warning A4011: multiple .MODEL directives found : .MODEL ignored"
							; and this is because include Irvine32.inc 
.stack 4096

ExitProcess PROTO, dwExitCode:DWORD

;*********************************************
;		DATA
;*********************************************
.data			; insert data below

; The project requires to use ALIGN. The only logical place to use this is in array1, which is five 8-bit elements each.
; If ALIGN was not require, I can declare 
; array1 BYTE 1,2,3,4,5 and increment one byte to get to the next element.
; According to the book in Chapter 4
; Why bother aligning data? Because the CPU can process data stored at evennumbered
; addresses more quickly than those at odd-numbered addresses.
array1	BYTE 1
		ALIGN 2
		BYTE 2
		ALIGN 2
		BYTE 3
		ALIGN 2
		BYTE 4
		ALIGN 2
		BYTE 5
		ALIGN 2

array1Length WORD ($ - array1) / 2	; to use $ this line must be right after array1 declaration

array2 BYTE 5 dup (0)		; this is same as array2 BYTE 0,0,0,0,0
array2Length WORD ?			; will calculate array2Length later
startIndex SBYTE ?			; this is SBYTE because user is allowed to enter -1

displayTitleStr		BYTE	"--- Array Copier ---",0
promptIndex			BYTE	"Index (0 - 4): ",0
displayError		BYTE	"Invalid Input. Try again", 0
programTerminated	BYTE	"... Program Terminated ...", 0
continueProgram		BYTE	"Continue? y/n: ", 0

continue BYTE 'y'			; continue program y or n
yLowerCase = 79h			; ascii for 'y' is 79h
nLowerCase = 6Eh			; ascii for 'n' is 6Eh

;*********************************************
;		MAIN
;*********************************************
.code			
main PROC

		call displayTitle	; Per requirement displays "--- Array Copier ---",0
	start:
		call Crlf
		mov edx,OFFSET promptIndex
		call WriteString	; write "Index (0 - 4): ",0

		call ReadInt		; get user input. ReadInt returns signed 32 bit into eax
		mov startIndex,al	; saves user input to startIndex

		; check if startIndex is between 0 and 4
		cmp al,0			; is al < 0?
		jl invalidRange		; Yes, al < 0   Jump if less (if leftOp < rightOp)
		cmp al,4			; is al > 4?
		jg invalidRange		; yes, al > 4   Jump if greater (if leftOp > rightOp)

		; startIndex is in range between 0-4 starting to copy array1 to array2
		mov esi,OFFSET [array1]			; esi points to array1[0]

		movsx ecx,startIndex			; never enter loop starting with ecx = 0. al is the startingIndex
		jcxz startIndexIsZero			; Jump if CX = 0

	firstElementOfArray1:				; if startindex is > 0
			add esi,2					; esi = array1[startIndex]. Add 2 because ALIGN 2 was used at the declaration 
		LOOP firstElementOfArray1

	startIndexIsZero:					; startIndex is 0
		; Prepare parameters for procedure copyArray
		mov edi,OFFSET array2			; edi points to array2[0]
		movzx ecx,array1Length			; mov with zero extended, otherwise ecx may have a very large number
		sub cl,startIndex				; loop (array1Length - startIndex) times
		call copyArray					; copy array1 to array2

		; Prepare parameters for procedure showArray
		mov edi,OFFSET array2			; points to array2
		movzx ecx,array1Length			; loop array1Length times
		call showArray					; show array to the console

		jmp runAgain

	invalidRange:
		mov edx,OFFSET displayError
		call WriteString				; write "Invalid Input. Try again", 0
		jmp start

	invalidInput_y_n:
		mov edx,OFFSET displayError
		call WriteString				; write "Invalid Input. Try again", 0
		call Crlf						; Irvine lib go to next line

	runAgain:
		mov edx,OFFSET continueProgram
		call WriteString				; write "Continue? y/n", 0
		call ReadChar					; read in a char. ReadChar returns al
		call WriteChar					; write al to the screen
		call Crlf
		mov continue,al
		cmp continue,yLowerCase			; ascii 79h is lower case 'y'
		jz start						; continue with the program from the beginning.  Jump if zero ZF = 1
		cmp continue,nLowerCase			; ascii 6Eh is lower case 'n'		
		jz terminateProgram				; continue = n terminated program.   Jump if zero ZF = 1
		jnz invalidInput_y_n			; not y or n.  Jump if not zero ZF = 0

	terminateProgram:
		call endProgram					; write "... Program Terminated ..."

	INVOKE ExitProcess,0				; end the program
main ENDP
		
;******************************************
;   displayTitle
;	"--- Array Copier ---"
;******************************************

displayTitle PROC Uses edx
	mov edx,OFFSET displayTitleStr
	call WriteString					; call Irvine library procedure
	ret
displayTitle ENDP

;******************************************
;   copyArray : Copy array1 to array2
; input: esi - array1
; input: edi - array2
; input: ecx - loop
; Copies elements from array1 to array2
;******************************************
copyArray PROC uses eax edi esi ecx edx
		mov dl,cl
	loopArray:
		mov eax,[esi]			; get content of array1
		mov [edi],eax			; copy to array2
		add edi,TYPE array2		; go to next element in array2
		add esi,2				; go to next element in array1
	LOOP loopArray

		; check if any missing zero needs to be fill in array2
		mov array2Length,LENGTHOF array2
		mov cl,BYTE PTR array2Length   
		sub cl,dl
		je nothingToCopy		; Jump if equal (leftOp = rightOp)

	zeroRemainingArray2:		
		mov eax,0
		mov [edi],eax
		add edi,TYPE array2
	LOOP zeroRemainingArray2

	nothingToCopy:
	ret
copyArray ENDP

;******************************************
; showArray : Displays array contents on the console
;
; input edi : point to array2[0]
; input ecx : how many times to loop
; Displays array2 contents on the console
;******************************************
showArray PROC Uses eax edi
	l1:
		mov dl,[edi]
		movzx eax,dl	
		call WriteHex			; write eax to console
		mov al,'H'				; WriteChar takes al
		call WriteChar			; to write 'H" "takes AL
		add edi,TYPE array2		; go to next element
		call Crlf				; Irvine lib go to next line
	LOOP l1
	ret
showArray ENDP

;******************************************
; endProgram - Prints the termination message
;******************************************
endProgram PROC uses edx
	call Crlf
	mov edx,OFFSET programTerminated
	call WriteString	; call Irvine library procedure
	call Crlf			; Irvine lib go to next line
	ret
endProgram ENDP

END main