DSEG    SEGMENT
        ONENUM DB  20,0,20 DUP('$')
        NUM DD  11 DUP(?)
        NEGATIVENUM DB  ?
        CORRECTLETTER DB '0123456789$'
        DISPLAYARRAY DB 12 DUP(?)
        SUM DD 0
        ORDER DD 10 DUP(0)
        JMPTABLE DW 3 DUP(0)

        WRONGLETTERIMFORMATION1 DB 'ERROR.',0DH,0AH,24H
        WRONGLETTERIMFORMATION2 DB 'ERROR.',0DH,0AH,24H
        WRONGLETTERIMFORMATION3 DB 'ERROR.',0DH,0AH,24H
        WRONGLETTERIMFORMATION4 DB 'ERROR.',0DH,0AH,24H
        ENDIMFORMATION DB 0DH,0AH,24H
        WRONGLETTERERROR DB 0
        INPUTIMFORMATION DB 'Input:$'
        NEGATIVEIMFORMATION DB '-$'
        COUNTNEGATIVEIMFORMATION DB 'The count of negative numbers is $'
        SUMALLIMFORMATION DB 'The sum of all input numbers is $'
        SORTIMFORMATION1 DB 'The sorted array is [$'
        SORTIMFORMATION2 DB ' $'
        SORTIMFORMATION3 DB ' ]$'
        ORIGINIMFORMATION1 DB 'The original array is [$'
        ORIGINIMFORMATION2 DB ' $'
        ORIGINIMFORMATION3 DB ' ]$'

        INSTRUCTIONIMFORMATION1 DB 'Please enter your instruction:',0DH,0AH,24H
        INSTRUCTIONIMFORMATION2 DB '(1 for neg count, 2 for sum, 3 for sort, 4 for print original array, 5 for enter again, q for quit)',0DH,0AH,24H
        WRONGINSTRUCTIONIMFORMATION DB 'The instruction code is undefined. Please enter again.',0DH,0AH,24H


        HAVEF DB 0
        STRINGNUM DB 10
        SORTINDEX DW 0

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
        CALL EXP3
        MOV AH,4CH
        INT 21H

PUBLIC EXP3
EXP3 PROC FAR
        PUSH DS
        MOV AX, DSEG
        MOV DS, AX
        MOV ES, AX

        
ENTER10:

        LEA BX, ONENUM+2 ;ONENUM清零
        MOV DI,0
        MOV CX, 20
CLEAR1:
        MOV BYTE PTR [BX+DI],0
        INC DI
        LOOP CLEAR1

        PRINT INPUTIMFORMATION
        MOV AH, 0AH
        LEA DX, ONENUM
        INT 21H
        PRINT ENDIMFORMATION

        CALL REMOVEEMPTY
        CALL WRONGLETTER
        CMP WRONGLETTERERROR,0
        JZ LETTER

WRONG1:
        CMP WRONGLETTERERROR,1
        JNZ WRONG2
        PRINT WRONGLETTERIMFORMATION1
        JMP WRONGIMFORMATION

WRONG2:
        CMP WRONGLETTERERROR,2
        JNZ WRONG3
        PRINT WRONGLETTERIMFORMATION2
        JMP WRONGIMFORMATION

WRONG3:
        CMP WRONGLETTERERROR,3
        JNZ WRONG4
        PRINT WRONGLETTERIMFORMATION3
        JMP WRONGIMFORMATION

WRONG4:
        PRINT WRONGLETTERIMFORMATION4
        JMP WRONGIMFORMATION

WRONGIMFORMATION:
        INC STRINGNUM
LETTER:
        CMP WRONGLETTERERROR,0
        JNZ HAVEWRONG
        CALL STORENUM

HAVEWRONG:
        MOV WRONGLETTERERROR,0
        

        MOV HAVEF,0
        DEC STRINGNUM
        CMP STRINGNUM,0
        JNZ ENTER10

INSTRUCTION:        
        PRINT INSTRUCTIONIMFORMATION1
        PRINT INSTRUCTIONIMFORMATION2
        

        MOV AH, 01H
        INT 21H



        CMP AL, '1'
        JZ INSTRUCTION1

        CMP AL, '2'
        JZ INSTRUCTION2

        CMP AL, '3'
        JZ INSTRUCTION3

        CMP AL, '4'
        JZ INSTRUCTION4

        CMP AL, '5'
        JZ INSTRUCTION5

        CMP AL, 'q'
        JZ OVER

        CMP AL, 'Q'
        JZ OVER

        PRINT ENDIMFORMATION
        PRINT WRONGINSTRUCTIONIMFORMATION
        JMP INSTRUCTION


INSTRUCTION1:
        PRINT ENDIMFORMATION
        CALL COUNTFUN
        JMP INSTRUCTION

INSTRUCTION2:
        PRINT ENDIMFORMATION
        CALL SUMFUN
        JMP INSTRUCTION

INSTRUCTION3:
        PRINT ENDIMFORMATION
        CALL SORTFUN
        JMP INSTRUCTION

INSTRUCTION4:
        PRINT ENDIMFORMATION
        CALL PRINTORIGINFUN
        JMP INSTRUCTION

INSTRUCTION5:
        PRINT ENDIMFORMATION
        MOV STRINGNUM, 10
        JMP ENTER10


OVER:
        ; for exp7
        MOV NEGATIVENUM,0
        MOV SUM,0
        MOV HAVEF,0
        MOV STRINGNUM,10
        MOV SORTINDEX,0
        POP DS
        RET

EXP3 ENDP
        

REMOVEEMPTY PROC NEAR
        PUSH DI
        PUSH DX
        MOV DX, 0
        LEA DI, ONENUM[1]
        MOV DL, ONENUM[1]
        ADD DI, DX
CHEAKEMPTY:
        CMP BYTE PTR [DI], 20H
        JNZ NONEMPTY
        MOV [DI], '$'
        DEC DL
        MOV ONENUM[1], DL
        DEC DI
        JMP CHEAKEMPTY

NONEMPTY:
        POP DX
        POP DI
        RET


REMOVEEMPTY ENDP


COUNTFUN:
        ; 统计负数个数
        PRINT COUNTNEGATIVEIMFORMATION
        CALL COUNTNEGATIVE
        CALL DISPLAYINT
        PRINT ENDIMFORMATION
        RET

SUMFUN:
        ; 求出所有数的总和,存放在SUM这块内存中
        PRINT SUMALLIMFORMATION
        CALL SUMALL
        MOV SUM, EDX
        CALL DISPLAYINT
        PRINT ENDIMFORMATION
        RET

SORTFUN:
        ;冒泡排序
        CALL SORT
        CALL DISPLAYSORTEDARRAY
        RET


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

;先有无判断符号位
        CMP BYTE PTR [BX], '+'
        JNZ FLAGJUG
        MOV HAVEF,1
        INC BX
        JMP NOFLAG

FLAGJUG:
        CMP BYTE PTR [BX], 2DH
        JNZ NOFLAG
        MOV HAVEF,1
        INC BX 
        JMP NOFLAG

NOFLAG:
        MOV DL, ONENUM[1]
        SUB DL, HAVEF
        CMP DL,5
        JLE NOTOVERFLOW
        MOV WRONGLETTERERROR,1 ;WRONGLETTERERROR的值为1，代表越界的错误

NOTOVERFLOW:
;判断第一个字符是否是0
        CMP BYTE PTR [BX],'0'
        JNZ NOTZERO
        MOV WRONGLETTERERROR,2 ;WRONGLETTERERROR的值为2，代表数字开头为0的错误
        RET

NOTZERO:
         
        ;MOV SI, 2   
        ;ADD SI, HAVEF


CHEAKWRONGLETTER:   ;遍历输入的字符串检查错误符号
        CLD
        MOV AX,0
        MOV AL, [BX]
        MOV CX, 10
        LEA DI, CORRECTLETTER
        REPNE SCASB
        JE PASSLETTER ;字符为0~9，继续下个字符
        MOV WRONGLETTERERROR, 3 ;返回值为3，表示非法字符
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
        
;--------将输入字符串转换为整数储存函数
STORENUM:
        LEA BX, ONENUM[2]
        CMP HAVEF,0
        JZ POSITIVE
        INC BX
        

POSITIVE:
        MOV EAX,0
        MOV CX, 0
        MOV CL, ONENUM[1]
        SUB CL, HAVEF
        MOV DI,0

STRING2INT:
        IMUL EAX,10
        MOV EDX,0
        MOV DL,[BX+DI]
        INC DI
        ADD EAX, EDX
        SUB EAX, 30H
        LOOP STRING2INT

        CMP ONENUM[2],'-'
        JNZ POSITIVE2
        NEG EAX

POSITIVE2:
        MOV BX, 10
        SUB BL, STRINGNUM
        IMUL BX,4
        MOV NUM[BX], EAX
        RET

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
        RET

; 显示整数的函数，整数必须放在EDX中,执行完该函数原数据丢失，只有字符串数据
DISPLAYINT PROC NEAR
        PUSH CX
        LEA BX, DISPLAYARRAY ;DISPLAYARRAY清零
        MOV DI, 0
CLEAR2:
        MOV BYTE PTR [BX+DI], '$'
        INC DI
        CMP DI, 12
        JNZ CLEAR2


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
        POP CX
        RET

DISPLAYINT ENDP


;--------求出所有数总和的函数
SUMALL:
        MOV CX,10
        MOV EDX,0
        MOV DI, 0
SUMP:
        ADD EDX, NUM[DI]
        ADD DI, 4
        LOOP SUMP
        RET

;-------冒泡排序的函数
SORT:

        CLD ;拷贝NUM到ORDER
        LEA SI, NUM
        LEA DI, ORDER
        MOV CX, 10
        REP MOVSD

        MOV CX, 9
LP1:
        MOV DI, CX
        MOV BX, 0
LP2:
        MOV EDX, ORDER[BX]
        CMP EDX, ORDER[BX+4]
        JL NEXT
        XCHG EDX, ORDER[BX+4]
        MOV ORDER[BX],EDX
NEXT:
        ADD BX,4
        DEC DI
        JNZ LP2
        LOOP LP1


        RET

;--------显示排序好的数组的函数
DISPLAYSORTEDARRAY:
        MOV SORTINDEX, 0
        PRINT SORTIMFORMATION1
DISPLAY1:
        PRINT SORTIMFORMATION2
        MOV DI, SORTINDEX
        MOV EDX, ORDER[DI]
        CALL DISPLAYINT
        ADD WORD PTR SORTINDEX, 4
        CMP SORTINDEX, 40
        JNZ DISPLAY1

        PRINT SORTIMFORMATION3
        PRINT ENDIMFORMATION
        RET

PRINTORIGINFUN:
        PUSH CX
        PUSH DI

        MOV CX, 0
        PRINT ORIGINIMFORMATION1
DISPLAY2:
        PRINT ORIGINIMFORMATION2
        MOV DI, CX
        MOV EDX, NUM[DI]
        CALL DISPLAYINT
        ADD CX, 4
        CMP CX, 40
        JNZ DISPLAY2

        PRINT ORIGINIMFORMATION3
        PRINT ENDIMFORMATION

        POP DI
        POP CX
        RET



CSEG    ENDS
        END  BEGIN