DSEG    SEGMENT
ONENUM DB  20,0,20 DUP('$')
        NUM DD  0,-1,2,3,4,-1,-3,0,2,-5
        NEGATIVENUM DB  ?
        CORRECTLETTER DB '0123456789$'
        DISPLAYARRAY DB 12 DUP(?)

        WRONGLETTERIMFORMATION1 DB 'ERROR: The input number is overflow.',0DH,0AH,24H
        WRONGLETTERIMFORMATION2 DB 'ERROR: The first effect letter of the input number is 0.',0DH,0AH,24H
        WRONGLETTERIMFORMATION3 DB 'ERROR: There is an illegal number.',0DH,0AH,24H
        ENDIMFORMATION DB 0DH,0AH,24H
        WRONGLETTERERROR DB 0
        INPUTIMFORMATION DB 'Input:$'
        NEGATIVEIMFORMATION DB '-$'

        HAVEF DB 0
        STRINGNUM DB 10
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
BEGIN:  MOV AX,DSEG
        MOV DS,AX

        MOV EDX, -123
        CALL COUNTNEGATIVE
        CALL DISPLAYINT
        MOV AH,4CH
        INT 21H

; 统计负数个数的函数
COUNTNEGATIVE:
        MOV EDX,0
        MOV CX,10
        MOV DI,0

COUNT1:
        CMP NUM[DI],0
        JGE POSITIVE3
        INC DX
POSITIVE3:
        ADD DI,4
        LOOP COUNT1
        MOV CX, 0
        MOV DI, 0
        RET

; 显示整数的函数，整数必须放在EDX中,执行完该函数原数据丢失，只有字符串数据
DISPLAYINT:
        LEA BX, DISPLAYARRAY ;DISPLAYARRAY清零
        MOV CX, 12
        MOV AL, '$'
        REP STOSB 

        MOV SI, 11
        MOV EAX, EDX
        CMP EAX, 0
        JGE POSITIVE4
        PUSH EAX
        PRINT NEGATIVEIMFORMATION
        POP EAX
        NEG EAX

POSITIVE4:
        MOV EDX, 0
        MOV ECX, 10
        DIV ECX
        MOV DISPLAYARRAY[SI],DL
        ADD DISPLAYARRAY[SI],30H
        DEC SI
        CMP EAX, 0
        JNZ POSITIVE4

        INC SI
        MOV DI,0
COPYNUM:
        MOV DL,DISPLAYARRAY[SI]
        MOV DISPLAYARRAY[DI],DL
        MOV DISPLAYARRAY[SI],'$'
        INC DI
        INC SI
        CMP SI, 12
        JNZ COPYNUM

        PRINT DISPLAYARRAY
        PRINT ENDIMFORMATION
        RET

       
CSEG    ENDS
        END  BEGIN