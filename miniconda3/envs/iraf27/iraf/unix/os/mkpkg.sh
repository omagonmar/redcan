# Bootstrap the LIBOS.A library.

echo		"--------------------- OS ----------------------"


$CC -c $HSI_CF -Wall alloc.c getproc.c
$CC $HSI_LF -Wall alloc.o getproc.o $HSI_OSLIBS -o alloc.e
chmod		4755 alloc.e
mv -f		alloc.e ../hlib
rm -f		alloc.o


if test "$IRAFARCH" != "macosx"; then
    for i in zsvjmp ;\
        do $CC -c $HSI_CF -Wall ../as/$i.s -o $i.o ;\
    done
fi


for i in gmttolst.c irafpath.c prwait.c z*.c ;\
    do $CC -c $HSI_CF -Wall $i ;\
done

#ar rv		libos.a *.o; ar dv libos.a zmain.o; rm *.o

if test "$IRAFARCH" = "macosx"; then
#    $CC -c -O -DMACOSX -w -Wunused -arch ppc ../as/zsvjmp_ppc.s -o zsvjmp.o ;\
#    libtool -a -T -o libos.a zsvjmp.o
#    rm -f zsvjmp.o
#    $CC -c -O -DMACOSX -w -Wunused -arch i386 ../as/zsvjmp_i386.s -o zsvjmp.o ;\
#    libtool -a -T -o libos.a libos.a zsvjmp.o
#    rm -f zsvjmp.o zmain.o
#    libtool -a -T -o libos.a libos.a *.o


    # UR (JT): I'm not sure why HSI_CF was missing here, for macosx only, but
    # it causes lots of OS version warnings from clang on 10.10. I've instead
    # added HSI_LF below, which is a bit of a hack but specifies the correct
    # architecture without including additional compiler options that might
    # perhaps have been omitted intentionally to avoid some obscure problem.
    $CC -c $HSI_LF -O -DMACOSX -w -Wunused -arch i386 ../as/zsvjmp_i386.s -o zsvjmp.o ;\
    libtool -a -T -o libos.a zsvjmp.o
    rm -f zsvjmp.o zmain.o
    libtool -a -T -o libos.a libos.a *.o


else
    rm -f zmain.o
    ar r	libos.a *.o; 
    ranlib	libos.a
fi

rm *.o

there=../bin/libos.a
rm -f $there
cp -f libos.a $there 

there=$hlib/libos.a
rm -f $there
cp -f libos.a $there

