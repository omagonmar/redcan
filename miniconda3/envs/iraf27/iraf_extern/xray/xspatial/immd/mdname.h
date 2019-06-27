#$Header: /home/pros/xray/xspatial/immd/RCS/mdname.h,v 11.2 2000/01/04 22:29:01 prosb Exp $
#$Log: mdname.h,v $
#Revision 11.2  2000/01/04 22:29:01  prosb
# copy from pros_2.5 (or pros_2.5_p1)
#
#Revision 9.0  1995/11/16  18:52:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:19  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:00  prosb
#General Release 2.2
#
#Revision 5.1  93/04/07  13:36:39  orszak
#jso - changes to add lorentzian model.
#
#Revision 5.0  92/10/29  21:34:34  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:26  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:15  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:03  pros
#General Release 1.0
#

char	mdname[7,NUM_CODES]
int	mdcode[NUM_CODES]
data	mdcode/MDBOXCAR,MDEXPO,MDGAUSS,MDIMPULS,MDKING,MDPOWER,
	MDTOPHAT,MDPRF_A,MDFILE,MDFUNC,MDLOPASS,MDHIPASS,MDKFILE,
	MDKFUNC,MDLORENT/
data	(mdname[i, 1],i=1,7)/'B','O','X','C','A','R', 0/
data	(mdname[i, 2],i=1,7)/'E','X','P','O', 0,  0,  0/
data	(mdname[i, 3],i=1,7)/'G','A','U','S','S', 0,  0/
data	(mdname[i, 4],i=1,7)/'I','M','P','U','L','S','E'/
data	(mdname[i, 5],i=1,7)/'K','I','N','G', 0,  0,  0/
data	(mdname[i, 6],i=1,7)/'P','O','W','E','R', 0,  0/
data	(mdname[i, 7],i=1,7)/'T','O','P','H','A','T', 0/
data	(mdname[i, 8],i=1,7)/'P','R','F', 0,  0,  0,  0/
data	(mdname[i, 9],i=1,7)/'F','I','L','E', 0,  0,  0/
data	(mdname[i,10],i=1,7)/'M','Y','M','O','D', 0,  0/
data	(mdname[i,11],i=1,7)/'L','O','P','A','S','S', 0/
data	(mdname[i,12],i=1,7)/'H','I','P','A','S','S', 0/
data	(mdname[i,13],i=1,7)/'K','F','I','L','E', 0,  0/
data	(mdname[i,14],i=1,7)/'M','Y','K','M','O','D', 0/
data	(mdname[i,15],i=1,7)/'L','O','R','E','N','T','Z'/
