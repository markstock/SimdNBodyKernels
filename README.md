# SimdNBodyKernels
Easy-to-implement n-body simulation kernels created using Intel's [ispc](https://github.com/ispc/ispc/) and llvm/clang


This package contains several simple single-step programs for force summation 
using the direct O(N^2) n-body method, accelerated with both SIMD extensions
(SSE2, SSE4, AVX, AVX2, FMA3) and multithreading using Intel's ispc compiler.
These blocks of code
should be easy to incorporate into your own n-body simulation projects.

Note that ispc makes writing SIMD-accelerated kernels easy. In the examples herein,
the *exact* same code is used in the serial (X87) version as is used in the 
SIMD version. You don't have to be aware of the underlying instruction set when
writing your code, you just express the inner loop as simply as possible and let
ispc/clang/llvm do the rest.

### Compiling

On Fedora, you'll need to install some packages first.

    sudo yum install llvm-static llvm-devel clang-devel bison flex

Then, install and build [ispc](https://github.com/ispc/ispc/).

    git clone https://github.com/ispc/ispc.git
    cd ispc
    make
    sudo cp ispc /usr/local/bin

Finally, you can build these examples.

    git clone https://github.com/markstock/SimdNBodyKernels.git
    cd SimdNBodyKernels/grav3Daccel
    make
    ./nbody


### Kernel details

The magic of ispc is that the inner-loop kernel code used for the SIMD-accelerated
version (`nbody.ispc`) is exactly the same as the inner-loop kernel code for the 
serial version (`nbody_serial.cpp`).

* grav2Daccel

    This is a two-dimensional gravitational kernel using Krasny-style desingularization
    with radius 0.1 and returning only acceleration (not potential).
    It's not really the solution to a Green's function, but given its
    lack of transcedental operations, is a very fast performer.

* grav3Daccel

    This is a three-dimensional gravitational kernel using Krasny-style desingularization
    with radius 0.1 and returning only acceleration (not potential).

* elec3Daccel

    This is a three-dimensional electrostatic kernel using Krasny-style desingularization
    with radius 0.1 and returning only acceleration (not potential).

* vortex3Dvel

    This is a three-dimensional vorticity kernel using Krasny-style desingularization
    with variable radius and returning velocity.

* vortex3Dvel_mt1d

    This is the same as vortex3Dvel, but uses a 1D block of threads for multithreading.
    It illustrates how easy it is to combine SIMD and multi-threaded parallelism. The
    only differences are in the `nbody.ispc` file.

All kernels use "structure of arrays"-style data patterns. Other systems may be more performant.
All kernels use separate lists for source and target particles for generality, but should
be easily reconfigurable to use the same lists.
Users are encouraged to create new kernels or faster implementations of the current ones.


### Performance

When you build the example programs, the compiler will build multiple versions and
dynamically dispatch at run-time to accomodate whichever instruction sets your CPU
supports. It will always choose the fastest available version.
Edit the `Makefile` to limit the available versions if you want to test just
SSE2 instructions on a machine that supports AVX, for example.

Performance of the serial and SIMD-accelerated functions is reported in clock "cycles".
To find the compute time or Flop/s you'll need to divide by the clock frequency in MHz.

* Laptop (2-core i5-2467M, 2.0/2.3GHz turbo, Fedora 21, llvm/clang 3.5.0), n=10000

~~~~
    grav3Daccel serial          3229.017 mcycles
    grav3Daccel SIMD (AVX)      475.211 mcycles		6.79x speedup	(peak at 7.862 GFlop/s)

    vortex3Dvel serial          3373.734 mcycles
    vortex3Dvel SIMD (AVX)      477.759 mcycles		7.06x speedup	(peak at 12.16 GFlop/s)
    vortex3Dvel_mt1d SIMD (AVX) 270.951 mcycles		12.45x speedup	(peak at 21.44 GFlop/s)
~~~~

* Server (6-core Xeon E5-2640, 2.5GHz, RHEL 6.5, llvm/clang 3.4.2), n=20000

~~~~
    grav3Daccel serial          17930.472 mcycles
    grav3Daccel SIMD (AVX)       2237.404 mcycles	8.01x speedup	(peak at 8.048 GFlop/s)

    vortex3Dvel serial          18530.592 mcycles
    vortex3Dvel SIMD (AVX)       2274.150 mcycles	8.15x speedup	(peak at 12.32 GFlop/s)
    vortex3Dvel_mt1d SIMD (AVX)   214.259 mcycles	86.49x speedup	(peak at 130.7 GFlop/s)
~~~~

* Desktop (8-core i7-5960X, 4.5GHz OC, Fedora 21, llvm/clang 3.5.0), n=50000

~~~~
    grav3Daccel serial          82465.704 mcycles
    grav3Daccel SIMD (AVX2)      5877.314 mcycles	14.03x speedup	(peak at 34.45 GFlop/s)

    vortex3Dvel serial          82140.888 mcycles
    vortex3Dvel SIMD (AVX2)      7499.812 mcycles	10.95x speedup	(peak at 42.00 GFlop/s)
    vortex3Dvel_mt1d SIMD (AVX2)  932.404 mcycles	88.10x speedup	(peak at 337.9 GFlop/s)
~~~~


### Acknowledgements

Big thanks to the team at Intel Corp. for creating ispc. Some code in this 
distribution is taken from the ispc project, and is used in accordance with 
the license.

