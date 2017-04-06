org 0x7E00
jmp 0x0000:start

PlayerInfoY dw 172              ;coordenada inicial y do player
BlockInfoX dw 319               ;coordenada inicial x do bloco
BlockInfoY dw 172               ;coordenada inicial y do bloco
JumpH dw 0                      ;variavel para verificar altura do pulo
JumpInfo dw 0                   ;variavel para verificar se pula ou nao
BlockColor db 1
GameOver dw 0

StartVideo:
    mov ah, 0                   ;numero da chamada
    mov al, 0x13                ;modo video 320x200
    int 10h
    ret

Delay:
    push cx                     ;guarda valores dos regs na pinha
    push dx
    mov cx, 0                   ;high value = 0
    mov dx, 1500                ;low value = 2000
    mov ah, 86h                 ;modo da chamda
    int 15h 
    pop dx                      ;retorna valores originais dos regs
    pop cx
    ret                         ;sai da funcao

DrawFloor:
    mov cx, 0                   ;x e y iniciais para desenhar o chao
    mov dx, 173

    MainFloor:                  ;loop principal para desenha o chao
        call SubFloor           ;chama o sub loop
        mov cx, 0               ;volta a coordenada x para o incio
        inc dx                  ;aumenta coordenada y
        cmp dx, 200             ;verifica se chegou no final
        jne MainFloor           ;caso n, repete
        ret                     ;sai da sub funcao

    SubFloor:                   ;sub loop, printa uma linha do chao
        mov ah, 0xC             ;pixel na coordenada cx dx
        mov bh, 0
        mov al, 0xE             ;cor do pixel
        int 10h
        inc cx                  ;aumenta coordenada x
        cmp cx, 319             ;verifica se chegou no final
        jne SubFloor            ;caso n, repete
        ret                     ;sai do sub loop

DrawPlayer:
    mov cx, 30                  ;busca posicao x do player
    mov dx, word[PlayerInfoY]   ;busca posicao y do player
    mov si, dx                  ;copia posicao y
    sub si, 30                  ;si contem final y do player

    MainPlayer:                 ;loop principal para desenhar
        call SubPlayer          ;chama sub loop
        mov cx, 30              ;volta x para inicio
        dec dx                  ;diminui y
        cmp dx, si              ;verifica se chegou no final
        jne MainPlayer          ;caso n, repete
        ret                     ;sai do loop
    SubPlayer:                  ;sub loop, desenha uma linha
        mov ah, 0xC             ;pixel na coordenada cx dx
        mov bh, 0
        mov al, 0xC             ;cor do pixel
        int 10h 
        inc cx                  ;aumenta coordenada x
        cmp cx, 45              ;verifica se chegou no final
        jne SubPlayer           ;caso n, repete
        ret                     ;sai do sub loop

DrawBlock:
    mov dx, 172
    mov si, cx
    add si, 30

    MainBlock:
        call SubBlock
        mov cx, word[BlockInfoX]
        dec dx
        cmp dx, 110
        jne MainBlock
        ret
    SubBlock:
        mov ah, 0xC
        mov bh, 0
        mov al, byte[BlockColor]
        int 10h
        inc cx
        cmp cx, si
        jne SubBlock
        ret

DrawCleanBlock:
    add cx, 30
    mov dx, 172
    LoopCleanY:
        mov ah, 0xC
        mov bh, 0
        mov al, 0
        int 10h
        dec dx
        cmp dx, 109
        jne LoopCleanY
    ret

DrawCleanPlayer:
    mov cx, 30
    LoopCleanX:
        mov ah, 0xC
        mov bh, 0
        mov al, 0
        int 10h
        inc cx
        cmp cx, 45
        jne LoopCleanX
    ret

CheckInput:                     ;funcao para verificar se tecla foi apertada
    mov ah, 01h                 ;modo da chamada para keystroke
    int 16h
    jz CheckInputEnd

    ProcessInput:               ;verifica se a tecla é de sair do jogo ou pular
        mov ah, 00h
        int 16h
        cmp al, 'r'
        je EndGame
        cmp al, ' '
        je DoJump
        cmp al, 'e'
        je fim

    CheckInputEnd:
    ret

DoJump:
    mov ax, word[JumpInfo]
    cmp ax, 1
    jne PlusOne
    ret
    PlusOne:
        mov ax, 1
        mov word[JumpInfo], ax
        ret

UpPlayer:
    mov bx, word[GameOver]
    cmp bx, 1
    je EndGame
    mov dx, word[PlayerInfoY]
    mov ax, word[JumpH]
    cmp ax, 100
    jne Aumenta
    call DownPlayer
    ret
    Aumenta:
        inc ax
        dec dx
        mov word[PlayerInfoY], dx
        mov word[JumpH], ax
        inc dx
        call DrawCleanPlayer
        ret

DownPlayer:
    mov bx, word[GameOver]
    cmp bx, 1
    je EndGame
    mov dx, word[PlayerInfoY]
    mov ax, word[JumpH]
    cmp ax, 0
    jne Diminui
    ret
    Diminui:
        dec ax
        inc dx
        mov word[PlayerInfoY], dx
        mov word[JumpH], ax
        mov bx, 0
        mov word[JumpInfo], bx
        sub dx, 31
        call DrawCleanPlayer
        ret

MainJump:
    mov ax, word[JumpInfo]
    cmp ax, 1
    je IncY
    call DownPlayer
    ret
    IncY:
        call UpPlayer
        ret

BlockAnimation:
    mov cx, word[BlockInfoX]
    cmp cx, 0
    jne CoreAnimation
    mov word[BlockInfoX], 319
    mov al, byte[BlockColor]
    inc al
    mov byte[BlockColor], al
    ret
    CoreAnimation:
        call DrawBlock
        mov cx, word[BlockInfoX]
        call DrawCleanBlock
        call Delay
        sub cx, 31
        mov word[BlockInfoX], cx
    ret

CheckGameStatus:
    mov ax, 30
    mov bx, word[BlockInfoX]
    add ax, 15
    cmp ax, bx
    jae CheckY
    ret
    CheckY:
        mov ax, word[PlayerInfoY]
        cmp ax, 110
        jae Over
        ret
        Over:
            mov ax, 1
            mov word[GameOver], ax
            ret

Restart:
    mov ax, 30
    mov bx, 172
    mov cx, 319
    mov word[PlayerInfoY], bx
    mov word[BlockInfoX], cx
    mov word[BlockInfoY], bx
    xor ax, ax
    mov word[GameOver], ax
    mov word[JumpH], ax
    mov word[JumpInfo], ax
    inc ax
    mov byte[BlockColor], al
    jmp start

start:
    call StartVideo
    call DrawFloor

    MainGame:
        call DrawPlayer
        call BlockAnimation
        call CheckInput
        call MainJump
        call CheckGameStatus
        jmp MainGame

EndGame:
    call Delay
    call Restart
fim:
    times 3072-($-$$) db 0
