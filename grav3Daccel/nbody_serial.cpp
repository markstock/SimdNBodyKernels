/*
  Copyright (c) 2015, Mark J Stock
*/

#include <math.h>

static inline void nbody_kernel_serial(float sx, float sy, float sz, float ss,
                                       float tx, float ty, float tz,
                                       float* tax, float* tay, float* taz) {
    // 18 flops
    float dx = sx - tx;
    float dy = sy - ty;
    float dz = sz - tz;
    float r2 = dx*dx + dy*dy + dz*dz + 0.01;
    r2 = ss/(r2*sqrt(r2));
    *tax += r2 * dx;
    *tay += r2 * dy;
    *taz += r2 * dz;
}

void nbody_serial(int numSrcs, float sx[], float sy[], float sz[], float ss[],
                  int numTarg, float tx[], float ty[], float tz[], float ts[],
                  float tax[], float tay[], float taz[])
{
    for (int i = 0; i < numTarg; i++) {
        tax[i] = 0.0;
        tay[i] = 0.0;
        taz[i] = 0.0;
        for (int j = 0; j < numSrcs; j++) {
            nbody_kernel_serial(sx[j], sy[j], sz[j], ss[j], tx[i], ty[i], tz[i], &tax[i], &tay[i], &taz[i]);
        }
        tax[i] /= ts[i];
        tay[i] /= ts[i];
        taz[i] /= ts[i];
    }
}
