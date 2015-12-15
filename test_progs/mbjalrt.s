	lda 	$r5, 0x8
	lda 	$r5, 0x16
	bsr     $r26, dest
dest:	addq    $r26, $26, $1
	call_pal  0x555	
