// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  hsG_0__0 (struct dummyq_struct * I1328, EBLK  * I1323, U  I696);
void  hsG_0__0 (struct dummyq_struct * I1328, EBLK  * I1323, U  I696)
{
    U  I1589;
    U  I1590;
    U  I1591;
    struct futq * I1592;
    struct dummyq_struct * pQ = I1328;
    I1589 = ((U )vcs_clocks) + I696;
    I1591 = I1589 & ((1 << fHashTableSize) - 1);
    I1323->I741 = (EBLK  *)(-1);
    I1323->I742 = I1589;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID(I1323);
    }
    if (I1589 < (U )vcs_clocks) {
        I1590 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1323, I1590 + 1, I1589);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I696 == 1)) {
        I1323->I744 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I741 = I1323;
        peblkFutQ1Tail = I1323;
    }
    else if ((I1592 = pQ->I1231[I1591].I764)) {
        I1323->I744 = (struct eblk *)I1592->I762;
        I1592->I762->I741 = (RP )I1323;
        I1592->I762 = (RmaEblk  *)I1323;
    }
    else {
        sched_hsopt(pQ, I1323, I1589);
    }
}
void  hs_0_M_1_0__ase_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1656;
    typedef
    UB
     * TermTypePtr;
    U  I1342;
    U  I914;
    TermTypePtr  I1374;
    scalar  * I938;
    I1374 = (TermTypePtr )pcode;
    I914 = *I1374;
    I1374 -= I914;
    I938 = (scalar  *)(I1374 + 2U);
    if (I938[I914] == val) {
        return  ;
    }
    I938[I914] = val;
    val = I938[0];
    val = Xunion[(val << 7) + I938[1U]];
    pcode = ((UB  *)I1374) + 4U;
    {
        U  I1391 = 0;
        pcode = (UB  *)((UB  *)(((RP )pcode + I1391 + 7) & ~7));
    }
    {
        EBLK  * I1323;
        struct dummyq_struct * pQ;
        U  I1326;
        I1326 = 0;
        pQ = (struct dummyq_struct *)ref_vcs_clocks;
        if (*(scalar  *)((pcode + 0) + 24U) != val) {
            RmaEblk  * I1323 = (RmaEblk  *)(pcode + 0);
            *(scalar  *)((pcode + 0) + 24U) = val;
            if (!(I1323->I741)) {
                pQ->I1225->I741 = (EBLK  *)I1323;
                pQ->I1225 = (EBLK  *)I1323;
                I1323->I741 = (RP )((EBLK  *)-1);
                if (0 && rmaProfEvtProp) {
                    vcs_simpSetEBlkEvtID(I1323);
                }
            }
        }
    }
}
void  hs_0_M_1_5__ase_simv_daidir (UB  * pcode, UB  val)
{
    typedef
    UB
     * TermTypePtr;
    U  I1342;
    U  I914;
    TermTypePtr  I1374;
    scalar  * I938;
    I1374 = (TermTypePtr )pcode;
    I914 = *I1374;
    I1374 -= I914;
    I938 = (scalar  *)(I1374 + 2U);
    val = I938[I914];
    I938[I914] = 0xff;
    hs_0_M_1_0__ase_simv_daidir(pcode, val);
}
void  hs_0_M_1_9__ase_simv_daidir (UB  * pcode, scalar  val)
{
    val = *(scalar  *)((pcode + 0) + 24U);
    if (*(pcode + 40) == val) {
        return  ;
    }
    *(pcode + 40) = val;
    {
        RP  I1516;
        RP  * I732 = (RP  *)(pcode + 48);
        {
            I1516 = *I732;
            if (I1516) {
                hsimDispatchCbkMemOptNoDynElabS(I732, val, 1U);
            }
        }
    }
    {
        RmaNbaGate1  * I1424 = (RmaNbaGate1  *)(pcode + 56);
        U  I1425 = (((I1424->I5) >> (16)) & ((1 << (1)) - 1));
        scalar  I1055 = X4val[val];
        if (I1425) {
            I1424->I1061.I842 = (void *)((RP )(((RP )(I1424->I1061.I842) & ~0x3)) | (I1055));
        }
        else {
            I1424->I1061.I843.I818 = I1055;
        }
        NBA_Semiler(0, &I1424->I1061);
    }
    {
        scalar  I1336;
        I1336 = val;
        pcode += 144;
        (*(FP  *)(pcode + 0))(*(UB  **)(pcode + 8), I1336);
    }
}
void  hs_0_M_14_0__ase_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1656;
    typedef
    UB
     * TermTypePtr;
    U  I1342;
    U  I914;
    TermTypePtr  I1374;
    scalar  * I938;
    I1374 = (TermTypePtr )pcode;
    I914 = *I1374;
    I1374 -= I914;
    I938 = (scalar  *)(I1374 + 2U);
    if (I938[I914] == val) {
        return  ;
    }
    I938[I914] = val;
    val = I938[0];
    val = Xunion[(val << 7) + I938[1U]];
    pcode = ((UB  *)I1374) + 4U;
    {
        U  I1391 = 0;
        pcode = (UB  *)((UB  *)(((RP )pcode + I1391 + 7) & ~7));
    }
    {
        EBLK  * I1323;
        struct dummyq_struct * pQ;
        U  I1326;
        I1326 = 0;
        pQ = (struct dummyq_struct *)ref_vcs_clocks;
        if (*(scalar  *)((pcode + 0) + 24U) != val) {
            RmaEblk  * I1323 = (RmaEblk  *)(pcode + 0);
            *(scalar  *)((pcode + 0) + 24U) = val;
            if (!(I1323->I741)) {
                pQ->I1225->I741 = (EBLK  *)I1323;
                pQ->I1225 = (EBLK  *)I1323;
                I1323->I741 = (RP )((EBLK  *)-1);
                if (0 && rmaProfEvtProp) {
                    vcs_simpSetEBlkEvtID(I1323);
                }
            }
        }
    }
}
void  hs_0_M_14_5__ase_simv_daidir (UB  * pcode, UB  val)
{
    typedef
    UB
     * TermTypePtr;
    U  I1342;
    U  I914;
    TermTypePtr  I1374;
    scalar  * I938;
    I1374 = (TermTypePtr )pcode;
    I914 = *I1374;
    I1374 -= I914;
    I938 = (scalar  *)(I1374 + 2U);
    val = I938[I914];
    I938[I914] = 0xff;
    hs_0_M_14_0__ase_simv_daidir(pcode, val);
}
void  hs_0_M_14_9__ase_simv_daidir (UB  * pcode, scalar  val)
{
    val = *(scalar  *)((pcode + 0) + 24U);
    if (*(pcode + 40) == val) {
        return  ;
    }
    *(pcode + 40) = val;
    {
        RP  I1516;
        RP  * I732 = (RP  *)(pcode + 48);
        {
            I1516 = *I732;
            if (I1516) {
                hsimDispatchCbkMemOptNoDynElabS(I732, val, 1U);
            }
        }
    }
    {
        RmaNbaGate1  * I1424 = (RmaNbaGate1  *)(pcode + 56);
        U  I1425 = (((I1424->I5) >> (16)) & ((1 << (1)) - 1));
        scalar  I1055 = X4val[val];
        if (I1425) {
            I1424->I1061.I842 = (void *)((RP )(((RP )(I1424->I1061.I842) & ~0x3)) | (I1055));
        }
        else {
            I1424->I1061.I843.I818 = I1055;
        }
        NBA_Semiler(0, &I1424->I1061);
    }
}
void  hs_0_M_15_0__ase_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1656;
    typedef
    UB
     * TermTypePtr;
    U  I1342;
    U  I914;
    TermTypePtr  I1374;
    scalar  * I938;
    I1374 = (TermTypePtr )pcode;
    I914 = *I1374;
    I1374 -= I914;
    I938 = (scalar  *)(I1374 + 2U);
    if (I938[I914] == val) {
        return  ;
    }
    I938[I914] = val;
    val = I938[0];
    val = Xunion[(val << 7) + I938[1U]];
    pcode = ((UB  *)I1374) + 4U;
    {
        U  I1391 = 0;
        pcode = (UB  *)((UB  *)(((RP )pcode + I1391 + 7) & ~7));
    }
    {
        EBLK  * I1323;
        struct dummyq_struct * pQ;
        U  I1326;
        I1326 = 0;
        pQ = (struct dummyq_struct *)ref_vcs_clocks;
        if (*(scalar  *)((pcode + 0) + 24U) != val) {
            RmaEblk  * I1323 = (RmaEblk  *)(pcode + 0);
            *(scalar  *)((pcode + 0) + 24U) = val;
            if (!(I1323->I741)) {
                pQ->I1225->I741 = (EBLK  *)I1323;
                pQ->I1225 = (EBLK  *)I1323;
                I1323->I741 = (RP )((EBLK  *)-1);
                if (0 && rmaProfEvtProp) {
                    vcs_simpSetEBlkEvtID(I1323);
                }
            }
        }
    }
}
void  hs_0_M_15_5__ase_simv_daidir (UB  * pcode, UB  val)
{
    typedef
    UB
     * TermTypePtr;
    U  I1342;
    U  I914;
    TermTypePtr  I1374;
    scalar  * I938;
    I1374 = (TermTypePtr )pcode;
    I914 = *I1374;
    I1374 -= I914;
    I938 = (scalar  *)(I1374 + 2U);
    val = I938[I914];
    I938[I914] = 0xff;
    hs_0_M_15_0__ase_simv_daidir(pcode, val);
}
void  hs_0_M_15_9__ase_simv_daidir (UB  * pcode, scalar  val)
{
    val = *(scalar  *)((pcode + 0) + 24U);
    if (*(pcode + 40) == val) {
        return  ;
    }
    *(pcode + 40) = val;
    {
        RP  I1516;
        RP  * I732 = (RP  *)(pcode + 48);
        {
            I1516 = *I732;
            if (I1516) {
                hsimDispatchCbkMemOptNoDynElabS(I732, val, 1U);
            }
        }
    }
    {
        RmaNbaGate1  * I1424 = (RmaNbaGate1  *)(pcode + 56);
        U  I1425 = (((I1424->I5) >> (16)) & ((1 << (1)) - 1));
        scalar  I1055 = X4val[val];
        if (I1425) {
            I1424->I1061.I842 = (void *)((RP )(((RP )(I1424->I1061.I842) & ~0x3)) | (I1055));
        }
        else {
            I1424->I1061.I843.I818 = I1055;
        }
        NBA_Semiler(0, &I1424->I1061);
    }
}
void  hs_0_M_16_0__ase_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1656;
    *(pcode + 0) = val;
    {
        RP  I1516;
        RP  * I732 = (RP  *)(pcode + 8);
        {
            I1516 = *I732;
            if (I1516) {
                hsimDispatchCbkMemOptNoDynElabS(I732, val, 1U);
            }
        }
    }
    {
        RmaNbaGate1  * I1424 = (RmaNbaGate1  *)(pcode + 16);
        U  I1425 = (((I1424->I5) >> (16)) & ((1 << (1)) - 1));
        scalar  I1055 = X4val[val];
        if (I1425) {
            I1424->I1061.I842 = (void *)((RP )(((RP )(I1424->I1061.I842) & ~0x3)) | (I1055));
        }
        else {
            I1424->I1061.I843.I818 = I1055;
        }
        NBA_Semiler(0, &I1424->I1061);
    }
}
void  hs_0_M_16_5__ase_simv_daidir (UB  * pcode, UB  val)
{
    val = *(pcode + 0);
    *(pcode + 0) = 0xff;
    hs_0_M_16_0__ase_simv_daidir(pcode, val);
}
void  hs_0_M_22_0__ase_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1656;
    *(pcode + 0) = val;
    {
        RP  I1516;
        RP  * I732 = (RP  *)(pcode + 8);
        {
            I1516 = *I732;
            if (I1516) {
                hsimDispatchCbkMemOptNoDynElabS(I732, val, 1U);
            }
        }
    }
    {
        RmaNbaGate1  * I1424 = (RmaNbaGate1  *)(pcode + 16);
        U  I1425 = (((I1424->I5) >> (16)) & ((1 << (1)) - 1));
        scalar  I1055 = X4val[val];
        if (I1425) {
            I1424->I1061.I842 = (void *)((RP )(((RP )(I1424->I1061.I842) & ~0x3)) | (I1055));
        }
        else {
            I1424->I1061.I843.I818 = I1055;
        }
        NBA_Semiler(0, &I1424->I1061);
    }
}
void  hs_0_M_22_5__ase_simv_daidir (UB  * pcode, UB  val)
{
    val = *(pcode + 0);
    *(pcode + 0) = 0xff;
    hs_0_M_22_0__ase_simv_daidir(pcode, val);
}
void  hs_0_M_23_0__ase_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1656;
    *(pcode + 0) = val;
    {
        RP  I1516;
        RP  * I732 = (RP  *)(pcode + 8);
        {
            I1516 = *I732;
            if (I1516) {
                hsimDispatchCbkMemOptNoDynElabS(I732, val, 1U);
            }
        }
    }
    {
        RmaNbaGate1  * I1424 = (RmaNbaGate1  *)(pcode + 16);
        U  I1425 = (((I1424->I5) >> (16)) & ((1 << (1)) - 1));
        scalar  I1055 = X4val[val];
        if (I1425) {
            I1424->I1061.I842 = (void *)((RP )(((RP )(I1424->I1061.I842) & ~0x3)) | (I1055));
        }
        else {
            I1424->I1061.I843.I818 = I1055;
        }
        NBA_Semiler(0, &I1424->I1061);
    }
    {
        scalar  I1336;
        I1336 = val;
        (*(FP  *)(pcode + 104))(*(UB  **)(pcode + 112), I1336);
    }
}
void  hs_0_M_23_5__ase_simv_daidir (UB  * pcode, UB  val)
{
    val = *(pcode + 0);
    *(pcode + 0) = 0xff;
    hs_0_M_23_0__ase_simv_daidir(pcode, val);
}
void  hs_0_M_56_0__ase_simv_daidir (UB  * pcode, scalar  val)
{
    UB  * I1656;
    typedef
    UB
     * TermTypePtr;
    U  I1342;
    U  I914;
    TermTypePtr  I1374;
    scalar  * I938;
    I1374 = (TermTypePtr )pcode;
    I914 = *I1374;
    I1374 -= I914;
    I938 = (scalar  *)(I1374 + 2U);
    if (I938[I914] == val) {
        return  ;
    }
    I938[I914] = val;
    val = I938[0];
    val = Xunion[(val << 7) + I938[1U]];
    pcode = ((UB  *)I1374) + 4U;
    {
        U  I1391 = 0;
        pcode = (UB  *)((UB  *)(((RP )pcode + I1391 + 7) & ~7));
    }
    {
        EBLK  * I1323;
        struct dummyq_struct * pQ;
        U  I1326;
        I1326 = 0;
        pQ = (struct dummyq_struct *)ref_vcs_clocks;
        if (*(scalar  *)((pcode + 0) + 24U) != val) {
            RmaEblk  * I1323 = (RmaEblk  *)(pcode + 0);
            *(scalar  *)((pcode + 0) + 24U) = val;
            if (!(I1323->I741)) {
                pQ->I1225->I741 = (EBLK  *)I1323;
                pQ->I1225 = (EBLK  *)I1323;
                I1323->I741 = (RP )((EBLK  *)-1);
                if (0 && rmaProfEvtProp) {
                    vcs_simpSetEBlkEvtID(I1323);
                }
            }
        }
    }
}
void  hs_0_M_56_9__ase_simv_daidir (UB  * pcode, scalar  val)
{
    val = *(scalar  *)((pcode + 0) + 24U);
    if (*(pcode + 40) == val) {
        return  ;
    }
    *(pcode + 40) = val;
    {
        RP  I1516;
        RP  * I732 = (RP  *)(pcode + 48);
        {
            I1516 = *I732;
            if (I1516) {
                hsimDispatchCbkMemOptNoDynElabS(I732, val, 1U);
            }
        }
    }
    {
        RmaNbaGate1  * I1424 = (RmaNbaGate1  *)(pcode + 56);
        U  I1425 = (((I1424->I5) >> (16)) & ((1 << (1)) - 1));
        scalar  I1055 = X4val[val];
        if (I1425) {
            I1424->I1061.I842 = (void *)((RP )(((RP )(I1424->I1061.I842) & ~0x3)) | (I1055));
        }
        else {
            I1424->I1061.I843.I818 = I1055;
        }
        NBA_Semiler(0, &I1424->I1061);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
