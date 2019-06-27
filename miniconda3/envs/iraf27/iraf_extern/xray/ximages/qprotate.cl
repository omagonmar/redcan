#$Header: /home/pros/xray/ximages/RCS/qprotate.cl,v 11.0 1997/11/06 16:29:11 prosb Exp $
#$Log: qprotate.cl,v $
#Revision 11.0  1997/11/06 16:29:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:48  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:42:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:25:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:04:04  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  09:24:12  mo
#Initial revision
#
procedure qprotate(qpoe,region,oqpoe,eventdef,angle)
#
#  Parameters for the Imcontour task
#
# -- Imcontour Params -
 string qpoe    {prompt="input qpoe filename",mode="a"}
 string region  {"",prompt="region",mode="a"}
 string oqpoe   {".",prompt="output qpoe filename",mode="a"}
 string eventdef {"",prompt="event definition string",mode="a"}
 real   angle    {prompt="angle through which to rotate(degrees)",mode="a"}
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

    string inqp
    string outqp
	inqp	= qpoe
	outqp   = oqpoe

qplintran (inqp,
region, outqp, eventdef, angle, exposure="NONE", expthresh=0., xin=INDEF,
yin=INDEF, xout=INDEF, yout=INDEF, xmag=1., ymag=1., mwcs=mwcs, random=random,
clobber=clob, display=display, sort=sort, sorttype=sorttype, sortsize=ssize,
qp_internals=qpi, qp_pagesize=psize, qp_bucketlen=bsize, qp_blockfact=1,
qp_mkindex=mkindex, qp_key=key, qp_debug=debug)
end
