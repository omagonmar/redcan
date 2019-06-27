#$Header: /home/pros/xray/lib/pros/RCS/xarea.x,v 11.0 1997/11/06 16:21:20 prosb Exp $
#$Log: xarea.x,v $
#Revision 11.0  1997/11/06 16:21:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:13  prosb
#General Release 2.3
#
#Revision 6.1  93/10/21  11:38:59  mo
#MC	10/21/93	Add PROS/QPIO bug fix (qpx_addf)
#
#Revision 6.0  93/05/24  15:54:47  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:50:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:02:25  wendy
#General
#
#Revision 2.0  91/03/07  00:07:48  pros
#General Release 1.0
#
#
#  PUT_QPAREA -- put the area parameter to the qpoe file
#
procedure put_qparea(qp, area, indices)

pointer	qp				# i: qpoe handle
pointer	area				# i: pointer to area array
int	indices				# i: size of the arrays

int	qp_accessf()			# l: access a qpoe param

begin
	# see if we inherited area information
	if( qp_accessf(qp, "XS-NAREA") == YES ){
	    # delete the old xs-area param - the new one might be bigger
	    call qp_deletef(qp, "XS-NAREA")
	    call qp_deletef(qp, "XS-AREA")
	}
	# add area params
	call qpx_addf(qp, "XS-NAREA", "i", 1, "number of areas in xs-area", 0)
	call qpx_addf(qp, "XS-AREA", "i", indices,
			"region areas in pixels", 0)
	# add the count and the areas themselves
	call qp_addi(qp, "XS-NAREA", indices, "Number of regiosn")
	call qp_write(qp, "XS-AREA", Memi[area], indices, 1, "i")
end

#
#  GET_QPAREA -- get the area parameter from the qpoe file
#
procedure get_qparea(qp, area, indices)

pointer	qp				# i: qpoe handle
pointer	area				# o: pointer to area array
int	indices				# o: size of the arrays

int	nrecs				# l: areas actually read

int	qp_geti()			# l: get integer param from qpoe
int	qp_read()			# l: read opaque array
int	qp_accessf()			# l: access a qpoe param

begin
	# see if we have area information
	if( qp_accessf(qp, "XS-NAREA") == NO ){
	    indices = 0
	    return
	}
	# find out how many areas we have
	indices = qp_geti(qp, "XS-NAREA")
	# allocate space for an area buffer
	call calloc(area, indices, TY_INT)
	# get the areas
	nrecs = qp_read(qp, "XS-AREA", Memi[area], indices, 1, "i")
	# check for consistency
	if( nrecs != indices )
	    call error(1, "XS-NAREA != NUMBER OF AREAS IN XS-AREA")
end
