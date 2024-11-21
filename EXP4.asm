DSEG    SEGMENT
        QUANCIRCLEY DW 300 DUP(0) ;存y坐标
        R DW 3
        XORG DW 320
        YORG DW 240
        COLOR EQU 10

        FORMERY DW 0
        LATTERY DW 0
        DIRECTION DB 0
        
        BIND1 DW 0
        UPPERBIND DW 0
        BIND2 DW 0
        LOWERBIND DW 0

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
        

        MOV SI, 0
        MOV DX, XORG
        DEC DX
        MOV BIND1, DX
        MOV DX, XORG
        ADD DX, R
        SUB DX, 2
        MOV UPPERBIND, DX
        MOV DX, XORG
        INC DX
        MOV BIND2, DX
        MOV DX, XORG
        SUB DX, R
        SUB DX, 1
        MOV LOWERBIND, DX
        MOV DX, 0 ; 行数

        CMP DIRECTION, 0
        JE LU
        CMP DIRECTION, 1
        JE RU
        CMP DIRECTION, 2
        JE RD
        CMP DIRECTION, 3
        JE LD

; 左上方圆
LU:

        MOV CX, XORG ; 列数
        SUB CX, R
        ADD CX, 1

LP1:
        MOV DX, YORG
        MOV BX, YORG

        MOV DI, SI
        
        ADD DI, 2
        SUB DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        SUB BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        INC BX

NOTOVERLU:
        PUSH BX
        MOV BX, 0
        INT 10H
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JLE OVERLU
        DEC DX
        JMP NOTOVERLU
OVERLU:
        ADD SI, 2
        INC CX
        CMP CX, XORG
        JNZ LP1


; 右上方圆
RU:

        MOV SI, 0
        MOV CX, XORG ; 列数

LP2:
        MOV DX, YORG
        MOV BX, YORG

        MOV DI, SI

        ADD DI, 2
        ; 倒置遍历存的圆圈位置坐标
        PUSH SI
        PUSH DI
        SUB SI, R
        SUB SI, R
        ADD SI, 4
        NEG SI
        SUB DI, R
        SUB DI, R
        ADD DI, 4
        NEG DI
        SUB DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        SUB BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        POP DI
        POP SI
        DEC BX


NOTOVERRU:
        PUSH BX
        MOV BX, 0
        INT 10H
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JGE OVERRU
        INC DX
        JMP NOTOVERRU
OVERRU:
        ADD SI, 2
        INC CX
        CMP CX, UPPERBIND
        JNZ LP2


; 右下方圆

RD:

        MOV SI, 0
        MOV CX, XORG ; 列数
        ADD CX, R
        SUB CX, 3

LP3:
        MOV DX, YORG
        MOV BX, YORG

        MOV DI, SI
        
        ADD DI, 2

       
        ADD DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        ADD BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标

        DEC BX

NOTOVERRD:
        PUSH BX
        MOV BX, 0
        INT 10H
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JGE OVERRD
        INC DX
        JMP NOTOVERRD
OVERRD:
        ADD SI, 2
        DEC CX
        CMP CX, BIND1
        JNZ LP3



; 左下方圆

LD:

        MOV SI, 0
        MOV CX, XORG ; 列数
        DEC CX

LP4:
        MOV DX, YORG
        MOV BX, YORG

        MOV DI, SI
        
        ADD DI, 2
        PUSH SI
        PUSH DI
        SUB SI, R
        SUB SI, R
        ADD SI, 2
        NEG SI
        SUB DI, R
        SUB DI, R
        ADD DI, 2
        NEG DI
        ADD DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        ADD BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        POP DI
        POP SI
        INC BX

NOTOVERLD:
        PUSH BX
        MOV BX, 0
        INT 10H
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JLE OVERLD
        DEC DX
        JMP NOTOVERLD
OVERLD:
        ADD SI, 2
        DEC CX
        CMP CX, LOWERBIND
        JNZ LP4

        JMP FINAL


FINAL:
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