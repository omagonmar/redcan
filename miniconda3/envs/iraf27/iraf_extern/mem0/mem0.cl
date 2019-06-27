#{ MEM0 -- Maximum Entropy Package, version C

print(" ")
print("	   Welcome to the Maximum Entropy Package (version C)")
print(" ")
print("                            ", version)
print(" ")

# Define the Maximum Entropy Package
cl < "mem0$lib/zzsetenv.def"
package mem0, bin = mem0bin$

# Executables
task	imconv,
	immake,
	irfftes,
	irme0,
	pfactor	= "mem0src$/x_mem0.e"

clbye()
