DSEG    SEGMENT
        MUSIC DW 262,294,330,349,392,440,494,524
        CORRECTLETTER DB '12345678q$'
        FREQUENCY DW 500
        LASTKEY DB 0

        LYON DB 'LYON$'
       
DSEG    ENDS

SSEG    SEGMENT PARA STACK 
        DW  256 DUP(?)
SSEG    ENDS


CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG
.386
BEGIN:
        CALL EXP6
        MOV AH,4CH
        INT 21H



PUBLIC EXP6
EXP6 PROC FAR
        PUSH DS
        MOV AX,DSEG
        MOV DS,AX

        
        MOV AL, 10110110B
        OUT 43H, AL

INPUT:
        MOV AH, 01H
        INT 16H
        JZ NOKEY
        JMP HAVEKEY

NOKEY:
        CALL DELAY
        ; END
        IN AL, 61H
        AND AL, 0FCH
        OUT 61H, AL
        JMP INPUT


HAVEKEY:
        ;CMP AL, LASTKEY
        ;JZ INPUT
        ;MOV LASTKEY,AL
        
        MOV DI, 0
CHECK:
        CMP AL, CORRECTLETTER[DI]
        JZ PASSLETTER
        ADD DI, 1
        CMP DI, 9
        JNZ CHECK
        MOV AH, 07H
        INT 21H
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

        ; END
        IN AL, 61H
        AND AL, 0FCH
        OUT 61H, AL

        ; START
        IN AL, 61H
        OR AL, 03H
        OUT 61H, AL



        MOV AH, 07H
        INT 21H 


        ;CALL CLEAR
        JMP INPUT

RETURN:
        CALL CLEAR
        MOV AL, 0
        POP DS
        RET
EXP6 ENDP

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
    
DELAY PROC NEAR
        PUSH CX
        MOV CX, 15

TIMEDELAY1:
        PUSH CX
        MOV CX, 40000

TIMEDELAY2:
        NOP
        LOOP TIMEDELAY2
        POP CX
        LOOP TIMEDELAY1
        POP CX
       
        RET

DELAY ENDP

CLEAR PROC NEAR
        MOV AH, 0CH
        MOV AL, 0
        INT 21H

        RET
CLEAR ENDP

CSEG    ENDS
        END  BEGIN