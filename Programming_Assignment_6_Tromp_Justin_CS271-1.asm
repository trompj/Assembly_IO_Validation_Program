TITLE Programming_Assignment_6   (Programming_Assignment_6_Tromp_Justin_CS271.asm)

; Author: Justin Tromp
; Contact: Trompj@oregonstate.edu
; Course: CS271-400
; Assignment: Programming Project/Assignment 6
; Date: 03/08/2019
; Due Date: 03/17/2019
; Programming_Assignment_6_Tromp_Justin_CS271.asm - Program starts by displaying title of program and
; name of programmer (Justin Tromp). Program requests user input for 10 decimal integers (signed or unsigned)
; and prompts user that integer must be small enough to fit inside a 32-bit register. After all integers are
; input within guidelines, display list of integers, the sum of all 10 integers, and their average value.
; 
; EC COMPLETED:
; 1. ReadVal and WriteVal procedures are called recursively instead of using loops.
; 2. Each line of user input is numbered and a running subtotal of all values entered is displayed.
; 3. Not an extra credit per say, but program handles leading zeros as well, which is outside of program requirements.

INCLUDE Irvine32.inc

;Macro Declarations/Implementations
;Get string macro gets/reads string from user input
getString      MACRO    offsetArrBuffer, maxStr, offsetPrompt, sizeStrAddr
     ;Preserve registers
     push      edx
     push      ecx

     displayString  offsetPrompt

     ;Place address of buffer for string read in edx register
     mov       edx, offsetArrBuffer

     ;Set ecx register to maximum number of character read from user input.
     mov       ecx, maxStr

     ;Read user input
     call      ReadString

     mov       sizeStrAddr, eax

     ;Restore registers
     pop       ecx
     pop       edx
ENDM

;Display string macro receives address of string to print
displayString  MACRO    offsetString
     ;Preserve registers
     push      edx

     ;Move address of string to display into edx register
     mov       edx, offsetString
     call      WriteString

     ;Restore registers
     pop       edx
ENDM

.const
MAX_LIMit      EQU      <57>                                              ;Constant for upper limit of number of generated random numbers
MIN_LIMIT      EQU      <48>                                              ;Constant for lower limit of number of generated random numbers

.data
userInputStr   BYTE      50 DUP(?)                                        ;Hold string of up to 50 bytes from user input.
intConvertStr  BYTE      11 DUP(?)                                        ;Holds string up to 11 bytes for conversion from int to string value
inputStrSize   DWORD     0                                                ;Holds size of string read from user during input for validation
intArrSize     DWORD     10                                               ;Holds current size of integer array of values entered by user.
userIntArray   DWORD     10 DUP(?)                                        ;Uninitialized array to hold integers from user input.
runSubtotal    DWORD     0                                                ;Keeps track of a running subtotal as program reads and adds strings to arrays

progTitle      BYTE      "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
inOutIntro_1   BYTE      "Written by: Justin Tromp", 13, 10, 13, 10, 0
inOutIntro_2   BYTE      "Please provide 10 signed or unsigned decimal integers.", 13, 10, 0
inOutIntro_3   BYTE      "Each number needs to be small enough to fit inside a 32 bit register.", 13, 10, 0
inOutIntro_4   BYTE      "After you have finished inputting the raw numbers I will display a list", 13, 10, 0
inOutIntro_5   BYTE      "of the integers, their sum, and their average value.", 13, 10, 0
extraCred_1    BYTE      "EC #1: ReadVal and WriteVal procedures are called recursively instead of using loops.", 13, 10, 0
extraCred_2    BYTE      "EC #2: Each line of user input is numbered and a running subtotal of all values entered is displayed.", 13, 10, 0
extraCred_3    BYTE      "EC #3: Not specifically listed, but program handles leading zeros outside of requirement.", 13, 10, 0

arrOutputDesc  BYTE      "You entered the following numbers: ", 13, 10, 0

sumTitle       BYTE      "The sum of these numbers is: ", 0
subtotalTitle  BYTE      "The subtotal so far is: ", 0
avgTitle       BYTE      "The average of these numbers is: ", 0
goodbyeMsg     BYTE      "Thanks for playing!", 0

numPrompt      BYTE      "Please enter an unsigned integer value: ", 0
numErrPrompt   BYTE      "Please try again: ", 0
validateMsg    BYTE      "ERROR: You did not enter a valid unsigned number or your number was too big.", 13, 10, 0
inputValid     DWORD     0                                                 ;Variable to hold boolean value of 1 or 0 from validate procedure
partitionInd   DWORD     0                                                 ;Variable to hold partition index for QuickSort algorithm

.code
main PROC
     ;Push offsets of strings to print to terminal to stack for introduction procedure.
     push      OFFSET extraCred_3
     push      OFFSET extraCred_2
     push      OFFSET progTitle
     push      OFFSET inOutIntro_1
     push      OFFSET inOutIntro_2
     push      OFFSET inOutIntro_3
     push      OFFSET inOutIntro_4
     push      OFFSET inOutIntro_5
     push      OFFSET extraCred_1
     ;Calls procedure to display programmer and program information.
     call      introduction


     ;Push value needed in procedure to stack.
     push      OFFSET subtotalTitle
     push      OFFSET runSubtotal
     push      OFFSET userIntArray
     push      OFFSET inputStrSize
     push      OFFSET numErrPrompt
     push      OFFSET userInputStr
     push      OFFSET inputValid
     push      OFFSET validateMsg
     push      OFFSET numPrompt
     push      intArrSize
     ;Calls procedure to get user input for number of random numbers and validates
     ;entry through validate sub-procedure. Converts strings received by user to
     ;integer values and stores in array passed to procedure.
     call      readVal


     ;Push values/addresses needed in procedure to stack (address of array to convert/print, address of string to hold converted
     ;integer values, and value of size of array to convert to string/print)
     push      OFFSET arrOutputDesc
     push      OFFSET intConvertStr
     push      OFFSET userIntArray
     push      intArrSize
     ;Display sorted list to user on screen (converts int values from array to string values and prints strings to terminal)
     call      writeVal

     ;Push values/addresses needed in procedure to stack (address of string array for sum title, address of array to calculate 
     ;sum of and value of array size to calculate sum of)
     push      OFFSET sumTitle
     push      OFFSET userIntArray
     push      intArrSize
     ;Display sorted list to user on screen
     call      displaySum

     ;Push values/addresses needed in procedure to stack (address of string array for sum title, address of array to calculate 
     ;sum of and value of array size to calculate sum of)
     push      OFFSET avgTitle
     push      OFFSET userIntArray
     push      intArrSize
     ;Display sorted list to user on screen
     call      displayAvg


     exit                                                             ;Exit to operating system

main ENDP

;###########################################################################
;Name: introduction
;Description: Procedure to introduce programmer and program function to user.
;Receives: OFFSET of 8 strings on stack to output to user on screen.
;[ebp+40] = Program EC #3
;[ebp+36] = Program EC #2
;[ebp+32] = Program title
;[ebp+28] = Programmer name
;[ebp+24] = Program functionality part 1
;[ebp+20] = Program functionality part 2
;[ebp+16] = Program functionality part 3
;[ebp+12] = Program functionality part 4
;[ebp+8] = Program EC #1
;Post-conditions/Return: No values returned. String output to terminal.
;Pre-conditions: Must have string variable OFFSETS passed on stack from calling
;function in order above. 
;Registers Changed: None changes (only edx changed within macro)
;###########################################################################

introduction     PROC

     ;Set up stack frame
     push      ebp
     mov       ebp, esp

;Prints initial introduction to user with my name, program title, and extra credit options completed
programIntro:
     ;Print title/programmer name
     displayString [ebp+32]                                                    ;[ebp+32] is set to title offset
     call      CrLf

     ;Print  program function and requirements to screen for user
     displayString [ebp+28]
     displayString [ebp+24]
     displayString [ebp+20]
     displayString [ebp+16]
     displayString [ebp+12]
     
     ;Output extra credit completed to screen
     displayString [ebp+8]
     displayString [ebp+36]
     displayString [ebp+40]
     call      CrLf

     pop       ebp
     ret       36
introduction   ENDP


;###########################################################################
;Name: readVal
;Description: Procedure works by prompting user for unsigned value input, which
;is read in as a string and converted to an integer to be placed in an array after
;validation. If user incorrectly enters a value that is not an integer or is too large,
;procedure will re-prompt for input. Value entered must consist of only unsigned integers.
;Procedure calls sub-procedures convertInt and validateInt. Function is called recursively
;to read values and validate.
;Receives: 9 address values passed on stack
;[ebp+8]  = Address of intArrSize for size of integer array
;[ebp+12] = Address of string array, requesting input from user (numPrompt)
;[ebp+16] = Address of string array, error message (validateMsg)
;[ebp+20] = Address of inputValid variable.
;[ebp+24] = Address of userInputStr to accept string value from user input
;[ebp+28] = Address of numErrPrompt, used with readString macro after error occurs for re-entry
;[ebp+32] = Address of inputStrSize to store size of string input from user with getString
;[ebp+36] = Address of userIntArray to store converted integer values in
;[ebp+40] = Address of integer value variable to keep running subtotal for display
;[ebp+44] = Address of string for subtotal title display
;Post-conditions/returns: Returns array filled with 10 validated 32-bit unsigned integer values.
;String array used to accept user input and inputValid variables are also changed, but they are not
;used. Only aspect returned for use is the array of integers at ebp+36.
;Pre-conditions: Addresses must be passed on stack in order above for user input and validation
;to function properly.
;Registers Changed: edx, eax, ebx, ecx (not including edp, esi, and edi)
;All registers are saved prior to starting procedure and returned to original
;values when procedure ends.
;###########################################################################


readVal       PROC
     ;Set up stack frame
     push      ebp
     mov       ebp, esp
     ;Save all registers
     pushad

     ;Set esi to array to add validated integer values to
     mov       esi, [ebp+36]

     ;Store address of intArrSize in ecx
     mov       ecx, [ebp+8]
     jmp       getUserInput

;Request/Accept input from user for integer value in string format - Please try again printed as prompt
getUserInputInvalid:
     ;Display error message
     displayString [ebp+16]

     ;Display number of current input line (Number of integers already accepted, plus the current value)
     mov       eax, 11
     sub       eax, [ebp+8]
     call      WriteDec
     ;Write character '.' and ' ' for proper alignment
     mov       al, 46
     call      WriteChar
     mov       al, 32
     call      WriteChar

     ;Accept user input for value to add (reads string values up to 50 characters long)
     getString [ebp+24], 50, [ebp+28], [ebp+32]
     jmp       validateInput

;Request/accept input from user for integer value in string format - Regular prompt for input
getUserInput:                
     ;Display number of current input line (Number of integers already accepted, plus the current value)
     mov       eax, 11
     sub       eax, [ebp+8]
     call      WriteDec
     ;Write characters '.' and ' ' for proper output
     mov       al, 46
     call      WriteChar
     mov       al, 32
     call      WriteChar

     ;Accept user input for value to add (reads string values up to 50 characters long)
     getString [ebp+24], 50, [ebp+12], [ebp+32]

;Validate user input to ensure that all values entered are integers ("within ASCII integer range) by passing to validateInt
validateInput:
     ;Push address of size of string input variable
     push      [ebp+32]
     ;Push address of string inputted by user for validation
     push      [ebp+24]
     ;Push address of inputValid to validate procedure (testing for non-digits)
     push      [ebp+20]
     ;Call validate procedure to make sure string is a valid integer
     call      validateInt   

     ;Retreive returned validate value
     mov       edi, [ebp+20]
     mov       edx, [edi]

     ;Check inputValid for true or false (0 is false, 1 is true)
     cmp       edx, 0
     je        getUserInputInvalid

;Convert user string input to integer value after validation
convertInput:
     ;Push address of inputValid to hold boolean value for valid input (testing for size of integer)
     push      [ebp+20]
     ;Push address of current array position to add converted integer to
     push      esi
     ;Push size of string input variable
     push      [ebp+32]
     ;Push address of string inputted by user for validation
     push      [ebp+24]
     ;Call string conversion procedure to convert from string to integer
     call      convertInt

;Check inputValid (ebp+20) to see if integer value was too large. If too large, request new input from user.
integerSizeCheck:
     mov      edi, [ebp+20]
     mov      edx, [edi]                                              ;Set edx to boolean inputValid value
     cmp      edx, 0
     je       getUserInputInvalid
     cmp      ecx, 1
     je       endInput

;Add value to subtotal after being verified and added to array and then display value to user.
displaySubtotal:
     ;Save registers used in subtotal section
     push     eax
     push     edi

     ;Display subtotal title to user
     displayString    [ebp+44]

     ;Move subtotal variable address to edi
     mov      edi, [ebp+40]

     ;Copy last value added to array to eax
     mov      eax, [esi]

     ;Add running subtotal to last value added to array
     add      eax, [edi]

     ;Display current subtotal
     call     WriteDec

     ;Move total subtotal into edi address location for running subtotal
     mov      [edi], eax

     ;Restore registers
     pop      edi
     pop      eax


;End of loop after user input/validation. Loop again if more values are needed.
endReadLoop:
     add       esi, 4                                                 ;Increment to next position in array
     call      CrLf
     dec       ecx

     ;Push value needed in procedure to stack (address of numRandom for user input and address of string output)
     push      [ebp+44]                                               ;Address of subtotal title
     push      [ebp+40]                                               ;Address of subtotal value variable place
     push      esi                                                    ;Current address of array to add value to
     push      [ebp+32]                                               ;Address of userIntArray to store converted integers in
     push      [ebp+28]                                               ;Address of numErrPrompt to display error message ("Try Again: ")
     push      [ebp+24]                                               ;Address of userInputStr to accept string value from user input
     push      [ebp+20]                                               ;Address of inputValid variable to store boolean valid or invalid value
     push      [ebp+16]                                               ;Address of string error message (validateMsg)
     push      [ebp+12]                                               ;Address of string, prompting user for number input (numPrompt)
     push      ecx                                                    ;Number of values left to add in array (decrement from array size)
     ;Calls procedure to get user input for number of random numbers and validates
     ;entry through validate sub-procedure.
     call      readVal
     
;Restore stack and return
endInput:
     ;Restore all registers
     popad
     pop       ebp
     ret       40

readVal       ENDP

;###########################################################################
;Name: convertInt
;Description: Procedure works to convert array of characters (string) all within ASCII
;value range for integer representations to an integer value. The converted string value
;is checked to ensure it does not go out of bounds for a 32-bit representation for an
;unsigned integer and is stored in an array. If it does exceed the register and string value
;is deemed to be invalid, inputValid memory location is set to invalid and calling procedure
;will re-prompt user for input.
;Receives: 4 address values are passed by stack
;[ebp+20] = Address of inputValid to hold boolean value (1 for valid, 0 for invalid input)
;[ebp+16] = Address of array position to integer value to.
;[ebp+12] = Address of size of string variable.
;[ebp+8] = Address of string passed to validate all values are integers.
;Post-conditions/returns: Procedure returns a value in [ebp+20] (inputValid) indicating
;whether or not integer is correct/within boundaries. If procedure deems integer value
;to be valid, value is added to [ebp+16] current integer array position and array is returned
;with value.
;Pre-conditions: All conditions on stack must be met for conversion to work properly and 
;in the order above.
;Registers Changed: edx, ebx, ecx, eax (as well as esi/edi for array manipulations)
;All register values are saved at procedure start and restored at end of procedure.
;###########################################################################


convertInt     PROC

     ;Set up stack frame
     push      ebp
     mov       ebp, esp

     ;Save registers
     pushad

     ;Set up registers for procedure
     mov       edi, [ebp+16]                                               ;Set esi to address of array to add converted value to
     mov       esi, [ebp+8]                                                ;Set edi to address of string array to convert
     mov       ecx, [ebp+12]                                               ;Set ecx counter to size of string to convert
     mov       edx, 1                                                      ;Set edx to 1 for multiplier of string character position for conversion
     mov       ebx, 0                                                      ;Set ebx to 0 to clear register
     ;Set esi register to end of string (ecx register hold length of string)
     dec       ecx
     add       esi, ecx
     inc       ecx
     ;Set direction flag to 1 for string primitives movements
     std

;Convert current character in string array to integer value
convertCharacters:
     mov       eax, 0
     ;Place ASCII character in eax register of current string position and subtract 48 from ASCII value to get integer
     ;representation.
     lodsb
     sub       eax, 48

     ;Save edx register value for multiplier
     push      edx

     ;Multiply character integer value by place position
     mul       edx

     ;Pop edx register value back in place
     pop       edx

     ;Check for carry, if carry exists, value is too large
     jc        inputSizeInvalid

     ;Check to see if new multiplier needs to be found, if yes continue past
     cmp       ecx, 1
     jb        endConvertLoop

     ;Save eax register value holding integer to add to running total
     push      eax

     ;Find next edx multiplier by multiplying current edx value by 10 (1, 10, 100, 1000, etc...)
     mov       eax, 10
     mul       edx
     mov       edx, eax
     
     ;Restore eax register value holding integer to add to running total
     pop       eax

;End of conversion loop, check if looping again
endConvertLoop:
     ;Add value from string to current running total in ebx register
     add       ebx, eax

     ;If carry occurred, exit loop
     jc        inputSizeInvalid

     ;Check to see if current value is larger than 1000000000, if so and there is another loop, it will not fit in 32-bit register
     ;Check loop number, if greater than 1, jump to value comparison.
     ;Check size of current value, if less then continue
     cmp       ebx, 1000000000
     jb        endLoop
     ;Check loop counter
     cmp       ecx, 1
     ja        inputSizeInvalid

endLoop:
     ;Loop until the end of the string
     loop      convertCharacters

;Add converted character to array
addToArray:
     ;Add value in ebx register to array
     mov       [edi], ebx

     ;Set boolean value to 1 for valid
     mov       edi, [ebp+20]
     mov       ecx, 1
     mov       [edi], ecx

     ;Move to endConversion section, input is valid (skip invalid section)
     jmp       endConversion

;Loop through remainder of string (since any additional value other than 0 means that integer is too large)
checkRemainingString:
     ;If ASCII value is not 0, input is invalid at this point
     cmp       eax, 0
     jne       inputSizeInvalid

     ;Load next position in string for ASCII value and subtract 48 to give integer value
     lodsb
     sub       eax, 48

     ;Loop through remainder of string values, if nothing other than 0's are found, add value to array.
     loop      checkRemainingString
     jmp       addToArray

;Input size is determined to be invalid, set inputValid boolean value to 0
inputSizeInvalid:
     mov       edi, [ebp+20]
     mov       ecx, 0
     mov       [edi], ecx                                                                    ;Set boolean value to 0 for false or invalid

;End of conversion procedure
endConversion:
     ;Restore registers
     popad

     ;Return stack values and return from procedure
     pop       ebp
     ret       16

convertInt     ENDP
 
;###########################################################################
;Name: validateInt
;Description: Procedure works by traversing through string read from user input and
;compares ASCII code value of each position in string to ensure that all values are
;within the integer ASCII code range. If not within range return 0 to calling
;procedure. If within range, set return value to true/return 1.
;Receives: Three address values are passed from calling procedure by stack.
;[ebp+16] = Address of size of string variable.
;[ebp+12] = Address of string passed to validate all values are integers.
;[ebp+8] = Address of inputValid variable for storing boolean integer value.
;Constants for upper and lower user input limits are used as global variables.
;Post-conditions/returns: 0 or 1 is returned in [edp+8] space to calling procedure to
;indicate validity of string for integer conversion.
;Pre-conditions: Space for return boolean value and integer value to validate must
;be passed through stack to procedure. Two constant global variables should be
;properly declared for upper and lower limits of ASCII integer table. These should be
;pushed onto stack in order above for functionality.
;Registers Changed: ebx, eax, ecx (edi for boolean manipulation and esi for string array comparisons)
;All registers saved at procedure start and restored at procedure end.
;###########################################################################


validateInt    PROC

     ;Set up stack frame
     push      ebp
     mov       ebp, esp

     ;Save registers
     pushad

     ;Set up registers for procedure
     mov       esi, [ebp+12]                                               ;Set esi to string array
     mov       edi, [ebp+8]                                                ;Set edi to address of inputValid
     mov       ecx, [ebp+16]                                               ;Set ecx counter to size of string to check

;If string size is 0, string is not valid.
checkStringSize:
     cmp       ecx, 0
     jbe       stringNotValid

checkStringValues:
     ;Select for individual character in string
     movzx     eax, BYTE PTR [esi]
     cmp       eax, MIN_LIMIT
     jae       valueAboveMin
     jmp       stringNotValid

;Value is equal to or larger than 48 for ASCII integer range
valueAboveMin:
     cmp       eax, MAX_LIMIT
     jbe       checkLoopCount

;If string character at current position is not an integer value from 0 through 9, set input valid to 0 and exit loop.
stringNotValid:
     mov       ebx, 0
     jmp       endValidate

;Increase esi address by 1 to move to next character in string and loop if not at 0.
checkLoopCount:
     inc       esi
     loop      checkStringValues
     mov       ebx, 1                                                           ;Set boolean value to 1 as string did is valid


;End jump point for invalid input. End of validation. Return stack values.
endValidate:
     ;Move value in ebx to inputValid
     mov       [edi], ebx

     ;Return registers
     popad
     pop       ebp
     ret       12

validateInt    ENDP


;###########################################################################
;Name: writeVal
;Description: Procedure takes array of integers and converts values to ASCII characters.
;Upon conversion, characters are placed into string array and are printed as a screen
;to terminal. writeVal is called recursively to print all array values to terminal.
;Receives: Three stack values passed to procedure.
;[ebp+16] = Address of string array to store converted ASCII values in
;[ebp+12] = Address of first element of array of integers to be converted and printed
;[ebp+8] = Number of total values in array to be printed
;Post-conditions/returns: No values are returned to calling procedure. Only printed to screen.
;Although the string array is changed throughout conversion/writing process.
;Pre-conditions: All elements above must be passed on stack in order for procedure
;to work properly.
;Registers Changed: eax, edx, ebx, ecx
;###########################################################################

writeVal      PROC

     ;Set up stack frame
     push      ebp
     mov       ebp, esp

     ;Save registers
     pushad

     ;If this is the first recursive run, display title, otherwise jump past title display
     mov       ecx, [ebp+8]                                                     ;Set ecx to number of values to print in array
     cmp       ecx, 10
     jne       startRec
     ;Print out title of array display with line spacing
     call      CrLf
     displayString  [ebp+20]
     
     ;Clear direction flag
     cld

startRec:
     ;Set up registers for procedure
     mov       esi, [ebp+12]                                                    ;Set esi to address of array to print to screen
     mov       edi, [ebp+16]                                                    ;Set edi to address of string array to hold ASCII values
     mov       ecx, [ebp+8]                                                     ;Set ecx to number of values to print in array
     mov       eax, [esi]                                                       ;[esi] is current total integer value of current array position
     mov       ebx, 1000000000                                                  ;Set divisor to move from largest to smallest for conversion

     ;Check initial eax value, if 0 to start with, add to first position in edi and jump to display value. No need to do conversion calculations.
     mov       edx, 0
     cmp       eax, 0
     je        addOnlyZero
     cmp       ebx, eax
     jbe       convertIntToStr
     jc        convertIntToStr

;Reduce max possible divisor to value that divises given value in eax (current array integer value)
adjustDivisorFirst:
     push      eax
     ;Find new divisor
     mov       edx, 0
     mov       eax, ebx
     mov       ebx, 10
     div       ebx
     mov       ebx, eax
     pop       eax

     
     ;Loop until first addable value is encountered and begin converting integers to string ASCII characters
     cmp       ebx, eax
     ja        adjustDivisorFirst
     jmp       convertIntToStr

;Adjust divisor by dividing by ten to find next value to convert to string
adjustDivisor:
     push      edx
     ;Find new divisor
     mov       edx, 0
     mov       eax, ebx
     mov       ebx, 10
     div       ebx
     mov       ebx, eax
     pop       eax

     ;Compare total integer value left with divisor, if integer value left to add to string is less than divisor, add zero to string
     cmp       eax, ebx
     jb        addZeroToString

;Convert integer at current array position to string value
convertIntToStr:
     mov       edx, 0                                                           ;Set to 0 for division to mitigate overflow
     div       ebx
     jmp       addToStringArr

;If a zero space is detected, add zero to string 
addZeroToString:
     push      eax
     mov       eax, 0
     add       eax, 48
     ;Add 0 ASCII value to string
     stosb
     pop       eax


     ;Compare value in ebx register to 1, if the value is larger, adjust the divisor again, if not print value
     mov       edx, eax
     cmp       ebx, 1
     ja        adjustDivisor
     jmp       printVal

;If there is a value to add, add to position in string array
addToStringArr:
     ;Add 48 to eax value to convert to ASCII decimal value and add to string array
     add       eax, 48

     ;Store ASCII int value in string array
     stosb

     ;Move to next position in array
     cmp       ebx, 1
     jg        adjustDivisor
     jmp       printVal

;If there is only zero present, add only zero and exit procedure
addOnlyZero:
     ;Add 48 to eax value to convert to ASCII decimal value and add to string array
     add       eax, 48

     ;Store ASCII int value in string array
     stosb

;Output string value just converted from integer to screen
printVal:
     ;Right before output, place 0 terminus at end of string in case previous string was larger and has leftover characters
     mov       al, 0
     stosb

     ;Output current array position value
     displayString [ebp+16]

     ;Check for end of array, if at end of array do not print comma/space
     cmp       ecx, 1
     je        setNextPrint

     ;Print comma followed by space for readability
     mov       al, 44
     call      WriteChar
     mov       al, 32
     call      WriteChar

setNextPrint:
     ;Move array pointer forward to next value and loop
     add       esi, 4
     ;If number of values to print is equal to 1, all values have been printed, end recursion [ebp+8] in ecx register
     cmp       ecx, 1
     je        endDisplay
     dec       ecx
     
     ;Push values needed in procedure to stack (address of title of values, address of array and numRandom for number
     ;of values in the array) for writeVal recursive call.
     push      [ebp+20]
     push      [ebp+16]                                                                      ;Address of string array for holding converted integer values to ASCII
     push      esi                                                                           ;Address of current value to print on next call
     push      ecx                                                                           ;Push value of number of values left to print
     ;Display sorted list to user on screen
     call      writeVal

;Restore cursor position, stack, and return
endDisplay:
     ;Restore registers
     popad

     ;Restore stack/return
     pop       ebp
     ret       16

writeVal      ENDP

;###########################################################################
;Name: displaySum
;Description: Procedure displays sum of all values currently in array passed
;as parameter on stack by address.
;Receives: Two addresses and one value passed to procedure on stack.
;[ebp+16] = Address of string array containing sum title output
;[ebp+12] = Address of array containing integer values
;[ebp+8] = Number of values present in array
;Post-conditions/returns: No values are returned to calling procedure.
;Pre-conditions: All elements above must be passed on stack in order for procedure
;to work properly.
;Registers Changed: eax, ebx, ecx (esi used with array manipulations to gather
;values to add together for sum)
;All registers saved and restored in procedure.
;###########################################################################

displaySum     PROC
     
     ;Set up stack frame
     push      ebp
     mov       ebp, esp

     ;Save registers
     pushad

     ;Move to new line
     call      CrLf

     ;Set up values in respective registers
     ;Move address of array of integers to esi and number of values in array to ecx
     mov       esi, [ebp+12]
     mov       ecx, [ebp+8]
     mov       eax, 0                                                                          ;Set eax to 0 for addition
     mov       ebx, 0                                                                          ;Set ebx as a counter for position in array

;Determine sum of all values in array
calculateSum:
     add       eax, [esi+(ebx*4)]

     ;Move to next array position
     inc       ebx

     mov       edx, [esi]

     ;Loop for number of values in array
     loop      calculateSum

;Display calculated sum on screen (in eax)
printSum:
     ;Output title of sum output
     displayString  [ebp+16]

     ;Write out sum
     call      WriteDec
     call      CrLf

     ;Restore registers
     popad

     ;Restore stack/return
     pop       ebp
     ret       12

displaySum     ENDP

;###########################################################################
;Name: displayAvg
;Description: Procedure calculates and displayes average of all integers in
;array passed by address to procedure.
;Receives: Two addresses and one value passed to procedure on stack.
;[ebp+16] = Address of string array containing sum title output
;[ebp+12] = Address of array containing integer values
;[ebp+8] = Number of values present in array
;Post-conditions/returns: No values are returned to calling procedure.
;Pre-conditions: All elements above must be passed on stack in order for procedure
;to work properly.
;Registers Changed: eax, ebx, ecx, edx (esi used with array manipulations to gather
;values to add together for sum)
;All registers saved and restored in procedure.
;###########################################################################

displayAvg     PROC
     
     ;Set up stack frame
     push      ebp
     mov       ebp, esp

     ;Save registers
     pushad

     ;Set up values in respective registers
     ;Move address of array of integers to esi and number of values in array to ecx
     mov       esi, [ebp+12]
     mov       ecx, [ebp+8]
     mov       eax, 0                                                                          ;Set eax to 0 for addition
     mov       ebx, 0                                                                          ;Set ebx as a counter for position in array
     mov       edx, 0                                                                          ;Clear edx by setting to 0

;Determine sum of all values in array
calculateTotSum:
     ;Add values from array together
     add       eax, [esi+(ebx*4)]

     ;Move to next array position
     inc       ebx

     ;Loop for number of values in array
     loop      calculateTotSum

;Calculate the average value from the sum calculated above
calculateAvg:
     ;Set edx to 0 for clean slate
     mov       edx, 0

     ;Set ebx register to number of values in array
     mov       ebx, [ebp+8]

     ;Divide eax value (total sum) by number of values in array
     div       ebx

;Display calculated average on screen (in eax register)
printAvg:
     ;Output title of sum output
     displayString  [ebp+16]

     ;Write out sum
     call      WriteDec
     call      CrLf

     ;Restore registers
     popad

     ;Restore stack/return
     pop       ebp
     ret       12

displayAvg     ENDP


END main