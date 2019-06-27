# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
#JCC(6/9/97) - A new version for iraf2.11.beta from Maureen. 
#            - The old one saved in RCS as qpaddf.x.pros2.4. 
 
#include        <syserr.h>
#include        <error.h>
#include        <qpset.h>
 
# QP_ADDF -- Add a new field (header parameter) to the datafile.  It is an
# error if the parameter redefines an existing symbol.  For variable array
# parameters the initial size is zero, and a new lfile is allocated for the
# parameter value.  For static parameters storage is initialized to all zeros.
 
procedure qpx_addf (qp, param, datatype, maxelem, comment, flags)
 
pointer qp                      #I QPOE descriptor
char    param[ARB]              #I parameter name
char    datatype[ARB]           #I parameter data type
int     maxelem                 #I allocated length of parameter
char    comment[ARB]            #I comment describing parameter
int     flags                   #I parameter flags
 
begin
        call qp_addf (qp, param, datatype, maxelem, comment, flags)
end

