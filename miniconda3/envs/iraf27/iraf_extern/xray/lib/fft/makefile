#####################################################################

FFLAGS = -f68881

FFTROUTINES = for2d.o btrvd.o dft2d.o fxrld.o dft2r.o

fftlib:	${FFTROUTINES}
	ar ruv libfft.a $?
	ranlib libfft.a
	rm $?

.f.o:
	${FC} ${FFLAGS} -c $<
