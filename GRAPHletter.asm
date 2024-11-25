DSEG    SEGMENT
        STRINGINPUT DB 100,0,100 DUP('$')
        LOOPLOWBOND DW 20
        STRINGLEN DW 0
        TOTALTIME DB 10

        QUERYSTRINGIMFORMATION DB 'Please enter the string: $'
        ENDIMFORMATION DB 0DH,0AH,24H

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
BEGIN:  MOV AX,DSEG
        MOV DS,AX

        PRINT QUERYSTRINGIMFORMATION
        MOV AH, 0AH
        LEA DX, STRINGINPUT
        INT 21H
        PRINT ENDIMFORMATION

        CALL DSTRING
        CALL DSTRING
        CALL DSTRING
        CALL DSTRING
        CALL DSTRING
   
        
        MOV AH,4CH
        INT 21H

DSTRING PROC NEAR
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH AX
        PUSH BX
       
        MOV DX, 20
        MOV LOOPLOWBOND, DX
       

        
        SCREEN
        MOV CX, 60
        MOV DX, 0
        MOV DL, STRINGINPUT[1]
        MOV STRINGLEN,DX
        SUB LOOPLOWBOND, DX

OUTLOOP:
        MOV SI, CX
        MOV DI, 0
INNERLOOP:
        CMP SI, 60
        JGE HIDED
        CMP SI, 20
        JBE HIDED

        MOV AH, 2        ; BIOS 功能：设置光标位置
        MOV BH, 0        ; 页号，通常为 0
        MOV DX, SI      ;COLUMN
        MOV DH, 15          ; Y 坐标（行）
        INT 10H            ; 调用 BIOS

        ; 绘制字符
        MOV AH, 0EH        ; BIOS 功能：显示字符
        MOV AL, STRINGINPUT[DI+2]         ; 显示字符 
        MOV BL, 0FH        ; 白色前景，黑色背景
        INT 10H            ; 调用 BIOS


HIDED:
        INC SI
        INC DI


        CMP DI, STRINGLEN
        JNZ INNERLOOP

        PUSH CX
        MOV CX, 65535
DELAY:
        NOP
        NOP
        NOP
        LOOP DELAY
        POP CX

        ;清屏
        PUSH AX
        PUSH BX
        MOV AH, 06H      ; 滚屏/清屏功能
        MOV AL, 0        ; 清除整个屏幕
        MOV BH, 0H      ; 属性：黑底白字
        INT 10H          ; 调用 BIOS 中断

        POP BX
        POP AX

        DEC CX
        CMP CX, LOOPLOWBOND
        JGE OUTLOOP


        POP BX
        POP AX
        POP DI
        POP SI
        POP DX
        POP CX
        RET
DSTRING ENDP

CSEG    ENDS
        END  BEGIN