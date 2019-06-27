"""
$Revision: 1.2 $ $Date: 2010/05/18 07:56:00 $
Author: Martin Kuemmel (mkuemmel@stecf.org)
Affiliation: Space Telescope - European Coordinating Facility
WWW: http://www.stecf.org/software/slitless_software/axesim/
"""
import os
import iraf
import sys

no = iraf.no
yes = iraf.yes

from axe import axesrc
#import axesrc

# Point to default parameter file for task
_parfile = 'axe$prepimages.par'
_taskname = 'prepimages'


######
# Set up Python IRAF interface here
######
def prepimages_iraf(inlist, model_images=None):

    # properly format the strings
    inlist       = axesrc.straighten_string(inlist)
    model_images = axesrc.straighten_string(model_images)

    # check for minimal input
    if inlist == None:
        # print the help
        iraf.help(_taskname)

    # if there is enough input
    else:

        # execute the python function
        axesrc.prepimages(inlist=inlist, model_images=model_images)

# Initialize IRAF Task definition now...
parfile = iraf.osfn(_parfile)
a = iraf.IrafTaskFactory(taskname=_taskname,value=parfile,
            pkgname=PkgName, pkgbinary=PkgBinary, function=prepimages_iraf)
