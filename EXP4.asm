DSEG    SEGMENT
        QUANCIRCLEY DW 300 DUP(0) ;存y坐标
        SAMENUM DB 300 DUP(0)
        R DW 0
        XORG DW 320
        YORG DW 240
        COLOR EQU 10

        QUERYRIMFORMATION DB 'Please enter the R (from 1 to 240): '
        ENDIMFORMATION DB 0DH,0AH,24H
        RSTRING DB 5,0,5 DUP('$')
        
        
        BIND1 DW 0
        UPPERBIND DW 0
        BIND2 DW 0
        LOWERBIND DW 0

        LUSQX DW 0
        RUSQX DW 0
        RDSQX DW 0
        LDSQX DW 0
        LUSQY DW 0
        RUSQY DW 0
        RDSQY DW 0
        LDSQY DW 0

        FLAG DB 0
        COLORFLAG DB 0
        DIRECTION DB 0

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


        CALL QUERYR
        SCREEN
        CMP R, 0
        JNZ NOTONE
        MOV AH, 0CH
        MOV AL, 4
        MOV CX, XORG
        MOV DX, YORG
        INT 10H
        JMP RETURN

NOTONE:
        CALL CALCULATEY
        CALL WRITECIRCLE
        CALL WRITESQUARE

RETURN:
        




        MOV AH,4CH
        INT 21H

QUERYR PROC NEAR
        PRINT QUERYRIMFORMATION
        MOV AH, 0AH
        LEA DX, RSTRING
        INT 21H
        PRINT ENDIMFORMATION
        CALL STORER
        RET
QUERYR ENDP

STORER PROC NEAR
        PUSH CX
        PUSH BX
        PUSH DX
        PUSH AX

        MOV CX, 0
        MOV CL, RSTRING[1]
        LEA BX, RSTRING[2]
        MOV DX, 0
        PUSH DX
STORE:
        MOV AX, 10
        POP DX
        MUL DX
        MOV DX, 0
        MOV DL, [BX]
        SUB DL, 30H
        ADD AX, DX
        PUSH AX
        INC BX
        LOOP STORE

        POP DX
        DEC DX
        MOV R, DX

        POP AX
        POP DX
        POP BX
        POP CX
        RET

STORER ENDP

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



; 左上方圆
LU:
        MOV DIRECTION,1

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
        CALL DELAYANDCOLOR
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
        MOV DIRECTION,2

        MOV SI, R
        ADD SI, R
        SUB SI, 2


        MOV CX, XORG ; 列数
        MOV DX, YORG
        SUB DX, R
        CALL DELAYANDCOLOR
        INT 10H

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
        CALL DELAYANDCOLOR
        INT 10H
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
        MOV DIRECTION,3

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
        CALL DELAYANDCOLOR
        INT 10H
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
        MOV DIRECTION,4

        MOV SI, R
        ADD SI, R
        SUB SI, 2

        MOV CX, XORG ; 列数

        MOV DX, YORG
        ADD DX, R
        MOV BX, 0
        CALL DELAYANDCOLOR
        INT 10H
        DEC CX

LP4:
        MOV DX, YORG
        MOV BX, YORG

        MOV DI, SI
        
        ADD DI, 2
        
        ADD BX, QUANCIRCLEY[SI] ; DX存当前的y坐标
        ADD DX, QUANCIRCLEY[DI] ; BX存当前位置下一个位置的y坐标
        CMP DX, BX
        JZ NOTOVERLD
        DEC DX

NOTOVERLD:
        PUSH BX
        MOV BX, 0
        CALL DELAYANDCOLOR
        INT 10H
        POP BX

        CMP DX, BX ;如果比下一行的值大1个以上，就继续，否则跳出
        JBE OVERLD
        DEC DX
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

; 延时以及改变颜色的函数
DELAYANDCOLOR PROC NEAR
        CMP DIRECTION, 3
        JNZ DXNOTMID
        CMP DX, YORG
        JNZ DXNOTMID

        PUSH DX
        MOV DL, 1
        SUB DL, COLORFLAG
        MOV COLORFLAG, DL
        POP DX
DXNOTMID:
        PUSH CX
        PUSH DX
        MOV DL, 1
        SUB DL, COLORFLAG
        MOV COLORFLAG, DL
        CMP DL, 0
        JZ COLOR1
        MOV AL, 4
        JMP COLOROVER
COLOR1: 
        MOV AL, 10

COLOROVER:
        MOV CX, 10000
TIMEDELAY:
        NOP
        LOOP TIMEDELAY

        POP DX
        POP CX
        RET
DELAYANDCOLOR ENDP

WRITESQUARE PROC NEAR
        PUSH DX
        PUSH BX
        PUSH CX
        PUSH SI
        PUSH AX

        MOV AX, R
        MUL AX
        SHR AX,1
        MOV SI, AX
        POP AX
        CALL SQROOT

        MOV DX, XORG
        SUB DX, SI
        MOV LUSQX, DX
        MOV DX, YORG
        SUB DX, SI
        MOV LUSQY, DX

        MOV DX, XORG
        ADD DX, SI
        MOV RUSQX, DX
        MOV DX, YORG
        SUB DX, SI
        MOV RUSQY, DX

        MOV DX, XORG
        ADD DX, SI
        MOV RDSQX, DX
        MOV DX, YORG
        ADD DX, SI
        MOV RDSQY, DX

        MOV DX, XORG
        SUB DX, SI
        MOV LDSQX, DX
        MOV DX, YORG
        ADD DX, SI
        MOV LDSQY, DX


        MOV CX, LUSQX
        MOV DX, LUSQY
UP:
        CALL DELAYANDCOLOR
        INT 10H
        CMP CX, RUSQX
        JZ RIGHT
        INC CX
        JMP UP

RIGHT:
        CALL DELAYANDCOLOR
        INT 10H
        CMP DX, RDSQY
        JZ DOWN
        INC DX
        JMP RIGHT

DOWN:
        CALL DELAYANDCOLOR
        INT 10H
        CMP CX, LDSQX
        JZ LEFT
        DEC CX
        JMP DOWN

LEFT:
        CMP DX, LUSQY
        JZ SQOVER
        CALL DELAYANDCOLOR
        INT 10H
        DEC DX
        JMP LEFT

SQOVER:

        POP SI
        POP CX
        POP BX
        POP DX

        RET
WRITESQUARE ENDP
    
CSEG    ENDS
        END  BEGIN