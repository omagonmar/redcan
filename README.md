# redcan
0. Enable i386 compatibility.
	In debian-based system (Ubuntu, Linux Mint, etc...)
		sudo dpkg --add-architecture i386
		sudo apt-get update
		sudo apt-get install libc6:i386 libz1:i386 libncurses5:i386 libbz2-1.0:i386 libuuid1:i386 libxcb1:i386 libxmu6:i386
1. Install Gemini IRAF package. (https://www.gemini.edu/node/11823).
2. Execute
	./configure.sh
3. Activate geminiconda and generate login.cl:
	conda activate geminiconda
	cd ~
	mkiraf
		(choose xgterm)
4. To use redcan:
	conda activate geminiconda
	redcan -d <inputfile.lst>

