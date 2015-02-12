/*
  Copyright (c) 2015, Mark J Stock
*/

#include <math.h>

static inline void nbody_kernel_serial(float sx, float sy, float sz,
                                       float ssx,float ssy,float ssz, float sr,
                                       float tx, float ty, float tz,
                                       float* tax, float* tay, float* taz) {
    // 28 flops
    float dx = sx - tx;
    float dy = sy - ty;
    float dz = sz - tz;
    float r2 = dx*dx + dy*dy + dz*dz + sr*sr;
    r2 = 1.0/(r2*sqrt(r2));
    (*tax) += r2 * (dz*ssy - dy*ssz);
    (*tay) += r2 * (dx*ssz - dz*ssx);
    (*taz) += r2 * (dy*ssx - dx*ssy);
}

void nbody_serial(int numSrcs, float sx[], float sy[], float sz[],
                               float ssx[],float ssy[],float ssz[], float sr[],
                  int numTarg, float tx[], float ty[], float tz[],
                               float tax[], float tay[], float taz[])
{
    for (int i = 0; i < numTarg; i++) {
        tax[i] = 0.0;
        tay[i] = 0.0;
        taz[i] = 0.0;
        for (int j = 0; j < numSrcs; j++) {
            nbody_kernel_serial(sx[j], sy[j], sz[j], ssx[j], ssy[j], ssz[j], sr[j],
                                tx[i], ty[i], tz[i], &tax[i], &tay[i], &taz[i]);
        }
    }
}
