#
# print out a line of data

procedure prnr (a, npix)

real	a[ARB]			# input vector
int	npix			# number of pixels
int	i			# loop counter

begin

    do i = 1, npix{
	call printf("%f ")
        call pargr(a[i])
    }
end
