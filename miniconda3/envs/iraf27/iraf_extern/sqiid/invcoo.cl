## GETCOO extract objects from frmae buffer and IMCNTR

procedure invcoo (coordlist,xshift,yshift,xinvert,yinvert)
   string coordlist  {prompt="List of files with X Y star coord"}
   real   xshift     {prompt="X shift"}
   real   yshift     {prompt="Y shift"}
   bool   xinvert    {prompt="Invert X cooordinates?"}
   bool   yinvert    {prompt="Invert X cooordinates?"}
   int    ncols      {prompt="# of columns (X dimension)"}
   int    nrows      {prompt="# of rows    (Y dimension)"}

   struct  *inlist

   begin

      int    stat
      real   xs,ys,xin, yin, xout, yout
      string coord
      struct line = ""
      bool   xinv,yinv

      coord   = coordlist
      xs      = xshift
      ys      = yshift
      xinv    = xinvert
      yinv    = yinvert

      inlist = coord
      while (fscan(inlist, line) != EOF) {
         if (stridx("#",line) != 1) {
            stat = fscan(line, xin, yin)
            if (xinv)
               xout = ncols - (xin + xs)
            else
               xout = xin + xs
            if (yinv)
               yout = ncols - (yin + ys)
            else
               yout = yin + ys
            print (xout,yout)
        
         } else
            print (line)
      }

      inlist = ""

   end
