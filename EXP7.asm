EXTRN EXP3:FAR
EXTRN EXP4:FAR 
EXTRN EXP4_2:FAR
EXTRN EXP5:FAR 
EXTRN EXP6:FAR

DSEG    SEGMENT
        SEGMENTINFORMATION DB '-----------------------------------------------------------------------------$'
        ENTERINFORMATION0 DB 'Instructions Table:',0DH,0AH
        ENTERINFORMATION1 DB '1.sort',0DH,0AH
        ENTERINFORMATION2 DB '2.dynamic title',0DH,0AH
        ENTERINFORMATION3 DB '3.draw circle',0DH,0AH
        ENTERINFORMATION4 DB '4.Hexadecimal to decimal',0DH,0AH
        ENTERINFORMATION5 DB '5.keyboard',0DH,0AH 
        ENTERINFORMATION6 DB 'q.''q'' for quit',0DH,0AH    
        SEGMENTINFORMATION1 DB '-----------------------------------------------------------------------------',0DH,0AH               
        ENTERINFORMATION DB 'Please enter the experiment program you want to run :$'
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
        PRINT ENDIMFORMATION
        PRINT SEGMENTINFORMATION
        MOV AL, 0
        PRINT ENDIMFORMATION
        PRINT ENTERINFORMATION0
        MOV AH, 07H
        INT 21H
        PRINT ENDIMFORMATION

        CMP AL, '1'
        JZ FUNC1

        CMP AL, '2'
        JZ FUNC2

        CMP AL, '3'
        JZ FUNC3

        CMP AL, '4'
        JZ FUNC4

        CMP AL, '5'
        JZ FUNC5

        CMP AL, 'q'
        JZ OVER

        JMP START

FUNC1:
        CALL EXP3
        JMP START

FUNC2:
        CALL EXP4_2
        JMP START

FUNC3:
        CALL EXP4
        MOV AX, 0600h    
        MOV BH, 00h      
        MOV CX, 0        
        MOV DX, 4F9Fh    
        INT 10h          

        JMP START

FUNC4:
        CALL EXP5
        JMP START

FUNC5: 
        CALL EXP6
        JMP START



OVER:
        MOV AH,4CH
        INT 21H
CSEG    ENDS
        END  BEGIN