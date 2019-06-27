#
# print out a line of data

procedure prns (a, npix)

short	a[ARB]			# input vector
int	npix			# number of pixels
int	i			# loop counter

begin

    do i = 1, npix{
	call printf("%d ")
        call pargs(a[i])
    }
end
