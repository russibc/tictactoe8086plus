;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;										  ;;
;;			     ___   ___   ___    __                                ;;
;;			    / _ \ / _ \ / _ \  / /                                ;;
;;			   | (_) | | | | (_) |/ /_                                ;;
;;			    > _ <| | | |> _ <| '_ \                               ;;
;;			   | (_) | |_| | (_) | (_) |                              ;;
;;			    \___/ \___/ \___/ \___/                               ;;
;;										  ;;
;;	  _______ _____ _____ _______       _____ _______ ____  ______            ;;
;;	 |__   __|_   _/ ____|__   __|/\   / ____|__   __/ __ \|  ____|           ;;
;;	    | |    | || |       | |  /  \ | |       | | | |  | | |__              ;;
;;	    | |    | || |       | | / /\ \| |       | | | |  | |  __|             ;;
;;	    | |   _| || |____   | |/ ____ \ |____   | | | |__| | |____            ;;
;;	    |_|  |_____\_____|  |_/_/    \_\_____|  |_|  \____/|______|           ;;
;;										  ;;
;;			  _____  _     _    _  _____ 				  ;;
;;			 |  __ \| |   | |  | |/ ____|				  ;;
;;			 | |__) | |   | |  | | (___  				  ;;
;;			 |  ___/| |   | |  | |\___ \ 				  ;;
;;			 | |    | |___| |__| |____) |				  ;;
;;			 |_|    |______\____/|_____/ 				  ;;
;;                                                   				  ;;
;;                                                  				  ;;
;;										  ;;								      										              ;;
;;	 Copyright (C) 2017 Bruna Caroline Russi				  ;;
;;                                                                                ;;
;;       This program is free software: you can redistribute it and/or modify     ;;
;;       it under the terms of the GNU General Public License as published by     ;;
;;	 the Free Software Foundation, either version 3 of the License, or        ;;
;;	 (at your option) any later version.                                      ;;
;;                                                                                ;;
;;	 This program is distributed in the hope that it will be useful,          ;;
;;	 but WITHOUT ANY WARRANTY; without even the implied warranty of           ;;
;;	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            ;;
;;	 GNU General Public License for more details.                             ;;
;;                                                                                ;;
;;	 You should have received a copy of the GNU General Public License        ;;
;;	 along with this program.  If not, see <http://www.gnu.org/licenses/>.    ;;
;;                                                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.MODEL	SMALL

;8253
IO3  EQU  0600h

ADR_TIMER_DATA0   EQU  (IO3 + 00h)
ADR_TIMER_DATA1   EQU  (IO3 + 02h)
ADR_TIMER_DATA2   EQU  (IO3 + 04h)
ADR_TIMER_CONTROL EQU  (IO3 + 06h)

TIMER_COUNTER0	EQU 00h
TIMER_COUNTER1	EQU 40h
TIMER_COUNTER2	EQU 80h

TIMER_LATCH	  EQU 00h
TIMER_LSB	  EQU 10h
TIMER_MSB	  EQU 20h
TIMER_LSB_MSB 	  EQU 30h

TIMER_MODE0	EQU 00h
TIMER_MODE1	EQU 02h
TIMER_MODE2	EQU 04h
TIMER_MODE3	EQU 06h
TIMER_MODE4	EQU 08h
TIMER_MODE5	EQU 09h
TIMER_BCD	EQU 01h

; 8251
IO6  EQU  0C00H

ADR_USART_DATA EQU  (IO6 + 00h)

ADR_USART_CMD  EQU  (IO6 + 02h)

ADR_USART_STAT EQU  (IO6 + 02h)

.8086
.CODE

MACRO_INITIALIZE_8253_TIMER0 MACRO HIGH,LOW
   PUSHF
   PUSH AX
   PUSH DX

   MOV AL,36H
   MOV DX, ADR_TIMER_CONTROL
   OUT DX,AL

   MOV AL,LOW
   MOV DX, ADR_TIMER_DATA0
   OUT DX,AL

   MOV AL,HIGH
   MOV DX, ADR_TIMER_DATA0
   OUT DX,AL
   POP DX
   POP AX
   POPF
ENDM

MACRO_INITIALIZE_8253_TIMER1 MACRO HIGH,LOW
   PUSHF
   PUSH AX
   PUSH DX

   MOV AL,76H
   MOV DX, ADR_TIMER_CONTROL
   OUT DX,AL

   MOV AL,LOW
   MOV DX, ADR_TIMER_DATA1
   OUT DX,AL

   MOV AL,HIGH
   MOV DX, ADR_TIMER_DATA1
   OUT DX,AL

   POP DX
   POP AX
   POPF
ENDM

MACRO_INITIALIZE_8253_TIMER2 MACRO HIGH,LOW
   PUSHF
   PUSH AX
   PUSH DX

   MOV AL,0B6H
   MOV DX, ADR_TIMER_CONTROL
   OUT DX,AL

   MOV AL,LOW
   MOV DX, ADR_TIMER_DATA2
   OUT DX,AL

   MOV AL,HIGH
   MOV DX, ADR_TIMER_DATA2
   OUT DX,AL

   POP DX
   POP AX
   POPF
ENDM

INITIALIZE_8251:
   MOV AL,0
   MOV DX, ADR_USART_CMD
   OUT DX,AL
   OUT DX,AL
   OUT DX,AL
   MOV AL,40H
   OUT DX,AL
   MOV AL,4DH
   OUT DX,AL
   MOV AL,37H
   OUT DX,AL
   RET

READS_DATA:
   PUSHF
   PUSH DX
WAIT_INPUT:
   MOV DX, ADR_USART_STAT
   IN  AL,DX
   TEST AL,2
   JZ WAIT_INPUT
   MOV DX, ADR_USART_DATA
   IN AL,DX
   SHR AL,1
NO_INPUT:
   POP DX
   POPF
   RET

SHOW_CARACTER:
   PUSHF
   PUSH DX
   PUSH AX  ; SALVA AL
BUSY:
   MOV DX, ADR_USART_STAT
   IN  AL,DX
   TEST AL,1
   JZ BUSY
   MOV DX, ADR_USART_DATA
   POP AX  ; RESTAURA AL
   OUT DX,AL
   POP DX
   POPF
   RET

SHOW_STRING:
	MOV AL, [BX]
	CMP AL, '$'
	JE END_SHOW
	CALL SHOW_CARACTER
	INC BX
	JMP SHOW_STRING

END_SHOW: RET

READ_INPUT:
	CALL READS_DATA
	CALL SHOW_CARACTER
	CALL SONG_PLAY
	RET

INITIALIZE_TEMPLATE:
	LEA DI, TICTACTOE_COUNTER
	MOV CX, 9
	MOV AL, '1'
INITIALIZE_NEXT_TEMPLATE:
	MOV [DI], AL
	INC AL
	INC DI
	LOOP INITIALIZE_NEXT_TEMPLATE
	RET

GENERAL_FNCT:
	CALL CLEAN_SCREEN

	LEA BX, MSG_BEGIN
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

	CALL ROUTINE_TEMPLATE
	RET

CLEAN_SCREEN:
	PUSH AX
	MOV AL, 12
	CALL SHOW_CARACTER
	POP AX
	RET

ROUTINE_TEMPLATE:
	LEA DI, TICTACTOE_COUNTER

	CALL SHOW_LINE

	LEA BX, TICTACTOE_BOARD
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

	CALL SHOW_LINE

	LEA BX, TICTACTOE_BOARD
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

	CALL SHOW_LINE

	RET

SHOW_LINE:
	MOV AL, ' '
	CALL SHOW_CARACTER
	MOV AL, [DI]
	CALL SHOW_CARACTER
	MOV AL, ' '
	CALL SHOW_CARACTER
	MOV AL, '|'
	CALL SHOW_CARACTER
	INC DI

	MOV AL, ' '
	CALL SHOW_CARACTER
	MOV AL, [DI]
	CALL SHOW_CARACTER
	MOV AL, ' '
	CALL SHOW_CARACTER
	MOV AL, '|'
	CALL SHOW_CARACTER
	INC DI

	MOV AL, ' '
	CALL SHOW_CARACTER
	MOV AL, [DI]
	CALL SHOW_CARACTER

	INC DI
	RET

GUESS:
	CALL READ_INPUT
	CALL VALIDATION_1

	CMP AH, 1
	JE VALIDATION_2

	MOV BL, 0DH
	CALL SHOW_CARACTER

	LEA BX, MSG_ERROR2
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

	JMP GUESS

VALIDATION_1:
	MOV AH, 0
	CMP AL, '1'
	JL END_VAL1
	CMP AL, '9'
	JG END_VAL1
	MOV AH, 1
END_VAL1:
	RET

VALIDATION_2:
	LEA DI, TICTACTOE_COUNTER
	SUB AL, '1'
	MOV AH, 0
	ADD DI, AX
	MOV AL, [DI]
	CMP AL, '9'
	JNG END_VAL_2

	MOV BL, 0DH
	CALL SHOW_CARACTER

	LEA BX, MSG_ERROR1
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

	JMP GUESS
END_VAL_2:
	LEA BX, JUMP_LINE
	CALL SHOW_STRING
	RET

VALIDATE_WINNER:
	LEA SI, TICTACTOE_COUNTER
	CALL VERIFY_DIAG
	CMP VICTORY, 1
	JE END_WINNER_VALIDATION
	CALL VERIFY_LINES
	CMP VICTORY, 1
	JE END_WINNER_VALIDATION
	CALL VALIDATE_COLUNAS
END_WINNER_VALIDATION:
	RET

VERIFY_DIAG:
	MOV DI, SI
	MOV AL, [DI]
	ADD DI, 4
	CMP AL, [DI]
	JNE VALIDATE_DIAGONAL
	ADD DI, 4
	CMP AL, [DI]
	JNE VALIDATE_DIAGONAL
	MOV VICTORY, 1
	RET

VERIFY_LINES:
	MOV DI, SI
	MOV AL, [DI]
	INC DI
	CMP AL, [DI]
	JNE SEC_LINE
	INC DI
	CMP AL, [DI]
	JNE SEC_LINE
	MOV VICTORY, 1
	RET

SEC_LINE:
	MOV DI, SI
	ADD DI, 3
	MOV AL, [DI]
	INC DI
	CMP AL, [DI]
	JNE THIRD_LINE
	INC DI
	CMP AL, [DI]
	JNE THIRD_LINE
	MOV VICTORY, 1
	RET

THIRD_LINE:
	MOV DI, SI
	ADD DI, 6
	MOV AL, [DI]
	INC DI
	CMP AL, [DI]
	JNE END_VALID_LINES
	INC DI
	CMP AL, [DI]
	JNE END_VALID_LINES
	MOV VICTORY, 1
END_VALID_LINES:
	RET

VALIDATE_COLUNAS:
	MOV DI, SI
	MOV AL, [DI]
	ADD DI, 3
	CMP AL, [DI]
	JNE COLUNA_DOIS
	ADD DI, 3
	CMP AL, [DI]
	JNE COLUNA_DOIS
	MOV VICTORY, 1
	RET

COLUNA_DOIS:
	MOV DI, SI
	INC DI
	MOV AL, [DI]
	ADD DI, 3
	CMP AL, [DI]
	JNE COLUNA_TRES
	ADD DI, 3
	CMP AL, [DI]
	JNE COLUNA_TRES
	MOV VICTORY, 1
	RET

COLUNA_TRES:
	MOV DI, SI
	ADD DI, 2
	MOV AL, [DI]
	ADD DI, 3
	CMP AL, [DI]
	JNE END_VAL_COLUNAS
	ADD DI, 3
	CMP AL, [DI]
	JNE END_VAL_COLUNAS
	MOV VICTORY, 1
END_VAL_COLUNAS:
	RET

VALIDATE_DIAGONAL:
	MOV DI, SI
	ADD DI, 2
	MOV AL, [DI]
	ADD DI, 2
	CMP AL, [DI]
	JNE END_VERIF_DIAG
	ADD DI, 2
	CMP AL, [DI]
	JNE END_VERIF_DIAG
	MOV VICTORY, 1
	END_VERIF_DIAG:
	RET

WINNER_SONG:
	MACRO_INITIALIZE_8253_TIMER0 00H,0BFH
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,097H
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,07FH
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,05FH
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,07FH
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,097H
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,0BFH
	CALL DELAY
	CALL STOP
	RET

SONG_END:
	MACRO_INITIALIZE_8253_TIMER0 00H,0BFH
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,097H
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,07FH
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,05FH
	CALL DELAY
	CALL STOP
	RET

SONG_INICIO:
	MACRO_INITIALIZE_8253_TIMER0 00H,078H
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,087H
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,097H
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,0AAH
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,0BFH
	CALL DELAY
	CALL STOP
	RET

SONG_TIE:
	MACRO_INITIALIZE_8253_TIMER0 00H,05FH ; C5
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,065h ; B3
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,06bh ; A3#
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,071h ; A3
	CALL DELAY
	MACRO_INITIALIZE_8253_TIMER0 00H,078h ; G3#
	CALL DELAY
	CALL STOP
	RET

SONG_PLAY:
 	MACRO_INITIALIZE_8253_TIMER0 00H,0BFH
	CALL DELAY
	CALL STOP
	RET

STOP:
	MACRO_INITIALIZE_8253_TIMER0 00H,00H
	CALL DELAY
	RET
DELAY:
	PUSH CX
	MOV CX, 2710H
WAIT_A:
	LOOP WAIT_A
	POP CX
	RET

.startup

	MOV AX,0000
	MOV DS,AX

	MOV AX,@DATA
	MOV DS,AX
	MOV AX,@STACK
	MOV SS,AX

	CALL INITIALIZE_8251

NEW_GAME:
	MOV PLAYER, 10B
	MOV VICTORY, 0
	MOV GAME_COUNTER, 9

	CALL SONG_INICIO

	CALL INITIALIZE_TEMPLATE

RESTART:
	CALL GENERAL_FNCT

	LEA BX, MSG_POS
	CALL SHOW_STRING

	MOV AL, PLAYER
	CMP AL, 1

	JE VEZ_J2

	SHR PLAYER, 1

	LEA BX, MSG_PLAYER1_TURN
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING
	JMP END_VEZES

VEZ_J2:
	SHL PLAYER, 1

	LEA BX, MSG_PLAYER2_TURN
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

END_VEZES:
	CALL GUESS

	MOV BL, PLAYER
	CMP BL, 1
	JNE PLAY_JOG2

	MOV BL, 'X'
	JMP CONT_MOV

PLAY_JOG2:
	MOV BL, 'O'
CONT_MOV:
	MOV [DI], BL

	CALL VALIDATE_WINNER

	CMP VICTORY, 1
	JE ROUTINE_GANHADOR

VERIFY_TIE:
	SUB GAME_COUNTER, 1
	CMP GAME_COUNTER, 0
	JNE RESTART

	CALL GENERAL_FNCT

	LEA BX, MSG_TIE
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

	CALL SONG_TIE

	JMP ROUTINE_MSG_RESTART

ROUTINE_GANHADOR:
	CALL GENERAL_FNCT

	CALL WINNER_SONG

	LEA BX, MSG_VICTORY
	CALL SHOW_STRING

	MOV AL, PLAYER
	ADD AL, '0'

	CALL SHOW_CARACTER

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

ROUTINE_MSG_RESTART:
	LEA BX, MSG_RESTART
	CALL SHOW_STRING

	LEA BX, JUMP_LINE
	CALL SHOW_STRING

	CALL READ_INPUT

	CMP AL, 'Y'
	JE NEW_GAME

	CMP AL, 'y'
	JE NEW_GAME

	CALL SONG_END
END_GAME:
	JMP END_GAME

.DATA
	JUMP_LINE DB 13,10,'$'

	TICTACTOE_BOARD DB 13,10,'---|---|---',13,10,'$'

	MSG_RESTART DB 13,10,'PLAY AGAIN? Y (YES) / N (NO)$'
	MSG_BEGIN DB '.:: TIC TAC TOE ::.$'
	MSG_POS DB 13,10,'INSERT THE BOARD POSITION TO YOUR PLAY...$'
	MSG_TIE DB 13,10,'ITS A TIE!$'
	MSG_VICTORY DB 13,10,13,10,'THE WINNER IS: PLAYER $'
	MSG_ERROR1 DB 13,10,'ALREADY CHOSEN! TRY AGAIN$'
	MSG_ERROR2 DB 13,10,'INVALID CHARACTER! TRY AGAIN:$'
	MSG_PLAYER1_TURN DB 13,10,'ITS PLAYER 1 (X) TURN!$'
	MSG_PLAYER2_TURN DB 13,10,'ITS PLAYER 2 (O) TURN!$'

	TICTACTOE_COUNTER DB 9 DUP(0)
	PLAYER DB 0
	VICTORY DB 0
	GAME_COUNTER DB 0

.STACK
MY_STACK DW 128 DUP(?)
END
