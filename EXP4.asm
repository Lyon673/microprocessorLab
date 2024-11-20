DSEG    SEGMENT
        QUANCIRCLEY DW 300 DUP(0) ;存y坐标
        R DW 500
        XORG DW 320
        YORG DW 240
        COLOR EQU 10

        FORMERY DW 0
        LATTERY DW 0
     

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
        MOV CX, XORG ; 列数
        SUB CX, R
        MOV DX, 0 ; 行数
        MOV SI, 0
LP1:
        MOV DX, QUANCIRCLEY[SI]
        ADD DX, YORG
        MOV DI, SI
        ADD DI, 2
        MOV BX, QUANCIRCLEY[DI]
        ADD BX, YORG


NOTOVER:
        PUSH BX
        MOV BX, 0
        INT 10H
        POP BX

        CMP DX, BX
        JE SAMEOVER
        INC DX
        JMP NOTOVER

SAMEOVER:
        ADD SI, 2
        INC CX
        CMP CX, XORG
        JNZ LP1

        RET

WRITECIRCLE ENDP


    
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