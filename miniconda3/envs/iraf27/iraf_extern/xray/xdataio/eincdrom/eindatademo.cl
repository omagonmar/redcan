#$Log: eindatademo.cl,v $
#Revision 11.0  1997/11/06 16:37:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:54  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:23:47  prosb
#General Release 2.3.1
#
#Revision 1.2  94/06/22  14:10:10  dvs
#Removed sequence 5936 from eindatademo script.  It will now
#only check for the existence of sequence 5803 in the demo
#directory.
#
#Revision 1.1  94/06/01  11:43:44  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/RCS/eindatademo.cl,v 11.0 1997/11/06 16:37:17 prosb Exp $

#################################################################
# Module:       eindatademo.cl
# Author:       David Van Stone
# Project:      PROS -- EINSTEIN DATA
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
#
# Purpose :     To demonstrate the Einstein unscreened IPC data
#
# Note: 	The user must have the four QPOE files loaded
#		into the eincdromdemo directory.
#################################################################

	print("")

	# check that the data is in the eincdromdemo directory
	
	if ( ! (access("eincdromdemo$i5803.qp") &&
                access("eincdromdemo$i5803u.qp")))
	{

	    print("The necessary data for this demo has not been installed.")
	    print("")
	    print("The directory eincdromdemo$ should have the following")
	    print("two QPOE files:")
	    print("")
	    print("  i5803.qp   (Einstein IPC event sequence 5803)")
	    print("  i5803u.qp  (Einstein IPC unscreened sequence 5803)")
	    print("")
	    print("See the PROS installation notes for information on")
	    print("installing this data.")
	    beep
	    bye
	}
	else
	{
	    # now run the demo
	    stty delay=1000 playback=eincdrom$eindatademo
	}
