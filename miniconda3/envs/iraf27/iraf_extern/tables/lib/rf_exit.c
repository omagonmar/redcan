/* This routine is used by unix system and is called by 
 *  fitsio$strfits/t_rfits.x
*/
#include <stdlib.h>
#if defined (__hpux) || defined (_AIX) 
#define rfexit_ rfexit
#endif

void rfexit_ (exit_code) 
int	*exit_code;
{ 
	exit (*exit_code);
}
