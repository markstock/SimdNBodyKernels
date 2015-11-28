/*
  Copyright (c) 2015, Mark J Stock
*/

#include <math.h>

static inline void nbody_kernel_serial(float sx, float sy, float sz,
                                       float ssx,float ssy,float ssz, float sr,
                                       float tx, float ty, float tz,
                                       float* tax, float* tay, float* taz,
                                       float* tux, float* tuy, float* tuz,
                                       float* tvx, float* tvy, float* tvz,
                                       float* twx, float* twy, float* twz) {
    // 66 flops (assuming most common code path)
    float dx = sx - tx;
    float dy = sy - ty;
    float dz = sz - tz;
    float dxlensq = dx*dx + dy*dy + dz*dz;
    float dxlen = sqrtf(dxlensq);
    float ratio = dxlen * dxlensq;
    dxlen = ratio * sr;

    float bbb = 0.0;
    if (dxlen > 20.) {
        ratio = 1.0 / ratio;
        bbb = -3.0 * ratio / dxlensq;
    } else if (dxlen < 1.e-3) {
        ratio = sr;
    } else {
        dxlen = expf(-dxlen);
        ratio = (1.0 - dxlen) / ratio;
        bbb = 3.0 * (sr*dxlen - ratio) / dxlensq;
    }

    // vels
    float dxxw1 = dz*ssy - dy*ssz;
    float dxxw2 = dx*ssz - dz*ssx;
    float dxxw3 = dy*ssx - dx*ssy;
    (*tax) += ratio * dxxw1;
    (*tay) += ratio * dxxw2;
    (*taz) += ratio * dxxw3;

    // vel grads (these may be in the wrong order---not important yet)
    dxxw1 *= bbb;
    dxxw2 *= bbb;
    dxxw3 *= bbb;
    (*tux) += dx * dxxw1;
    (*tuy) += dx * dxxw2 + ssz * ratio;
    (*tuz) += dx * dxxw3 - ssy * ratio;
    (*tvx) += dy * dxxw1 - ssz * ratio;
    (*tvy) += dy * dxxw2;
    (*tvz) += dy * dxxw3 + ssx * ratio;
    (*twx) += dz * dxxw1 + ssy * ratio;
    (*twy) += dz * dxxw2 - ssx * ratio;
    (*twz) += dz * dxxw3;
}

void nbody_serial(int numSrcs, float sx[], float sy[], float sz[],
                               float ssx[],float ssy[],float ssz[], float sr[],
                  int numTarg, float tx[], float ty[], float tz[],
                               float tax[], float tay[], float taz[],
                               float tux[], float tuy[], float tuz[],
                               float tvx[], float tvy[], float tvz[],
                               float twx[], float twy[], float twz[])
{
    for (int i = 0; i < numTarg; i++) {
        tax[i] = 0.0;
        tay[i] = 0.0;
        taz[i] = 0.0;
        tux[i] = 0.0;
        tuy[i] = 0.0;
        tuz[i] = 0.0;
        tvx[i] = 0.0;
        tvy[i] = 0.0;
        tvz[i] = 0.0;
        twx[i] = 0.0;
        twy[i] = 0.0;
        twz[i] = 0.0;
        for (int j = 0; j < numSrcs; j++) {
            nbody_kernel_serial(sx[j], sy[j], sz[j], ssx[j], ssy[j], ssz[j], sr[j],
                                tx[i], ty[i], tz[i], &tax[i], &tay[i], &taz[i],
                                &tux[i], &tuy[i], &tuz[i],
                                &tvx[i], &tvy[i], &tvz[i],
                                &twx[i], &twy[i], &twz[i]);
        }
    }
}
