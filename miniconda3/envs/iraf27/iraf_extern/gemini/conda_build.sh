export SP_DIR="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27/lib/python2.7/site-packages"
export ignore_build_only_deps="['python']"
export PKG_BUILD_STRING="placeholder"
export CONDA_LUA="5"
export R_VER="3.4"
export PREFIX="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27"
export PY_VER="2.7"
export BUILD_PREFIX="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27"
export HOME="/home/rtfuser"
export ARCH="64"
export DISPLAY="localhost:10.0"
export LANG="en_US.UTF-8"
export cpu_optimization_target="nocona"
export LD_RUN_PATH="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27/lib"
export STDLIB_DIR="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27/lib/python2.7"
export CONDA_R="3.4"
export CONDA_DEFAULT_ENV="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27"
export PYTHONNOUSERSITE="1"
export PERL_VER="5.26"
export ROOT="/rtfproc/anaconda2_4.2.0"
export SUBDIR="linux-64"
export pin_run_as_build="{'python': {'max_pin': 'x.x', 'min_pin': 'x.x'}, 'r-base': {'max_pin': 'x.x.x', 'min_pin': 'x.x.x'}}"
export PKG_BUILDNUM="1"
export CONDA_BUILD_STATE="BUILD"
export CPU_COUNT="1"
export RECIPE_DIR="/rtfproc/ac_build/astroconda-iraf/iraf.gemini"
export CONDA_PY="27"
export CONDA_PERL="5.26"
export PATH="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27:/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27/bin:/rtfproc/anaconda2_4.2.0/bin:/usr/local/git/bin:/home/rtfuser/gvs:/usr/local/bin:/bin:/usr/bin"
export SYS_PREFIX="/rtfproc/anaconda2_4.2.0"
export NPY_VER="1.11"
export LUA_VER="5"
export PKG_NAME="iraf.gemini"
export PY3K="0"
export PKG_CONFIG_PATH="/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27/lib/pkgconfig"
export CONDA_NPY="111"
export target_platform="linux-64"
export r_base="3.4"
export SYS_PYTHON="/rtfproc/anaconda2_4.2.0/bin/python"
export CONDA_BUILD="1"
export CMAKE_GENERATOR="Unix Makefiles"
export fortran_compiler="gfortran"
export SHLIB_EXT=".so"
export c_compiler="gcc"
export PKG_HASH="1234567"
export cxx_compiler="gxx"
export PKG_VERSION="1.14"
export SRC_DIR="/rtfproc/anaconda2_4.2.0/conda-bld/iraf.gemini_1553891406885/work"
export BUILD="x86_64-conda_cos6-linux-gnu"
source "/rtfproc/anaconda2_4.2.0/bin/activate" "/fs/computo52/other0/dani/Omaira/CanariCam/CCAM/miniconda3/envs/iraf27"
# Configure the environment for IRAF, since conda build appears not to do
# "source activate" after installing dependencies (this would instead need to
# eval $PREFIX/iraf/unix/hlib/setup directly if "--level" needs specifying):
. setup_iraf.sh

# As of v1.14, the "source" tarball contains some unwanted Apple binaries that
# mess up linking unless removed:
find . \( -name "*.a" -o -name "*.o" \) -exec rm -f {} \;

# Build from source in envs/_build (using build script from astroconda-utils):
ac_build_iraf_pkg

