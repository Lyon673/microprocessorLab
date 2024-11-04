DSEG    SEGMENT
        QUERYNAME DB 0AH,'What'' your name?',0DH,0AH,24H
        MNAME    DB  20,0,20 DUP('$')
        QUERYCLASS  DB  'Which class are you in?',0DH,0AH,24H
        MCLASS    DB  20,0,20 DUP('$')
        INFORMATION1    DB      'Your name is $'
        INFORMATION2    DB      ',and your class is $'
        INFORMATION3    DB      '. confirm(y/n)',0DH,0AH,24H
        WRONG   DB      0AH,'ERROR:Please enter the correct letter~',0DH,0AH,24H
DSEG    ENDS

SSEG    SEGMENT PARA STACK 
        DW  256 DUP(?)
SSEG    ENDS

CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG
BEGIN:  MOV AX,DSEG
        MOV DS,AX

START:  MOV DX, OFFSET QUERYNAME
        MOV AH,9
        INT 21H

        LEA DX, MNAME
        MOV AH,0AH
        INT 21H

        MOV DX, OFFSET QUERYCLASS
        MOV AH,9
        INT 21H

        MOV AH,0AH
        LEA DX, MCLASS
        INT 21H

EXITP:
        LEA DX, INFORMATION1
        MOV AH,09H
        INT 21H

CHANGENAME:
        INC BX
        CMP MNAME[BX], 0DH
        JNZ CHANGENAME
        MOV MNAME[BX], 24H

        LEA DX, MNAME+2
        MOV AH,09H
        INT 21H

        LEA DX, INFORMATION2
        MOV AH,09H
        INT 21H

        MOV BX,0
CHANGECLASS:
        INC BX
        CMP MCLASS[BX], 0DH
        JNZ CHANGECLASS
        MOV MCLASS[BX], 24H

        LEA DX, MCLASS+2
        MOV AH,09H
        INT 21H

        LEA DX, INFORMATION3
        MOV AH,09H
        INT 21H

        MOV AH,01H
        INT 21H

        CMP AL, 'y'
        JZ SUC

        CMP AL, 'n'
        JZ FAIL
        
        LEA DX, WRONG
        MOV AH, 09H
        INT 21H

        JMP EXITP

FAIL:   JMP START

SUC:    MOV AH,4CH
        INT 21H
CSEG    ENDS
        END  BEGIN