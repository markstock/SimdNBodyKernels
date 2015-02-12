# SimdNBodyKernels
Easy-to-implement n-body simulation kernels created using Intel's ispc and llvm/clang


This package contains several simple single-step programs for force summation 
using the direct O(N^2) n-body method, accelerated with both SIMD extensions
(SSE2, AVX) and multithreading using Intel's ispc compiler. These blocks of code
should be easy to incorporate into your own n-body simulation projects.

### Compiling

On Fedora, you'll need to install some packages first.

    sudo yum install llvm-static llvm-devel clang-devel bison flex

Then, install and build ispc.

    git clone https://github.com/ispc/ispc.git
    cd ispc
    make
    sudo cp ispc /usr/local/bin

Finally, you can build these examples.

    git clone https://github.com/markstock/SimdNBodyKernels.git
    cd SimdNBodyKernels/gravitation3Daccel
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

Performance of the serial and SIMD-accelerated functions is reported in clock "cycles".
To find the compute time or Flop/s you'll need to divide by the clock frequency in MHz.

* Laptop (dual-core i5-2467M, 1.6GHz nominal, 2.0/2.3GHz turbo, Fedora 21, llvm/clang 3.5.0), 10000 points

    grav3Daccel serial	3229.017 mcycles
    grav3Daccel SIMD (AVX)	475.211 mcycles		6.79x speedup	(peak at 7.862 GFlop/s)

    vortex3Dvel serial	3373.734 mcycles
    vortex3Dvel SIMD (AVX)	477.759 mcycles		7.06x speedup	(peak at 12.16 GFlop/s)
    vortex3Dvel_mt1d SIMD (AVX)	270.951 mcycles		12.45x speedup	(peak at 21.44 GFlop/s)

* Server (6-core Xeon E5-2640, 2.5GHz, RHEL 6.5, llvm/clang 3.4.2), 50000 points

    TBD

* Desktop (8-core i7-5960X, 4.5GHz OC, Fedora 21, llvm/clang 3.5.0), 100000 points

    TBD


