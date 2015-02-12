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
Users are encouraged to create new kernels or faster implementations of the current ones.


### Performance

Performance of the serial and SIMD-accelerated functions is reported in clock "cycles".
To find the compute time or Flop/s you'll need to divide by the clock frequency in MHz.


