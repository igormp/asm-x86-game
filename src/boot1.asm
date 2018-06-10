BITS 16 ; informa ao assembler que eh um codigo de 16 bits, ou seja, no modo real
org 0x7c00 ; endereco do bootsector area, apos utilizar a diretiva org deve-se carregar o CS e o DS com 0
jmp 0x0000:start ; carrega o DS com 0 atraves de um far jump

data:

start:

xor ax, ax ; zera o DS, pois a partir dele que o processador busca os dados utilizados no programa
mov ds, ax

mov si, msg     ; Print msg

print:
	lodsb           ; AL=memory contents at DS:SI
	cmp al, 0       ; If AL=0 then hang
	je keypress
	mov ah, 0Eh     ; Print AL
	mov bx, 7
	int 10h
	jmp print       ; Print next character

keypress:
	mov ah, 01h     ; modo da chamada para keystroke
    int 16h
	mov ah, 00h
    int 16h
    cmp al, ' '
    je reset
	jmp keypress


reset:
mov ah, 0 ; AH = 0, codigo da funcao que reinicia o controlador de disco
mov dl, 0 ; numero do drive a ser resetado
int 13h
jc reset ; caso aconteca algum erro, tenta novamente


mov ax, 0x50 ; ler o setor do endereco 0x500
mov es, ax ; segmento com dados extra
xor bx, bx

ler:
mov ah, 0x02 ; codigo da funcao que le do disco
mov al, 1 ; numero de setores a serem lidos
mov ch, 0 ; numero do cilindro a ser lido
mov cl, 2 ; numero do setor
mov dh, 0 ; numero do cabecote
mov dl, 0 ; numero do drive
int 13h
jc ler ; caso aconteca algum erro, tenta novamente

jmp 0x50:0x0 ; executar o setor do endereco 0x500:0, vai para o boot2


msg db "Booting Successful..",10,13,"Press space to continue!",10,13,10,13,0

times 510-($-$$) db 0 ; boot tem que ter 512 bytes
dw 0xAA55 ; assinatura do boot no final
