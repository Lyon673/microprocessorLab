DSEG    SEGMENT
NUMB    DB  36H, 18H
RESULT1 DB  ?
RESULT2 DB  ?
DSEG    ENDS

CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG
.386
BEGIN:  MOV AX,DSEG
        MOV DS,AX

        MOV BL, NUMB[0]
        SUB BL, NUMB[1]
        MOV RESULT1,BL


        MOV AX, 0
        MOV AL, NUMB[0]
        DIV NUMB[1]
        MOV RESULT2, AL


        MOV AH,4CH
        INT 21H
CSEG    ENDS
        END  BEGIN

