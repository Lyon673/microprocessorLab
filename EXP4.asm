DSEG    SEGMENT
        QUANCIRCLEY DW 300 DUP(0) ;存y坐标
        SAMENUM DB 300 DUP(0)
        R DW 100
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
        COLORFLAG DB 0

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

        MOV AX, R
        MOV QUANCIRCLEY[DI],AX

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
        ADD DX, 1
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

        MOV SI, 0
        MOV CX, XORG ; 列数
        SUB CX, R

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
        CALL DELAYANDCOLOR
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

        MOV SI, R
        ADD SI, R
        SUB SI, 2


        MOV CX, XORG ; 列数
        MOV DX, YORG
        SUB DX, R
        INT 10H
        CALL DELAYANDCOLOR

        INC CX

LP2:
        MOV DX, YORG
        MOV BX, YORG

        MOV DI, SI

        ADD DI, 2
        ; 倒置遍历存的圆圈位置坐标

        SUB BX, QUANCIRCLEY[SI] ; BX存当前的y坐标
        SUB DX, QUANCIRCLEY[DI] ; DX存当前位置上一个位置的y坐标
        CMP BX, DX
        JZ NOTOVERRU
        INC DX




NOTOVERRU:
        PUSH BX
        MOV BX, 0
        INT 10H
        CALL DELAYANDCOLOR
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JGE OVERRU
        INC DX
        JMP NOTOVERRU

OVERRU:
        SUB SI, 2
        INC CX
        CMP CX, UPPERBIND
        JNZ LP2




; 右下方圆

RD:

        MOV SI, 0
        MOV CX, XORG ; 列数
        ADD CX, R

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
        CALL DELAYANDCOLOR
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JGE OVERRD
        INC DX
        JMP NOTOVERRD
OVERRD:
        ADD SI, 2
        DEC CX
        CMP CX, XORG
        JNZ LP3



; 左下方圆

LD:

        MOV SI, R
        ADD SI, R
        SUB SI, 2

        MOV CX, XORG ; 列数

        MOV DX, YORG
        ADD DX, R
        MOV BX, 0
        INT 10H
        CALL DELAYANDCOLOR
        DEC CX

LP4:
        MOV DX, YORG
        MOV BX, YORG

        MOV DI, SI
        
        ADD DI, 2
        
        ADD DX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        ADD BX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        CMP DX, BX
        JZ NOTOVERLD
        INC DX

NOTOVERLD:
        PUSH BX
        MOV BX, 0
        INT 10H
        CALL DELAYANDCOLOR
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JGE OVERLD
        INC DX
        JMP NOTOVERLD
OVERLD:
        SUB SI, 2
        DEC CX
        CMP CX, LOWERBIND
        JNZ LP4



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

DELAYANDCOLOR PROC NEAR
        PUSH CX
        PUSH DX
        MOV DL, 1
        SUB DL, COLORFLAG
        MOV COLORFLAG, DL
        CMP DL, 0
        JZ COLOR1
        MOV AL, 8
COLOR1: 
        MOV AL, 10

        MOV CX, 10000
TIMEDELAY:
        NOP
        LOOP TIMEDELAY

        POP DX
        POP CX
        RET
DELAYANDCOLOR ENDP

    
CSEG    ENDS
        END  BEGIN