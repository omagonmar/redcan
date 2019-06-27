#
# print out a line of data

procedure prnd (a, npix)

double	a[ARB]			# input vector
int	npix			# number of pixels
int	i			# loop counter

begin

    do i = 1, npix{
	call printf("%f ")
        call pargd(a[i])
    }
end
