/*
  Copyright (c) 2015, Mark J Stock
*/

#include <math.h>

static inline void nbody_kernel_serial(float sx, float sy, float ss, float sr,
                                       float tx, float ty, 
                                       float* tax, float* tay) {
    // 12 flops
    float dx = sx - tx;
    float dy = sy - ty;
    float r2 = dx*dx + dy*dy + sr*sr;
    r2 = ss/r2;
    *tax += r2 * dy;
    *tay -= r2 * dx;
}

void nbody_serial(int numSrcs, float sx[], float sy[], float ss[], float sr[],
                  int numTarg, float tx[], float ty[], float tax[], float tay[])
{
    for (int i = 0; i < numTarg; i++) {
        tax[i] = 0.0;
        tay[i] = 0.0;
        for (int j = 0; j < numSrcs; j++) {
            nbody_kernel_serial(sx[j], sy[j], ss[j], sr[j],
                                tx[i], ty[i], &tax[i], &tay[i]);
        }
    }
}
