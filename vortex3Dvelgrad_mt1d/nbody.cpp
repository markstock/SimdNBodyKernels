/*
  Copyright (c) 2015, Mark J Stock
*/

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#define NOMINMAX
#pragma warning (disable: 4244)
#pragma warning (disable: 4305)
#endif

#include <cstdlib>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <algorithm>
#include "../timing.h"
#include "nbody_ispc.h"
using namespace ispc;

extern void nbody_serial(int numSrcs, float sx[], float sy[], float sz[],
                                      float ssx[], float ssy[], float ssz[], float sr[],
                         int numTarg, float tx[], float ty[], float tz[],
                                      float tax[], float tay[], float taz[],
                                      float tux[], float tuy[], float tuz[],
                                      float tvx[], float tvy[], float tvz[],
                                      float twx[], float twy[], float twz[]);

static void usage() {
    fprintf(stderr, "Usage: nbody [-n=<factor>] [simd iterations] [serial iterations]\n");
    exit(1);
}

int main(int argc, char *argv[]) {

    static unsigned int test_iterations[] = {4, 2};
    int numSrcs = 10000;
    int numTargs = 10000;
    int maxGangSize = 16;

    if (argc > 1) {
        if (strncmp(argv[1], "-n=", 3) == 0) {
            int num = atof(argv[1] + 3);
            if (num < 1) usage();
            numSrcs = maxGangSize*(num/maxGangSize);
            numTargs = maxGangSize*(num/maxGangSize);
        }
    }
    if ((argc == 3) || (argc == 4)) {
        for (int i = 0; i < 2; i++) {
            test_iterations[i] = atoi(argv[argc - 2 + i]);
        }
    }


    // allocate particle data
    float *sx = new float[numSrcs];
    float *sy = new float[numSrcs];
    float *sz = new float[numSrcs];
    float *ssx = new float[numSrcs];
    float *ssy = new float[numSrcs];
    float *ssz = new float[numSrcs];
    float *sr = new float[numSrcs];
    float *tx = new float[numTargs];
    float *ty = new float[numTargs];
    float *tz = new float[numTargs];
    float *tax = new float[numTargs];
    float *tay = new float[numTargs];
    float *taz = new float[numTargs];
    float *tux = new float[numTargs];
    float *tuy = new float[numTargs];
    float *tuz = new float[numTargs];
    float *tvx = new float[numTargs];
    float *tvy = new float[numTargs];
    float *tvz = new float[numTargs];
    float *twx = new float[numTargs];
    float *twy = new float[numTargs];
    float *twz = new float[numTargs];

    for (int i = 0; i < numSrcs; i++) {
        sx[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        sy[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        sz[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        ssx[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        ssy[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        ssz[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        float rawRadius = 1.0 / sqrt((float)numSrcs);
        sr[i] = powf(rawRadius,-3);
    }
    for (int i = 0; i < numTargs; i++) {
        tx[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        ty[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
        tz[i] = 2.*(float)rand()/(float)RAND_MAX - 1.0;
    }


    //
    // Compute the result using the ispc implementation; report the minimum
    // time of three runs.
    //
    double minISPC = 1e30;
    for (unsigned int i = 0; i < test_iterations[0]; ++i) {
        reset_and_start_timer();
        nbody_ispc(numSrcs, sx, sy, sz, ssx, ssy, ssz, sr,
                   numTargs, tx, ty, tz, tax, tay, taz,
                   tux, tuy, tuz, tvx, tvy, tvz, twx, twy, twz);
        double dt = get_elapsed_mcycles();
        printf("@time of ISPC run:\t\t\t[%.3f] million cycles\n", dt);
        minISPC = std::min(minISPC, dt);
    }

    printf("[nbody ispc]:\t\t[%.3f] million cycles\n", minISPC);

    // Write sample results
    for (int i = 0; i < 2; i++) printf("   particle %d vel %g %g %g\n",i,tax[i],tay[i],taz[i]);


    //
    // And run the serial implementation a few times, again reporting the
    // minimum time.
    //
    double minSerial = 1e30;
    for (unsigned int i = 0; i < test_iterations[1]; ++i) {
        reset_and_start_timer();
        nbody_serial(numSrcs, sx, sy, sz, ssx, ssy, ssz, sr,
                     numTargs, tx, ty, tz, tax, tay, taz,
                     tux, tuy, tuz, tvx, tvy, tvz, twx, twy, twz);
        double dt = get_elapsed_mcycles();
        printf("@time of serial run:\t\t\t[%.3f] million cycles\n", dt);
        minSerial = std::min(minSerial, dt);
    }

    printf("[nbody serial]:\t\t[%.3f] million cycles\n", minSerial);

    // Write sample results
    for (int i = 0; i < 2; i++) printf("   particle %d vel %g %g %g\n",i,tax[i],tay[i],taz[i]);

    printf("\t\t\t(%.2fx speedup from ISPC)\n", minSerial/minISPC);

    return 0;
}
