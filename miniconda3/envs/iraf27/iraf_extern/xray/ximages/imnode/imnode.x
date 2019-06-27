#$Header: /home/pros/xray/ximages/imnode/RCS/imnode.x,v 11.0 1997/11/06 16:28:12 prosb Exp $
#$Log: imnode.x,v $
#Revision 11.0  1997/11/06 16:28:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:14  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:25:07  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:07:08  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:37  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:29:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:50:35  pros
#General Release 1.0
#
#
#	IMNODE.X -- change the the node name or pathname from a pixel file
#	example: one simply removes the node name (change to "0!")
#	so that no password is requested when accessing the image
#

define TY_NODE	1
define TY_DIR	2

procedure t_imnode()

int	imlist			# list of images to edit
int	index			# index into node name for "!"
int	display			# display level
int	len			# string length
int	ntype			# conversion type (node or dir)
pointer	im			# image handle of current image
pointer	image			# name of current image
pointer oldname			# old pixfile parameter with old node
pointer	newname			# new pixfile parameter with new node
pointer	nodename		# new node
pointer	sp			# stack pointer

int	clgeti()		# get a int cl param
int	stridx()		# index into string
int	strldx()		# last index into string
int	imtopenp()		# open image list
int	imtgetim()		# get next image from list
int	strlen()		# string length
bool	streq()			# string compare
pointer	immap()			# open an image

begin
	# mark the stack
	call smark (sp)

	# allocate string space
	call salloc (image, SZ_FNAME, TY_CHAR)
	call salloc (oldname, SZ_PATHNAME, TY_CHAR)
	call salloc (newname, SZ_PATHNAME, TY_CHAR)
	call salloc (nodename, SZ_PATHNAME, TY_CHAR)

	# get list of images to edit
	imlist = imtopenp ("images")
	# get the new node name
	call clgstr("node", Memc[nodename], SZ_PATHNAME)
	# get display level
	display = clgeti("display")

	# if nodename is null, make it "0"
	# also, add the "!" if necessary
	if( streq("", Memc[nodename]) ){
	    call strcpy("0!", Memc[nodename], SZ_FNAME)
	    ntype = TY_NODE
	}
	else{
	    len = strlen(Memc[nodename])
	    switch( Memc[nodename+len-1] ){
	    case '!':
		ntype = TY_NODE
	    case '/':
		ntype = TY_DIR
	    default:
		call error(1, "node name must end with a '!' or '/'")
	    }
	}

	# Main processing loop.  An image is processed in each pass through
	# the loop.
	while (imtgetim (imlist, Memc[image], SZ_FNAME) != EOF) {
	    # Open the image.
	    iferr {
		im = immap (Memc[image], READ_WRITE, 0)
	    } then {
		call printf("can't open %s\n")
		call pargstr(Memc[image])
		next
	    }

	    # get the "pixfile" parameter
	    iferr( call imgstr (im, "pixfile",  Memc[oldname], SZ_PATHNAME) ){
         	call printf ("can't get 'pixfile' for %s (not an .imh?)\n")
                call pargstr (Memc[image])
		call imunmap(im)
		next
	    }
	    # look for a null pixfile => no pixfile
	    if( streq("", Memc[oldname]) ){
         	call printf ("null valued 'pixfile' for %s (not an .imh?)\n")
                call pargstr (Memc[image])
		call imunmap(im)
		next
	    }

	    # seed the new name with the node
	    call strcpy(Memc[nodename], Memc[newname], SZ_PATHNAME)
	    # look for index into old name where node or directory ends
	    switch(ntype){
	    case TY_NODE:
		index = stridx("!", Memc[oldname])
	    case TY_DIR:
		index = strldx("/", Memc[oldname])
	    }
	    # copy in the old name without the old node
	    call strcat(Memc[oldname+index], Memc[newname], SZ_PATHNAME)
	    # write the new "pixfile" into the image
	    iferr (call impstr (im, "pixfile", Memc[newname])) {
         	call printf ("can't edit 'pixfile' for %s (%s)\n")
                call pargstr (Memc[image])
                call pargstr (Memc[oldname])
		call imunmap(im)
		next
	    }
	    # display, if necessary
	    if( display >0 ){
		call printf("%s")
		call pargstr(Memc[image])
		if( display >1 ){
		    call printf(":  %s -> %s")
		    call pargstr(Memc[oldname])
		    call pargstr(Memc[newname])
		}
		call printf("\n")
	    }
	    # close the image
	    call imunmap (im)
	    # flush output
	    call flush (STDOUT)
	}

	# close the list
	call imtclose (imlist)
	# free up stack space
	call sfree (sp)
end
