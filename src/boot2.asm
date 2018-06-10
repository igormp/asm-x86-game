BITS 16 ; informa ao assembler que eh um codigo de 16 bits, ou seja, no modo real
org 0x500 ; endereco do bootsector area, apos utilizar a diretiva org deve-se carregar o CS e o DS com 0
jmp 0x0000:start ; carrega o DS com 0 atraves de um far jump

data:

start:

xor ax, ax ; zera o DS, pois a partir dele que o processador busca os dados utilizados no programa
mov ds, ax

mov ah, 0
mov al, 12h ; inicia o modo video
int 10h

mov ah, 0xb
mov bh, 0   ;seta a cor de fundo pra cyan
mov bl, 0x3
int 10h


mov ah, 2
mov bh, 0
mov dh, 13  ; move o curso pro meio da tela
mov dl, 35
int 10h

mov si, msg     ; salva Text em si

print:
	lodsb           ; carrega si em al
	cmp al, 0       ; compara al e 0
	je barrinha		; se al = 0, pula
	mov ah, 0Eh     ; Printa AL
	mov bh, 0       ; paǵina
    mov bl, 0x8     ; cor
	int 10h
    call delay4
	jmp print       ; repete pra prox caractere

barrinha:
    mov ch, 6       ; contador pro loop
    lop:            ; loop
        mov ah, 2    
        mov bh, 0
        mov dh, 14  ; coloca uma linha abaixo do texto
        mov dl, 40
        int 10h
        mov ah, 0x0E  ; chamada
        mov al, '\'   ; printa
        int 0x10   ; chama bios
        call delay2
        mov ah, 2
        mov bh, 0
        mov dh, 14  ; reescreve por cima do anterior
        mov dl, 40
        int 10h
        mov ah, 0x0E  ; print function
        mov al, '|'   ; ascii char
        int 0x10   ; IO int
        call delay2
        mov ah, 2
        mov bh, 0
        mov dh, 14
        mov dl, 40
        int 10h
        mov ah, 0x0E  ; print function
        mov al, '/'   ; ascii char
        int 0x10   ; IO int
        call delay2
        dec ch      ; diminui o contador
        cmp ch, 0   ; compara com 0
        jne lop     ; se n, repete
        jmp reset   ; se s, continua


delay4:
    pusha
    push ds
    mov  ax, 0
    mov  ds, ax
    mov  cx, 3      ; quantidade de ticks do timer
    mov  bx, [46Ch] ; chamada dos ticks

dif:
nodif:
    mov  ax, [46Ch] ; chamada dos ticks
    cmp  ax, bx     ; compara a quantidade de ticks passados com a desejada
    je   nodif      ; se n, continua esperando
    mov  bx, ax
    loop dif        ;se sim, popa
    pop  ds
    popa
    ret


delay2:
    pusha
    push ds
    mov  ax, 0
    mov  ds, ax
    mov  cx, 2
    mov  bx, [46Ch]

dif1:
nodif1:
    mov  ax, [46Ch]
    cmp  ax, bx
    je   nodif1
    mov  bx, ax
    loop dif1
    pop  ds
    popa
    ret


reset:
mov ah, 0 ; AH = 0, codigo da funcao que reinicia o controlador de disco
mov dl, 0 ; numero do drive a ser resetado
int 13h
jc reset ; caso aconteca algum erro, tenta novamente

mov ax, 0x7E0 ; ler o setor do endereco 0x7e0
mov es, ax ; segmento com dados extra
xor bx, bx

ler:
mov ah, 0x02 ; codigo da funcao que le do disco
mov al, 0x06 ; numero de setores a serem lidos
mov ch, 0x00 ; numero do cilindro a ser lido
mov cl, 0x04 ; numero do setor
mov dh, 0 ; numero do cabecote
mov dl, 0 ; numero do drive
int 13h
jc ler ; caso aconteca algum erro, tenta novamente


jmp 0x7E0:0x0 ; executar o setor do endereco 0x7e0:0, vai para o kernel

msg db "Loading..."