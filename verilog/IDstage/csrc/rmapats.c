#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

scalar dummyScalar;
scalar fScalarIsForced=0;
scalar fScalarIsReleased=0;
scalar fScalarHasChanged=0;
scalar fForceFromNonRoot=0;
void  hsG_0(struct dummyq_struct * I887, EBLK  * I888, U  I660);
void  hsG_0(struct dummyq_struct * I887, EBLK  * I888, U  I660)
{
    U  I1091;
    U  I1092;
    U  I1093;
    struct futq * I1094;
    I1091 = ((U )vcs_clocks) + I660;
    I1093 = I1091 & 0xfff;
    I888->I593 = (EBLK  *)(-1);
    I888->I603 = I1091;
    if (I1091 < (U )vcs_clocks) {
        I1092 = ((U  *)&vcs_clocks)[1];
        sched_millenium(I887, I888, I1092 + 1, I1091);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I660 == 1)) {
        I888->I604 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I593 = I888;
        peblkFutQ1Tail = I888;
    }
    else if ((I1094 = I887->I855[I1093].I610)) {
        I888->I604 = (struct eblk *)I1094->I609;
        I1094->I609->I593 = (RP )I888;
        I1094->I609 = (RmaEblk  *)I888;
    }
    else {
        sched_hsopt(I887, I888, I1091);
    }
}
U   hsG_1(U  I900);
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
