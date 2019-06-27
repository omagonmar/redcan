#$Header: /home/pros/xray/lib/regions/RCS/rgset.h,v 11.0 1997/11/06 16:19:18 prosb Exp $
#$Log: rgset.h,v $
#Revision 11.0  1997/11/06 16:19:18  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:27  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:43  prosb
#General Release 2.1
#
#Revision 3.1  92/10/25  16:42:23  mo
#no changes
#
#Revision 3.0  91/08/02  01:06:36  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:27  pros
#General Release 1.0
#

# define region painting operations
define RG_ROP 0		# use rop argument as PLIO.H rop function
define RG_PAINT 1	# paint region onto existing mask
define RG_MASK 2	# clear all of mask except under region
define RG_ERASE 3	# clear existing mask under region
define RG_VALUE 4	# use region as mask to paint value given by rop arg
define RG_SURROUND 5	# use region as inv-mask to paint rop value

define PI 3.14159265358979323846
define SMALL_NUMBER 1.0E-24

define PIXCEN real($1)		# real coord of center of pixel with int coord
define PIXNUM int(($1)+0.5)	# int coord of pixel with real coord
# to assure that geometrically adjoining regions touch but don't overlap
# when edge is exactly on a pixel center it goes to right or upper region
define PIXINCL int(($1)+1.0)	# first pixel counted when scanning low to high
