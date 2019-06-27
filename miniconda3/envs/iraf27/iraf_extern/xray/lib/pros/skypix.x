#$Header: /home/pros/xray/lib/pros/RCS/skypix.x,v 11.0 1997/11/06 16:21:08 prosb Exp $
#$Log: skypix.x,v $
#Revision 11.0  1997/11/06 16:21:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:39  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:13:07  mo
#MC	7/2/93		Correct return values from YES to TRUE for correct bool..
#
#Revision 6.0  93/05/24  15:54:07  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:28  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:01:18  wendy
#General
#
#Revision 2.0  91/03/07  00:07:30  pros
#General Release 1.0
#

# SKYPIX.X -- Convert from a sky system to pixels and back
#


bool procedure skypix_qp(qp, sky1, sky2, x1, y1)

pointer	qp
real	sky1, sky2
real	x1, y1
#--

pointer ct, mw, qp_loadwcs(), mw_sctran()

begin
	mw = qp_loadwcs(qp)
	ct = mw_sctran (mw, "world", "physical", 3)

	call mw_c2tranr(ct, sky1, sky2, x1, y1)

	return(TRUE) 
end




bool procedure skypix_qpio(qpio, sky1, sky2, x1, y1)

pointer	qpio
real	sky1, sky2
real	x1, y1
#--

pointer ct, mw, qpio_lwcs(), mw_sctran()

begin
	mw = qpio_lwcs(qpio)
	ct = mw_sctran (mw, "world", "physical", 3)

	call mw_c2tranr(ct, sky1, sky2, x1, y1)

	return(TRUE)
end



bool procedure skypix_im(im, sky1, sky2, x1, y1)

pointer	im
real	sky1, sky2
real	x1, y1
#--

pointer ct, mw, mw_openim(), mw_sctran()

begin
	mw = mw_openim(im)
	ct = mw_sctran (mw, "world", "physical", 3)

	call mw_c2tranr(ct, sky1, sky2, x1, y1)

	return(TRUE) 
end



bool procedure pixsky_qp(qp, x1, y1, sky1, sky2)
pointer	qp
real	x1, y1
real	sky1, sky2
#--

pointer ct, mw, qp_loadwcs(), mw_sctran()

begin
	mw = qp_loadwcs(qp)
	ct = mw_sctran (mw, "physical", "world", 3)

	call mw_c2tranr(ct, x1, y1, sky1, sky2)

	return(TRUE) 
end




bool procedure pixsky_qpio(qpio, x1, y1, sky1, sky2)

pointer	qpio
real	x1, y1
real	sky1, sky2
#--

pointer ct, mw, qpio_lwcs(), mw_sctran()

begin
	mw = qpio_lwcs(qpio)
	ct = mw_sctran (mw, "physical", "world", 3)

	call mw_c2tranr(ct, x1, y1, sky1, sky2)

	return(TRUE)
end



bool procedure pixsky_im(im, x1, y1, sky1, sky2)

pointer	im
real	x1, y1
real	sky1, sky2
#--

pointer ct, mw, mw_openim(), mw_sctran()

begin
	mw = mw_openim(im)
	ct = mw_sctran (mw, "physical", "world", 3)

	call mw_c2tranr(ct, x1, y1, sky1, sky2)

	return(TRUE)
end



