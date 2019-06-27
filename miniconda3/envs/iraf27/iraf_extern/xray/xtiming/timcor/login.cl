# Identify login.cl version (checked in images.cl).
if (defpar ("logver"))
    logver = "IRAF V2.11 May 1997"

set	home		= "/home/pros/xray/xtiming/timcor/"
set	imdir		= "./"
set	uparm		= "home$uparm/"
set	userid		= "prosb"

#
# Set up X Windows equivalent of gterm if appropriate 
#
if ( envget("TERM") == "xterm" || envget("TERM") == "vs100") {
#               set     graphcap        = "home$dev/graphcap.pers"
	if (!access (".hushiraf") ) 
	    print "resetting terminal to xterm with graphics"
    	reset terminal = xterm
    	reset stdgraph = xterm
    	stty xterm nl=44
}
else if (envget("TERM") == "xgterm" ){
#       set     graphcap    = "dev$graphcap.noao"
	if (!access (".hushiraf") ) 
 		print "resetting terminal to xgterm with graphics"
	reset terminal = xgterm
	reset stdgraph = xgterm
#       stty xgterm
}
# Set the terminal type.
else if (envget("TERM") == "sun") {
    if (!access (".hushiraf"))
	print "setting terminal type to gterm..."
    reset terminal = gterm
    reset stdgraph = gterm
    stty gterm
} else {
    if (!access (".hushiraf"))
	print "setting terminal type to y..."
    stty y
}

# Default the printer, plotter and editor to the UNIX values
# PRINTER end EDITOR environment variables already set in cl wrapper..

    set printer = envget("PRINTER")
    set stdplot = envget("PRINTER")
    set editor = envget("EDITOR")

# Uncomment and edit to change the defaults.
#set	editor		= vi
#set	printer		= lw
#set	stdimage	= imt800
#set	stdimcur	= stdimage
#set	stdplot		= lw
#set	clobber		= no
#set	filewait	= yes
set	cmbuflen	= 512000
set	min_lenuserarea	= 64000
#set	imtype		= "imh"

set qmfiles = home$dev/QPDEFS

# IMTOOL/XIMAGE stuff.  Set node to the name of your workstation to
# enable remote image display.  The trailing "!" is required.
#set	node		= "my_workstation!"

# CL parameters you might want to change.
#ehinit   = "nostandout eol noverify"
#epinit   = "standout showall"
showtype = yes

# Default USER package; extend or modify as you wish.  Note that this can
# be used to call FORTRAN programs from IRAF.

package user

task	$adb $bc $cal $cat $comm $cp $csh $date $dbx $df $diff	= "$foreign"
task	$du $find $finger $ftp $grep $lpq $lprm $ls $mail $make	= "$foreign"
task	$man $mon $mv $nm $od $ps $rcp $rlogin $rsh $ruptime	= "$foreign"
task	$rwho $sh $spell $sps $strings $su $telnet $tip $top	= "$foreign"
task	$touch $vi $emacs $w $wc $less $rusers $sync $pwd $gdb	= "$foreign"
task	$hotseat $lpr = "$foreign"

task	$xc $mkpkg $generic $rtar $wtar $buglog			= "$foreign"
#task	$fc = "$xc -h $* -limfort -lsys -lvops -los"
task	$fc = ("$" // envget("iraf") // "unix/hlib/fc.csh" //
	    " -h $* -limfort -lsys -lvops -los")
task	$nbugs = ("$(setenv EDITOR 'buglog -e';" //
	    "less -Cqm +G " // envget ("iraf") // "local/bugs.*)")
task	$cls = "$clear;ls"

if (access ("home$loginuser.cl"))
    cl < "home$loginuser.cl"
;

keep;   clpackage

prcache directory
cache   directory page type help

print ("printer = ", envget ("printer"))
print ("editor = ", envget ("editor"))

!sleep 2 

# Print the message of the day.
if (access (".hushiraf"))
    menus = no
else {
    clear
    if ( envget("xrayversion") == "new") 
        type hlib$motdd
    else if ( envget("xrayversion") == "dev")
	type hlib$motddd
    else
        type hlib$motd
}

# Delete any old MTIO lock (magtape position) files.
if (deftask ("mtclean"))
    mtclean
else
    delete uparm$mt?.lok,uparm$*.wcs verify-

# List any packages you want loaded at login time, ONE PER LINE.
images          # general image operators
plot            # graphics tasks
dataio          # data conversions, import export
lists           # list processing

# The if(deftask...) is needed for V2.9 compatibility.
if (deftask ("proto"))
    proto       # prototype or ad hoc tasks

tv              # image display
utilities       # miscellaneous utilities
noao            # optical astronomy packages

# define the default iraf and pros demo tasks 
set     demos = "iraf$demos/"
task    demos = demos$demos.cl

keep
