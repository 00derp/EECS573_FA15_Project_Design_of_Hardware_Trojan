/*
  Assembly code compiled from Decaf by 'decaf470', written by Doug Li.
*/

	  .set noat
	  .set noreorder
	  .set nomacro
	  data = 0x1000
	  global = 0x2000
	  lda		$r30, 0x7FF0	# set stack ptr to a sufficiently high addr
	  lda		$r15, 0x0000	# initialize frame ptr to something
	  lda		$r29, global	# initialize global ptr to 0x2000
	# Initialize Heap Management Table
	#   could be done at compile-time, but then we get a super large .mem file
	  heap_srl_3 = 0x1800
	  lda		$r28, heap_srl_3	# work-around since heap-start needs >15 bits
	  sll		$r28, 3, $r28	# using the $at as the heap-pointer
	# Do not write to heap-pointer!
	  stq		$r31, -32*8($r28)	# init heap table
	  stq		$r31, -31*8($r28)	# init heap table
	  stq		$r31, -30*8($r28)	# init heap table
	  stq		$r31, -29*8($r28)	# init heap table
	  stq		$r31, -28*8($r28)	# init heap table
	  stq		$r31, -27*8($r28)	# init heap table
	  stq		$r31, -26*8($r28)	# init heap table
	  stq		$r31, -25*8($r28)	# init heap table
	  stq		$r31, -24*8($r28)	# init heap table
	  stq		$r31, -23*8($r28)	# init heap table
	  stq		$r31, -22*8($r28)	# init heap table
	  stq		$r31, -21*8($r28)	# init heap table
	  stq		$r31, -20*8($r28)	# init heap table
	  stq		$r31, -19*8($r28)	# init heap table
	  stq		$r31, -18*8($r28)	# init heap table
	  stq		$r31, -17*8($r28)	# init heap table
	  stq		$r31, -16*8($r28)	# init heap table
	  stq		$r31, -15*8($r28)	# init heap table
	  stq		$r31, -14*8($r28)	# init heap table
	  stq		$r31, -13*8($r28)	# init heap table
	  stq		$r31, -12*8($r28)	# init heap table
	  stq		$r31, -11*8($r28)	# init heap table
	  stq		$r31, -10*8($r28)	# init heap table
	  stq		$r31, -9*8($r28)	# init heap table
	  stq		$r31, -8*8($r28)	# init heap table
	  stq		$r31, -7*8($r28)	# init heap table
	  stq		$r31, -6*8($r28)	# init heap table
	  stq		$r31, -5*8($r28)	# init heap table
	  stq		$r31, -4*8($r28)	# init heap table
	  stq		$r31, -3*8($r28)	# init heap table
	  stq		$r31, -2*8($r28)	# init heap table
	  stq		$r31, -1*8($r28)	# init heap table
	# End Initialize Heap Management Table
	  bsr		$r26, main	# branch to subroutine
	  call_pal	0x555		# (halt)
	  .data
	  L_DATA:			# this is where the locals and temps end up at run-time
	  .text
_test:
	# BeginFunc 16
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 16, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = 2
	  lda		$r3, 2		# load (signed) int constant value 2 into $r3
	  stq		$r3, -16($r15)	# spill _tmp0 from $r3 to $r15-16
	# _tmp1 = i * _tmp0
	  ldq		$r1, 8($r15)	# fill i to $r1 from $r15+8
	  ldq		$r2, -16($r15)	# fill _tmp0 to $r2 from $r15-16
	  mulq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill _tmp1 from $r3 to $r15-24
	# Return _tmp1
	  ldq		$r3, -24($r15)	# fill _tmp1 to $r3 from $r15-24
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
main:
	# BeginFunc 504
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 504	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp2 = 1000
	  lda		$r3, 1000		# load (signed) int constant value 1000 into $r3
	  stq		$r3, -40($r15)	# spill _tmp2 from $r3 to $r15-40
	# _tmp3 = _tmp2 < ZERO
	  ldq		$r1, -40($r15)	# fill _tmp2 to $r1 from $r15-40
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -48($r15)	# spill _tmp3 from $r3 to $r15-48
	# IfZ _tmp3 Goto __L0
	  ldq		$r1, -48($r15)	# fill _tmp3 to $r1 from $r15-48
	  blbc		$r1, __L0	# branch if _tmp3 is zero
	# Throw Exception: Array size is <= 0
	  call_pal	0xDECAF		# (exception: Array size is <= 0)
	  call_pal	0x555		# (halt)
__L0:
	# _tmp4 = _tmp2 + 1
	  ldq		$r1, -40($r15)	# fill _tmp2 to $r1 from $r15-40
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp4 from $r3 to $r15-56
	# PushParam _tmp4
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -56($r15)	# fill _tmp4 to $r1 from $r15-56
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp5 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -64($r15)	# spill _tmp5 from $r3 to $r15-64
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp5) = _tmp2
	  ldq		$r1, -40($r15)	# fill _tmp2 to $r1 from $r15-40
	  ldq		$r3, -64($r15)	# fill _tmp5 to $r3 from $r15-64
	  stq		$r1, 0($r3)	# store with offset
	# _tmp6 = _tmp5 + 8
	  ldq		$r1, -64($r15)	# fill _tmp5 to $r1 from $r15-64
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -72($r15)	# spill _tmp6 from $r3 to $r15-72
	# temp = _tmp6
	  ldq		$r3, -72($r15)	# fill _tmp6 to $r3 from $r15-72
	  stq		$r3, -32($r15)	# spill temp from $r3 to $r15-32
	# _tmp7 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -80($r15)	# spill _tmp7 from $r3 to $r15-80
	# i = _tmp7
	  ldq		$r3, -80($r15)	# fill _tmp7 to $r3 from $r15-80
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L1:
	# _tmp8 = 1000
	  lda		$r3, 1000		# load (signed) int constant value 1000 into $r3
	  stq		$r3, -88($r15)	# spill _tmp8 from $r3 to $r15-88
	# _tmp9 = i < _tmp8
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -88($r15)	# fill _tmp8 to $r2 from $r15-88
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp9 from $r3 to $r15-96
	# IfZ _tmp9 Goto __L2
	  ldq		$r1, -96($r15)	# fill _tmp9 to $r1 from $r15-96
	  blbc		$r1, __L2	# branch if _tmp9 is zero
	# _tmp10 = i < ZERO
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -104($r15)	# spill _tmp10 from $r3 to $r15-104
	# _tmp11 = *(temp + -8)
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -112($r15)	# spill _tmp11 from $r3 to $r15-112
	# _tmp12 = _tmp11 <= i
	  ldq		$r1, -112($r15)	# fill _tmp11 to $r1 from $r15-112
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -120($r15)	# spill _tmp12 from $r3 to $r15-120
	# _tmp13 = _tmp10 || _tmp12
	  ldq		$r1, -104($r15)	# fill _tmp10 to $r1 from $r15-104
	  ldq		$r2, -120($r15)	# fill _tmp12 to $r2 from $r15-120
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp13 from $r3 to $r15-128
	# IfZ _tmp13 Goto __L3
	  ldq		$r1, -128($r15)	# fill _tmp13 to $r1 from $r15-128
	  blbc		$r1, __L3	# branch if _tmp13 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L3:
	# _tmp14 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -136($r15)	# spill _tmp14 from $r3 to $r15-136
	# _tmp15 = temp + _tmp14
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r2, -136($r15)	# fill _tmp14 to $r2 from $r15-136
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp15 from $r3 to $r15-144
	# *(_tmp15) = i
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r3, -144($r15)	# fill _tmp15 to $r3 from $r15-144
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L1
	  br		__L1		# unconditional branch
__L2:
	# _tmp16 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -152($r15)	# spill _tmp16 from $r3 to $r15-152
	# i = _tmp16
	  ldq		$r3, -152($r15)	# fill _tmp16 to $r3 from $r15-152
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L4:
	# _tmp17 = 999
	  lda		$r3, 999		# load (signed) int constant value 999 into $r3
	  stq		$r3, -160($r15)	# spill _tmp17 from $r3 to $r15-160
	# _tmp18 = i < _tmp17
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -160($r15)	# fill _tmp17 to $r2 from $r15-160
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -168($r15)	# spill _tmp18 from $r3 to $r15-168
	# IfZ _tmp18 Goto __L5
	  ldq		$r1, -168($r15)	# fill _tmp18 to $r1 from $r15-168
	  blbc		$r1, __L5	# branch if _tmp18 is zero
	# _tmp19 = i < ZERO
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -176($r15)	# spill _tmp19 from $r3 to $r15-176
	# _tmp20 = *(temp + -8)
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -184($r15)	# spill _tmp20 from $r3 to $r15-184
	# _tmp21 = _tmp20 <= i
	  ldq		$r1, -184($r15)	# fill _tmp20 to $r1 from $r15-184
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -192($r15)	# spill _tmp21 from $r3 to $r15-192
	# _tmp22 = _tmp19 || _tmp21
	  ldq		$r1, -176($r15)	# fill _tmp19 to $r1 from $r15-176
	  ldq		$r2, -192($r15)	# fill _tmp21 to $r2 from $r15-192
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -200($r15)	# spill _tmp22 from $r3 to $r15-200
	# IfZ _tmp22 Goto __L6
	  ldq		$r1, -200($r15)	# fill _tmp22 to $r1 from $r15-200
	  blbc		$r1, __L6	# branch if _tmp22 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L6:
	# _tmp23 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -208($r15)	# spill _tmp23 from $r3 to $r15-208
	# _tmp24 = temp + _tmp23
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r2, -208($r15)	# fill _tmp23 to $r2 from $r15-208
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -216($r15)	# spill _tmp24 from $r3 to $r15-216
	# _tmp25 = *(_tmp24)
	  ldq		$r1, -216($r15)	# fill _tmp24 to $r1 from $r15-216
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -224($r15)	# spill _tmp25 from $r3 to $r15-224
	# j = _tmp25
	  ldq		$r3, -224($r15)	# fill _tmp25 to $r3 from $r15-224
	  stq		$r3, -24($r15)	# spill j from $r3 to $r15-24
	# _tmp26 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -232($r15)	# spill _tmp26 from $r3 to $r15-232
	# _tmp27 = i + _tmp26
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -232($r15)	# fill _tmp26 to $r2 from $r15-232
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -240($r15)	# spill _tmp27 from $r3 to $r15-240
	# _tmp28 = _tmp27 < ZERO
	  ldq		$r1, -240($r15)	# fill _tmp27 to $r1 from $r15-240
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -248($r15)	# spill _tmp28 from $r3 to $r15-248
	# _tmp29 = *(temp + -8)
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -256($r15)	# spill _tmp29 from $r3 to $r15-256
	# _tmp30 = _tmp29 <= _tmp27
	  ldq		$r1, -256($r15)	# fill _tmp29 to $r1 from $r15-256
	  ldq		$r2, -240($r15)	# fill _tmp27 to $r2 from $r15-240
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -264($r15)	# spill _tmp30 from $r3 to $r15-264
	# _tmp31 = _tmp28 || _tmp30
	  ldq		$r1, -248($r15)	# fill _tmp28 to $r1 from $r15-248
	  ldq		$r2, -264($r15)	# fill _tmp30 to $r2 from $r15-264
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -272($r15)	# spill _tmp31 from $r3 to $r15-272
	# IfZ _tmp31 Goto __L7
	  ldq		$r1, -272($r15)	# fill _tmp31 to $r1 from $r15-272
	  blbc		$r1, __L7	# branch if _tmp31 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L7:
	# _tmp32 = _tmp27 << 3
	  ldq		$r1, -240($r15)	# fill _tmp27 to $r1 from $r15-240
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -280($r15)	# spill _tmp32 from $r3 to $r15-280
	# _tmp33 = temp + _tmp32
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r2, -280($r15)	# fill _tmp32 to $r2 from $r15-280
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -288($r15)	# spill _tmp33 from $r3 to $r15-288
	# _tmp34 = 2
	  lda		$r3, 2		# load (signed) int constant value 2 into $r3
	  stq		$r3, -296($r15)	# spill _tmp34 from $r3 to $r15-296
	# _tmp35 = j * _tmp34
	  ldq		$r1, -24($r15)	# fill j to $r1 from $r15-24
	  ldq		$r2, -296($r15)	# fill _tmp34 to $r2 from $r15-296
	  mulq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -304($r15)	# spill _tmp35 from $r3 to $r15-304
	# *(_tmp33) = _tmp35
	  ldq		$r1, -304($r15)	# fill _tmp35 to $r1 from $r15-304
	  ldq		$r3, -288($r15)	# fill _tmp33 to $r3 from $r15-288
	  stq		$r1, 0($r3)	# store with offset
	# _tmp36 = i < ZERO
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -312($r15)	# spill _tmp36 from $r3 to $r15-312
	# _tmp37 = *(temp + -8)
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -320($r15)	# spill _tmp37 from $r3 to $r15-320
	# _tmp38 = _tmp37 <= i
	  ldq		$r1, -320($r15)	# fill _tmp37 to $r1 from $r15-320
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -328($r15)	# spill _tmp38 from $r3 to $r15-328
	# _tmp39 = _tmp36 || _tmp38
	  ldq		$r1, -312($r15)	# fill _tmp36 to $r1 from $r15-312
	  ldq		$r2, -328($r15)	# fill _tmp38 to $r2 from $r15-328
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -336($r15)	# spill _tmp39 from $r3 to $r15-336
	# IfZ _tmp39 Goto __L8
	  ldq		$r1, -336($r15)	# fill _tmp39 to $r1 from $r15-336
	  blbc		$r1, __L8	# branch if _tmp39 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L8:
	# _tmp40 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -344($r15)	# spill _tmp40 from $r3 to $r15-344
	# _tmp41 = temp + _tmp40
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r2, -344($r15)	# fill _tmp40 to $r2 from $r15-344
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -352($r15)	# spill _tmp41 from $r3 to $r15-352
	# _tmp42 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -360($r15)	# spill _tmp42 from $r3 to $r15-360
	# _tmp43 = i + _tmp42
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -360($r15)	# fill _tmp42 to $r2 from $r15-360
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -368($r15)	# spill _tmp43 from $r3 to $r15-368
	# _tmp44 = _tmp43 < ZERO
	  ldq		$r1, -368($r15)	# fill _tmp43 to $r1 from $r15-368
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -376($r15)	# spill _tmp44 from $r3 to $r15-376
	# _tmp45 = *(temp + -8)
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -384($r15)	# spill _tmp45 from $r3 to $r15-384
	# _tmp46 = _tmp45 <= _tmp43
	  ldq		$r1, -384($r15)	# fill _tmp45 to $r1 from $r15-384
	  ldq		$r2, -368($r15)	# fill _tmp43 to $r2 from $r15-368
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -392($r15)	# spill _tmp46 from $r3 to $r15-392
	# _tmp47 = _tmp44 || _tmp46
	  ldq		$r1, -376($r15)	# fill _tmp44 to $r1 from $r15-376
	  ldq		$r2, -392($r15)	# fill _tmp46 to $r2 from $r15-392
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -400($r15)	# spill _tmp47 from $r3 to $r15-400
	# IfZ _tmp47 Goto __L9
	  ldq		$r1, -400($r15)	# fill _tmp47 to $r1 from $r15-400
	  blbc		$r1, __L9	# branch if _tmp47 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L9:
	# _tmp48 = _tmp43 << 3
	  ldq		$r1, -368($r15)	# fill _tmp43 to $r1 from $r15-368
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -408($r15)	# spill _tmp48 from $r3 to $r15-408
	# _tmp49 = temp + _tmp48
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r2, -408($r15)	# fill _tmp48 to $r2 from $r15-408
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -416($r15)	# spill _tmp49 from $r3 to $r15-416
	# _tmp50 = *(_tmp49)
	  ldq		$r1, -416($r15)	# fill _tmp49 to $r1 from $r15-416
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -424($r15)	# spill _tmp50 from $r3 to $r15-424
	# *(_tmp41) = _tmp50
	  ldq		$r1, -424($r15)	# fill _tmp50 to $r1 from $r15-424
	  ldq		$r3, -352($r15)	# fill _tmp41 to $r3 from $r15-352
	  stq		$r1, 0($r3)	# store with offset
	# _tmp51 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -432($r15)	# spill _tmp51 from $r3 to $r15-432
	# _tmp52 = i + _tmp51
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -432($r15)	# fill _tmp51 to $r2 from $r15-432
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -440($r15)	# spill _tmp52 from $r3 to $r15-440
	# _tmp53 = _tmp52 < ZERO
	  ldq		$r1, -440($r15)	# fill _tmp52 to $r1 from $r15-440
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -448($r15)	# spill _tmp53 from $r3 to $r15-448
	# _tmp54 = *(temp + -8)
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -456($r15)	# spill _tmp54 from $r3 to $r15-456
	# _tmp55 = _tmp54 <= _tmp52
	  ldq		$r1, -456($r15)	# fill _tmp54 to $r1 from $r15-456
	  ldq		$r2, -440($r15)	# fill _tmp52 to $r2 from $r15-440
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -464($r15)	# spill _tmp55 from $r3 to $r15-464
	# _tmp56 = _tmp53 || _tmp55
	  ldq		$r1, -448($r15)	# fill _tmp53 to $r1 from $r15-448
	  ldq		$r2, -464($r15)	# fill _tmp55 to $r2 from $r15-464
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -472($r15)	# spill _tmp56 from $r3 to $r15-472
	# IfZ _tmp56 Goto __L10
	  ldq		$r1, -472($r15)	# fill _tmp56 to $r1 from $r15-472
	  blbc		$r1, __L10	# branch if _tmp56 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L10:
	# _tmp57 = _tmp52 << 3
	  ldq		$r1, -440($r15)	# fill _tmp52 to $r1 from $r15-440
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -480($r15)	# spill _tmp57 from $r3 to $r15-480
	# _tmp58 = temp + _tmp57
	  ldq		$r1, -32($r15)	# fill temp to $r1 from $r15-32
	  ldq		$r2, -480($r15)	# fill _tmp57 to $r2 from $r15-480
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -488($r15)	# spill _tmp58 from $r3 to $r15-488
	# _tmp59 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -496($r15)	# spill _tmp59 from $r3 to $r15-496
	# _tmp60 = i + _tmp59
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -496($r15)	# fill _tmp59 to $r2 from $r15-496
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -504($r15)	# spill _tmp60 from $r3 to $r15-504
	# PushParam _tmp60
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -504($r15)	# fill _tmp60 to $r1 from $r15-504
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp61 = LCall _test
	  bsr		$r26, _test	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -512($r15)	# spill _tmp61 from $r3 to $r15-512
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp58) = _tmp61
	  ldq		$r1, -512($r15)	# fill _tmp61 to $r1 from $r15-512
	  ldq		$r3, -488($r15)	# fill _tmp58 to $r3 from $r15-488
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L4
	  br		__L4		# unconditional branch
__L5:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# EndProgram
	#
	# (below is reserved for auto-appending of built-in functions)
	#
__Alloc:
	  ldq		$r16, 8($r30)	# fill arg0 to $r16 from $r30+8
	#
	# $r28 holds addr of heap-start
	# $r16 is the number of lines we want
	# $r1 holds the number of lines remaining to be allocated
	# $r2 holds the curent heap-table-entry
	# $r3 holds temp results of various comparisons
	# $r4 is used to generate various bit-masks
	# $r24 holds the current starting "bit-addr" in the heap-table
	# $r25 holds the bit-pos within the current heap-table-entry
	# $r27 holds the addr of the current heap-table-entry
	#
	  lda		$r4, 0x100
	  subq		$r28, $r4, $r27	# make addr of heap-table start
    __AllocFullReset:
	  mov		$r16, $r1	# reset goal amount
	  sll		$r27, 3, $r24	# reset bit-addr into heap-table
	  clr		$r25		# clear bit-pos marker
    __AllocSearchStart:
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  cmpult	$r1, 64, $r3	# less than a page to allocate?
	  blbs		$r3, __AllocSearchStartLittle
	  blt		$r2, __AllocSearchStartSetup	# MSB set?
	  lda		$r4, -1		# for next code-block
    __AllocSearchStartShift:
	  and		$r2, $r4, $r3
	  beq		$r3, __AllocSearchStartDone
	  sll		$r4, 1, $r4
	  addq		$r24, 1, $r24
	  and		$r24, 63, $r25
	  bne		$r25, __AllocSearchStartShift
    __AllocSearchStartSetup:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  br		__AllocSearchStart	# unconditional branch
    __AllocSearchStartLittle:
	  lda		$r4, 1
	  sll		$r4, $r1, $r4
	  subq		$r4, 1, $r4
	  br		__AllocSearchStartShift	# unconditional branch
    __AllocSearchStartDone:
	  subq		$r1, 64, $r1
	  addq		$r1, $r25, $r1
	  bgt		$r1, __AllocNotSimple
    __AllocSimpleCommit:
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  br		__AllocReturnGood	# unconditional branch
    __AllocNotSimple:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
    __AllocSearchBlock:
	  cmpult	$r1, 64, $r3
	  blbs		$r3, __AllocSearchEnd
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  bne		$r2, __AllocFullReset
	  subq		$r1, 64, $r1
	  br		__AllocSearchBlock	# unconditional branch
    __AllocSearchEnd:
	  beq		$r1,__AllocCommitStart
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  lda		$r4, 1
	  sll		$r4, $r1, $r4
	  subq		$r4, 1, $r4
	  and		$r2, $r4, $r3
	  bne		$r3, __AllocFullReset
    __AllocCommitEnd:
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, $r1, $r16
    __AllocCommitStart:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  ldq		$r2, 0($r27)
	  lda		$r4, -1
	  sll		$r4, $r25, $r4
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, 64, $r16
	  addq		$r16, $r25, $r16
	  lda		$r4, -1		# for next code-block
    __AllocCommitBlock:
	  cmpult	$r16, 64, $r3
	  blbs		$r3, __AllocReturnCheck
	  addq		$r27, 8, $r27	# next heap-table entry
	  stq		$r4, 0($r27)	# set all bits in that entry
	  subq		$r16, 64, $r16
	  br		__AllocCommitBlock	# unconditional branch
    __AllocReturnCheck:
	  beq		$r16, __AllocReturnGood	# verify we are done
	  call_pal	0xDECAF		# (exception: this really should not happen in Malloc)
	  call_pal	0x555		# (halt)
    __AllocReturnGood:
	# magically compute address for return value
	  lda		$r0, 0x2F
	  sll		$r0, 13, $r0
	  subq		$r24, $r0, $r0
	  sll		$r0, 3, $r0
	  ret				# return to caller
    __AllocReturnFail:
	  call_pal	0xDECAF		# (exception: Malloc failed to find space in heap)
	  call_pal	0x555		# (halt)
	# EndFunc
