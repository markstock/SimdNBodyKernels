/*
  Copyright (c) 2015, Mark J Stock
*/

static inline void nbody_kernel_ispc(float sx, float sy, float ss,
                                     float tx, float ty,
                                     varying float* uniform tax, varying float* uniform tay)
{
    // 10 flops
    float dx = sx - tx;
    float dy = sy - ty;
    float r2 = dx*dx + dy*dy;
    r2 = ss/r2;
    *tax += r2 * dx;
    *tay += r2 * dy;
}

export void nbody_ispc(uniform int numSrcs, uniform float sx[], uniform float sy[], uniform float ss[],
                       uniform int numTarg, uniform float tx[], uniform float ty[], uniform float ts[],
                       uniform float tax[], uniform float tay[])
{
    for (uniform int i = 0; i < numTarg; i++) {
        uniform float sumx, sumy;
        float partialx, partialy;
        partialx = 0.0;
        partialy = 0.0;
        foreach (j = 0 ... numSrcs) {
            nbody_kernel_ispc(sx[j], sy[j], ss[j], tx[i], ty[i], &partialx, &partialy);
        }
        sumx = reduce_add(partialx);
        sumy = reduce_add(partialy);
        tax[i] = sumx / ts[i];
        tay[i] = sumy / ts[i];
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

