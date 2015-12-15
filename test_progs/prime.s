/* GROUP 17
 * prime.s
 * Finds prime numbers less than 32
 * in an exceedingly inefficient way. 
 * Actually it finds all non primes,
 * and outputs what is left.

#define NUM 32
long a[NUM];
int main(){
  int i,j,sum;
  
  a[1]=0;
  for(i=2;i<NUM;++i) a[i]=i;
  for(i=2;i<NUM/2;++i){ 
    sum=j=i;
    do{
      for(;j<sum;++j);
      if(i!=sum)a[j]=0;
      sum+=i;      
    }while(sum<NUM);
  }
}  
 
 */

  data=1000
  lda $r29, 32 #NUM
  lda $r30, 16  #NUM/2
  lda $r9, 0  #keep track of num of overwrites
  lda $r1, 2
  lda $r11, data

/* initialize list with numbers */  
  mov $r11, $r13
  lda $r8, 1
  stq  $r31, 0($r13)
  addq $r13, 0x8, $r13
  addq  $r8, 1, $r8
initloop:
  stq  $r8, 0($r13)
  addq $r13, 0x8, $r13
  addq  $r8, 1, $r8  
  cmplt $r8, $29, $r10
  bne $r10, initloop
  
  /* compensate for init memory changes */
  addq $r11, 0x8, $r11
iloop:
  mov $r1, $r2
  mov $r1, $r3
  mov $r11,$r12
jloop:
  /* increment memory to next possible non-prime */
  addq $r3, 1, $r3
  addq $r12, 0x8, $r12
  cmplt $r3, $r2, $r10
  bne $r10, jloop

  /* don't tag if divisible by self */
  subq $r2,$r1, $r10
  beq $r10, move

  /* tag as not prime */
  addq $r9,1,$r9
  stq $31, 0($r12)

move:
  /* increment j loop */
  addq $r2, $r1, $r2
  cmplt $r2, $r29, $r10
  bne $r10, jloop
  
  /* increment possible multiples */
  addq $r11,0x8,$r11
  addq $r1, 1, $r1
  cmplt $r1, $r30, $r10
  bne $r10, iloop
  
  /*done*/
  stq $r9, 0x1100($r31)
  call_pal 0x555
  

