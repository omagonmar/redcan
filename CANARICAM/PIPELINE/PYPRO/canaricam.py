#!/usr/bin/env python

from pylab import *
from scipy.interpolate import interp1d
from scipy.interpolate import interp2d
from scipy.integrate import quad,trapz
from scipy.ndimage import gaussian_filter as gf
#from spitzer import *
#from spectools import *
from pyraf import iraf
import astropy.io.fits as pyfits
import pyfits as pf
import matplotlib as mpl
import matplotlib.pyplot as plt


#a = loadtxt('reduced.list',dtype='S')
#a.sort()

def contslope(wl,flux,z):
  """
  Evaluate the continuum slope
  """
  
  zcor = 1.+z
  flux = normspec(wl,flux,11.3*zcor,.2)
  clims = ( ((wl>10.8*zcor)&(wl<10.9*zcor)) | ((wl>11.7*zcor)&(wl<11.8*zcor)) )
  wlcont,fluxcont = wl[clims],flux[clims]
  pcont = polyfit(wlcont,fluxcont,1)
  print 'polyfit: ',pcont
  fcont = lambda x : polyval(pcont,x)

  figspec = plt.figure(2)
  plt.clf()
  axspec = axes()
  axspec.plot(wl,flux)
  axspec.plot(wlcont,polyval(pcont,wlcont))
  axspec.plot(wl,fcont(wl))
  axspec.set_xlabel(r'Wavelength ($\mu$m)')
  axspec.set_ylabel(r'$F_\nu/F_{12\mu m}$')

  print 'Continuum slope between {:.2f} and {:.2f}: {:.2f}'.format(10.85*zcor,11.85*zcor,pcont[0])

  #pahcoeff = quad(lambda x : fpah(x)*fcont(x),7,15,epsrel=1.e-3,limit=1000)[0]
  #contcoeff = quad(lambda x : fsi(x)*fcont(x),7,15,epsrel=1.e-3,limit=1000)[0]

  #print 'contcoeff: {:.2f}'.format(contcoeff)
  #print 'pahcoeff: {:.2f}'.format(pahcoeff)

  factor = polyval(pcont,11.3*zcor)/polyval(pcont,11.6*zcor)

  print 'F_PAH2 / F_Si-5: {:.2f}'.format(factor)
  return factor


def filters_subtraction(contfile,pahfile,spec=None,z1=0,z2=5,cont_fwidth=.9,pah_fwidth=.6,showfigs='True',xlims=(-10,10),ylims=(-10,10),savefigs='False',plotname='lixo.pdf',redshift=0):
  """
  Plots the three images continuum,pah+continuum,pah.

  cont andi pah should be arrays.
  here the continuum is expected to be the filter Si5-11.6

  spec : array
    Array containing the wavelength in the first column
    and the flux in the second. This will be used to yield
    the continuum flux factor between the two filters.
  """

#  cgain,pgain = [pf.open(x)[0].header['gain'] for x in (contfile,pahfile)]
#  cont,pah = [pf.open(x)[0].data for x in (contfile,pahfile)]

  cont,pah = [pf.open(i)[0].data[0] for i in (contfile,pahfile)]


  
  dx,dy = .27,.75
  fpah = interp1d(loadtxt('/scratch/druschel/PAH2.txt')[:,0],loadtxt('/scratch/druschel/PAH2.txt')[:,1]/100.,bounds_error=False,fill_value=0)
  fsi = interp1d(loadtxt('/scratch/druschel/Si-5.txt')[:,0],loadtxt('/scratch/druschel/Si-5.txt')[:,1]/100.,bounds_error=False,fill_value=0)
 
  if spec == None:
    sub = pah*pah_fwidth-cont*cont_fwidth
  else:
    # Evaluate the continuum slope
    wl,flux = spec[:,0],spec[:,1]
    zcor = 1.+redshift
    flux = normspec(wl,flux,11.3*zcor,.2)
    clims = ( ((wl>10.8*zcor)&(wl<10.9*zcor)) | ((wl>11.7*zcor)&(wl<11.8*zcor)) )
    wlcont,fluxcont = wl[clims],flux[clims]
    pcont = polyfit(wlcont,fluxcont,1)
    fcont = lambda x : polyval(pcont,x)

    figspec = plt.figure(2)
    plt.clf()
    axspec = axes()
    axspec.plot(wl,flux)
    axspec.plot(wlcont,polyval(pcont,wlcont))
    axspec.plot(wl,fcont(wl))
    axspec.set_xlabel(r'Wavelength ($\mu$m)')
    axspec.set_ylabel(r'$F_\nu/F_{12\mu m}$')

    print 'Continuum slope between {:.2f} and {:.2f}: {:.2f}'.format(10.85*zcor,11.85*zcor,pcont[0])

    pahcoeff = quad(lambda x : fpah(x)*fcont(x),7,15,epsrel=1.e-3,limit=1000)[0]
    contcoeff = quad(lambda x : fsi(x)*fcont(x),7,15,epsrel=1.e-3,limit=1000)[0]

    print 'contcoeff: {:.2f}'.format(contcoeff)
    print 'pahcoeff: {:.2f}'.format(pahcoeff)

    c = (cont-pah)/(contcoeff-pahcoeff)
    sub = pah-contcoeff*c

  fig = plt.figure(1,figsize=(9,3))
  plt.clf()

  axc = plt.axes((.05,.15,dx,dy))
  axpah = plt.axes((2*.05+dx,.15,dx,dy))
  axsub = plt.axes((3*+.05+2*dx,.15,dx,dy))

  eixos = [axc,axpah,axsub]
  
  pxscale = 0.08  # arcsec/pixel
  ext = tuple(array([-160,160,-120,120])*pxscale)
  axc.imshow(cont,origin='lower',vmin=z1,vmax=z2,extent=ext)
  axpah.imshow(pah,origin='lower',vmin=z1,vmax=z2,extent=ext)
  axsub.imshow(sub,origin='lower',vmin=z1,vmax=z2,extent=ext)

  axpah.set_title(pf.open(contfile)[0].header['object'])

  for i in eixos:
    i.set_xlim(xlims)
    i.set_ylim(ylims)

  if showfigs:
    plt.show()

  if savefigs:
    plt.savefig(plotname,format='pdf',bbox_inches='tight')

  if spec == None:
    return sub
  else:
    return sub,c,pcont[0]

def overplot_filters(specfile,showfigs=True):
  
  spec = readtbl(specfile)
  fpah = interp1d(loadtxt('/scratch/druschel/PAH2.txt')[:,0],loadtxt('/scratch/druschel/PAH2.txt')[:,1],bounds_error=False,fill_value=0)
  fsi = interp1d(loadtxt('/scratch/druschel/Si-5.txt')[:,0],loadtxt('/scratch/druschel/Si-5.txt')[:,1],bounds_error=False,fill_value=0)

  if (shape(spec)[1] == 5):
    x,y = spec[:,1],spec[:,2]
  elif (shape(spec)[1] == 3):
    x,y = spec[:,0],spec[:,1]  

  fig = plt.figure(1)
  plt.clf()
  ax = axes()

  ax.plot(x,normspec(x,y,12.,.5))
  ax.plot(x,fpah(x)/100)
  ax.plot(x,fsi(x)/100)

  ax.set_xlabel(r'Wavelength ($\mu$m)')
  ax.set_ylabel(r'$F_\nu/F_{12\mu m}$')

  if showfigs:
    plt.show()

def saveset_peakcoords(basename,threshold=100,hwhm=3):
  """
  Attempts to find the peak of each saveset in
  an already tprepared image.

  Parameters:
  -----------
  basename : string
    Everything before the .fits
  threshold : number
    Detection threshold for images.imcoords.starfind
    in counts

  Returns:
  --------
  c : numpy.array
    Row stacked coordinates for each of the savesets
  """
  #deleting files from previous runs
  iraf.delete('*fits*obj*')
  iraf.delete('images_ext.lst')
  iraf.images()
  iraf.imcoords()

  exts = len(pf.open(basename+'.fits'))-1
  
  f = open('images_ext.lst','w')
  for i in range(exts):
    f.write(basename+'.fits['+str(i+1)+'][*,*,3]\n')
  f.close()
 
  iraf.starfind(r'@images_ext.lst','default',hwhm,threshold)
  a = [basename+'.fits'+str(i+1)+'.obj.1' for i in range(exts)]
  b = [loadtxt(a[i]) for i in range(exts) if len(loadtxt(a[i])) != 0]
  c = row_stack(b)

  f = open(a[0],'r')
  d = f.readlines()
  f.close()

  header = [i for i in d if i[0] == '#']

  f = open(basename+'_coords.dat','w')
  for i in header:
    f.write(i)
  f.write('\n')

  savetxt(f,c,fmt='%.3f')

  f.close()

  iraf.delete('*fits*obj*')
  iraf.delete('images_ext.lst')

  return c

class midir_stack:
  
  def __init__(self,filename):
   
    self.filename = filename
    self.image = pf.open(filename)
    self.savesets = shape(self.image[1].data)[0]
    self.exts = shape(self.image)[0]-1
    self.dimensions = shape(self.image[1].data[0,0])

  def diff_savesets(self):
    """
    Creates a three dimensional array with all the
    savesets already with the background already
    subtracted.
    """

    arr = reshape(zeros(self.savesets*self.exts*self.dimensions[0]*self.dimensions[1]),
                  (self.savesets*self.exts,self.dimensions[0],self.dimensions[1]))

    nod_positions = [self.image[i].header['nod'] for i in arange(self.exts)+1]

    for i in arange(self.exts):
      for j in arange(self.savesets):
        a = self.image[i+1].data[j,0,:,:]
        b = self.image[i+1].data[j,1,:,:]
        if nod_positions[i] == 'A':
          arr[i*self.savesets+j,:,:] = a - b
        if nod_positions[i] == 'B':
          arr[i*self.savesets+j,:,:] = b - a

    self.diff = arr
    
    return arr

  def findcenter(self,smooth_sigma=1.8,smoothbg_sigma=40):
    """
    Finds the pixel with the highest intensity.

    Parameters:
    -----------
    smooth_sigma : number
      Sigma for the 2D gaussian that is to convolve
      the frame before attempting to find the center.
    smoothbg_sigma : number
      Sigma for the 2D gaussian that will be used
      to remove low frequency variations across the
      detector.
    """

    try:
      arr = self.diff
    except AttributeError:
      arr = self.diff_savesets()

    nframes = len(arr)
    locs = reshape(zeros(nframes*2,dtype='int'),(nframes,2))

    for i in range(nframes):
      a = arr[i]
      b = gf(a,smooth_sigma) - gf(a,smoothbg_sigma)
      locs[i] = [j[0] for j in where(b == b.max())]

    self.centerlocs = locs

    return locs

  def rej_badframes(self,threshold=10,verbose=True):
    """
    Rejects the frames based on the distance, over the
    detector, from the brightest pixel in each frame
    relative to the average of all frames.

    Parameters:
    -----------
    threshold : number
      Maximum distance on a good frame in pixels.
    """

    try:
      locs = self.centerlocs
    except AttributeError:
      locs = self.findcenter()

    try:
      arr = self.diff
    except AttributeError:
      arr = self.diff_savesets()

    y,x = locs[:,0],locs[:,1]

    x0,y0 = median(x),median(y)
    
    if verbose:
      print '##################'
      print 'Median center of image: {:s}'.format(self.filename)
      print 'x0 = {:.1f},y0 = {:.1f}'.format(x0,y0)
      print '##################'

    h = sqrt((x-x0)**2 + (y-y0)**2)

    arr = self.diff_savesets()

#    condition = h < std(h)*threshold 
    condition = h <= threshold 

    arr = arr[condition]
    rejframes = where(~condition)[0]
    nrej = len(rejframes)

    if verbose:
      print '{:d} rejected frames.'.format(nrej)
      if nrej:
        print 'Coordinates of rejected frames:'
        for i in rejframes:
          print '{:d},{:d} on extension {:d}, saveset {:d}'.format(locs[i,1],locs[i,0],i/self.exts,i%self.exts)

    self.diff_rej = arr
    self.x0 = x0
    self.y0 = y0
    self.centerlocs_rej = locs[condition]

    return arr

  def centerframes(self,smooth_sigma=1.8,smoothbg_sigma=40,threshold=10,verbose=True,maxrej=.3):
    """
    Do it.
    """

    try:
      arr = self.diff_rej
      locs = self.centerlocs_rej
    except AttributeError:
      arr = self.rej_badframes(threshold=threshold,verbose=verbose)
      locs = self.centerlocs_rej

    carr = arr*0.0
    nframes = len(arr)
    shift = locs-column_stack([ones(nframes)*self.y0,ones(nframes)*self.x0])

    for i,a in enumerate(arr):
      f = interp2d(arange(self.dimensions[1])-shift[i,1],arange(self.dimensions[0])-shift[i,0],ravel(a,order='C'),bounds_error=False,fill_value=0.0)
      carr[i] = f(arange(self.dimensions[1]),arange(self.dimensions[0]))

    self.diff_centered = carr

    return carr

  def writesum(self,output,combine='average',threshold=10,verbose=True,clob=True,maxrej=0.3,centerstack=True):

    try:
      arr = self.diff_rej
      arr_complete = self.diff
    except AttributeError:
      arr = self.centerframes(threshold=threshold,verbose=verbose,maxrej=maxrej)

    if len(self.diff_rej) < (1.0-maxrej)*len(self.diff) or not centerstack:
      arr = self.diff
      if verbose:
        print 'WARNING! midir_stack is performing a direct stack,'
        print 'completely disregarding the centering algorithm.'

    if combine == 'average':
      comb = average(arr,axis=0)
    if combine == 'sum':
      comb = sum(arr,axis=0)
    if combine == 'median':
      comb = median(arr,axis=0)

    imagehdr = self.image[1].header
    
    copycards = ['ctype1','crpix1','crval1','ctype2','crpix2','crval2',
                 'CD1_1','CD1_2','CD2_1','CD2_2']

    descriptions = ['RA in tangent plane projection',
                    'Ref pix of axis 1',
                    'RA at Ref pix in decimal degrees',
                    'DEC in tangent plane projection',
                    'Ref pix of axis 2',
                    'DEC at Ref pix in decimal degrees',
                    'WCS matrix element 1 1',
                    'WCS matrix element 1 2',
                    'WCS matrix element 2 1',
                    'WCS matrix element 2 2',]


    imagehdr.update('ncombine',len(arr),comment='Number of combined savesets')
    imagehdr.update('rejsaves',len(self.diff) - len(arr),comment='Number of rejected savesets')
    imagehdr.update('extname','SCI',comment='Name of the FITS extension.')
    imagehdr.update('wcsaxes',2,comment='Number of WCS axes in the image')
    for n,i in enumerate(copycards):
      imagehdr.update(i,self.image[0].header[i],comment=descriptions[n])
    imagehdr.update('radecsys',0,comment='RA/DEC coordinate system reference')
     

    hl = pf.HDUList()
    hl.append(self.image[0])
    hl.append(pf.ImageHDU(comb,header=imagehdr))
    hl.writeto(output,output_verify='silentfix',clobber=clob)
