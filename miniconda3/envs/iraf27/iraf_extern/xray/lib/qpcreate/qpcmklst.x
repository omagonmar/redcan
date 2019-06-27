# $Header: /home/pros/xray/lib/qpcreate/RCS/qpcmklst.x,v 11.0 1997/11/06 16:22:01 prosb Exp $
# $Log: qpcmklst.x,v $
# Revision 11.0  1997/11/06 16:22:01  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:29:34  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:27  prosb
#General Release 2.3.1
#
#Revision 1.1  94/03/25  14:37:31  mo
#Initial revision
#
#
# Module:       QPCMKLST.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      QPOE EVENT list definitions of record structures
# Description:  This routine uses the EVENT definition info stored in 
#		qpcreate.com by the qpcreate.x routine, to
#		re-construct the PROS/EVENTDEF string
# External:     qpcmklst
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC   -- initial version            1994

procedure qpc_mklst(prosdef)
char	prosdef		# o:
include "qpcreate.com"

begin
	call ev_credef(msymbols,mvalues,nmacros,prosdef)
end
