from ghc-8.0:base

user root
run rm -fr /home/$builduser/.abuild/*.rsa*

copy alpine-keys.tar /home/$builduser/.abuild/alpine-keys.tar
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
user $builduser
workdir /tmp
run cd /home/$builduser/.abuild && tar xvf alpine-keys.tar
copy apk.sign /home/$builduser/packages
user root
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
user $builduser
run apk index -o /home/$builduser/packages/x86_64/APKINDEX.unsigned.tar.gz `find /home/$builduser/packages/x86_64 -name '*.apk'` || /bin/true
run apk index -o /home/$builduser/packages/armhf/APKINDEX.unsigned.tar.gz `find /home/$builduser/packages/armhf -name '*.apk'` || /bin/true
user root
run rm /home/$builduser/packages/x86_64/APKINDEX.tar.gz || /bin/true
run cp /home/$builduser/packages/x86_64/APKINDEX.unsigned.tar.gz /home/$builduser/packages/x86_64/APKINDEX.tar.gz
run rm /home/$builduser/packages/armhf/APKINDEX.tar.gz || /bin/true
run cp /home/$builduser/packages/armhf/APKINDEX.unsigned.tar.gz /home/$builduser/packages/armhf/APKINDEX.tar.gz
run find /home/$builduser \! -user $builduser -exec chown -R $builduser:$builduser {} \;
run abuild-sign -k /home/$builduser/.abuild/*.rsa /home/$builduser/packages/x86_64/APKINDEX.tar.gz
run abuild-sign -k /home/$builduser/.abuild/*.rsa /home/$builduser/packages/armhf/APKINDEX.tar.gz
run cp /home/$builduser/.abuild/*.pub /etc/apk/keys && chmod o+r /etc/apk/keys/*.pub
