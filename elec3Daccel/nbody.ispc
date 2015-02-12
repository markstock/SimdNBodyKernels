/*
  Copyright (c) 2015, Mark J Stock
*/

static inline void nbody_kernel_ispc(float sx, float sy, float sz, float ss,
                                     float tx, float ty, float tz, float ts,
                                     varying float* uniform tax,
                                     varying float* uniform tay,
                                     varying float* uniform taz)
{
    // 19 flops
    float dx = sx - tx;
    float dy = sy - ty;
    float dz = sz - tz;
    float r2 = dx*dx + dy*dy + dz*dz + 0.01;
    r2 = ts*ss/(r2*sqrt(r2));
    *tax += r2 * dx;
    *tay += r2 * dy;
    *taz += r2 * dz;
}

export void nbody_ispc(uniform int numSrcs, uniform float sx[], uniform float sy[], uniform float sz[], uniform float ss[],
                       uniform int numTarg, uniform float tx[], uniform float ty[], uniform float tz[], uniform float ts[], uniform float tm[],
                       uniform float tax[], uniform float tay[], uniform float taz[])
{
    for (uniform int i = 0; i < numTarg; i++) {
        uniform float sumx, sumy, sumz;
        varying float partialx, partialy, partialz;
        partialx = 0.0;
        partialy = 0.0;
        partialz = 0.0;
        foreach (j = 0 ... numSrcs) {
            nbody_kernel_ispc(sx[j], sy[j], sz[j], ss[j], tx[i], ty[i], tz[i], ts[i], &partialx, &partialy, &partialz);
        }
        sumx = reduce_add(partialx);
        sumy = reduce_add(partialy);
        sumz = reduce_add(partialz);
        tax[i] = sumx / tm[i];
        tay[i] = sumy / tm[i];
        taz[i] = sumz / tm[i];
    }
}

export uniform int isa() {
#if defined(ISPC_TARGET_SSE2)
    return 0;
#elif defined(ISPC_TARGET_SSE4)
    return 1;
#elif defined(ISPC_TARGET_AVX)
    return 2;
#else
    return -1;
#endif
}

