#$Header: /home/pros/xray/xspectral/source/extra/RCS/hri_test.x,v 11.0 1997/11/06 16:41:38 prosb Exp $
#$Log: hri_test.x,v $
#Revision 11.0  1997/11/06 16:41:38  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:26  prosb
#General Release 2.4
#
Revision 8.0  1994/06/27  17:35:26  prosb
General Release 2.3.1

Revision 7.0  93/12/27  18:53:44  prosb
General Release 2.3

Revision 6.0  93/05/24  16:53:14  prosb
General Release 2.2

Revision 5.0  92/10/29  22:43:00  prosb
General Release 2.1

Revision 3.0  91/08/02  01:59:28  prosb
General Release 1.1

#Revision 2.0  91/03/06  23:03:52  pros
#General Release 1.0
#

DEFINE AREA_BINS 128

procedure t_getarea ()

pointer	efar_area		# l: ptr for real array of effective areas
pointer efar_energy		# l: corresponding energies
pointer sp
int i

begin
	call smark (sp)
	call salloc (efar_area, AREA_BINS, TY_REAL)
	call salloc (efar_energy, AREA_BINS, TY_REAL)
	call get_hri_efar (Memr[efar_energy], Memr[efar_area], 3)
	call printf( "Effective areas: first energy, then area\n");
	do i = 0, AREA_BINS - 1
	{
	    call printf( "%10.6f, %10.6f\n" )
	     call pargr (Memr[efar_energy + i])
	     call pargr (Memr[efar_area + i])
	}
	call sfree(sp)
end


procedure t_scatter ()

double	energy
double	val1, val2, val3, val4
double	vala, valb, valc
real	angle
int	i
double	hri_coma_scatter()

begin
	{
	    do i = 150, 750, 150 
	    {
		angle = real(i) / 60.0
		energy = 0.28d0
		vala = hri_coma_scatter(energy, angle)
		energy = 1.5d0
		valb = hri_coma_scatter(energy, angle)
		energy = 2.98d0
		valc = hri_coma_scatter(energy, angle)

		energy = 0.1275d0
		val4 = hri_coma_scatter(energy, angle)
		energy = 0.585d0
		val1 = hri_coma_scatter(energy, angle)
		energy = 0.89d0
		val2 = hri_coma_scatter(energy, angle)
		energy = 1.195d0
		val3 = hri_coma_scatter(energy, angle)
		call printf ("%5.3f  %5.3  %5.3f %5.3f %5.3f  %5.3")
		 call pargr(val4)
		 call pargr(vala)
		 call pargr(val1)
		 call pargr(val2)
		 call pargr(val3)
		 call pargr(valb)

		energy = 1.87d0
		val1 = hri_coma_scatter(energy, angle)
		energy = 2.24d0
		val2 = hri_coma_scatter(energy, angle)
		energy = 2.61d0
		val3 = hri_coma_scatter(energy, angle)
		energy = 3.35d0
		val4 = hri_coma_scatter(energy, angle) 
		call printf ("  %5.3f %5.3f %5.3f  %5.3f  %5.3f\n\n")
		 call pargr(val1)
		 call pargr(val2)
		 call pargr(val3)
		 call pargr(valc)
		 call pargr(val4)
	    }
	}
end
