/*
  Copyright (c) 2015, Mark J Stock
*/

static inline void nbody_kernel_ispc(float sx, float sy, float sz,
                                     float ssx,float ssy,float ssz, float sr,
                                     float tx, float ty, float tz,
                                     varying float* uniform tax,
                                     varying float* uniform tay,
                                     varying float* uniform taz,
                                     varying float* uniform tux,
                                     varying float* uniform tuy,
                                     varying float* uniform tuz,
                                     varying float* uniform tvx,
                                     varying float* uniform tvy,
                                     varying float* uniform tvz,
                                     varying float* uniform twx,
                                     varying float* uniform twy,
                                     varying float* uniform twz)
{
    // 66 flops (assuming most common code path)
    float dx = sx - tx;
    float dy = sy - ty;
    float dz = sz - tz;
    float dxlensq = dx*dx + dy*dy + dz*dz;
    float dxlen = sqrt(dxlensq);
    float ratio = dxlen * dxlensq;
    dxlen = ratio * sr;

    float bbb = 0.0;
    if (dxlen > 20.) {
        ratio = 1.0 / ratio;
        bbb = -3.0 * ratio / dxlensq;
    } else if (dxlen < 1.e-3) {
        ratio = sr;
    } else {
        dxlen = exp(-dxlen);
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


// compute results for span of target particles
task void nbody_target(uniform int numSrcs, uniform float sx[], uniform float sy[], uniform float sz[],
                       uniform float ssx[], uniform float ssy[], uniform float ssz[], uniform float sr[],
                       uniform int numTarg, uniform float tx[], uniform float ty[], uniform float tz[],
                       uniform float tax[], uniform float tay[], uniform float taz[],
                       uniform float tux[], uniform float tuy[], uniform float tuz[],
                       uniform float tvx[], uniform float tvy[], uniform float tvz[],
                       uniform float twx[], uniform float twy[], uniform float twz[],
                       uniform int span)
{
    uniform int tstart = taskIndex * span;
    uniform int tend = min((taskIndex+1) * span, (unsigned int)numTarg);

    for (uniform int i = tstart; i < tend; i++) {
        uniform float sumx, sumy, sumz;
        varying float partialx, partialy, partialz;
        varying float pux, puy, puz;
        varying float pvx, pvy, pvz;
        varying float pwx, pwy, pwz;
        partialx = 0.0;
        partialy = 0.0;
        partialz = 0.0;
        pux = 0.0;
        puy = 0.0;
        puz = 0.0;
        pvx = 0.0;
        pvy = 0.0;
        pvz = 0.0;
        pwx = 0.0;
        pwy = 0.0;
        pwz = 0.0;
        foreach (j = 0 ... numSrcs) {
            nbody_kernel_ispc(sx[j], sy[j], sz[j], ssx[j], ssy[j], ssz[j], sr[j],
                              tx[i], ty[i], tz[i],
                              &partialx, &partialy, &partialz,
                              &pux, &puy, &puz, &pvx, &pvy, &pvz, &pwx, &pwy, &pwz);
        }
        sumx = reduce_add(partialx);
        sumy = reduce_add(partialy);
        sumz = reduce_add(partialz);
        tax[i] = sumx;
        tay[i] = sumy;
        taz[i] = sumz;
        sumx = reduce_add(pux);
        sumy = reduce_add(puy);
        sumz = reduce_add(puz);
        tux[i] = sumx;
        tuy[i] = sumy;
        tuz[i] = sumz;
        sumx = reduce_add(pvx);
        sumy = reduce_add(pvy);
        sumz = reduce_add(pvz);
        tvx[i] = sumx;
        tvy[i] = sumy;
        tvz[i] = sumz;
        sumx = reduce_add(pwx);
        sumy = reduce_add(pwy);
        sumz = reduce_add(pwz);
        twx[i] = sumx;
        twy[i] = sumy;
        twz[i] = sumz;
    }
}


// callable from C/C++
export void nbody_ispc(uniform int numSrcs, uniform float sx[], uniform float sy[], uniform float sz[],
                       uniform float ssx[], uniform float ssy[], uniform float ssz[], uniform float sr[],
                       uniform int numTarg, uniform float tx[], uniform float ty[], uniform float tz[],
                       uniform float tax[], uniform float tay[], uniform float taz[],
                       uniform float tux[], uniform float tuy[], uniform float tuz[],
                       uniform float tvx[], uniform float tvy[], uniform float tvz[],
                       uniform float twx[], uniform float twy[], uniform float twz[])
{
    uniform int numTasks = 8 * num_cores();
    uniform int span = numTarg / numTasks;

    launch[numTarg/span] nbody_target(numSrcs,sx,sy,sz,ssx,ssy,ssz,sr,
                                      numTarg,tx,ty,tz,tax,tay,taz,
                                      tux,tuy,tuz,tvx,tvy,tvz,twx,twy,twz,
                                      span);
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

