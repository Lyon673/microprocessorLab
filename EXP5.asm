DSEG    SEGMENT
        NUM DW 0
        ONENUM DB 4 DUP(0)
        CORRECTLETTER DB '0123456789ABCDEFabcdef$'
        DISPLAYARRAY DB 12 DUP(?)
        

        QUERYIMFORMATION DB 'Please input a 4-bit hexadecimal number: ',0DH,0AH,24H
        ANWSERIMFORMATION DB 'ABCDH=$'

        ENDIMFORMATION DB 0DH,0AH,24H
        WRONGLETTERERROR DB 0
DSEG    ENDS

SSEG    SEGMENT PARA STACK 
        DW  256 DUP(?)
SSEG    ENDS

PRINT MACRO STRING
        MOV AH,09H
        LEA DX,STRING
        INT 21H
ENDM

CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG
.386

BEGIN:
        CALL EXP5
        MOV AH,4CH
        INT 21H

PUBLIC EXP5
EXP5 PROC FAR
        PUSH DS

        MOV AX,DSEG
        MOV DS,AX
        MOV ES,AX

        MOV CX, 4
        MOV SI, 0

        PRINT QUERYIMFORMATION
        MOV SI, 0
INPUT:

        MOV AH, 07H
        INT 21H

        MOV DI, 0

CHECK:
        CMP AL, CORRECTLETTER[DI]
        JZ PASSLETTER
        INC DI
        CMP DI, 22
        JNZ CHECK
        JMP INPUT

PASSLETTER:
        MOV DL, AL
        MOV AH, 02H
        INT 21H
        MOV ONENUM[SI],AL
        INC SI
        LOOP INPUT

; 将输入的字符串计算为十进制放在NUM中
        MOV CX, 4
        MOV DI, 0
CALCULATE:
        MOV AX, NUM
        MOV DX, 16
        MUL DX
        MOV DH, 0
        MOV DL, ONENUM[DI]
        INC DI

        ADD AX, DX
        SUB AX, 30H
        CMP DX, 39H
        JBE NUMBER
        SUB AX, 7
        CMP DX, 46H
        JBE NUMBER
        SUB AX, 32
NUMBER:
        MOV NUM, AX
        LOOP CALCULATE

; 显示十进制字符串

        MOV DX, '$'
        PUSH DX
        PRINT ENDIMFORMATION
        PRINT ANWSERIMFORMATION
        MOV AX, NUM
DISPLAY:
        MOV DX, 0
        MOV BX, 10
        DIV BX
        PUSH DX
        CMP AX, 0
        JNZ DISPLAY

NOTOVER:
        POP DX
        CMP DX, '$'
        JZ OVER
        ADD DL, 30H
        MOV AH, 02H
        INT 21H
        JMP NOTOVER


OVER:
        POP DS
        RET
EXP5 ENDP

CSEG    ENDS
        END  BEGIN