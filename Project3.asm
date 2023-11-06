comment @
***********************************************************************
* Name: Vinh Huynh
* Assignment: CMPE 102 Project 3
* Course: CMPE 102 Section 4. Spring Semester 2023
* Instructor: Professor Loc Lam
* Date: April 23, 2023
*
* Description:
Write a program that controls the laser system at a medical devices company. 
The program includes a main procedure which gets user inputs and uses the input values for the OK button press,
CANCEL button press, the SET button press, the CLEAR button press, and other functionalities on the touch screen. 
The program should generate the output which is shown on the sample run/output below.

Specifications
o	Define a 8-bit control variable and initialize it with 0.
o	Declare status messages for the program output.
o	Create a main procedure to get user inputs.
o	Use 'y' for the OK button press and 'n' for the CANCEL button press.
o	Display an error message if user input is neither 'y' nor 'n'.
o	Note that the system has four different modes: Start, Standby, Ready, and Fire.
o	Assume the user enters 1 to set the bit and enters 0 to clear the bit.
o	Set the MSB of the control byte to confirm the laser is in the standby mode.
o	Set the LSB of the control byte to confirm the laser is in the ready mode.
o	Make sure the MSB and the LSB of the control variable should be set before firing the laser.
o	Use the following instructions along with other instructions for your program: CMP, JZ, SHL, RCL, RCR, and OR.
o	Test the program and generate the output.

***********************************************************************
 NOTE: This program meets all the requirements.
       In addition to check for valid input for 'y', and 'n', I have added procedure
	   isValidInput1or0 to check for valid input for 1 and 0.
	   Also, I am using ReadChar for all inputs. So the user only have to type in ONE ascii without the Enter key.
***********************************************************************
@
include Irvine32.inc
.386
.stack 4096

ExitProcess PROTO, dwExitCode:DWORD

.data
;***********************************************************
control			BYTE 00000000b	; MSB is the standby bit, LSB is the ready bit

productStr		BYTE "Medical Laser System",0
startStr		BYTE "Start? y/n: ",0
standbyBitStr	BYTE "Standby bit (1/0): ",0
sysStandbyStr	BYTE " System Standby.",0

readyStr		BYTE "Ready? y/n: ",0
readyBitStr		BYTE "Ready bit (1/0): ",0
sysReadyStr		BYTE " System Ready.",0

fireStr			BYTE "Fire? y/n: ",0
sysFireStr		BYTE " System fired.",0
unableFireStr	BYTE " Unable to fire.",0
invalidInputStr	BYTE " Invalid input",0
shutDownStr     BYTE " System shutdown.",0

yLowerCase = 79h			; ascii for 'y' is 79h
nLowerCase = 6Eh			; ascii for 'n' is 6Eh
asciiForNumber0 = 30h		; ascii for '0' is 30h
asciiForNumber1 = 31h		; ascii for '1' is 31h

.code
;******************************************
main PROC
;******************************************
	mov edx,OFFSET productStr	; display "Medical Laser System"
	call WriteString			; Irvine library procedure. WriteString takes edx
	call Crlf					; Irvine lib go to next line

start:
	mov control,00000000b		; reset control variable
	call Crlf					
	mov edx,OFFSET startStr		; display "Start? y/n:"
	call WriteString
	call ReadChar				; ReadChar returns al
	call WriteChar				; write al to the screen

	; Check for input for 'y' or 'n'
	call isValidInput_y_or_n	; isValidInput_y_or_n returns in bl - 1 for valid, 0 for invalid in bl
	cmp bl,0
	jz start					; jump to start if bl = 0 (invalid)
								; another way to check jump to start if al is NOT equal to y or n

	cmp al,yLowerCase			; ascii 79h is lower case 'y'. If y, jz to getStandByBit
	jz getStandByBit

	cmp al,nLowerCase			; if al == n, ZR = 1, jz to shutdown
	jz shutDown

getStandByBit:
	call systemStatus				; display system status. "System Standby" or "System Ready"

invalidStandbyBit:
	mov control,00000000b			; reset control here because standby bit may have been set, but ready y/n = n
	mov edx,OFFSET standbyBitStr	; display "Standby bit (1/0):"
	call WriteString
	call ReadChar					; I could have used ReadInt
									; ReadInt reads a 32-bit signed decimal integer from the keyboard, terminated by the Enter key.
									; However, I choose to use ReadChar to make the user interface consistent with ReadChar when getting 'y' and 'n'									
	call WriteChar					; write al to the screen

	call isValidInput1or0			; isValidInput1or0 returns in bl - 1 for valid, 0 for invalid in bl
	cmp bl,0
	jz invalidStandbyBit			; ask for standby bit again because input was invalid

	sub al,30h						; al is a ascii. Since I used ReadChar() so I have subtract 30h which is zero
	shl al,7						; shift left starting from LSB to MSB which is the Standby bit
	or control,al					; store MSB bit (standby) to control byte

getReady:
	call Crlf
	mov edx,OFFSET readyStr			; "Ready? y/n:"
	call WriteString				
	call ReadChar					; ReadChar returns al
	call WriteChar					; write al to the screen

	call isValidInput_y_or_n		; isValidInput_y_or_n returns in bl - 1 for valid, 0 for invalid in bl
	cmp bl,0
	jz getReady

checkStandBit:						; standby bit must be set before asking for ready bit.
									; it does not matter "Ready? y/n" = y or n here. if standby bit is 0 ask for standby bit again
	test control,10000000b			; check for MSB which is the standby bit
	jz getStandByBit				; jump if zero zf = 1, in other words standby bit is 0

	cmp al,yLowerCase				; ascii 79h is lower case 'y'. If y, jmp to getReadyBit
	jz getReadyBit
	cmp al,nLowerCase				; if al == n, ZR = 1, jz to getStandByBit
	jz getStandByBit

	
getReadyBit:						; Now deal with y
	call systemStatus
	mov edx,OFFSET readyBitStr		; display "Ready bit (1/0): "
	call WriteString
	call ReadChar
	call WriteChar					; write al to the screen

	call isValidInput1or0			; isValidInput1or0 returns 1 for valid, 0 for invalid in bl
	cmp bl,0
	je getReadyBit

	sub al,30h						; al is a char. I used ReadChar() so I need to  subtract 30h which is zero
	or control,al

fire:								; now deal with fire? y/n
	call Crlf
	mov edx,OFFSET fireStr			; display "Fire? y/n: "
	call WriteString
	call ReadChar					; ReadChar returns al
	call WriteChar					; write al to the screen

	; check for valid input
	cmp al,nLowerCase				; al =? n, if yes to go start
	jz start						; if true, jmp to start
	cmp al,yLowerCase				; al =? y, if true, al == n or al == y
	jz valid						

	call isValidInput_y_or_n		; isValidInput_y_or_n returns 1 for valid, 0 for invalid in bl
	cmp bl,0
	jz fire

valid:
	; check for LSB aka ready bit
	rcr control,1					; Per requirement I must use RCR. Otherwise, I can use OR or TEST to find is LSB was set or not
	jc checkAllBit					; check for carry flag

	jnc unableToFire				; jump if cf is 1 ; ready bit is NOT ready

checkAllBit:
	rcl control,1					; recover control
	cmp control,81h					; 81H - standby and ready are sets
									; actually here, I only have to check for the ready bit
									; because the requirement requires standby bit is set by the time I get to here
									; but the requiremnt also stated to check for both bits.
	jz systemFired					; jump if zr = 1 (a1 == 81h)

unableToFire:	
	rcl control,1					; recover control
	mov edx,OFFSET unableFireStr	; display "Unable to fire."
	call WriteString
	call Crlf
	
	cmp control,80h					; if readybit is 0 ask for it again.
	je getReadyBit

systemFired:						; label executed if standyBy and ready bit are both 1
	mov edx,OFFSET sysFireStr		; display "System fired."
	call WriteString
	jmp fire

shutDown:
	mov edx,OFFSET shutDownStr		; display "System shutdown."
	call WriteString
	call Crlf

  INVOKE ExitProcess,0
main ENDP


;******************************************
;   isValidInput1or0
;   Check if the user entered 1 or 0, and return the approviate value in bl
;	Receives: al
;	Returns: bl. 0 -> invalid input, 1 -> valid input
;   Note: This checking is not required in the project description. 
;         Project only required to check for y and n.
;		  I figure it would be cool to check for 0 or 1.
;******************************************
isValidInput1or0 PROC uses edx
	; checkZero
	cmp al,asciiForNumber0		; 30H is 0 (zero)
	jz valid

	;check1:
	cmp al,asciiForNumber1		; 31h is 1 (one)
	jz valid

invalid:
	mov edx,OFFSET invalidInputStr	; display "Invalid input"
	call WriteString
	;******************************************
	; The line below Crlf is the reason that I cannot combine 
	; isValidInput1or0 and isValidInput_y_or_n into one procedure
	;******************************************
	call Crlf		
	mov bl,0		; return 0 (invalid input)
	ret
valid:
	mov bl,1		; return 1 (valid input)
	ret
isValidInput1or0 ENDP

;******************************************
;   isValidInput_y_or_n
;   Check if the user entered 'y' neither 'n', and return the approviate value in bl
;	Receives: al
;	Returns: bl. 0 -> invalid input, 1 -> valid input
;******************************************
isValidInput_y_or_n PROC uses edx
	cmp al,yLowerCase	; check for lowercase y
	jz valid			; jz is same as je

	cmp al,nLowerCase	; check for lowercase n
	jz valid
	jmp invalid

invalid:
	mov edx,OFFSET invalidInputStr	; display "Invalid input"
	call WriteString
	mov bl,0			; return 0 (invalid input)
	ret
valid:
	mov bl,1			; return 1 (valid input)
	ret
isValidInput_y_or_n ENDP

;******************************************
;   systemStatus
;	Display status line. If standby bit is 0 displays "System Standby", else "System Ready"
;	Receives: nothing
;	Returns: nothing
;******************************************
systemStatus PROC uses edx
	cmp control, 00000000b
	jz standby
	mov edx,OFFSET sysReadyStr		; display "System Ready."
	jmp exitProc

standby:
	mov edx,OFFSET sysStandbyStr	; display "System Standby."
exitProc:
	call WriteString
	call Crlf
	ret

systemStatus ENDP


END main        ;last line for the entire program