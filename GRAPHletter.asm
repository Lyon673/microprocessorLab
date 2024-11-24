DSEG    SEGMENT
       
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
BEGIN:  MOV AX,DSEG
        MOV DS,AX

        SCREEN

        MOV AH, 2        ; BIOS 功能：设置光标位置
        MOV BH, 0        ; 页号，通常为 0
        MOV DL, 10          ; X 坐标（列）
        MOV DH, 10          ; Y 坐标（行）
        INT 10H            ; 调用 BIOS

        ; 绘制字符
        MOV AH, 0EH        ; BIOS 功能：显示字符
        MOV AL, 'H'         ; 显示字符 'H'
        MOV BL, 0FH        ; 白色前景，黑色背景
        INT 10H            ; 调用 BIOS

         MOV AH, 0EH        ; BIOS 功能：显示字符
        MOV AL, 'G'         ; 显示字符 'H'
        MOV BL, 0FH        ; 白色前景，黑色背景
        INT 10H            ; 调用 BIOS

CSEG    ENDS
        END  BEGIN