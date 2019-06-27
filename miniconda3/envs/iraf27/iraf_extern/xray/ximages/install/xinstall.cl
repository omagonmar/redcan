# xinstall.cl
#
# do any xray specific instalation procedures


procedure	xinstall()


	struct	*list	{mode="h"}
begin

	# Spectral caliberation datarep parameters
	#
	##

	file	speclist = "xray$xray/install/spectral.list"
	file	specdata = "/pool14/john/data/"
	file	specieee = "xray$spectral/ieee/"
	file	spectmpl = "xray$spectral/ieee/"

	string	fname	= ""
	string	in	= ""
	string	out	= ""
	string	template= ""



	print "------- Datarep spectral caliberation files ----------------"

	list = speclist
	while ( fscan(list, fname, template) != EOF ) {
		in	= specieee + fname
		out	= specdata + fname
		template= spectmpl + template

		print(in, " --> ", out)
		datarep(in, out, template, "ieee", oformat="host")
	}
	print ""
end


	