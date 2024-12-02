DSEG    SEGMENT
        MUSIC DW 262,294,330,349,392,440,494
        CORRECTLETTER DB '1234567q$'
        FREQUENCY DW 500
       
DSEG    ENDS

SSEG    SEGMENT PARA STACK 
        DW  256 DUP(?)
SSEG    ENDS


CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG
.386
BEGIN:  MOV AX,DSEG
        MOV DS,AX

        
        MOV AL, 10110110B
        OUT 43H, AL

INPUT:
        MOV AH, 07H
        INT 21H
        
        MOV DI, 0
CHECK:
        CMP AL, CORRECTLETTER[DI]
        JZ PASSLETTER
        ADD DI, 1
        CMP DI, 8
        JNZ CHECK
        JMP INPUT

PASSLETTER:
        CMP AL, 'q'
        JZ RETURN

        PUSH DX
        MOV AH, 0
        MOV DI, AX
        SUB DI, 31H
        SHL DI, 1
        MOV DX, MUSIC[DI]
        MOV FREQUENCY, DX
        POP DX

        CALL SETFRE
        CALL SOUND
        CALL CLEAR
        JMP INPUT

RETURN:
        MOV AH,4CH
        INT 21H

SETFRE PROC NEAR

        MOV		DX, 12H
		MOV		AX, 34DEH
		MOV		CX, FREQUENCY
		DIV		CX
		OUT		42H, AL
		MOV		AL, AH
		OUT		42H, AL

        RET
SETFRE ENDP
    
SOUND PROC NEAR
 
        IN AL, 61H
        OR AL, 03H
        OUT 61H, AL


        PUSH CX
        MOV CX, 100

TIMEDELAY1:
        PUSH CX
        MOV CX, 40000

TIMEDELAY2:
        NOP
        LOOP TIMEDELAY2
        POP CX
        LOOP TIMEDELAY1
        POP CX
       
        IN AL, 61H
        AND AL, 0FCH
        OUT 61H, AL

        RET

SOUND ENDP

CLEAR PROC NEAR
        MOV AH, 0CH
        MOV AL, 0
        INT 21H

        RET
CLEAR ENDP

CSEG    ENDS
        END  BEGIN