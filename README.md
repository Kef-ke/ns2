# ns2 2.35 - Ubuntu 18.04

Download at ns2.35 at https://www.isi.edu/nsnam/ns/ns-build.html
Download Ubuntu - bootable USB stick https://ubuntu.com/tutorials/try-ubuntu-before-you-install#1-getting-started

Ubuntu Wifi connection error (repeated authetication): https://askubuntu.com/questions/469575/repeated-authentication-required-for-wifi
Solution: Changing the router's configuration: Changed the mode to Wireless-G and security mode to WPA2 Personal. (no 20/40M)

Terminal: (ref: https://www.youtube.com/watch?v=FXm8i1K-6jI&list=LLaC_vBRGddepb0SiPzHSLkQ&index=8&t=0s)
$] tar zxvf ns-allinone-2.35.tar.gz 

if you have installed ubuntu just now, you can try these commands also in the beginning
$ sudo apt update
$ sudo apt install build-essential autoconf automake libxmu-dev 

Try
$] sudo apt install gcc-4.8 g++-4.8 
if display error: "E: Unable to locate package", check: https://itsfoss.com/unable-to-locate-package-error-ubuntu/
e.g.,
$] sudo add-apt-repository universe
$] sudo apt update

change CPP to g++-4.8 and C to gcc-4.8 in all relavant files
$ cd ns-allinone-2.35/ns-2.35
$ gedit Makefile.in 
$ gedit linkstate/ls.h

$ cd ..
$ ./install 

export PATH=$PATH:/home/pradeepkumar/ns-allinone-2.35/bin:/home/pradeepkumar/ns-allinone-2.35/tcl8.5.10/unix:/home/pradeepkumar/ns-allinone-2.35/tk8.5.10/unix
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/pradeepkumar/ns-allinone-2.35/otcl-1.14:/home/pradeepkumar/ns-allinone-2.35/lib
