import os
files = os.listdir('testing/tests/rgb_asm/')
for file in files:
	print(file)
	filename = file[0 : len(file) - 2] # cut off .s
	if os.path.exists("testing/tests/rbg_hex/"+filename+".h"):
  		os.remove("testing/tests/rbg_hex/"+filename+".h")
	os.system('./bin/class -i testing/tests/rgb_asm/'+filename+'.s -o testing/tests/rgb_hex/'+filename+'.h -s hex')


