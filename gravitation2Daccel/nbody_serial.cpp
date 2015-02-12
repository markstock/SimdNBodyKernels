/*
  Copyright (c) 2015, Mark J Stock
*/


static inline void nbody_kernel_serial(float sx, float sy, float ss,
                                       float tx, float ty,
                                       float* tax, float* tay) {
    // 11 flops
    float dx = sx - tx;
    float dy = sy - ty;
    float r2 = dx*dx + dy*dy + 0.01;
    r2 = ss/r2;
    *tax += r2 * dx;
    *tay += r2 * dy;
}

void nbody_serial(int numSrcs, float sx[], float sy[], float ss[],
                  int numTarg, float tx[], float ty[], float ts[],
                  float tax[], float tay[])
{
    for (int i = 0; i < numTarg; i++) {
        tax[i] = 0.0;
        tay[i] = 0.0;
        for (int j = 0; j < numSrcs; j++) {
            nbody_kernel_serial(sx[j], sy[j], ss[j], tx[i], ty[i], &tax[i], &tay[i]);
        }
        tax[i] /= ts[i];
        tay[i] /= ts[i];
    }
}
