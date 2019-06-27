import sgmllib
import sys

class MyParser(sgmllib.SGMLParser):
	"A simple parser class."

	def parse(self, s):
		"Parse the given string 's'."
		self.feed(s)
		self.close()

	def __init__(self, verbose=0):
		"Initialise an object, passing 'verbose' to the superclass."

		sgmllib.SGMLParser.__init__(self, verbose)
		self.td = []
		self.inside_td_element = 0

	def start_td(self, attributes):
		self.inside_td_element = 1

	def end_td(self):
		"Record the end of a td."

		self.inside_a_element = 0


	def handle_data(self, data):
		"Handle the textual 'data'."

		if self.inside_td_element:
			self.td.append(data)

	def get_td(self):
		"Return a list of td."

		return self.td

	def get_td(self, index):
		"Return a list of td."
		if len(self.td) >= index+1:
			return self.td[index]
		else:
			return -999

	

import urllib, sgmllib

# Get something to work with.

# Try and process the page.
# The class should have been defined first, remember.

# Get the hyperlinks.
count = 0
for name in sys.argv:
	if (count > 0):
		myparser = MyParser()
		f = urllib.urlopen("http://nedwww.ipac.caltech.edu/cgi-bin/nDistance?name=%s" % name, proxies={})
		html = f.read()
		myparser.parse(html)
		dist = float(myparser.get_td(4))
		redshift = dist*70./2.998E5
		start_name = 'http://nedwww.ipac.caltech.edu/cgi-bin/nph-datasearch?objname='
		end_name = '&search_type=Redshifts&zv_breaker=30000.0&of=table'
		www_page = start_name+name+end_name
		myparser = MyParser()
		f = urllib.urlopen(www_page, proxies={})
		html = f.read()
		myparser.parse(html)
		try:
			redshiftt = float(myparser.get_td(7))
		except ValueError:
			redshiftt = 0.00000
		distt = redshiftt*2.998E5/70.
		if (dist < 0): 
			print '%s %.6f %.3f (Cosmological measurement, Ho=70)' % (name, redshiftt, distt)
		else:
			print '%s %.6f %.3f %6f %.3f (Redshift-independence, Ho=70)' % (name, redshift, dist, redshiftt, distt)
	count+=1
