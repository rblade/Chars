
format PE CONSOLE

include 'win32ax.inc' ; you can simply switch between win32ax, win32wx, win64ax and win64wx here

BUFSZ EQU 10000H
HISTSZ EQU 100H
SPACE EQU 20H

.code

  start:

	mov eax, 0
	mov ecx, HISTSZ
	mov edi, hist
	rep	stosd
	
	invoke GetCommandLineW
	invoke CommandLineToArgvW, eax, cnt
	mov eax, [eax+4]
	
	invoke	CreateFileW,eax,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0
	mov [hStd], eax

rd1:
	invoke	ReadFile, [hStd], buffer, BUFSZ,tmp, NULL
	.if eax=0
		jmp disphist
	.endif
	mov ecx, [tmp]
	.if ecx=0
		jmp disphist
	.endif
	
	xor eax,eax
	mov esi, buffer
lpr:
	lodsb
	inc [hist+(eax*4)]
	loop lpr
	
	jmp rd1
	
disphist:
	invoke	GetStdHandle, STD_OUTPUT_HANDLE 
	mov [hStd], eax
	
	mov [cnt], 0
lp1:	
	
	mov ebx,[cnt]
	mov eax, [hist+(ebx*4)]
	.if eax>0
		.if ebx < SPACE
			mov ebx, SPACE
		.endif
		invoke wsprintf, buffer, _title, [cnt], ebx, eax
		invoke WriteFile, [hStd], buffer, eax, tmp, NULL
	.endif
	
	inc	[cnt]
	.if [cnt]<>HISTSZ
		jmp lp1
	.endif

	invoke	ExitProcess,0

.end start


section '.data' data readable writeable

  _title db '%3d: %c: %d',13,10,0
  _titleln = $ - _title
  
section '.bss' readable writeable

  hStd dd ?
  tmp dd ?
  cnt dd ?
  buffer rb BUFSZ
  hist rd HISTSZ