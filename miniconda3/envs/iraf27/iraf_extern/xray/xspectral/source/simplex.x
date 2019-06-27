#$Header: /home/pros/xray/xspectral/source/RCS/simplex.x,v 11.0 1997/11/06 16:43:20 prosb Exp $
#$Log: simplex.x,v $
#Revision 11.0  1997/11/06 16:43:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:10  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:35:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:55  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:50  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:24  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:17  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:07:19  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:09  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:07:30  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# SIMPLEX -- perform simplex minimization, whatever that is!
#
# ? funct, monit are not declared
#
#

include <mach.h>

procedure simplex(n, x, fmin, eps, n1, pdstar, pstar, pbar,step,
     		   y, p, funct, monit, maxit, ifail)

int	n
double	x[n]
double 	fmin
double	eps
int	n1
double	pdstar[n]
double	pstar[n]
double	pbar[n]
double	step[n]
double	y[ARB]
double	p[n1,n]
extern	funct()
extern	monit()
int	maxit
int	ifail
#--

int	etest
int	h
int	ncall
int	i
int	j
int	np1
int	lastmx
int	mcount
int	k
int	l
double 	fmax
double	r
double	f1
double	x1
double	coeff
double	f2
double	x2
double	f3
double	x3
double	deriv
double	deriv2
double	xmin
double	a
double	b
double	c
double	serror
double	cent
double	ystar
double	ydstar

double	ymean

begin

	call printf("Simplex 1\n")
	call flush(STDOUT)

      	fmax = 1000.d0
      	fmin = 0.d0
      	ncall = 0
      	r = 0
      	if (n < 1 || eps < EPSILOND || n1 != n+1 || maxit < 1 ||
     	   (ifail != 1 && ifail != 0)) {
		ifail = etest(ifail, 1)
		return
	}
   	for ( i = 1; i <= n; i = i + 1 ) {	# Use a for loop so next; is Ok
            call funct(n, x, f1)
            ncall = ncall + 1
            x1 = 0.d0
            coeff = 1.d0
            do j=1,n {
             	if ( ( i - j ) == 0 )
		    pstar[j] = x[j] + coeff
	    	else 
		    pstar[j] = x[j]
   	    }
            call funct(n, pstar, f2)
            ncall = ncall + 1
            x2 = 1.d0
            pstar[i] = pstar[i] + coeff
            call funct(n, pstar, f3)
            ncall = ncall + 1
            x3 = 2.d0

  10        if (ncall > maxit) {
		ifail = etest(ifail, 2)
		return
	    }

            deriv = (x2-x3)*f1 + (x3-x1)*f2 + (x1-x2)*f3

            if ( ( dabs(deriv) - EPSILOND ) >= 0 ) {
 	        deriv2 = deriv / ( x1 - x2 ) / ( x2 - x3 ) / ( x3 - x1 )
                if ( deriv2 < 0 ) {

 	            xmin = .5d0*((x2**2-x3**2)*f1+(x3**2-x1**2)*f2+
			(x1**2-x2**2)*f3)/deriv

            	    if ( xmin == 0.0d0)
                        xmin = 0.1d0
            	    else {
  	                if (dabs(xmin) < 0.1d0) xmin = dsign(0.1d0,xmin)
                        if (dabs(xmin) > 5.0d0) xmin = dsign(5.0d0,xmin)
	    	    }
            	    step[i] = xmin
		    next;			# NEXT iteration!
		}
	    }
            if ( ( f1 - f3 ) < 0 ) {
  	        if( x1 >  -5.0d0 ) {
		    # this if statement avoids a comiler warning
		    if( 1 == 0 ) goto 97
            	    f3 = f2
            	    x3 = x2
            	    f2 = f1
            	    x2 = x1
            	    x1 = x1 - coeff
            	    pstar[i] = x[i] + x1
            	    call funct(n, pstar, f1)
            	    ncall = ncall + 1
            	    go to 10			# continue??
97		    call error(1, "1 cannot be equal to 0!")
	        } else
		    xmin = -5.0d0
	    } else {
     		if ( x3 < 5.0d0 ) {
		    # this if statement avoids a comiler warning
		    if( 1 == 0 ) goto 98
         	    f1 = f2
         	    x1 = x2
         	    f2 = f3
         	    x2 = x3
         	    x3 = x3 + coeff
         	    pstar[i] = x[i] + x3
         	    call funct(n, pstar, f3)
          	    ncall = ncall + 1
         	    go to 10			# continue??
98		    call error(1, "1 cannot be equal to 0!")
	        } else 
   	  	    xmin = 5.0d0
	    }
            step[i] = xmin
	}


 	np1 = n + 1

      	do i=1,np1 {
         do j=1,n {
            if ( ( i - j - 1 ) != 0) {
              pstar[j] = x[j]
              p(i,j) = x[j]
	    } else {
              pstar[j] = x[j] + step[j]
              p[i,j] = x[j] + step[j]
	    }
	 }
         ncall = ncall + 1
         call funct(n, pstar, y[i])
	}

      a = 1.d0
      b = .5d0
      c = 2.d0
      lastmx = 0
      mcount = 0
      k = 0

  42  k = k + 1
      fmax = y[1]
      fmin = y[1]
      h = 1
      l = 1

       do i=2,n1 {
            if ( ( y[i] - fmax ) > 0 ) {
                fmax = y(i)
                h = i
            } else {
                if ( ( y[i] - fmin ) < 0 ) {
        	    fmin = y[i]
         	    l = i
	        }
	    }
	}

       if ( ( lastmx - h ) == 0 ) {
          mcount = mcount + 1
          if ( ( mcount - 5 ) == 0 )
   		if ( ( h - 1 ) == 0 ) {
   		    h = 2
      		    fmax = y[h]
		} else {
   		    h = 1
      		    fmax = y[h]
		}
	} else {
   	    lastmx = h
      	    mcount = 0
	}

      call monit(fmin, fmax, p, n, n1, ncall)

      	if ( ( k != 1 ) && (( serror - eps ) < 0) ) {
  	    do i=1,n {
                 x[i] = p[l,i]
 	    }
	    ifail = etest(ifail, 0)
	    return
	}

      	if ( ( ncall - maxit ) >= 0 ) {
 	    do i=1,n {
                 x[i] = p[l,i]
 	    }
	    ifail = etest(ifail, 2)
	    return
	}

	do j=1,n {
         cent = 0.d0
         do i=1,n1 {
            if ( ( i - h ) != 0 )
              cent = cent + p[i,j]
	 }
         pbar[j] = cent/dfloat(n)
	}

#     reflection

      	do i=1,n {
         pstar[i] = (1.d0+a)*pbar[i] - a*p[h,i]
	}

      call funct(n, pstar, ystar)
      ncall = ncall + 1


#     expansion

      	if ( ( ystar - fmin ) < 0 ) {
           do i=1,n {
               pdstar[i] = (1.d0+c)*pstar[i] - c*pbar[i]
  	   }
           call funct(n, pdstar, ydstar)
           ncall = ncall + 1

           if ( ydstar-ystar  < 0 ){
	       # this if statement avoids a comiler warning
	       if( 1 == 0 ) goto 99
	       go to 11
99	       call error(1, "1 cannot be equal to 0!")
	   }
	   else go to 14
	}

#      contraction

      	do i=1,n {
         if ( ( i - h ) != 0 )
             if (ystar-y(i) < 0 ) go to 14

	}

      	if ( ( fmax - ystar ) > 0 ) {
  	    do i=1,n {
         	p[h,i] = pstar[i]
  	    }
	}

      	do i=1,n {
            pdstar[i] = b*p[h,i] + (1.d0-b)*pbar[i]
  	}

      call funct(n, pdstar, ydstar)
      ncall = ncall + 1

      if ( ( ydstar - fmax ) <= 0 ) go to 11

  94 	do i=1,n1 {
            do j=1,n {
                pbar[j] = (p[i,j]+p[l,j])*0.5d0
                p[i,j] = pbar[j]
	    }
            call funct(n, pbar, y[i])
            ncall = ncall + 1
	}

      go to 18

 11 	do j=1,n {
            p[h,j] = pdstar[j]
 	}
      	y[h] = ydstar

      go to 18

 14 	do j=1,n {
            p[h,j] = pstar[j]
 	}
        y[h] = ystar

 18 	ymean = 0.d0
      	serror = 0.d0
      	do i=1,n1 {
         ymean = ymean + y[i]
 	}
      	ymean = ymean/dfloat(n+1)
      	do i=1,n1 {
         serror = serror + (y[i]-ymean)**2
	}
      	serror = dsqrt(serror/dfloat(n+1))
      	go to 42
end

#
# ETEST -- Test the error value
# 
int procedure etest(ifail, eflag)
int	ifail
int	eflag
#--

#     returns the value of error or terminates the program.
#
begin
      	if ( eflag == 0 )			# test if no error detected
	    return eflag

      	if ( mod(ifail, 10) != 1 ) {	# test for soft failure
	    #     hard failure
	    #
	    call eprintf("Error detected by Minimization routine ifail = %d\n")
 	     call pargi(eflag)

      	    call error(1, "Simplex error")

	} else {
	    # soft fail
	    #
	    if ( mod(ifail / 10, 10) != 0 ) {		# supress errors 

	        call eprintf("Error detected by Minimization routine ifail = %d\n")
 	         call pargi(eflag)

	        return eflag
	    }
	}
end


