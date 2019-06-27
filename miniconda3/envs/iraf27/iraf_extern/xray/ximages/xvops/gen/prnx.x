#
# print out a line of data

procedure prnx (a, npix)

complex	a[ARB]			# input vector
int	npix			# number of pixels
int	i			# loop counter

begin

    do i = 1, npix{
	call printf("%f ")
        call pargx(a[i])
    }
end
