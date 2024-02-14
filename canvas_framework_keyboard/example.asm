.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Voicu Luisa - DX BALL",0
area_width EQU 811 ; latime  (nr coloane)
area_height EQU 614 ; lungime (nr linii)
area DD 0
format DB 13,10,"introdus : %d",13,10,0
format2 DB 13,10,"-------------------------->introdus : %d",13,10,0
format3 DB 13,10,"aici!!!====================== : %d",13,10,0
format4 DB 13,10,"---------------------------------------------------",13,10,"---------------------------------------------------  %d",13,10,"---------------------------------------------------",13,10,0
counter DD 0 ; numara evenimentele de tip timer
format5 DB 13,10,"~~`~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~: %d",13,10,0
format6 DB 13,10,"~~`~~: %d",13,10,0
format7 DB 13,10,"--------------------------------------------------------SE STERGE: %d",13,10,0
formaatL DB "%d ",0;
formats DB 13,10,0;
;variabile


;taste
stanga DD 'A'
dreapta DD 'D'
incepe_jocul DD  ' '
a_inceput DD 0


var1 DD 0 
var2 DD 0
var3 DD 0
var4 DD 0
var5 DD 0
var6 DD 0
var7 DD 0

;pentru suportul mingii
sup_x DD 368
sup_y1 DD 367

directie DD 0
ultimul_clock DD 0
dim_suport DD 20
index_sup DD 0
; pentru minge

ball_x DD 344;
ball_y DD 367;
directie_ball DD 1  ;; 1 sus ; 2 jos
unghi DD 90 ;;90->90gr/451->45stg/452->45drp ..60/30
erase_ball DD 1


;pentru cadouri / bonusuri
gift_x DD 0
gift_y DD 0
clock_gift DD 0  ;; dupa o unitate de timp cadoul incepe sa se deplaseze
exista_cadou DD 0




;limite cadran
nord DD 50
sud DD 380
vest DD 100
est DD 664
podea DD 480
;pentru blocuri/caramizi

ocupat DB area_width*area_height dup(0)
poz_ocupata DD 0
; pt scor

scor DD 0

; PT REsume
go DD 0
resume_ys DD 362
resume_yd DD 422
resume_xs DD 250
resume_xj DD 270
;;; coordonate de la ultima viata 

heart_x DD 151
heart_y DD 0
count_lives DD 3
index_heart DD 0



heart_brick_x DD 365
heart_brick_y DD 110

; iarba

index_grass DD 0
index_nori DD 0
index_premiu DD 0

is_gift DD 0
is_racoon DD 0
index_racoon DD 0
index_mirror DD 0
;633, 450
racoon_x DD 431
racoon_y DD 630
skate_x DD 471
skate_y DD 642

	

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

premiu_width equ 26
premiu_height equ 23
;
racoon_width EQU 33
racoon_height EQU 53 
symbol_width EQU 47
symbol_height EQU 24
ball_width EQU 12
ball_height EQU 10
digit_width EQU 10
digit_height EQU 20
is_ball DD 0

var_width DD 0
var_height DD 0




include digits.inc
include letters.inc
include ball.inc
include brick.inc 
include suport.inc
include erase.inc
include cerc.inc
include alb.inc
include verde.inc
include frame.inc
include heart.inc
include sterge.inc
include cadou.inc
include grass.inc
include nori.inc
include premiu.inc
include racoon.inc
include skateboard.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov is_ball,0 ; nu e bila 
	mov is_gift,0
	mov is_racoon,0
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	
	cmp eax, 'b'  ;; b = ball
	je make_ball	
	
	cmp eax, 'g'  ;; iarba
	je make_grass
	
	cmp eax, 't'  ;; sTerge = sterge bila (la dim 12x10)
	je make_sterge
	
	cmp eax, 'r' ;; r = bRick
	je make_brick
	
	cmp eax, 's' ;; s = suportul mingii
	je make_suport
	
	cmp eax, 'e' ;; e = sterge element
	je make_erase
	
	cmp eax, 'c' ;; e = cerc
	je make_cerc
	
	cmp eax, 'a' ;; a = alb
	je make_alb
	
	cmp eax, 'v' ;; v = verde
	je make_verde
	
	cmp eax, 'f' ;; f = frame
	je make_frame
	
	cmp eax, 'h' ;; h = heart
	je make_heart
		
	cmp eax, 'n' ;; nori
	je make_nori
	
	cmp eax, 'd' ;; d = caDou
	je make_cadou
	
	cmp eax, 'p' ;; premiu
	je make_premiu
	
	cmp eax, 'o' ;; racoon
	je make_racoon
		
	cmp eax, 'k' ;; racoon
	je make_skateboard
		



	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:

	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
	
make_space:
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	jmp draw_text
	
make_ball:

	mov is_ball,1	 ;;;marcam faptul ca elementul desenat e o bila deci are dimensiuni diferite de celalalte simboluri (pt a sterge nr corect de blocuri (altfel sterge aiurea )
	mov eax,0
	lea esi,ball
	jmp draw_text
     
make_sterge:

	mov eax,0
	lea esi,sterge
	mov is_ball,1 ;;;marcam faptul ca elementul desenat e o bila deci are dimensiuni diferite de celalalte simboluri (pt a sterge nr corect de blocuri (altfel sterge aiurea )
	jmp draw_text
     
	 
	 
make_brick:
	mov eax,0
	lea esi,brick
	jmp draw_text
	
make_suport:
	mov eax,index_sup
	lea esi,suport
	jmp draw_text
	
make_erase:
	mov eax,0
	lea esi,erase
    jmp draw_text
	
make_cerc:
	mov eax,0
	lea esi,cerc
    jmp draw_text
	
make_alb:
	mov eax,0
	lea esi,alb
    jmp draw_text
	
make_verde:
	mov eax,0
	lea esi,verde
    jmp draw_text

make_frame:
	mov eax,0
	lea esi,frame
    jmp draw_text
	
make_heart:
	mov eax,index_heart
	lea esi,heart
    jmp draw_text
	
make_cadou:
	mov eax,0
	lea esi,cadou
    jmp draw_text

make_grass:
	mov eax,index_grass
	lea esi,grass
    jmp draw_text

make_nori:
	mov eax,index_nori
	lea esi,nori
    jmp draw_text

make_premiu:
	mov is_gift,1
	mov eax,index_premiu
	lea esi,premiu
    jmp draw_text

make_racoon:
	mov is_racoon,1
	mov eax,index_racoon
	lea esi,racoon
    jmp draw_text
	

make_skateboard:
	mov eax,0
	lea esi,skateboard
    jmp draw_text
	

	
draw_text:

	cmp is_ball,1
	jne not_ball
		mov var_width, ball_width
		mov var_height, ball_height
		jmp solve
	
	not_ball:
		cmp is_gift,1
		jne not_gift
			mov var_width, premiu_width
			mov var_height, premiu_height
			jmp solve
		not_gift:
			cmp is_racoon,1
			jne not_racoon
			mov var_width, racoon_width
			mov var_height, racoon_height
			jmp solve
			
			not_racoon:
			mov var_width, symbol_width
			mov var_height, symbol_height
		
	solve:
	mov ebx, var_width
	mul ebx
	mov ebx, var_height
	mul ebx
	add esi, eax
	mov ecx, var_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, var_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, var_width
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CULORI  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	
	cmp byte ptr [esi],6
	je simbol_pixel_roz_rosu
	
	cmp byte ptr [esi],3
	je simbol_pixel_verde_inchis
	
	cmp byte ptr [esi],2
	je simbol_pixel_verde_inchis
	
	cmp byte ptr [esi],4
	je simbol_pixel_verde_deschis
	
	cmp byte ptr [esi],5
	je simbol_pixel_verde_deschis
	
	cmp byte ptr [esi],7
	je simbol_pixel_albastru_deschis
	
	cmp byte ptr [esi],8
	je simbol_pixel_rosu
	
	cmp byte ptr [esi],9
	je simbol_pixel_rosu_inchis
	
	cmp byte ptr [esi],10
	je simbol_pixel_galben
	
	cmp byte ptr [esi],11
	je simbol_pixel_verde_mediu
	
	cmp byte ptr [esi],12
	je simbol_pixel_roz
	
	cmp byte ptr [esi],13
	je simbol_pixel_mov
	
	cmp byte ptr [esi],14
	je simbol_pixel_violet
	
	cmp byte ptr [esi],15
	je simbol_pixel_portocaliu
	
		cmp byte ptr [esi],16
	je simbol_pixel_gri_inchis
	
			cmp byte ptr [esi],17
	je simbol_pixel_gri_deschis
	
				cmp byte ptr [esi],18
	je simbol_pixel_gri_mega_inchis
	
	
	
	
	;; altfel negru
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
	
	simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
	
	simbol_pixel_roz_rosu:
	mov dword ptr [edi], 0f14e56h
	jmp simbol_pixel_next
	
	simbol_pixel_verde_inchis:
	mov dword ptr [edi], 0167834h
	jmp simbol_pixel_next
	
	simbol_pixel_verde_deschis:
	mov dword ptr [edi], 095eaa6h
	jmp simbol_pixel_next
	
	simbol_pixel_albastru_deschis:
	mov dword ptr [edi], 099d9eah
	jmp simbol_pixel_next
	
	simbol_pixel_rosu:
	mov dword ptr [edi], 0ed1c24h
	jmp simbol_pixel_next
	
	simbol_pixel_rosu_inchis:
	mov dword ptr [edi], 08b0000h
	jmp simbol_pixel_next
	
	
	simbol_pixel_galben:
	mov dword ptr [edi], 0FFFF00h
	jmp simbol_pixel_next
	
	simbol_pixel_verde_mediu:
	mov dword ptr [edi], 022b14ch
	jmp simbol_pixel_next
	
		simbol_pixel_roz:
	mov dword ptr [edi], 0ed1c24h
	jmp simbol_pixel_next
	simbol_pixel_mov:
	mov dword ptr [edi], 0a349a4h
	jmp simbol_pixel_next
	simbol_pixel_violet:
	mov dword ptr [edi], 0d9aad9h
	jmp simbol_pixel_next
	simbol_pixel_portocaliu:
	mov dword ptr [edi], 0ffc90eh
	jmp simbol_pixel_next
		
	simbol_pixel_gri_deschis:
	mov dword ptr [edi], 0cbc2bdh
	jmp simbol_pixel_next
	
	simbol_pixel_gri_inchis:
	mov dword ptr [edi], 0847f7ch
	jmp simbol_pixel_next
	
		simbol_pixel_gri_mega_inchis:
	mov dword ptr [edi], 04b4643h
	jmp simbol_pixel_next
	
	
simbol_pixel_next:
	inc esi
	add edi, 4
	dec ecx
	cmp ecx,0
	jne bucla_simbol_coloane
	pop ecx
	dec ecx
	cmp ecx,0
	jne bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm



; macro ce marcheaza cu 1 pixelii din matrice ce sunt ocupati de un bloc/caramida

marcheaza_ocupat macro oy,ox,ocupat,val

	local repeta_i,repeta_j,cont
	mov var1,ox ;linii
	mov var3,0
	mov var2,oy
	mov var4,0
	
	;; fiecare bloc are 24 linii si 47 coloane
	
	repeta_i:
	
		mov var2,oy ;nu pierde indexul pt fiecare linie
		mov var4,0
		
		; push var1
			; push offset formaatL
			; call printf
			; add esp,8
		
		repeta_j:
			mov eax,area_width
			mul var2
			add eax,var1

			mov ocupat[eax],val
			
			
			
			; push var2
			; push offset formaatL
			; call printf
			; add esp,8
	
			
			
			
			inc var2
			inc var4
			mov eax,var4
			
		cmp eax,symbol_width
		jl repeta_j
		
			 ; push offset formats
			 ; call printf
			 ; add esp,4
		
		inc var1
		inc var3
		mov eax,var3
		
	cmp eax,symbol_height
	jl repeta_i
	
	 ; push offset formats
			 ; call printf
			 ; add esp,4
			  ; push offset formats
			 ; call printf
			 ; add esp,4
	
endm


verifica_ocupat macro oy,ox,ocupat
local este_ocupat,sfarsit
	;salvam valoarea reg ebx
	push ebx
	mov var7,ebx	
	
	mov eax,0
	mov var1,ox
	mov var2,oy

	mov eax,area_width
	mul var2
	add eax,var1
	mov ebx,0
	mov bl,ocupat[eax]

	; push ebx
	; push offset format5
	; call printf
	; add esp,8
	
	
	mov eax,ebx

	
	; push oy
	; push offset format6
	; call printf
	; add esp,8
	; mov eax,ebx
	
	; push ox
	; push offset format6
	; call printf
	; add esp,8
	
	mov eax,ebx

	
	mov ebx,var7
	
	pop ebx
endm

sterge_bloc macro oy,ox,ocupat
local repeta_col,repeta_lin,cont,cont2
	push eax
	push ebx
	
	verifica_ocupat oy,ox,ocupat
	cmp eax,1
	jne cont2
	mov ebx,ox
	repeta_lin:
		dec ebx
		verifica_ocupat oy,ebx,ocupat

	cmp eax,1
	je repeta_lin
	
	inc ebx
	mov var6,ebx
	
	mov ebx,oy
	
	repeta_col:
		dec ebx
		verifica_ocupat ebx,ox,ocupat
	cmp eax,1
	je repeta_col
	
	inc ebx
	mov var5,ebx

	
	
	;; aici!
	; push var5
	; push offset format7
	; call printf
	; add esp,8
	; push var6
	; push offset format7
	; call printf
	; add esp,8
	make_text_macro 'e',area,var5,var6			
	;marcheaza_ocupat eax,ebx,ocupat,2
	
	
	mov eax,var5
	mov ebx,var6
	cmp exista_cadou,1
	je cont
	mov gift_y,eax
	mov gift_x,ebx
	
	
	
	
	cont:
	
	cmp ebx,heart_brick_y
	jne cont2
	cmp eax,heart_brick_x
	jne cont2
	; altfel 
	
		; push heart_brick_y
	; push offset format5
	; call printf
	; add esp,8
		
	; push heart_brick_x
	; push offset format5
	; call printf
	; add esp,8
	
	inc count_lives
	add heart_x,23
	make_text_macro 'h',area,heart_y,heart_x			

	
	cont2:
	;marcheaza_ocupat eax,ebx,ocupat,2
	
	pop ebx
	pop eax
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc



	
	incepe_test:
	push ebp
	mov ebp, esp
	pusha
	
		cmp go,1
	je evt_click  ;;; verificam daca se da click pe retry

	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	cmp eax, 3
	jz evt_key
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
	
	

afisare_litere:

	
	
	
	

	
	;;;;albastru
	
	
	make_text_macro 'e', area, 100, 48
	make_text_macro 'e', area, 147, 48
	make_text_macro 'e', area, 194, 48
	make_text_macro 'e', area, 241, 48
	make_text_macro 'e', area, 288, 48
	make_text_macro 'e', area, 335, 48
	make_text_macro 'e', area, 382, 48
	make_text_macro 'e', area, 429, 48
	make_text_macro 'e', area, 476, 48
	make_text_macro 'e', area, 523, 48
	make_text_macro 'e', area, 570, 48
	make_text_macro 'e', area, 617, 48
	make_text_macro 'e', area, 664, 48
	make_text_macro 'e', area, 100, 60
	make_text_macro 'e', area, 147, 60
	make_text_macro 'e', area, 194, 60
	make_text_macro 'e', area, 241, 60
	make_text_macro 'e', area, 288, 60
	make_text_macro 'e', area, 335, 60
	make_text_macro 'e', area, 382, 60
	make_text_macro 'e', area, 429, 60
	make_text_macro 'e', area, 476, 60
	make_text_macro 'e', area, 523, 60
	make_text_macro 'e', area, 570, 60
	make_text_macro 'e', area, 617, 60
	make_text_macro 'e', area, 664, 60
	make_text_macro 'e', area, 100, 84
	make_text_macro 'e', area, 147, 84
	make_text_macro 'e', area, 194, 84
	make_text_macro 'e', area, 241, 84
	make_text_macro 'e', area, 288, 84
	make_text_macro 'e', area, 335, 84
	make_text_macro 'e', area, 382, 84
	make_text_macro 'e', area, 429, 84
	make_text_macro 'e', area, 476, 84
	make_text_macro 'e', area, 523, 84
	make_text_macro 'e', area, 570, 84
	make_text_macro 'e', area, 617, 84
	make_text_macro 'e', area, 664, 84
	make_text_macro 'e', area, 100, 108
	make_text_macro 'e', area, 147, 108
	make_text_macro 'e', area, 194, 108
	make_text_macro 'e', area, 241, 108
	make_text_macro 'e', area, 288, 108
	make_text_macro 'e', area, 335, 108
	make_text_macro 'e', area, 382, 108
	make_text_macro 'e', area, 429, 108
	make_text_macro 'e', area, 476, 108
	make_text_macro 'e', area, 523, 108
	make_text_macro 'e', area, 570, 108
	make_text_macro 'e', area, 617, 108
	make_text_macro 'e', area, 664, 108
	make_text_macro 'e', area, 100, 132
	make_text_macro 'e', area, 147, 132
	make_text_macro 'e', area, 194, 132
	make_text_macro 'e', area, 241, 132
	make_text_macro 'e', area, 288, 132
	make_text_macro 'e', area, 335, 132
	make_text_macro 'e', area, 382, 132
	make_text_macro 'e', area, 429, 132
	make_text_macro 'e', area, 476, 132
	make_text_macro 'e', area, 523, 132
	make_text_macro 'e', area, 570, 132
	make_text_macro 'e', area, 617, 132
	make_text_macro 'e', area, 664, 132
	make_text_macro 'e', area, 100, 156
	make_text_macro 'e', area, 147, 156
	make_text_macro 'e', area, 194, 156
	make_text_macro 'e', area, 241, 156
	make_text_macro 'e', area, 288, 156
	make_text_macro 'e', area, 335, 156
	make_text_macro 'e', area, 382, 156
	make_text_macro 'e', area, 429, 156
	make_text_macro 'e', area, 476, 156
	make_text_macro 'e', area, 523, 156
	make_text_macro 'e', area, 570, 156
	make_text_macro 'e', area, 617, 156
	make_text_macro 'e', area, 664, 156
	make_text_macro 'e', area, 100, 180
	make_text_macro 'e', area, 147, 180
	make_text_macro 'e', area, 194, 180
	make_text_macro 'e', area, 241, 180
	make_text_macro 'e', area, 288, 180
	make_text_macro 'e', area, 335, 180
	make_text_macro 'e', area, 382, 180
	make_text_macro 'e', area, 429, 180
	make_text_macro 'e', area, 476, 180
	make_text_macro 'e', area, 523, 180
	make_text_macro 'e', area, 570, 180
	make_text_macro 'e', area, 617, 180
	make_text_macro 'e', area, 664, 180
	make_text_macro 'e', area, 100, 204
	make_text_macro 'e', area, 147, 204
	make_text_macro 'e', area, 194, 204
	make_text_macro 'e', area, 241, 204
	make_text_macro 'e', area, 288, 204
	make_text_macro 'e', area, 335, 204
	make_text_macro 'e', area, 382, 204
	make_text_macro 'e', area, 429, 204
	make_text_macro 'e', area, 476, 204
	make_text_macro 'e', area, 523, 204
	make_text_macro 'e', area, 570, 204
	make_text_macro 'e', area, 617, 204
	make_text_macro 'e', area, 664, 204
	make_text_macro 'e', area, 100, 228
	make_text_macro 'e', area, 147, 228
	make_text_macro 'e', area, 194, 228
	make_text_macro 'e', area, 241, 228
	make_text_macro 'e', area, 288, 228
	make_text_macro 'e', area, 335, 228
	make_text_macro 'e', area, 382, 228
	make_text_macro 'e', area, 429, 228
	make_text_macro 'e', area, 476, 228
	make_text_macro 'e', area, 523, 228
	make_text_macro 'e', area, 570, 228
	make_text_macro 'e', area, 617, 228
	make_text_macro 'e', area, 664, 228
	make_text_macro 'e', area, 100, 252
	make_text_macro 'e', area, 147, 252
	make_text_macro 'e', area, 194, 252
	make_text_macro 'e', area, 241, 252
	make_text_macro 'e', area, 288, 252
	make_text_macro 'e', area, 335, 252
	make_text_macro 'e', area, 382, 252
	make_text_macro 'e', area, 429, 252
	make_text_macro 'e', area, 476, 252
	make_text_macro 'e', area, 523, 252
	make_text_macro 'e', area, 570, 252
	make_text_macro 'e', area, 617, 252
	make_text_macro 'e', area, 664, 252
	make_text_macro 'e', area, 100, 276
	make_text_macro 'e', area, 147, 276
	make_text_macro 'e', area, 194, 276
	make_text_macro 'e', area, 241, 276
	make_text_macro 'e', area, 288, 276
	make_text_macro 'e', area, 335, 276
	make_text_macro 'e', area, 382, 276
	make_text_macro 'e', area, 429, 276
	make_text_macro 'e', area, 476, 276
	make_text_macro 'e', area, 523, 276
	make_text_macro 'e', area, 570, 276
	make_text_macro 'e', area, 617, 276
	make_text_macro 'e', area, 664, 276
	make_text_macro 'e', area, 100, 300
	make_text_macro 'e', area, 147, 300
	make_text_macro 'e', area, 194, 300
	make_text_macro 'e', area, 241, 300
	make_text_macro 'e', area, 288, 300
	make_text_macro 'e', area, 335, 300
	make_text_macro 'e', area, 382, 300
	make_text_macro 'e', area, 429, 300
	make_text_macro 'e', area, 476, 300
	make_text_macro 'e', area, 523, 300
	make_text_macro 'e', area, 570, 300
	make_text_macro 'e', area, 617, 300
	make_text_macro 'e', area, 664, 300
	make_text_macro 'e', area, 100, 324
	make_text_macro 'e', area, 147, 324
	make_text_macro 'e', area, 194, 324
	make_text_macro 'e', area, 241, 324
	make_text_macro 'e', area, 288, 324
	make_text_macro 'e', area, 335, 324
	make_text_macro 'e', area, 382, 324
	make_text_macro 'e', area, 429, 324
	make_text_macro 'e', area, 476, 324
	make_text_macro 'e', area, 523, 324
	make_text_macro 'e', area, 570, 324
	make_text_macro 'e', area, 617, 324
	make_text_macro 'e', area, 664, 324
	make_text_macro 'e', area, 100, 348
	make_text_macro 'e', area, 147, 348
	make_text_macro 'e', area, 194, 348
	make_text_macro 'e', area, 241, 348
	make_text_macro 'e', area, 288, 348
	make_text_macro 'e', area, 335, 348
	make_text_macro 'e', area, 382, 348
	make_text_macro 'e', area, 429, 348
	make_text_macro 'e', area, 476, 348
	make_text_macro 'e', area, 523, 348
	make_text_macro 'e', area, 570, 348
	make_text_macro 'e', area, 617, 348
	make_text_macro 'e', area, 664, 348
	make_text_macro 'e', area, 100, 372
	make_text_macro 'e', area, 147, 372
	make_text_macro 'e', area, 194, 372
	make_text_macro 'e', area, 241, 372
	make_text_macro 'e', area, 288, 372
	make_text_macro 'e', area, 335, 372
	make_text_macro 'e', area, 382, 372
	make_text_macro 'e', area, 429, 372
	make_text_macro 'e', area, 476, 372
	make_text_macro 'e', area, 523, 372
	make_text_macro 'e', area, 570, 372
	make_text_macro 'e', area, 617, 372
	make_text_macro 'e', area, 664, 372
	make_text_macro 'e', area, 100, 396
	make_text_macro 'e', area, 147, 396
	make_text_macro 'e', area, 194, 396
	make_text_macro 'e', area, 241, 396
	make_text_macro 'e', area, 288, 396
	make_text_macro 'e', area, 335, 396
	make_text_macro 'e', area, 382, 396
	make_text_macro 'e', area, 429, 396
	make_text_macro 'e', area, 476, 396
	make_text_macro 'e', area, 523, 396
	make_text_macro 'e', area, 570, 396
	make_text_macro 'e', area, 617, 396
	make_text_macro 'e', area, 664, 396
	make_text_macro 'e', area, 100, 420
	make_text_macro 'e', area, 147, 420
	make_text_macro 'e', area, 194, 420
	make_text_macro 'e', area, 241, 420
	make_text_macro 'e', area, 288, 420
	make_text_macro 'e', area, 335, 420
	make_text_macro 'e', area, 382, 420
	make_text_macro 'e', area, 429, 420
	make_text_macro 'e', area, 476, 420
	make_text_macro 'e', area, 523, 420
	make_text_macro 'e', area, 570, 420
	make_text_macro 'e', area, 617, 420
	make_text_macro 'e', area, 664, 420
	make_text_macro 'e', area, 100, 444
	make_text_macro 'e', area, 147, 444
	make_text_macro 'e', area, 194, 444
	make_text_macro 'e', area, 241, 444
	make_text_macro 'e', area, 288, 444
	make_text_macro 'e', area, 335, 444
	make_text_macro 'e', area, 382, 444
	make_text_macro 'e', area, 429, 444
	make_text_macro 'e', area, 476, 444
	make_text_macro 'e', area, 523, 444
	make_text_macro 'e', area, 570, 444
	make_text_macro 'e', area, 617, 444
	make_text_macro 'e', area, 664, 444
	make_text_macro 'e', area, 100, 468
	make_text_macro 'e', area, 147, 468
	make_text_macro 'e', area, 194, 468
	make_text_macro 'e', area, 241, 468
	make_text_macro 'e', area, 288, 468
	make_text_macro 'e', area, 335, 468
	make_text_macro 'e', area, 382, 468
	make_text_macro 'e', area, 429, 468
	make_text_macro 'e', area, 476, 468
	make_text_macro 'e', area, 523, 468
	make_text_macro 'e', area, 570, 468
	make_text_macro 'e', area, 617, 468
	make_text_macro 'e', area, 664, 468
	
	
		;; nori
		

	
	

	
	
		;;;; rama
	
	make_text_macro 'f', area, 0, 0
	make_text_macro 'f', area, 45, 0
	make_text_macro 'f', area, 90, 0
	make_text_macro 'f', area, 135, 0
	make_text_macro 'f', area, 180, 0
	make_text_macro 'f', area, 225, 0
	make_text_macro 'f', area, 270, 0
	make_text_macro 'f', area, 315, 0
	make_text_macro 'f', area, 360, 0
	make_text_macro 'f', area, 405, 0
	make_text_macro 'f', area, 450, 0
	make_text_macro 'f', area, 495, 0
	make_text_macro 'f', area, 540, 0
	make_text_macro 'f', area, 585, 0
	make_text_macro 'f', area, 630, 0
	make_text_macro 'f', area, 675, 0
	make_text_macro 'f', area, 720, 0
	make_text_macro 'f', area, 765, 0
	
	make_text_macro 'f', area, 0, 21
	make_text_macro 'f', area, 45, 21
	make_text_macro 'f', area, 90, 21
	make_text_macro 'f', area, 135, 21
	make_text_macro 'f', area, 180, 21
	make_text_macro 'f', area, 225, 21
	make_text_macro 'f', area, 270, 21
	make_text_macro 'f', area, 315, 21
	make_text_macro 'f', area, 360, 21
	make_text_macro 'f', area, 405, 21
	make_text_macro 'f', area, 450, 21
	make_text_macro 'f', area, 495, 21
	make_text_macro 'f', area, 540, 21
	make_text_macro 'f', area, 585, 21
	make_text_macro 'f', area, 630, 21
	make_text_macro 'f', area, 675, 21
	make_text_macro 'f', area, 720, 21
	make_text_macro 'f', area, 765, 21
	
	make_text_macro 'f', area, 0, 42 
	make_text_macro 'f', area, 0, 63	
	make_text_macro 'f', area, 0, 84
	make_text_macro 'f', area, 0, 105
	make_text_macro 'f', area, 0, 126
	make_text_macro 'f', area, 0, 147
	make_text_macro 'f', area, 0, 168
	make_text_macro 'f', area, 0, 189
	make_text_macro 'f', area, 0, 210
	make_text_macro 'f', area, 0, 231
	make_text_macro 'f', area, 0, 252
	make_text_macro 'f', area, 0, 273 
	make_text_macro 'f', area, 0, 294
	make_text_macro 'f', area, 0, 315
	make_text_macro 'f', area, 0, 336
	make_text_macro 'f', area, 0, 357
	make_text_macro 'f', area, 0, 378
	make_text_macro 'f', area, 0, 399
	make_text_macro 'f', area, 0, 420
	make_text_macro 'f', area, 0, 441
	make_text_macro 'f', area, 0, 462
	make_text_macro 'f', area, 0, 483
	make_text_macro 'f', area, 0, 504
	make_text_macro 'f', area, 0, 525
	make_text_macro 'f', area, 0, 546
	make_text_macro 'f', area, 0, 567
	make_text_macro 'f', area, 0, 588
	
	make_text_macro 'f', area, 45, 42
	make_text_macro 'f', area, 45, 63
	make_text_macro 'f', area, 45, 84
	make_text_macro 'f', area, 45, 105
	make_text_macro 'f', area, 45, 126
	make_text_macro 'f', area, 45, 147
	make_text_macro 'f', area, 45, 168
	make_text_macro 'f', area, 45, 189
	make_text_macro 'f', area, 45, 210
	make_text_macro 'f', area, 45, 231
	make_text_macro 'f', area, 45, 252
	make_text_macro 'f', area, 45, 273
	make_text_macro 'f', area, 45, 294
	make_text_macro 'f', area, 45, 315
	make_text_macro 'f', area, 45, 336
	make_text_macro 'f', area, 45, 357
	make_text_macro 'f', area, 45, 378
	make_text_macro 'f', area, 45, 399
	make_text_macro 'f', area, 45, 420
	make_text_macro 'f', area, 45, 441
	make_text_macro 'f', area, 45, 462
	make_text_macro 'f', area, 45, 483
	make_text_macro 'f', area, 45, 504
	make_text_macro 'f', area, 45, 525
	make_text_macro 'f', area, 45, 546
	make_text_macro 'f', area, 45, 567
	make_text_macro 'f', area, 45, 588
	
	make_text_macro 'f', area, 720, 42
	make_text_macro 'f', area, 720, 63
	make_text_macro 'f', area, 720, 84
	make_text_macro 'f', area, 720, 105
	make_text_macro 'f', area, 720, 126
	make_text_macro 'f', area, 720, 147
	make_text_macro 'f', area, 720, 168
	make_text_macro 'f', area, 720, 189
	make_text_macro 'f', area, 720, 210
	make_text_macro 'f', area, 720, 231
	make_text_macro 'f', area, 720, 252
	make_text_macro 'f', area, 720, 273
	make_text_macro 'f', area, 720, 294
	make_text_macro 'f', area, 720, 315
	make_text_macro 'f', area, 720, 336
	make_text_macro 'f', area, 720, 357
	make_text_macro 'f', area, 720, 378
	make_text_macro 'f', area, 720, 399
	make_text_macro 'f', area, 720, 420
	make_text_macro 'f', area, 720, 441
	make_text_macro 'f', area, 720, 462
	make_text_macro 'f', area, 720, 483
	make_text_macro 'f', area, 720, 504
	make_text_macro 'f', area, 720, 525
	make_text_macro 'f', area, 720, 546
	make_text_macro 'f', area, 720, 567
	make_text_macro 'f', area, 720, 588

	make_text_macro 'f', area, 765, 0
	make_text_macro 'f', area, 765, 21
	make_text_macro 'f', area, 765, 42
	make_text_macro 'f', area, 765, 63
	make_text_macro 'f', area, 765, 84
	make_text_macro 'f', area, 765, 105
	make_text_macro 'f', area, 765, 126
	make_text_macro 'f', area, 765, 147
	make_text_macro 'f', area, 765, 168
	make_text_macro 'f', area, 765, 189
	make_text_macro 'f', area, 765, 210
	make_text_macro 'f', area, 765, 231
	make_text_macro 'f', area, 765, 252
	make_text_macro 'f', area, 765, 273
	make_text_macro 'f', area, 765, 294
	make_text_macro 'f', area, 765, 315
	make_text_macro 'f', area, 765, 336
	make_text_macro 'f', area, 765, 357
	make_text_macro 'f', area, 765, 378
	make_text_macro 'f', area, 765, 399
	make_text_macro 'f', area, 765, 420
	make_text_macro 'f', area, 765, 441
	make_text_macro 'f', area, 765, 462
	make_text_macro 'f', area, 765, 483
	make_text_macro 'f', area, 765, 504
	make_text_macro 'f', area, 765, 525
	make_text_macro 'f', area, 765, 546
	make_text_macro 'f', area, 765, 567
	make_text_macro 'f', area, 765, 588
	
	make_text_macro 'f', area, 0, 567
	make_text_macro 'f', area, 45, 567
	make_text_macro 'f', area, 90, 567
	make_text_macro 'f', area, 135, 567
	make_text_macro 'f', area, 180, 567
	make_text_macro 'f', area, 225, 567
	make_text_macro 'f', area, 270, 567
	make_text_macro 'f', area, 315, 567
	make_text_macro 'f', area, 360, 567
	make_text_macro 'f', area, 405, 567
	make_text_macro 'f', area, 450, 567
	make_text_macro 'f', area, 495, 567
	make_text_macro 'f', area, 540, 567
	make_text_macro 'f', area, 585, 567
	make_text_macro 'f', area, 630, 567
	make_text_macro 'f', area, 675, 567

	make_text_macro 'f', area, 0, 588
	make_text_macro 'f', area, 45, 588 
	make_text_macro 'f', area, 90, 588
	make_text_macro 'f', area, 135, 588
	make_text_macro 'f', area, 180, 588
	make_text_macro 'f', area, 225, 588
	make_text_macro 'f', area, 270, 588
	make_text_macro 'f', area, 315, 588
	make_text_macro 'f', area, 360, 588
	make_text_macro 'f', area, 405, 588
	make_text_macro 'f', area, 450, 588
	make_text_macro 'f', area, 495, 588
	make_text_macro 'f', area, 540, 588
	make_text_macro 'f', area, 585, 588
	make_text_macro 'f', area, 630, 588
	make_text_macro 'f', area, 675, 588
	
	
	
	
	
	; iarba / aici pierzi punctul!

	
	
		
	make_text_macro 'g', area, 100, 492
	make_text_macro 'g', area, 147, 492
	make_text_macro 'g', area, 194, 492
	make_text_macro 'g', area, 241, 492
	make_text_macro 'g', area, 288, 492
	make_text_macro 'g', area, 335, 492
	make_text_macro 'g', area, 382, 492
	make_text_macro 'g', area, 429, 492
	make_text_macro 'g', area, 476, 492
	make_text_macro 'g', area, 523, 492
	make_text_macro 'g', area, 570, 492
	make_text_macro 'g', area, 617, 492
	make_text_macro 'g', area, 664, 492
	
	mov index_grass,2
	make_text_macro 'g', area, 100, 516
	mov index_grass,1
	make_text_macro 'g', area, 147, 516
	make_text_macro 'g', area, 194, 516
	make_text_macro 'g', area, 241, 516
	make_text_macro 'g', area, 288, 516
	make_text_macro 'g', area, 335, 516
	mov index_grass,2
	make_text_macro 'g', area, 382, 516
	mov index_grass,1
	make_text_macro 'g', area, 429, 516
	make_text_macro 'g', area, 476, 516
	make_text_macro 'g', area, 523, 516
	make_text_macro 'g', area, 570, 516
	make_text_macro 'g', area, 617, 516
	make_text_macro 'g', area, 664, 516
	
	
	make_text_macro 'g', area, 100, 540
	make_text_macro 'g', area, 147, 540
	make_text_macro 'g', area, 194, 540
	mov index_grass,2
	make_text_macro 'g', area, 241, 540
	mov index_grass,1
	make_text_macro 'g', area, 288, 540
	make_text_macro 'g', area, 335, 540
	make_text_macro 'g', area, 382, 540
	make_text_macro 'g', area, 429, 540
	make_text_macro 'g', area, 476, 540
	make_text_macro 'g', area, 523, 540
	mov index_grass,2
	make_text_macro 'g', area, 570, 540
	mov index_grass,1
	make_text_macro 'g', area, 617, 540
	make_text_macro 'g', area, 664, 540

	

    ;;--> ai ramas aici
	mov index_heart,1
	make_text_macro 'h',area,365,110
	mov index_heart,0
	marcheaza_ocupat 365,110,ocupat,1	
	
	;make_text_macro 'r',area,142,140
	;marcheaza_ocupat 142,140,ocupat,1
	make_text_macro 'r',area,192,140
	marcheaza_ocupat 192,140,ocupat,1
	make_text_macro 'r',area,242,140
	marcheaza_ocupat 242,140,ocupat,1
	make_text_macro 'r',area,292,140
	marcheaza_ocupat 292,140,ocupat,1
	make_text_macro 'r',area,342,140
	marcheaza_ocupat 342,140,ocupat,1
	make_text_macro 'r',area,392,140
	marcheaza_ocupat 392,140,ocupat,1
	make_text_macro 'r',area,442,140
	marcheaza_ocupat 442,140,ocupat,1
	make_text_macro 'r',area,492,140
	marcheaza_ocupat 492,140,ocupat,1
	make_text_macro 'r',area,542,140
	marcheaza_ocupat 542,140,ocupat,1
	;make_text_macro 'r',area,592,140
	;marcheaza_ocupat 592,140,ocupat,1
;hello
	make_text_macro 'r',area,192,170
	marcheaza_ocupat 192,170,ocupat,1
	make_text_macro 'r',area,242,170
	marcheaza_ocupat 242,170,ocupat,1
	make_text_macro 'r',area,292,170
	marcheaza_ocupat 292,170,ocupat,1
	make_text_macro 'r',area,342,170
	marcheaza_ocupat 342,170,ocupat,1
	make_text_macro 'r',area,392,170
	marcheaza_ocupat 392,170,ocupat,1
	make_text_macro 'r',area,442,170
	marcheaza_ocupat 442,170,ocupat,1
	make_text_macro 'r',area,492,170
	marcheaza_ocupat 492,170,ocupat,1
	make_text_macro 'r',area,542,170
	marcheaza_ocupat 542,170,ocupat,1
	
	
	make_text_macro 'r',area,242,200
	marcheaza_ocupat 242,200,ocupat,1
	make_text_macro 'r',area,292,200
	marcheaza_ocupat 292,200,ocupat,1
	make_text_macro 'r',area,342,200
	marcheaza_ocupat 342,200,ocupat,1
	make_text_macro 'r',area,392,200
	marcheaza_ocupat 392,200,ocupat,1
	make_text_macro 'r',area,442,200
	marcheaza_ocupat 442,200,ocupat,1
	make_text_macro 'r',area,492,200
	marcheaza_ocupat 492,200,ocupat,1

	;; SCOR
	
	make_text_macro ' ', area, 0, 21
	make_text_macro 'S', area, 7, 21
	make_text_macro 'C', area, 17, 21
	make_text_macro 'O', area, 27, 21 
	make_text_macro 'R', area, 37, 21 
	make_text_macro 'E', area, 47, 21
	
	make_text_macro '0', area, 0, 42
	make_text_macro '0', area, 47, 42

	
	
	;; vieti
	
	make_text_macro 'h', area, 0, 105
	make_text_macro 'h', area, 0, 128
	make_text_macro 'h', area, 0, 151
	;make_text_macro 'h', area, 0, 174
;make_text_macro 'k',area,0,0
	make_text_macro 'k',area,skate_y,skate_x
	make_text_macro 'o', area, racoon_y, racoon_x; raton
	inc index_racoon
	mov eax,racoon_y
	add eax,33
	make_text_macro 'o', area, eax, racoon_x ; raton
		make_text_macro 'p', area, 120, 470
	;;make_text_macro 's',area,sup_y1,sup_x
	;; plasam la inceput mingea si suportul
	evt_key:	; a fost apasata o tasta
	mov eax , [ebp+arg2]
	

	
	cmp eax, stanga
	je deplasare_stanga
	
	cmp eax, dreapta 
	je deplasare_dreapta
	
	cmp eax,incepe_jocul
	je START_GAME
	
	
	
	
	
	
	deplasare_stanga:
		mov directie,1
		mov eax,counter
		mov ultimul_clock,eax
		make_text_macro 'e', area, sup_y1, sup_x
		jmp evt_click
		
	deplasare_dreapta:
		
		mov directie,2
		mov eax,counter
		mov ultimul_clock,eax
		make_text_macro 'e', area, sup_y1, sup_x
		
		START_GAME:
		mov a_inceput,1
	
	
	
	evt_click:
	
	;; desenez un pixel in matrice
	mov eax, [ebp+arg3] ; eax = y;
	mov ebx, area_width
	mul ebx ; eax = y*area_width
	add eax, [ebp+arg2] ; eax = y*area_width + x
	shl eax, 2 ; eax = 2*(y*area_width + x)
	add eax, area
	mov dword ptr [eax] , 0FF0000h
	
	cmp go,0
	je evt_timer
	
	
	mov ebx, [ebp+arg2] ; eax = x;
	mov eax, [ebp+arg3] ; eax = y;
		
	; altfel
	
	cmp resume_ys,eax
	jl game_over
	cmp eax,resume_yd
	jg game_over
	cmp resume_xs,ebx
	jl game_over
	cmp ebx,resume_xj
	jl game_over
	
	
	
	evt_timer:
		
		
		inc counter
		
		
		
	
		
		
				
		deplasare_raton:
		
		
		
		
		
		
	
		mov eax, vest
		add eax,5
		cmp eax,racoon_y
		jl go_racoon
				make_text_macro 'e',area,skate_y,skate_x
				mov eax,skate_y
				sub eax,15
				make_text_macro 'e',area,eax,skate_x
		mov ebx,racoon_y
		mov eax,racoon_x
		add eax,24
		add ebx,33
		make_text_macro 'e', area, racoon_y, racoon_x 
		make_text_macro 'e', area, ebx, racoon_x 
		make_text_macro 'e', area, racoon_y, eax 
		make_text_macro 'e', area, ebx, eax 
		add eax,5
		make_text_macro 'e', area, racoon_y, eax 
		make_text_macro 'e', area, ebx, eax 
		

		mov racoon_x , 431
		mov racoon_y , 630
		mov skate_x, 471
		mov skate_y, 642
		jmp MINGE

		go_racoon:
		;;;;;;;;;;;;;;;;;CAZ DEPLASARE DR-ST
		;sterge

				make_text_macro 'e',area,skate_y,skate_x
				mov eax,skate_y
				sub eax,15
				make_text_macro 'e',area,eax,skate_x
				mov ebx,racoon_y
				mov eax,racoon_x
				add eax,24
				add ebx,33
				make_text_macro 'e', area, racoon_y, racoon_x 
				make_text_macro 'e', area, ebx, racoon_x 
				make_text_macro 'e', area, racoon_y, eax 
				make_text_macro 'e', area, ebx, eax 
				add eax,5
				make_text_macro 'e', area, racoon_y, eax 
				make_text_macro 'e', area, ebx, eax 
					
					
			sub racoon_y,5
			sub skate_y,5
			make_text_macro 'k',area,skate_y,skate_x
			mov index_racoon,0
			make_text_macro 'o', area, racoon_y, racoon_x; raton
			inc index_racoon
			mov eax,racoon_y
			add eax,racoon_width
			make_text_macro 'o', area, eax, racoon_x ; raton
		
		

		;pentru MINGE (deplasare continua->pozitie relativa)
		;make_text_macro 'b', area, ball_y, ball_x
		
		; push counter
		; push offset format
		; call printf
		; add esp,8
		
		
		;;verificam daca loveste marginile(momentan)
		MINGE:
		cmp unghi,90
		je u90
		cmp unghi,451
		je u45st
		cmp unghi,452
		je u45dr
		cmp unghi,301
		je u30st
		cmp unghi,302
		je u30dr
		cmp unghi,601
		je u60st
		cmp unghi,602
		je u60dr
		
		u90:
			mov var3,10
			mov var4,0
			jmp depasire_cadran
		u45st:
			mov var3,10
			mov var4,10
			jmp depasire_cadran
		u45dr:
			mov var3,10
			mov var4,-10
			jmp depasire_cadran
		u30st: ;30
			mov var3,10
			mov var4,30
			jmp depasire_cadran
		u30dr:
			mov var3,10
			mov var4,-30
			jmp depasire_cadran
		u60st:
			;; aici nu ajunge la podea!!=>deci????????????
			mov var3,30
			mov var4,10
			jmp depasire_cadran
		u60dr:
			mov var3,30 
			mov var4,-10
			jmp depasire_cadran
			
		depasire_cadran:
			;sub ball_x,10
			;sub ball_y,10
			
			cmp directie_ball,2
			je jos
			
			;; merge in sus
			mov eax,ball_x
			sub eax,var3
			mov var1,eax
			mov eax,ball_y
			sub eax,var4
			mov var2,eax

			jmp compara
			
			jos:
			mov eax,ball_x
			add eax,var3
			mov var1,eax
			mov eax,ball_y
			add eax,var4
			mov var2,eax
			
			
			
			compara:
				mov eax,var1
				cmp eax,nord
				jle schimba_directie
				;altfel nu depaseste nord
				
				cmp eax,sud
				jge ciocnire_podea
				;altfel nu depaseste sud
				
				mov eax,var2
				cmp eax,vest
				jle schimba_directie
				; altfel nu depaseste vest
				
				cmp eax,est
				jge schimba_directie
				; altfel nu depaseste est
				; e in cadran
				
				
				jmp deseneaza_bila
			
		
		;altfel
		ciocnire_podea:

			;; altfel stergem o viata SAU scadem dimensiunea suportului daca  e marit
			cmp  dim_suport,symbol_width
			jne suport_mic
			
			
			
			;; altfel micsoram la loc paleta cand ne ciocnim de podea
			
			mov index_sup,0
			mov dim_suport,20
			jmp schimba_directie
			suport_mic:
			make_text_macro 'f', area, heart_y, heart_x
			sub heart_x,23
				dec count_lives
				cmp count_lives,0
				je game_over
				
	
			
			
		schimba_directie:
		cmp directie_ball,1 ; 1=sus
		je dir_down
		;altfel 
		mov directie_ball,1
		jmp deseneaza_bila

		dir_down:
			mov directie_ball,2

		
		deseneaza_bila:
			cmp erase_ball,1
			jne unghiuri
			make_text_macro 't', area, ball_y, ball_x ; stergem bila mai intai  ;; demonstratie
			;;;;;;;;;;;;;
			
			unghiuri:
			cmp unghi,90
			je directie_90grade
			cmp unghi,451
			je directie_45grade_stanga
			cmp unghi,452
			je directie_45grade_dreapta
			cmp unghi,301
			je directie_30grade_stanga
			cmp unghi,302
			je directie_30grade_dreapta
			cmp unghi,601
			je directie_60grade_stanga
			cmp unghi,602
			je directie_60grade_dreapta
			;;;;;;;;;;;;;;
			
			directie_90grade:
				cmp directie_ball,2
				je in_jos90
				sub ball_x,10
				jmp creaza_bila
				in_jos90:
					add ball_x,10

				jmp creaza_bila
				
			directie_45grade_stanga:
				
				
				cmp directie_ball,2
				je in_jos45_stanga
				sub ball_x,10
				sub ball_y,10
				jmp creaza_bila
				in_jos45_stanga:
					add ball_x,10
					add ball_y,10
				jmp creaza_bila
				
				
			directie_45grade_dreapta:
				cmp directie_ball,2
				je in_jos45_dreapta
				sub ball_x,10
				add ball_y,10
				jmp creaza_bila
				in_jos45_dreapta:
					add ball_x,10
					sub ball_y,10
				jmp creaza_bila
			
			directie_30grade_stanga:
				cmp directie_ball,2
				je in_jos30_stanga
				sub ball_x,10
				sub ball_y,25
				jmp creaza_bila
				in_jos30_stanga:
					add ball_x,10   
					add ball_y,25
				jmp creaza_bila
				
			directie_30grade_dreapta:
				cmp directie_ball,2
				je in_jos30_dreapta
				sub ball_x,10
				add ball_y,25
				jmp creaza_bila
				in_jos30_dreapta:
					add ball_x,10
					sub ball_y,25
				jmp creaza_bila	
					
			directie_60grade_stanga:
				cmp directie_ball,2
				je in_jos60_stanga 
				sub ball_x,25
				sub ball_y,10
				jmp creaza_bila
				in_jos60_stanga:
					add ball_x,25
					add ball_y,10
				jmp creaza_bila
				
			directie_60grade_dreapta:
				cmp directie_ball,2
				je in_jos60_dreapta
				sub ball_x,25
				add ball_y,10
				jmp creaza_bila
				in_jos60_dreapta:
					add ball_x,25
					sub ball_y,10
				jmp creaza_bila
				
			creaza_bila:
			
			
			
			;;; 	CIOCNIRE CU BLOCURI
			
			
			
			; trebuie sa verificam pixelii din colturi(4)
			
		
			
			mov esi,ball_x
			mov edi,ball_y
			;; cu cativa pixeli mai devreme ca sa nu stearga blocurile
			sub esi,3
			;sus stanga
			verifica_ocupat edi,esi,ocupat
			cmp eax,1
			je pozitie_ocupata ;ocupat

			;sus dreapta
			add edi,ball_width
			
			;; scadem ca sa nu stearga blocurile incomplet
			;sub edi,3
			verifica_ocupat edi,esi,ocupat
			cmp eax,1
			je pozitie_ocupata
			
			;jos dreapta
			add esi,ball_height
			verifica_ocupat edi,esi,ocupat
			cmp eax,1
			je pozitie_ocupata
			
			;jos stanga
			sub edi,ball_width
			verifica_ocupat edi,esi,ocupat
			cmp eax,1
			jne continua
			
			; daca nu e egal cu 1, atunci niciunul din cele 4 colturi ale mingii nu atinge vreun bloc
			pozitie_ocupata:

			sterge_bloc edi,esi,ocupat
				; push var5
				; push offset format7
				; call printf
				; add esp,8
				; push var6
				; push offset format7
				; call printf
				; add esp,8
			mov edi,var5
			mov esi,var6
			marcheaza_ocupat edi,esi,ocupat,2

		
	
		
			;; schimbam scorul
			inc scor
			mov ebx, 10
			mov eax, scor
			;cifra unitatilor
			mov edx, 0
			div ebx
			add edx, '0'
			make_text_macro edx, area, 47, 42
			;cifra zecilor
			mov edx, 0
			div ebx
			add edx, '0'
			make_text_macro edx, area, 0, 42

			
				;schimbam directia
						cmp directie_ball,1 ; 1=sus
						je dir_down2
						;altfel 
						mov directie_ball,1
						jmp deseneaza_bila
						dir_down2:
						mov directie_ball,2
							
			;jmp ciocnire_suport   ;; nu are sens sa continuam pt ca tocmai ce l-a spart
			
			;; CADOURI // BONUSURI
			
			continua:
			
		
			
			cmp exista_cadou,1
			je deplasare_cadou
			
			cmp gift_y,0
			je ciocnire_suport   ; daca cumva e pozitia de initializare (0,0) sar
			
			
		
			mov bx,3
			mov eax,scor
			mov edx,0
			div bx
			cmp edx,0
			jne ciocnire_suport
			
			
			mov eax,counter
			sub eax,2   ; dupa 2 u.t. cadoul se va deplasa
			cmp clock_gift,eax
			je ciocnire_suport
			

			test_cadou:
				
			;cmp exista_cadou,1
			;je ciocnire_suport
			
			deplasare_cadou:
			
				mov index_premiu,1
				make_text_macro 'p', area,  gift_y, gift_x
				
				mov exista_cadou,1
				mov eax,gift_x
				add eax,20
								
				;; verificam daca ajunge in sud
				
				
				;; verificam daca il prinde suportul
				
			
				cmp eax,sup_x
				jl deseneaza_cadoul
				
				mov ebx,sup_y1
				cmp gift_y,ebx
				jl verifica_colt_dreapta  ; paleta e prea in  dreapta fata de coltul stang al cadoului
				
				add ebx, dim_suport 
				cmp gift_y,ebx
				jg verifica_colt_dreapta ;; e paleta prea in stanga fata de coltul stang al cadoului
				
				jmp prinde_cadoul
				
				verifica_colt_dreapta:
					mov eax,gift_y
					add eax,premiu_width
					mov ebx,sup_y1
					
					cmp eax,ebx
					jl ciocnire_iarba  ; paleta e prea in  dreapta
					
					add ebx, dim_suport ;; schimba!
					cmp eax,ebx
					jg ciocnire_iarba ;; e paleta prea in stanga 
				
				
				; altfel se afla in dreptul paletei
				prinde_cadoul:

					mov index_sup, 1 ;marim suportul
					mov dim_suport,symbol_width
					mov exista_cadou,0
					jmp ciocnire_suport
				
				ciocnire_iarba: 
				
				mov ebx,podea
				sub ebx,10
				cmp gift_x,ebx
				jl deseneaza_cadoul
				
				
				mov eax,gift_x
				add eax,20
				cmp eax,ebx
				mov exista_cadou,0
				mov index_premiu,0
				make_text_macro 'p', area,  gift_y, gift_x
				mov gift_y,0
				mov gift_x,0
				
				jge ciocnire_suport
				
				deseneaza_cadoul:
					add gift_x,10
					mov index_premiu,0
					make_text_macro 'p', area,  gift_y, gift_x
					jmp ciocnire_suport
				
				
				

				
				
			;; CIOCNIRE CU SUPORTUL / PALETA
			ciocnire_suport:
			
			mov eax, ball_x
			cmp eax, sup_x
			jl nu_ciocneste
			
			; push sup_y1
			; push offset format2
			; call printf
			; add esp,8
			
			; push ball_y
			; push offset format2
			; call printf
			; add esp,8
			
			mov ebx,ball_y
			;add ebx,23
			mov eax,sup_y1
			cmp ebx,eax
			jl nu_ciocneste
			add eax,dim_suport   ;;;;;;;;;MODIFICA
			cmp ebx,eax
			jg nu_ciocneste
				
				; altfel ciocneste si deci schimba directia dar si unghiul
				mov erase_ball,0 ; altfel sterge aiurea sub suport
				sch_dir:
					cmp directie_ball,1 ; 1=sus
					je dir_jos
					;altfel 
					mov directie_ball,1
					jmp schimba_unghi
					dir_jos:
						mov directie_ball,2
				
				schimba_unghi:
				
				;;; cum schimba unghiul? --> IN FCT DE MIJLOCUL MINGII!! ADICA BALL_Y + 6
				;
				; x+     11    23    34
				;   _____|_____|_____|_____  <-paleta
				;    30  |  60 | 60  | 30
				;         45    90   45
				
				; alternativ
				
					;
				; x+     1
				;   ___|_______|_____ <-paleta
				;    30    45    60
				;
					
						
					mov edx,0
					mov eax,unghi
					mov bx,10
					div bx
					mov var1,edx
							; push var1
							; push offset format2
							; call printf
							; add esp,8
					cmp var1,2 ; vine din dreapta==> se va duce in stanga
					je scadere
					; altfel var1 =1 sau var1 = 0 prin incrementare fie avem 1 fie 2 (st sau dr)
					inc var1
					jmp det_unghi
					scadere:
					dec var1 ;(st)
					
					det_unghi:
							; push var1
							; push offset format2
							; call printf
							; add esp,8
						
					mov ebx,ball_y
					add ebx,6
					mov eax,sup_y1
					
					
									add eax,5
									cmp ebx,eax 
									jle unghi30
									
									add eax,10
									cmp ebx,eax
									jle unghi45
									;15
									add eax,10 ;;->supy+35
									cmp ebx,eax
									jle unghi60
									;25
									add eax,5
									cmp ebx,eax
									jle unghi90
									;30
									add eax,6 ;;->supy+34
									jle unghi45
									;36
									add eax,42
									cmp ebx,eax
									jl unghi60
									
									;altfel
									jmp unghi30
				    
					;add eax,5 ; supy+5
				;	cmp ebx,eax
					;jle unghi30
					
					;add eax,25; supy+30
					;cmp ebx,eax
					;jle unghi45
					
					;add eax,15; supy+45
					;cmp ebx,eax
					;jle unghi60
					
					;altfel se duce la 95
					
					unghi90:
					mov unghi,90 
					jmp deseneaza_bila
					
					unghi60:
					mov eax,var1
					mov unghi,600
					add unghi,eax
					jmp deseneaza_bila
					
					unghi30:
					mov eax,var1
					mov unghi,300
					add unghi,eax
					jmp deseneaza_bila
					
					unghi45:
					mov eax,var1
					mov unghi,450
					add unghi,eax
					jmp deseneaza_bila
			
						
						
				
				
					
			nu_ciocneste:
				mov erase_ball,1
				make_text_macro 'b', area, ball_y, ball_x

		;;;;;;;;;;;;;; pentru SUPORT (deplasare stanga dreapta) 
		deplasare_suport:
		
		cmp ultimul_clock, 0
		je final_draw
		mov eax,ultimul_clock
		add eax,1 ; dupa 1 clock-uri ar trebui sa desenam suportul pe urmatoarea pozitie!!!	
		
		cmp counter,eax
		jne final_draw
		mov ultimul_clock,eax
		
		;;aflam directia de deplasare
		cmp directie,2
		je la_dreapta
		
		cmp directie,1
		je la_stanga
		;altfel e 0
		
		la_dreapta:
			add sup_y1,10
			jmp deseneaza
		la_stanga:
			sub sup_y1,10
			
		deseneaza:	
			;verificam daca e sau nu depasit cadranul			
			mov eax,vest
			cmp sup_y1,eax
			jg verifica_est
			
			; altfel se "teleporteaza" in partea dreapta			
			mov eax,est
			mov sup_y1,eax
			jmp deseneaza_suportul
			
			verifica_est:
			mov eax,est
			cmp sup_y1,eax
			jl deseneaza_suportul
			; altfel se "teleporteaza" in partea stanga
 
			mov eax,vest
			mov sup_y1,eax
			
			deseneaza_suportul:
				make_text_macro 's', area, sup_y1, sup_x
		

		mov ultimul_clock,0 
		
		

		jmp final_draw
		
		
	
		
		
		
	game_over:
	mov go,1


	make_text_macro 'e',area,365,110
	marcheaza_ocupat 365,110,ocupat,0	
	;make_text_macro 'r',area,142,140
	;marcheaza_ocupat 142,140,ocupat,0
	make_text_macro 'e',area,192,140
	marcheaza_ocupat 192,140,ocupat,0
	make_text_macro 'e',area,242,140
	marcheaza_ocupat 242,140,ocupat,0
	make_text_macro 'e',area,292,140
	marcheaza_ocupat 292,140,ocupat,0
	make_text_macro 'e',area,342,140
	marcheaza_ocupat 342,140,ocupat,0
	make_text_macro 'e',area,392,140
	marcheaza_ocupat 392,140,ocupat,0
	make_text_macro 'e',area,442,140
	marcheaza_ocupat 442,140,ocupat,0
	make_text_macro 'e',area,492,140
	marcheaza_ocupat 492,140,ocupat,0
	make_text_macro 'e',area,542,140
	marcheaza_ocupat 542,140,ocupat,0
	make_text_macro 'e',area,192,170
	marcheaza_ocupat 192,170,ocupat,0
	make_text_macro 'e',area,242,170
	marcheaza_ocupat 242,170,ocupat,0
	make_text_macro 'e',area,292,170
	marcheaza_ocupat 292,170,ocupat,0
	make_text_macro 'e',area,342,170
	marcheaza_ocupat 342,170,ocupat,0
	make_text_macro 'e',area,392,170
	marcheaza_ocupat 392,170,ocupat,0
	make_text_macro 'e',area,442,170
	marcheaza_ocupat 442,170,ocupat,0
	make_text_macro 'e',area,492,170
	marcheaza_ocupat 492,170,ocupat,0
	make_text_macro 'e',area,542,170
	marcheaza_ocupat 542,170,ocupat,0
	make_text_macro 'e',area,242,200
	marcheaza_ocupat 242,200,ocupat,0
	make_text_macro 'e',area,292,200
	marcheaza_ocupat 292,200,ocupat,0
	make_text_macro 'e',area,342,200
	marcheaza_ocupat 342,200,ocupat,0
	make_text_macro 'e',area,392,200
	marcheaza_ocupat 392,200,ocupat,0
	make_text_macro 'e',area,442,200
	marcheaza_ocupat 442,200,ocupat,0
	make_text_macro 'e',area,492,200
	marcheaza_ocupat 492,200,ocupat,0
	
	make_text_macro 'G',area,342,220+50
	make_text_macro 'A',area,352,220+50
	make_text_macro 'M',area,362,220+50
	make_text_macro 'E',area,372,220+50
	make_text_macro ' ',area,383,220+50
	make_text_macro 'O',area,393,220+50
	make_text_macro 'V',area,403,220+50
	make_text_macro 'E',area,413,220+50
	make_text_macro 'R',area,423,220+50
	;make_text_macro 'e',area,433,220
	
	make_text_macro 'f',area,342,200+50
	make_text_macro 'f',area,387,200+50
	make_text_macro 'f',area,342,240+50
	make_text_macro 'f',area,387,240+50
	make_text_macro 'f',area,295,200+50
	make_text_macro 'f',area,434,200+50
	make_text_macro 'f',area,295,220+50
	make_text_macro 'f',area,434,220+50
	make_text_macro 'f',area,295,240+50
	make_text_macro 'f',area,434,240+50
	
	
	


;hello
	
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
	
	end_game:

draw endp

start:
	;alocam memorie pentru zona de desenat 
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
