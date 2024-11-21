DSEG    SEGMENT
        QUANCIRCLEY DW 300 DUP(0) ;存y坐标
        R DW 230
        XORG DW 320
        YORG DW 240
        COLOR EQU 10

        FORMERY DW 0
        LATTERY DW 0
        DIRECTION DB 0
     

        FLAG DB 0

DSEG    ENDS

SSEG    SEGMENT PARA STACK 
        DW  256 DUP(?)
SSEG    ENDS

SCREEN MACRO
        MOV AX,12H
        INT 10H
        MOV AH,0BH
        MOV BX,0
        INT 10H
ENDM

CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG
.386
BEGIN:  
        MOV AX,DSEG
        MOV DS,AX

        SCREEN

        CALL CALCULATEY
        CALL WRITECIRCLE


        MOV AH,4CH
        INT 21H

CALCULATEY PROC NEAR
        PUSH AX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI

        MOV AX, R
        MUL AX
        PUSH AX
        MOV CX, R
        MOV DI, 0
CAL:
        MOV AX, CX
        MUL AX
        MOV DX, AX
        POP AX
        PUSH AX
        SUB AX, DX
        MOV SI, AX 
        CALL SQROOT
        MOV QUANCIRCLEY[DI], SI
        ADD DI, 2
        LOOP CAL

        POP AX

        POP SI
        POP DI
        POP DX
        POP CX
        POP AX
        RET
CALCULATEY ENDP

WRITECIRCLE PROC NEAR
        MOV AH, 0CH
        MOV AL, COLOR
        
        MOV DX, 0 ; 行数
        MOV SI, 0
LP1:
        MOV DX, YORG
        MOV BX, YORG

        
        MOV DI, SI



        CMP DIRECTION, 0
        JE LU1
        CMP DIRECTION, 1
        JE RU1
        CMP DIRECTION, 2
        JE RD1
        CMP DIRECTION, 3
        JE LD1

LU1:
        ADD DI, 2
        MOV CX, XORG ; 列数
        SUB CX, R
        SUB DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        SUB BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        INC BX
        JMP NOTOVER

RU1:
        ADD DI, 2
        MOV CX, XORG ; 列数
        SUB DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        SUB BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        DEC BX
        JMP NOTOVER

RD1:
        SUB DI, 2
        MOV CX, XORG ; 列数
        ADD CX, R
        ADD DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        ADD BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        DEC BX
        JMP NOTOVER


LD1:
        SUB DI, 2
        MOV CX, XORG ; 列数
        ADD DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        ADD BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        INC BX


NOTOVER:
        PUSH BX
        MOV BX, 0
        INT 10H
        POP BX

        CMP DIRECTION, 0
        JE LU2
        CMP DIRECTION, 1
        JE RU2
        CMP DIRECTION, 2
        JE RD2
        CMP DIRECTION, 3
        JE LD2

LU2:
        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JLE OVERLU1
        DEC DX
        JMP NOTOVER
OVERLU1:
        ADD SI, 2
        INC CX
        CMP CX, XORG
        JNZ LP1

RU2:
RD2:
LD2:

        RET

WRITECIRCLE ENDP


; 开平方的函数，输入输出都在SI当中    
SQROOT  PROC  NEAR
        PUSH AX
        PUSH BX
        PUSH CX
        MOV AX,SI ;取被开方数
        SUB CX,CX ;CX置0 
AGAIN: MOV BX,CX ;下面三条指令使BX=2*CX+1
        ADD BX,BX
        INC BX
        SUB AX,BX
        JC OVER ;不够减转OVER 
        INC CX
        JMP AGAIN
OVER:  MOV SI,CX ;平方根放回原堆栈区
        POP CX
        POP BX
        POP AX
        RET
SQROOT ENDP 
    
CSEG    ENDS
        END  BEGIN