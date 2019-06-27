#$Header: /home/pros/xray/xtiming/fakesrc/RCS/fakesrc.h,v 11.0 1997/11/06 16:44:20 prosb Exp $
#$Log: fakesrc.h,v $
#Revision 11.0  1997/11/06 16:44:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:39:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:32  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:25  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:20  prosb
#General Release 2.1
#
#Revision 2.0  91/03/06  22:40:45  pros
#General Release 1.0
#
# argv structure ##### Need standard stuff first
define	LEN_ARG	15 + SZ_DEFARGV
define	AR_LENA	Memd[P2D(SZ_DEFARGV+argv)]	# length of aquisition
define	AR_TOTT	Memd[P2D(SZ_DEFARGV+argv)+1]	# total time of src fcn
define	AR_TIME	Memd[P2D(SZ_DEFARGV+argv)+2]	# last time written
define	AR_INLT	Memd[P2D(SZ_DEFARGV+argv)+3]	# how much through last bin
define	AR_SEED	Meml[P2D(SZ_DEFARGV+argv)+4]	# random number seed
define	AR_FNMN Memi[SZ_DEFARGV+argv + 10]	# name of sample rate file
define	AR_FNNM	Memc[AR_FNMN]			# time gone through
define	AR_FNCA	Memi[SZ_DEFARGV+argv + 11]	# array form of same
define	AR_FNCB	Memd[AR_FNCA + $1]		# actual src fcn bins
define	AR_NUMB	Memi[SZ_DEFARGV+argv + 12]	# number of src fcn bins
define	AR_LSTB	Memi[SZ_DEFARGV+argv + 13]	# last bin read
define	AR_SEQN	Memi[SZ_DEFARGV+argv + 14]	# sequence number of flight
define	AR_DOPR	Memi[SZ_DEFARGV+argv + 15]	# write profile file? 1 or 0
define	AR_PROF	Memi[SZ_DEFARGV+argv + 16]	# profile file 


# general constants
define	DEFAULT_X	512
define	DEFAULT_Y	512
define	DEFAULT_DX	0
define	DEFAULT_DY	0
define	DEFAULT_PHA	8
define	DEFAULT_PI	8
define	DEFAULT_ENERGY	7
