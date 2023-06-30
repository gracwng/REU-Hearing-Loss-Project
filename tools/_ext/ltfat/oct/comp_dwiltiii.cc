#define TYPEDEPARGS 0, 1
#define SINGLEARGS
#define COMPLEXINDEPENDENT
#define OCTFILENAME comp_dwiltiii // change to filename
#define OCTFILEHELP "This function calls the C-library\n\
                     coef=comp_dwiltiii(f,g,M);\n\
                     Yeah."


#include "ltfat_oct_template_helper.h"

static inline void
fwd_dwiltiii_fb(const Complex *f, const Complex *g,
                const octave_idx_type L, const octave_idx_type gl,
                const octave_idx_type W, const octave_idx_type M,
                Complex *cout)
{
    dwiltiii_fb_cd(reinterpret_cast<const fftw_complex*>(f),
                   reinterpret_cast<const fftw_complex*>(g),
                   L, gl, W, M, reinterpret_cast<fftw_complex*>(cout));
}

static inline void
fwd_dwiltiii_fb(const FloatComplex *f, const FloatComplex *g,
                const octave_idx_type L,  const octave_idx_type gl,
                const octave_idx_type W, const octave_idx_type M,
                FloatComplex *cout)
{
    dwiltiii_fb_cs(reinterpret_cast<const fftwf_complex*>(f),
                   reinterpret_cast<const fftwf_complex*>(g),
                   L, gl, W, M, reinterpret_cast<fftwf_complex*>(cout));
}

static inline void
fwd_dwiltiii_fb(const double *f, const double *g,
                const octave_idx_type L,  const octave_idx_type gl,
                const octave_idx_type W, const octave_idx_type M,
                double *cout)
{
    dwiltiii_fb_d(f, g, L, gl, W, M, cout);
}

static inline void
fwd_dwiltiii_fb(const float *f, const float *g,
                const octave_idx_type L,  const octave_idx_type gl,
                const octave_idx_type W, const octave_idx_type M,
                float *cout)
{
    dwiltiii_fb_s(f, g, L, gl, W, M, cout);
}

static inline void
fwd_dwiltiii_long(const Complex *f, const Complex *g,
                  const octave_idx_type L, const octave_idx_type W,
                  const octave_idx_type M, Complex *cout)
{
    dwiltiii_long_cd(reinterpret_cast<const fftw_complex*>(f),
                     reinterpret_cast<const fftw_complex*>(g),
                     L, W, M, reinterpret_cast<fftw_complex*>(cout));
}

static inline void
fwd_dwiltiii_long(const FloatComplex *f, const FloatComplex *g,
                  const octave_idx_type L, const octave_idx_type W,
                  const octave_idx_type M, FloatComplex *cout)
{
    dwiltiii_long_cs(reinterpret_cast<const fftwf_complex*>(f),
                     reinterpret_cast<const fftwf_complex*>(g),
                     L, W, M, reinterpret_cast<fftwf_complex*>(cout));
}

static inline void
fwd_dwiltiii_long(const double *f, const double *g,
                  const octave_idx_type L, const octave_idx_type W,
                  const octave_idx_type M, double *cout)
{
    dwiltiii_long_d(f, g, L, W, M, cout);
}

static inline void
fwd_dwiltiii_long(const float *f, const float *g,
                  const octave_idx_type L, const octave_idx_type W,
                  const octave_idx_type M, float *cout)
{
    dwiltiii_long_s(f, g, L, W, M, cout);
}

template <class LTFAT_TYPE, class LTFAT_REAL, class LTFAT_COMPLEX>
octave_value_list octFunction(const octave_value_list& args, int nargout)
{
    DEBUGINFO;
    const octave_idx_type M = args(2).int_value();

    MArray<LTFAT_TYPE> f = ltfatOctArray<LTFAT_TYPE>(args(0));
    MArray<LTFAT_TYPE> g = ltfatOctArray<LTFAT_TYPE>(args(1));
    const octave_idx_type gl = g.numel();
    const octave_idx_type W = f.columns();
    const octave_idx_type L = f.rows();
    const octave_idx_type N = L / M;

    dim_vector dims_out(M, N, W);
    dims_out.chop_trailing_singletons();

    MArray<LTFAT_TYPE> cout(dims_out);

    if (gl < L)
    {
        fwd_dwiltiii_fb(f.data(), g.data(), L, gl, W, M, cout.fortran_vec());
    }
    else
    {
        fwd_dwiltiii_long(f.data(), g.data(), L, W, M, cout.fortran_vec());
    }

    return octave_value(cout);
}

