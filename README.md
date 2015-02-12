# SimdNBodyKernels
Easy-to-implement n-body simulation kernels created using Intel's ispc and llvm/clang


This package contains several simple single-step programs for force summation 
using the direct O(N^2) n-body method, accelerated with both SIMD extensions
(SSE2, AVX) and multithreading using Intel's ispc compiler. These blocks of code
should be easy to incorporate into your own n-body simulation projects.

### Kernel details

Gravitation kernels solve for acceleration and use a Krasny-style desingularization
with radius 0.1.
Vortex kernels solve for velocity and use a Krasny-style desingularization with
variable radius.
All kernels use "structure of arrays"-style data patterns. Other systems
may be more performant.

### Performance
