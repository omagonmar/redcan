#
# print out a line of data

procedure prnl (a, npix)

long	a[ARB]			# input vector
int	npix			# number of pixels
int	i			# loop counter

begin

    do i = 1, npix{
	call printf("%d ")
        call pargl(a[i])
    }
end
