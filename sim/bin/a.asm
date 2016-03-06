
a.out:     ファイル形式 elf32-mist32


セクション .text の逆アセンブル:

00000000 <_start>:
   0:	0e e0 80 00 	lih	r0,0x400
   4:	1c 00 00 00 	srspw	r0
   8:	20 70 03 e2 	movepc	rret,8
   c:	14 30 00 27 	br	a8 <start>,#al

00000010 <_assert>:
  10:	0d 40 00 28 	wl16	r1,0x8
  14:	0d 60 00 20 	wh16	r1,0x0
  18:	10 a0 00 01 	st32	r0,r1
  1c:	0d 40 00 24 	wl16	r1,0x4
  20:	0d 60 00 20 	wh16	r1,0x0
  24:	0e c0 00 41 	lil	r2,1
  28:	10 a0 00 41 	st32	r2,r1
  2c:	14 30 00 00 	br	2c <_assert+0x1c>,#al

00000030 <start_timer32>:
  30:	0e c0 00 00 	lil	r0,0
  34:	1e a0 00 00 	srfrclw	r0
  38:	1e c0 00 00 	srfrchw	r0
  3c:	1e 80 00 00 	srfrcw
  40:	14 40 03 e0 	b	rret,#al

00000044 <stop_timer32>:
  44:	1a 80 00 00 	srfrcr
  48:	1a a0 00 20 	srfrclr	r1
  4c:	20 40 00 01 	move	r0,r1
  50:	14 40 03 e0 	b	rret,#al

00000054 <bench_mark>:
  54:	1f f0 ff fe 	srspadd	-8
  58:	0e c0 00 00 	lil	r0,0
  5c:	18 00 00 20 	srspr	r1
  60:	10 a0 00 01 	st32	r0,r1
  64:	13 e0 04 01 	std32	r0,r1,4
  68:	13 80 04 01 	ldd32	r0,r1,4
  6c:	00 d0 7c 07 	cmp	r0,999
  70:	14 3e 00 0c 	br	a0 <bench_mark+0x4c>,#gt
  74:	18 00 00 40 	srspr	r2
  78:	13 80 04 22 	ldd32	r1,r2,4
  7c:	10 40 00 02 	ld32	r0,r2
  80:	00 00 00 01 	add	r0,r1
  84:	10 a0 00 02 	st32	r0,r2
  88:	13 80 04 02 	ldd32	r0,r2,4
  8c:	02 00 00 00 	inc	r0,r0
  90:	13 e0 04 02 	std32	r0,r2,4
  94:	13 80 04 02 	ldd32	r0,r2,4
  98:	00 d0 7c 07 	cmp	r0,999
  9c:	14 3f ff f6 	br	74 <bench_mark+0x20>,#le
  a0:	1f f0 00 02 	srspadd	8
  a4:	14 40 03 e0 	b	rret,#al

000000a8 <start>:
  a8:	1f f0 ff fe 	srspadd	-8
  ac:	0e c0 00 00 	lil	r0,0
  b0:	1e a0 00 00 	srfrclw	r0
  b4:	1e c0 00 00 	srfrchw	r0
  b8:	1e 80 00 00 	srfrcw
  bc:	18 00 00 20 	srspr	r1
  c0:	10 a0 00 01 	st32	r0,r1
  c4:	13 e0 04 01 	std32	r0,r1,4
  c8:	13 80 04 01 	ldd32	r0,r1,4
  cc:	00 d0 7c 07 	cmp	r0,999
  d0:	14 3e 00 0c 	br	100 <start+0x58>,#gt
  d4:	18 00 00 40 	srspr	r2
  d8:	13 80 04 22 	ldd32	r1,r2,4
  dc:	10 40 00 02 	ld32	r0,r2
  e0:	00 00 00 01 	add	r0,r1
  e4:	10 a0 00 02 	st32	r0,r2
  e8:	13 80 04 02 	ldd32	r0,r2,4
  ec:	02 00 00 00 	inc	r0,r0
  f0:	13 e0 04 02 	std32	r0,r2,4
  f4:	13 80 04 02 	ldd32	r0,r2,4
  f8:	00 d0 7c 07 	cmp	r0,999
  fc:	14 3f ff f6 	br	d4 <start+0x2c>,#le
 100:	1a 80 00 00 	srfrcr
 104:	1a a0 00 20 	srfrclr	r1
 108:	1f f0 00 02 	srspadd	8
 10c:	20 40 00 01 	move	r0,r1
 110:	14 40 03 e0 	b	rret,#al

セクション .assert の逆アセンブル:

00001000 <CHECK_FLAG>:
    1000:	00 00 00 01 	add	r0,r1

00001004 <CHECK_FINISH>:
    1004:	00 00 00 00 	add	r0,r0

00001008 <CHECK_LOG>:
    1008:	00 00 00 00 	add	r0,r0

セクション .comment の逆アセンブル:

00000000 <.comment>:
   0:	47 43 43 3a 	*unknown*
   4:	20 28 47 4e 	*unknown*
   8:	55 29 20 35 	*unknown*
   c:	2e 31 2e 30 	*unknown*
	...
