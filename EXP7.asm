EXTRN EXP3:FAR
EXTRN EXP4:FAR 
EXTRN EXP5:FAR 
EXTRN EXP6:FAR

DSEG    SEGMENT
        ENTERINFORMATION DB 'Please enter the experiment program you want to run (from 3 to 6,q for quit):$'
        ENDIMFORMATION DB 0DH,0AH,24H
        LYON DB 'LYON$'
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
        MOV AX,DSEG
        MOV DS,AX


START:
        
        MOV AL, 0
        PRINT ENDIMFORMATION
        PRINT ENTERINFORMATION
        MOV AH, 07H
        INT 21H
        PRINT ENDIMFORMATION
        PRINT LYON

        CMP AL, '3'
        JZ FUNC3

        CMP AL, '4'
        JZ FUNC4

        CMP AL, '5'
        JZ FUNC5

        CMP AL, '6'
        JZ FUNC6

        CMP AL, 'q'
        JZ OVER

        JMP START

FUNC3:
        CALL EXP3
        JMP START

FUNC4:
        CALL EXP4
        JMP START

FUNC5:
        CALL EXP5
        JMP START

FUNC6: 
        CALL EXP6
        PRINT LYON
        JMP START



OVER:
        MOV AH,4CH
        INT 21H
CSEG    ENDS
        END  BEGIN