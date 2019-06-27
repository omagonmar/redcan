#
# print out a line of data

procedure prni (a, npix)

int	a[ARB]			# input vector
int	npix			# number of pixels
int	i			# loop counter

begin

    do i = 1, npix{
	call printf("%d ")
        call pargi(a[i])
    }
end
