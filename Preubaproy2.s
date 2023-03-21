; Archivo: main.s
; Dispositivo: PIC16F887
; Autor: bRYAN oRTIZ
; Compilador: pic-as (v2.30), MPLABX V5.40
;
; Programa: contador en el puerto A
; Hardware: LEDs en el puerto A
;
; Creado: 3 feb, 2023
PROCESSOR 16F887
#include <xc.inc>
    
; configuration word 1
CONFIG FOSC=INTRC_NOCLKOUT // Oscilador Interno sin salidas
CONFIG WDTE=OFF // WDT disabled (reinicio repetitivo del pic)
CONFIG PWRTE=OFF // PWRT enabled (espera de 72ms al iniciar)
CONFIG MCLRE=OFF // El pin de MCLR se utiliza como I/O
CONFIG CP=OFF	// Sin proteccion de codigo
CONFIG CPD=OFF	// Sin proteccion de datos
    
CONFIG BOREN=OFF // Sin reinicio cuando el voltaje de alimentacion baja de 4V
CONFIG IESO=OFF // Reinicio sin cambio de reloj de interno a externo
CONFIG FCMEN=OFF // Cambio de reloj externo a interno en caso de fallo
CONFIG LVP=OFF // Programacion en bajo voltaje permitida
    
;configuration word 2
CONFIG WRT=OFF // Proteccion de autoescritura por el programa desactivada
CONFIG BOR4V=BOR40V // Reinicio abajo de 4V, (BOR21V=2.1V)x

PSECT udata_bank0 ;common memory
	OFFSET: DS 1 ;1 byte
	W_TEMP: DS 1; 1 byte
	STATUS_TEMP: DS 1; 1 byte
        unidad: DS 1
	decena: DS 1	    ;valor de decena sin procesar
        centena:  DS 1
	display2: DS 1
        display1: DS 1	    ;valor de decena ya pasado por tabla
        display0: DS 1
        selector: DS 1
	DATO:     DS 1
	cambioPendiente: DS 1
	frecVar: DS 1
	preload_t0: DS 1
	Frec_preDisplay: DS 1
	toggle_cuadrada: DS 1
	toggle_funcion: DS 1 ;cambia de triangular a cuadrad
	tog: DS 1
	masF EQU 0
	menosF EQU 1
	selOnda EQU 4
 
    PSECT resVect, class=CODE, abs, delta=2
    ;---------------vector reset-------------
    ORG 00h	    ;posicion 0000h para el reset
    resetVec:
	PAGESEL main
	goto main
	
    ;-------------- ISR ---------------------
    PSECT code, delta=2, abs
    ORG 004h	    ; posicion para el codigo
    push:
	movwf W_TEMP
	swapf STATUS, W
	movwf STATUS_TEMP
	
    isr:
	btfsc RBIF
	call int_rb
	btfss T0IF
	goto pop
	
	btfss	toggle_funcion, 0
	goto $+2	;se va a tmr0 tri
	goto $+3	;se va a tmr0 cuadrado
	
	call int_tmr0 ;tmr0 tri
	goto $+2
	call int_tmr0_c
	
	
	btfsc TMR1IF
	call  int_tmr1
	
    
    pop:
	swapf STATUS_TEMP, W
	movwf STATUS
	swapf W_TEMP, F
	swapf W_TEMP, W
	retfie
    ;-------------- ISR Subrutinas-----------------------
    int_rb:
	btfss	PORTB, masF
	incf	frecVar
	btfss	PORTB, menosF   
	decf	frecVar
	movf	frecVar, W
	btfss	toggle_funcion,0
	goto	$+2	;triangu
	goto	$+3;cuadrada
	
	call	tabla_Frecuencias  ;falta hacer la tabla TRI
	goto	$+2
	call	tabla_Frecuencias_cua ;;AAAA
	movwf	preload_t0
	
	movf	frecVar, W
	
	btfss	toggle_funcion,0
	goto	$+2	;triangu
	goto	$+3;cuadrada
	call	tabla_F_disp  ;falta hacer la tabla TRI
	goto	$+2
	call	tabla_F_disp_cua ;AAAAAAA
	movwf	Frec_preDisplay	;tiene el valor decimal correcto, pero no procesado por Display
	
	btfss	PORTB, selOnda	;verificar boton de cmabio de onda
	incf	toggle_funcion
	;goto    $+5		;CAMBIAR CONCHETUMADRE
	;incf	toggle_funcion
	;btfss	toggle_funcion, 0
	;goto	main	    ;si toggle_funcion =0 configura cuadrada
	;goto	onda_cuadrada
	bcf	RBIF
	RETURN
    
    
    ;-------------- EMPIEZA NUESTRO CODIGO ---------------
    PSECT code, delta=2, abs
    ORG 100h	    ; posicion para el codigo
    ;----------------------TABLA 7-----------------------
    TABLA:
    CLRF	PCLATH
    BSF		PCLATH, 0
    ANDLW	0x0f
    ADDWF	PCL
    RETLW	01000000B   ;0
    RETLW	01111001B   ;1
    RETLW	00100100B   ;2
    RETLW	00110000B   ;3
    RETLW	00011001B   ;4
    RETLW	00010010B   ;5
    RETLW	00000010B   ;6
    RETLW	01111000B   ;7
    RETLW	00000000B   ;8
    RETLW	00010000B   ;9
    RETLW	00001000B   ;A
    RETLW	00000011B   ;B
    RETLW	01000110B   ;C
    RETLW	00100001B   ;D
    RETLW	00000110B   ;E
    RETLW	00001110B   ;F
    
    tabla_Frecuencias:
	CLRF	PCLATH
	BSF	PCLATH, 0
	ANDLW	0x1f
	ADDWF	PCL
	retlw 0x00
	retlw 0x08
	retlw 0x10
	retlw 0x18
	retlw 0x20
	retlw 0x28
	retlw 0x30
	retlw 0x38
	retlw 0x40
	retlw 0x48
	retlw 0x50
	retlw 0x58
	retlw 0x60
	retlw 0x68
	retlw 0x70
	retlw 0x78
	retlw 0x80
	retlw 0x88
	retlw 0x90
	retlw 0x98
	retlw 0xA0
	retlw 0xA8
	retlw 0xB0
	retlw 0xB8
	retlw 0xC0
	retlw 0xC8
	retlw 0xD0
	retlw 0xD8
	retlw 0xE0
	retlw 0xE8
	retlw 0xF0
	retlw 0xF8
	retlw 0xF8
	
    tabla_F_disp:
	CLRF	PCLATH
	BSF	PCLATH, 0
	ANDLW	0x1f
	ADDWF	PCL
	retlw 13
	retlw 14
	retlw 14
	retlw 15 ;14.7
	retlw 15
	retlw 16
	retlw 16
	retlw 17
	retlw 17
	retlw 18
	retlw 19
	retlw 19
	retlw 20
	retlw 21
	retlw 22  ;24
	retlw 23
	retlw 24 ;;;
	retlw 25
	retlw 27
	retlw 28
	retlw 30
	retlw 32
	retlw 34
	retlw 36
	retlw 40
	retlw 43
	retlw 48
	retlw 53
	 
	retlw 59
	retlw 67
	retlw 67
	retlw 114
	
	
    tabla_Frecuencias_cua:
	CLRF	PCLATH
	BSF	PCLATH, 0
	ANDLW	0x1f
	ADDWF	PCL
	retlw 0x00
	retlw 0x08
	retlw 0x10
	retlw 0x18
	retlw 0x20
	retlw 0x28
	retlw 0x30
	retlw 0x38
	retlw 0x40
	retlw 0x48
	retlw 0x50
	retlw 0x58
	retlw 0x60
	retlw 0x68
	retlw 0x70
	retlw 0x78
	retlw 0x80
	retlw 0x88
	retlw 0x90
	retlw 0x98
	retlw 0xA0
	retlw 0xA8
	retlw 0xB0
	retlw 0xB8
	retlw 0xC0
	retlw 0xC8
	retlw 0xD0
	retlw 0xD8
	retlw 0xE0
	retlw 0xE8
	retlw 0xF0
	retlw 0xF8
	retlw 0xF8
	
    tabla_F_disp_cua:
	CLRF	PCLATH
	BSF	PCLATH, 0
	ANDLW	0x1f
	ADDWF	PCL
	retlw 15
	retlw 16
	retlw 16
	retlw 17
	retlw 17
	retlw 18
	retlw 19
	retlw 20
	retlw 20
	retlw 21
	retlw 22
	retlw 23
	retlw 24
	retlw 26
	retlw 27  ;24
	retlw 28
	retlw 31
	retlw 33
	retlw 35
	retlw 38
	retlw 41
	retlw 44
	retlw 49
	retlw 54
	retlw 61
	retlw 69
	retlw 81
	retlw 97
	retlw 122
	retlw 161
	retlw 243
	retlw 476
	retlw 500
	

    ;---------------------FIN TABLA----------------------
    main:
	bcf	RBIF
	call setup_io
	call setup_rbpu
	call setup_clk
	call config_tmr0
	call config_tmr1
	call setup_iocb ; INTERRUPCION ON CHANCGE PORTB REGISTER
	
	clrf	cambioPendiente
	clrf	frecVar
	clrf	preload_t0
	BANKSEL PORTA
	
    ;--------------- LOOP -----------------------------------	
    loop:
	clrf	unidad
	clrf	decena
	clrf	centena
	call	separador_decimal3D
	goto loop
	
	;-----------------SUBRUTINAS----------------------
    setup_io:
	BANKSEL ANSEL	; pines digitales
	clrf ANSEL
	clrf ANSELH
	
	BANKSEL TRISA
	clrf TRISA ; PORTA como salida
	clrf TRISC ; PORTC como salida (display)
	clrf TRISD ; PORTD como salida
	clrf TRISE
	bsf TRISB, masF ; PORTB PIN7 como entrada
	bsf TRISB, menosF ; PORTB PIN6 como entrada
	
	BANKSEL PORTA
	clrf PORTA
	clrf PORTB
	clrf PORTC
	clrf PORTD
	clrf PORTE
	RETURN
	
    setup_clk:
	BANKSEL OSCCON
	bsf SCS	    ; Oscilador interno
	bsf IRCF2
	bsf IRCF1
	bsf IRCF0    ; Frecuencia de 8MHz
	RETURN
	
    setup_rbpu:
	BANKSEL TRISA
	bcf OPTION_REG, 7 ;RBPU
	bsf WPUB, masF
	bsf WPUB, menosF
	bsf WPUB, selOnda
	RETURN
	
    config_tmr0:
	BANKSEL	OPTION_REG 
	BCF	OPTION_REG, 5	;Usar oscilador interno
	BCF	OPTION_REG, 4	
	BCF	OPTION_REG, 2	;configurar prescaler a 1:1
	BCF	OPTION_REG, 1
	BCF	OPTION_REG, 0
	BSF	OPTION_REG, 3	;Asignar Prescaler a TMR0
	BANKSEL	INTCON
	BCF	INTCON, 2 ;Inicializar bandera en 0 del TMR0
	;MOVLW	245
	;MOVWF	TMR0
	return
	
    config_tmr1:
	BANKSEL	PORTA
	bcf		T1CKPS1		;Prescaler 1:1
	bcf		T1CKPS0
	bcf		T1OSCEN		;REloj interno
	bcf		TMR1CS		
	bsf		TMR1ON
	movlw	177		;Cargar valor para High tmr1
	movwf	TMR1H
	movlw	224		;Cargar valor para Low tmr1
	movwf	TMR1L
	bcf		TMR1IF		;limpiar bandera
	RETURN	
	
    setup_iocb:
	BANKSEL TRISA
	bsf IOCB, masF
	bsf IOCB, menosF
	bsf IOCB, selOnda
	bsf RBIE    ;interrupcion ONCHANGE
	
	BANKSEL PIE1
	bsf TMR1IE	;Habilitar interrupcion timer1
	BANKSEL PIR1
	bcf	TMR1IF	;borrar bandera tmr1
	BANKSEL TRISA
	bsf T0IE    ;interrupciones TIMER0
	bsf PEIE    ;interrupciones perifericas
	bsf GIE
	RETURN

    resttmr0:
	MOVF	preload_t0, W
	;MOVLW	245
	MOVWF	TMR0
	bcf	T0IF
	return
	
    int_tmr0:
	;btfsc	toggle_funcion, 0
	;goto	onda_cuadrada
	call config_tmr0
	call resttmr0
	INCF	PORTE
	BTFSS	cambioPendiente, 0
	GOTO	pendientepositiva
	GOTO	pendientenegativa
   
    pendientepositiva:
	;movf	PORTA, W
	;sublw	255
	;btfss	ZERO
	;call	pendientenegativa
	;nop
	incf	PORTA
	movf	PORTA, W
	sublw	254
	btfss	ZERO
	goto	$+2
	incf	cambioPendiente
	return
    pendientenegativa:
	decf	PORTA
	movf	PORTA, W
	sublw	0
	btfss	ZERO
	goto    $+2
	incf	cambioPendiente
	return
	
	;esta funcion separa un numero abc en unidades decenas y centenas
    separador_decimal3D:	
	movf	Frec_preDisplay, W	;PORTA a W
	movwf	DATO		;DATO vale PORTA
	movlw	100		;W vale 100
	subwf	DATO, W		;resto DATO DE 100, lo guardo en W
	btfss	CARRY		;reviso CARRY
	goto	$+4		;100 es mayor y ya no vuelvo a restar, porque CARRY es 0
	movwf	DATO		;CARRY es 1, por lo que el resultado si lo guardo en DATO
	incf	centena		;aumento el valor de centena
	goto	$-6		 ;vuelvo a restar porque DATO es más de 100
	
	
	movlw	10
	subwf	DATO, W
	btfss	CARRY
	goto    $+4 
	movwf	DATO
	incf	decena
	goto	$-6
	
	
	movlw	1
	subwf	DATO, W
	btfss	CARRY
	goto	$+4
	movwf	DATO
	incf	unidad
	goto	$-6
	
	
	call	prep_display
	return
	
    prep_display:; manda unidad a la tabla y la codifica y lo mismo con decena y centena
	movf	unidad, W
	call	TABLA
	movwf	display0
	
	movf	decena, W
	call	TABLA
	movwf	display1
	
	movf	centena, W
	call	TABLA
	movwf	display2
	
    int_tmr1:
	movlw	177
	movwf	TMR1H
	movlw	224
	movwf	TMR1L	;REINICIO TMR1
	bcf	TMR1IF
	
	clrf	PORTD	;los transistores comienzan apagados
	btfsc	selector, 1
	goto    display_centena	;10
	btfsc	selector, 0	;0X
	goto	display_decena  ;01
	;return
	
    display_unidad:		;00
	movf	display0, W
	movwf	PORTC
	BSF	PORTD, 0
	goto	toggle
    display_decena:		;01
	movf	display1, W
	movwf	PORTC
	BSF	PORTD, 1
	goto	toggle
    display_centena:
	movf	display2, W
	movwf	PORTC
	BSF	PORTD, 2
	;goto	toggle
    toggle:
	incf	selector
	return
    
	;;;;;;;;;;;;;;;;;;;;;EMPIEZA TODO DE CUADRADA
    int_tmr0_c:
	call config_tmr0_cuadrada
	call resttmr0_cua
	INCF	PORTE
	BTFSS	cambioPendiente, 0
	GOTO	pendientepositiva_cua
	GOTO	pendientenegativa_cua
	
    resttmr0_cua:
	movf	preload_t0, W
	;MOVLW	217
	MOVWF	TMR0
	bcf	T0IF
	return
    config_tmr0_cuadrada: ;INTERRUPCIÓN lo + lenta posible 0.00499s
	BANKSEL	OPTION_REG 
	BCF	OPTION_REG, 5	;Usar oscilador interno
	BCF	OPTION_REG, 4	
	BSF	OPTION_REG, 2	;configurar prescaler a 1:256
	BSF	OPTION_REG, 1
	BSF	OPTION_REG, 0
	BCF	OPTION_REG, 3	;Asignar Prescaler a TMR0
	BANKSEL	INTCON
	BCF	INTCON, 2 ;Inicializar bandera en 0 del TMR0
	return
	
    pendientepositiva_cua:
	movlw	11111111B
	movwf	PORTA
	incf	cambioPendiente
	return
	
    pendientenegativa_cua:
	clrf	PORTA
	incf	cambioPendiente
	return
	
    
    END	
