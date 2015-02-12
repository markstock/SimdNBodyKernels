/*
  Copyright (c) 2015, Mark J Stock
*/

static inline void nbody_kernel_ispc(float sx, float sy, float sz,
                                     float ssx,float ssy,float ssz, float sr,
                                     float tx, float ty, float tz,
                                     varying float* uniform tax,
                                     varying float* uniform tay,
                                     varying float* uniform taz)
{
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

export void nbody_ispc(uniform int numSrcs, uniform float sx[], uniform float sy[], uniform float sz[],
                       uniform float ssx[], uniform float ssy[], uniform float ssz[], uniform float sr[],
                       uniform int numTarg, uniform float tx[], uniform float ty[], uniform float tz[],
                       uniform float tax[], uniform float tay[], uniform float taz[])
{
    for (uniform int i = 0; i < numTarg; i++) {
        uniform float sumx, sumy, sumz;
        varying float partialx, partialy, partialz;
        partialx = 0.0;
        partialy = 0.0;
        partialz = 0.0;
        foreach (j = 0 ... numSrcs) {
            nbody_kernel_ispc(sx[j], sy[j], sz[j], ssx[j], ssy[j], ssz[j], sr[j],
                              tx[i], ty[i], tz[i], &partialx, &partialy, &partialz);
        }
        sumx = reduce_add(partialx);
        sumy = reduce_add(partialy);
        sumz = reduce_add(partialz);
        tax[i] = sumx;
        tay[i] = sumy;
        taz[i] = sumz;
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

