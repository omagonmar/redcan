#$Header: /home/pros/xray/ximages/RCS/qpshift.cl,v 11.0 1997/11/06 16:29:17 prosb Exp $
#$Log: qpshift.cl,v $
#Revision 11.0  1997/11/06 16:29:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:50  prosb
#General Release 2.4
#
#Revision 8.1  1995/06/28  18:43:17  prosb
#JCC - Added new parameters xdim/ydim for qplintran.
#
#Revision 8.0  1994/06/27  14:42:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:26:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:04:07  prosb
#General Release 2.2
#
#Revision 1.2  93/05/21  09:23:54  mo
#MC Fix RCS/LOG type
#
procedure qpshift(qpoe,oqpoe,xshift,yshift)
#
#  Parameters for the Imcontour task
#
# -- Imcontour Params -
 string qpoe    {prompt="input qpoe filename",mode="a"}
 string oqpoe   {".",prompt="output qpoe filename",mode="a"}
 real   xshift    {prompt="pixel shift in x",mode="a"}
 real   yshift    {prompt="pixel shift in y",mode="a"}
 string region  {"",prompt="region",mode="h"}
 string eventdef {"",prompt="event definition string",mode="h"}
 bool   clob     { no, prompt="OK to delete existing output file?",mode="h"}
 int    display  {0,min=0,max=5,prompt="0=no disp, 1=header",mode="h"}
 bool   mwcs    {yes,prompt="update MWCS parameters?",mode="h"}
 bool   random  {yes,prompt="apply random number digitizer?",mode="h"}
 bool   sort    {yes, prompt="sort output qpoe?",mode="h"}
 string sorttype {"position",prompt="sorttype for output QPOE file",mode="h"}
 int ssize {1000000, prompt="max number of events per sort",mode="h"}
 bool qpi    {yes, prompt="prompt for qp internals?",mode="h"}
 int psize   {2048,prompt="page size for qpoe file",mode="h"}
 int bsize   {4096,prompt="bucket length of qpoe file",mode="h"}
 bool mkindex       {yes,prompt="make an index on y, x?",mode="h"}
 string key {"y x",prompt="key on which to make index",mode="h"}
 int debug   {0,min=0,max=5,prompt="qpoe debug level"}
#

begin

    string  inqp
    string  outqp
    string  instrum    
    real    xref,yref
    real    xout,yout

	inqp	= qpoe
	outqp   = oqpoe

	imgets(inqp,"CRPIX1")
	xref = real(imgets.value)
	imgets(inqp,"CRPIX2")
	yref = real(imgets.value)
	xout = xref + xshift
	yout = yref + yshift

## qplintran (inqp,
## region, outqp, eventdef, 0.0, exposure="NONE", expthresh=0., xin=INDEF,
## yin=INDEF, xout=xout, yout=yout, xmag=1., ymag=1., mwcs=mwcs, random=random,
## clobber=clob, display=display, sort=sort, sorttype=sorttype, sortsize=ssize,
## qp_internals=qpi, qp_pagesize=psize, qp_bucketlen=bsize, qp_blockfact=1,
## qp_mkindex=mkindex, qp_key=key, qp_debug=debug)
## 
qplintran (input_qpoe=inqp, region=region, qpoe=outqp, eventdef=eventdef,
xrotation=0.0, exposure="NONE", expthresh=0., xin=INDEF, yin=INDEF,
xout=xout, yout=yout, xmag=1., ymag=1., xdim=INDEF, ydim=INDEF,
mwcs=mwcs, random=random, clobber=clob, display=display, sort=sort,
sorttype=sorttype, sortsize=ssize, qp_internals=qpi, qp_pagesize=psize,
qp_bucketlen=bsize, qp_blockfact=1, qp_mkindex=mkindex, qp_key=key,
qp_debug=debug)
end
