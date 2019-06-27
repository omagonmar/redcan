#!/usr/bin/env python

from numpy import *
from scipy.interpolate import interp2d
from scipy.ndimage import gaussian_filter as gf
import pyfits as pf
from scipy.ndimage import interpolation as interp

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
#      f = interp2d(arange(self.dimensions[1])-shift[i,1],arange(self.dimensions[0])-shift[i,0],ravel(a,order='F'),bounds_error=False,fill_value=0.0)
#      f = interp2d(arange(self.dimensions[1])-shift[i,1],arange(self.dimensions[0])-shift[i,0],reshape(a,(1,self.dimensions[0]*self.dimensions[1]),order='F'),bounds_error=False,fill_value=0.0)
      carr[i] = interp.shift(a, [-1.*shift[i,0], -1.*shift[i,1]])
#      carr[i] = f(arange(self.dimensions[1]),arange(self.dimensions[0]))
#      carr[i] = roll(roll(a,shift[i,1],axis=0),shift[i,0],axis=1)

    self.diff_centered = carr

    return carr

  def writesum(self,output,combine='average',threshold=10,verbose=True,clob=True,maxrej=0.3,centerstack=True):

    try:
      arr = self.diff_centered
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
