#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_addmsk.x,v 11.0 1997/11/06 16:45:08 prosb Exp $
#$Log: tim_addmsk.x,v $
#Revision 11.0  1997/11/06 16:45:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:31  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:04  prosb
#General Release 2.3
#
#Revision 6.1  93/12/08  01:24:55  dennis
#Added code to restore '\n's that had been replaced by '\\'s by put_mask();
#put_tbh() needs the '\n's.
#
#Revision 6.0  93/05/24  16:59:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:05:49  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:36:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:02:26  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:33  pros
#General Release 1.0
#
include <tbset.h>
include <qpset.h>
include <qpoe.h>
include <plhead.h>

#  ---------------------------------------------------------------------
#  TIM_ADDMSK - add mask info to table header
#
procedure tim_addmsk (tp, qp, qp_name, label)

pointer tp		# i: table pointer
pointer	qp		# i: pointer to qpoe source
char    qp_name[ARB]    # i: qpoe file name
char    label[ARB]      # i: src or bk label

int	i
int	nrecs
int     nchars
int	len

pointer sp
pointer tbuf		# l: buffer for "XS-MSK##" parameter name
pointer mask		# l: mask record(s), initially with '\n's replaced 
			#     by '\\'s, later with '\n's restored

int	qp_accessf()
int  	qp_geti()
int	qp_gstr()
int	strlen()

begin

	call smark(sp)
	call salloc(tbuf, SZ_LINE, TY_CHAR)
	call salloc(mask, SZ_PLHEAD, TY_CHAR)

#  Check for and output region info
	if (qp_accessf(qp, "XS-NMASK") == NO) {
	   nrecs = 0
	} else { 
	   call tbhadt(tp,"mskinfo","Region Mask Information from Input Qpoe:")
	   nrecs = qp_geti (qp, "XS-NMASK")
	   do i = 1, nrecs {
	      call sprintf (Memc[tbuf], SZ_LINE, "XS-MSK%02d")
	        call pargi(i)
	      if (qp_accessf(qp, Memc[tbuf]) == NO) {
	         call error (1, "can't find xs-mask record ", i)
	      } else {
	         nchars = qp_gstr (qp, Memc[tbuf], Memc[mask], SZ_PLHEAD)
	      }
	   }
	   # Restore '\n's to the mask record(s)
	   len = strlen(Memc[mask])
	   for (i = 0;  (i < len) && (Memc[mask + i] != EOS);  i = i + 1)  {
	      if (Memc[mask + i] == '\\')
	         Memc[mask + i] = '\n'
	   }
	   # Parse the mask record(s) out into table header parameters
	   call put_tbh (tp, label, qp_name, Memc[mask])
	}

	call sfree(sp)

end
