# Copyright(c) 2003-2009 Association of Universities for Research in Astronomy, Inc.
#
# Package script for the midir package
#
# Version: Jan   9, 2004 KL  Release v1.5
#          Apr  19, 2004 KL  Release v1.6
#          Oct  25, 2004 KL  Release v1.7
#          May   6, 2005 KL  Release v1.8
#          Jul  28, 2006 KL  Release v1.9
#          Jul  28, 2009 JH  Release v1.10
#
# Load necessary packages - if anything else than loaded
# by gemini should be necessary
gemtools
onedspec
gnirs

print ""
print "Loading the gnirs package:"
#? gnirs
print ""
print "Loading the midir package:"
package midir
# miutil			# NOT RELEASED		
set  miutil	= "midir$miutil/" # NOT RELEASED	
task miutil.pkg = "miutil$miutil.cl" # NOT RELEASED	

# TReCS Specific Tasks
task      tprepare=midir$tprepare.cl
task      tbackground=midir$tbackground.cl
task      tview=midir$tview.cl
task      tcheckstructure=midir$tcheckstructure.cl
#task      prueba=midir$prueba.cl

#Michelle Specific Tasks
task      mprepare=midir$mprepare.cl
task      mbackground=midir$mbackground.cl  	# NOT RELEASED
task      mview=midir$mview.cl
task      mcheckheader=midir$mcheckheader.cl
task      miclean=midir$miclean.cl

# Image reductions
task      miflat=midir$miflat.cl
task      miview=midir$miview.cl
task      mistack=midir$mistack.cl
task      mibackground=midir$mibackground.cl	# NOT RELEASED
task      miregister=midir$miregister.cl
task      mireduce=midir$mireduce.cl
task      mistdflux=midir$mistdflux.cl

# Michelle Polarimetry reductions
task      mipstack=midir$mipstack.cl
task      miptrans=midir$miptrans.cl
task      mipsplit=midir$mipsplit.cl
task      mipstokes=midir$mipstokes.cl
task      mipsstk=midir$mipsstk.cl
task      mipql=midir$mipql.cl
task      mipsf=midir$mipsf.cl

# Spectroscopy reductioms
task      mstelluric=midir$mstelluric.cl
task      msabsflux=midir$msabsflux.cl
task      msdefringe=midir$msdefringe.cl
task      msflatcor=midir$msflatcor.cl
task      msreduce=midir$msreduce.cl
task      msslice=midir$msslice.cl

# Cook book task
task      midirinfo=midir$midirinfo.cl
task      midirexamples=midir$midirexamples.cl

# Local tasks

clbye()
