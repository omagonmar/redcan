CFLAGS= -c
FFLAGS= -c

OBJ=	powell.o linmin.o mnbrak.o brent.o f1dim.o
 
LIBFILE=libextra.a

all:		$(OBJ) libextra.a

libextra.a:
		ar rcv $(LIBFILE) $(OBJ)
		ranlib $(LIBFILE)

powell.o:
		@$(FC) $(FFLAGS) powell.f
linmin.o:
		@$(FC) $(FFLAGS) linmin.f
mnbrak.o:
		@$(FC) $(FFLAGS) mnbrak.f
brent.o:
		@$(FC) $(FFLAGS) brent.f
f1dim.o:
		@$(FC) $(FFLAGS) f1dim.f
