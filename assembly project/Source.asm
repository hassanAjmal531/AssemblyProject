INCLUDE irvine32.inc
; 6 bits tag
; 4 bits set
; 6 bit offset

; same algorithm used as used in the assignment, but the addresses are  not string rather 16 bit numbers

.stack
.data
	ValidBit byte 64 DUP (-1)
	tag byte 64 DUP (-1)
	addresses DWORD 512 DUP (?)
	hitRate WORD 0
	missRate WORD 0
	tagbits word 0
	totalmiss word 0
	totalhit word 0
	hit byte 0
	miss byte 0

	str1 DWORD "the hit rate is",0
	str5 DWORD dh,ah,0

	str2 DWORD "the miss rate is",0
	str3 DWORD "average hit rate is: ","0"
	str4 DWORD "average miss rate is: ","0"
	
	set word 0

	

.code

main PROC
	
	mov eax , 5
	dec byte ptr[eax]
	call cache
	exit

	
main ENDP

cache:
	mov cl,0 ; loop counters
	mov esi ,0 ; address index
	outerLoop:
			call generateAddresses  ;;populating the the address arrays
			InnerLoop:
				mov eax,  addresses[esi]
				
				call get_tag_bits
				call getsetNumber
				mov bx , tagbits
				mov ch , BYTE ptr [tagbits]
				 
				cmp ValidBit[set], 1
				je check1
				jne l3
				check1:
					CMP tag[set], dh
					je l2
					jne l3
				mov edx, offset str
				call writeString
				mov eax, hitRate
				call writeDec
				mov edx, offset str5
				call writeString
				mov edx,offset str2
				call writeString
				mov eax,missRate
				call writeDec
				mov edx, offset str5
				call writeString
				call WriteString
				=
				add esi, 4
				CMP esi, 2084 ;
				jne InnerLoop

	call calculateTotal
	add cl,1
	CMP cl, 10
	jne outerloop

	l2:
		call calculateHitRate
		jmp InnerLoop
	
		
	l3:
		call UpdateCache
		jmp Innerloop

	mov edx, offset str3
	call writeString
	mov eax, totalhit
	call write decimal
	mov edx, offset str5
	call writeString
	mov edx, offset str4
	call writeString
	mov eax, totalmiss
	call writeDec
	
	
	ret
		

generateAddresses:
	mov esi, 0
	
	l1:
		mov bx ,0
		call Randomize
		call RandomRange
		mov addresses[esi], eax
		add esi ,2
		inc bx
		mov eax, 5120
		CMP bx, 512
		jne l1
	ret



get_tag_bits:
	mov ax, word ptr[eax]
	mov bx ,ax
	shr bx,10 ; rotating 10 bits to left to get tag bits
	mov tagbits, bx

	ret

getSetNumber:
	mov bx, ax
	shl bx,6
	shr bx, 12
	mov set, bx
	ret

calculateHitRate:
	
	
	;; calcualting hit rates 
	movzx ax, hit ; extending the 8 bit register to 16 bits
	mov bx , 512
	div bx
	mov bx, 100
	mul bx
	mov hitrate, bx
	ret

calculateMissRate:
	movzx ax, miss;; calculation miss rates  and extending the 8 bit register to 16 bits
	mov bx , 512
	div bx
	mov bx, 100
	mul bx
	mov missrate, ax
	ret

calculateTotal:  ;; calculating total miss and hit rate in order to find the average
	mov cx, hitrate
	add cx,1
	add totalhit, cx
	mov cx, missrate
	add cx, 1
	add totalmiss,cx
	ret

UpdateCache:
	mov ValidBit[set],1
	mov tag[set], dh
	call calculateMissRate
	





END main


