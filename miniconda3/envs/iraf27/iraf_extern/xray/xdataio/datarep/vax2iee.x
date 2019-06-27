#$Header: /home/pros/xray/xdataio/datarep/RCS/vax2iee.x,v 11.0 1997/11/06 16:34:02 prosb Exp $
#$Log: vax2iee.x,v $
#Revision 11.0  1997/11/06 16:34:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:51  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:38:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:48  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:14  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:21  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:36:23  pros
#General Release 1.0
#
# vax2iee.x
#
# vax to ieee initilizations and conversions for Datarep




procedure vax2iee()
#--

extern	iee2hostc()
extern	vax2iees()
extern	vax2ieel()
extern	vax2ieer()
extern	vax2ieed()

begin
	call setmaxrep(8)

	call datatype("char",	iee2hostc)
	call datatype("short",	vax2iees)
	call datatype("int", 	vax2ieel)
	call datatype("long", 	vax2ieel)
	call datatype("real", 	vax2ieer)
	call datatype("double",	vax2ieed)
end


procedure vax2iees(ibuf, iindex, obuf, oindex)

short 	ibuf[ARB]
int	iindex
short 	obuf[ARB]
int	oindex

begin	
	call bswap2(ibuf, iindex, obuf, oindex, 2)

	iindex = iindex + 2
	oindex = oindex + 2
end


procedure vax2ieel(ibuf, iindex, obuf, oindex)

long 	ibuf
int	iindex
long 	obuf
int	oindex

begin
	call bswap4(ibuf, iindex, obuf, oindex, 4)

	iindex = iindex + 4
	oindex = oindex + 4
end


procedure vax2ieer(ibuf, iindex, obuf, oindex)

real	ibuf[ARB]
int	iindex
real	obuf[ARB]
int	oindex
#--

real	vax[4], iee[4]

int	ands()
begin
	call bytmov(ibuf, iindex, vax, 1, 4)

	if ( ands(vax[1], 0FF80x) == 0 ) {	# zero exponent?
		iee[1] = 0;
		iee[2] = 0
	} else {
		iee[1] = vax[1] - 00100x	#-2 from exponent
		iee[2] = vax[2]
	}


	call bytmov(iee, 1, obuf, oindex, 4)

	iindex = iindex + 4
	oindex = oindex + 4
end


procedure vax2ieed(ibuf, iindex, obuf, oindex)

double	ibuf[ARB]
int	iindex
double	obuf[ARB]
int	oindex
#--

short	vax[4], iee[4]

int	ands(), ors(), shifts()
begin

	call bytmov(ibuf, iindex, vax, 1, 8)

	if ( ands(vax[1], 0FF80x) == 0 ) {	# zero exponent?
		iee[1] = 0
		iee[2] = 0
		iee[3] = 0
		iee[4] = 0
	} else {
		iee[1] = ors(        ands(vax[1], 08000x),
				 shifts( ands(vax[1], 07FFFx), -3) +
				 shifts( 1023 - 129, 4))

		iee[2] = ors(      shifts(vax[1], 13),
				 ands( shifts(vax[2], -3),
						01FFFx))

		iee[3] = ors(      shifts(vax[2], 13),
				 ands( shifts(vax[3], -3),
						01FFFx))

		iee[4] = ors(      shifts(vax[3], 13),
				 ands( shifts(vax[4], -3),
						01FFFx))
	}

	call bytmov(iee, 1, obuf, oindex, 8)

	iindex = iindex + 8
	oindex = oindex + 8
end
