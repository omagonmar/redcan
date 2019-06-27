#$Header: /home/pros/xray/xplot/imcontour/RCS/clevstore.x,v 11.0 1997/11/06 16:38:03 prosb Exp $
#$Log: clevstore.x,v $
#Revision 11.0  1997/11/06 16:38:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:48  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:00  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:23  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:53  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:35:00  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/01/15  13:29:33  janet
#*** empty log message ***
#
#Revision 3.0  91/08/02  01:23:58  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:27  wendy
#Initial revision
#
#Revision 2.1  91/03/26  10:32:03  janet
#Added init_params routine that initializes the contour level structure ptr.
#
#Revision 2.0  91/03/06  23:20:43  pros
#General Release 1.0
#
include "clevels.h"

# -----------------------------------------------------
procedure set_levels ()

include "clevels.com"

begin

     FUNC(sptr) = LEVELS

end

# -----------------------------------------------------

procedure set_linear ()

include "clevels.com"

begin

     FUNC(sptr) = LINEAR

end

# -----------------------------------------------------

procedure set_log ()

include "clevels.com"

begin

     FUNC(sptr) = LOG

end

# -----------------------------------------------------

procedure init_params ()

include "clevels.com"

begin

   NUM_PARAMS(sptr) = 0

end

# -----------------------------------------------------

procedure set_param (val)

real  val

include "clevels.com"

begin

   NUM_PARAMS(sptr) = NUM_PARAMS(sptr) + 1

   PARAMS(sptr,NUM_PARAMS(sptr)) = val 

end

# -----------------------------------------------------

procedure set_negparam (val)

real  val

include "clevels.com"

begin

   NUM_PARAMS(sptr) = NUM_PARAMS(sptr) + 1

   PARAMS(sptr,NUM_PARAMS(sptr)) = -(val) 

end
