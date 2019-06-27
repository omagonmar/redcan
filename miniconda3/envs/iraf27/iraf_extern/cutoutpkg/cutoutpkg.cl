#{ Package script task for the cutout package, added for Ureka.

print ("Parent package for cutout tasks, added in Ureka mainly to provide IRAF help")
print ("")

# cl < "cutoutpkg$lib/zzsetenv.def"

package cutoutpkg, bin = cutoutpkg$

task  cutout,
      ndwfsget 	= "cutoutpkg$x_cutout.e"

clbye()

