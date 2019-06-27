# T_MKIMAGE -- Make or edit an image with simple values.
# An image may be created of a specified size, dimensionality, and pixel
# datatype.  The image may also be edited to replace, add, or multiply
# by specified values.  The values may be a combination of a sloped plane
# (repeated for dimensions greater than 2) and Gaussian noise.
# The editing may be confined to sections of the image by use of image
# sections in the input image.  This task is a simple tool for
# specialized uses in test applications.
# The sloped plane is defined such that:
#    pix[i,j] = value + slope * ((ncols + nlines) / 2 - 1) + slope * (i + j)
# The interpretation of value is that it is the mean of the plane.
# The Gaussian noise is only approximately random for purposes of speed!
# MKLINE -- Make a line of data.  A slope of zero is a special case.
# The Gaussian random numbers are taken from the sequence of stored
# values with starting point chosen randomly in the interval 1 to ncols.
# This is not very random but is much more efficient.
# MKSIGMA -- A sequence of random numbers of the specified sigma and
# starting seed is generated.  The random number generator is modeled after
# that in Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.

###  Proprietary source code removed  ###
