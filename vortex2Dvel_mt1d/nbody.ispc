/*
  Copyright (c) 2015, Mark J Stock
*/

static inline void nbody_kernel_ispc(float sx, float sy, float ss, float sr,
                                     float tx, float ty,
                                     varying float* uniform tax,
                                     varying float* uniform tay)
{
    // 12 flops
    float dx = sx - tx;
    float dy = sy - ty;
    float r2 = dx*dx + dy*dy + sr*sr;
    r2 = ss/r2;
    *tax -= r2 * dy;
    *tay += r2 * dx;
}


// compute results for span of target particles
task void nbody_target(uniform int numSrcs, uniform float sx[], uniform float sy[], uniform float ss[], uniform float sr[],
                       uniform int numTarg, uniform float tx[], uniform float ty[], uniform float tax[], uniform float tay[],
                       uniform int span)
{
    uniform int tstart = taskIndex * span;
    uniform int tend = min((taskIndex+1) * span, (unsigned int)numTarg);

    for (uniform int i = tstart; i < tend; i++) {
        uniform float sumx, sumy;
        varying float partialx, partialy;
        partialx = 0.0;
        partialy = 0.0;
        foreach (j = 0 ... numSrcs) {
            nbody_kernel_ispc(sx[j], sy[j], ss[j], sr[j],
                              tx[i], ty[i], &partialx, &partialy);
        }
        sumx = reduce_add(partialx);
        sumy = reduce_add(partialy);
        tax[i] = sumx;
        tay[i] = sumy;
    }
}


// callable from C/C++
export void nbody_ispc(uniform int numSrcs, uniform float sx[], uniform float sy[], uniform float ss[], uniform float sr[],
                       uniform int numTarg, uniform float tx[], uniform float ty[], uniform float tax[], uniform float tay[])
{
    uniform int numTasks = 8 * num_cores();
    uniform int span = numTarg / numTasks;

    launch[numTarg/span] nbody_target(numSrcs,sx,sy,ss,sr,numTarg,tx,ty,tax,tay,span);
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

