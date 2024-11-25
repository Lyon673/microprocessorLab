DSEG    SEGMENT
        ONENUM DB  20,0,20 DUP('$')
        NUM DW 0
        NEGATIVENUM DB  ?
        CORRECTLETTER DB '0123456789ABCDEF$'
        DISPLAYARRAY DB 12 DUP(?)
        

        WRONGLETTERIMFORMATION1 DB 'ERROR: The input number is overflow.',0DH,0AH,24H
        WRONGLETTERIMFORMATION2 DB 'ERROR: The first effect letter of the input number is 0.',0DH,0AH,24H
        WRONGLETTERIMFORMATION3 DB 'ERROR: There is an illegal number.',0DH,0AH,24H
        WRONGLETTERIMFORMATION4 DB 'ERROR: The input is null.',0DH,0AH,24H
        ENDIMFORMATION DB 0DH,0AH,24H
        WRONGLETTERERROR DB 0
DSEG    ENDS

SSEG    SEGMENT PARA STACK 
        DW  256 DUP(?)
SSEG    ENDS


CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG
.386
BEGIN:  MOV AX,DSEG
        MOV DS,AX

        MOV CX, 4

INPUT:
        



        MOV AH,4CH
        INT 21H


;--------检查错误符号函数
WRONGLETTER:
        LEA BX, ONENUM
        ADD BX, 2

        CMP ONENUM[1],0
        JNZ NOTNONE
        MOV WRONGLETTERERROR,4 ;WRONGLETTERERROR的值为4，代表输入为空的字符
        RET

NOTNONE:
        CMP ONENUM[1],1
        JZ CHEAKWRONGLETTER



NOFLAG:
        MOV DL, ONENUM[1]
        CMP DL,4
        JLE NOTOVERFLOW
        MOV WRONGLETTERERROR,1 ;WRONGLETTERERROR的值为1，代表越界的错误

NOTOVERFLOW:
NOTZERO:
         
        ;MOV SI, 2   
        ;ADD SI, HAVEF


CHEAKWRONGLETTER:   ;遍历输入的字符串检查错误符号
        CLD
        MOV AX,0
        MOV AL, [BX]
        MOV CX, 16
        LEA DI, CORRECTLETTER
        REPNE SCASB
        JE PASSLETTER ;字符为0~9，继续下个字符
        MOV WRONGLETTERERROR, 2 ;返回值为2，表示非法字符
        RET
        
PASSLETTER:
        MOV DX,BX
        LEA AX, ONENUM
        SUB DX, AX
        SUB DX,1
        ;SUB AX, HAVEF
        CMP DL, ONENUM[1]
        JZ  PASSSTRING
        INC BX
        JMP CHEAKWRONGLETTER

PASSSTRING:
        RET
 

CSEG    ENDS
        END  BEGIN