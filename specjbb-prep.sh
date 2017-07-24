#!/bin/bash

yum install -y fontconfig, libXfont, libfontenc, ttmkfdir, xorg-x11-font-utils,xorg-x11-fonts-Type1
yum install -y freetype-devel

cat <<-EOF > env.sh
#!/bin/bash

export JAVA_HOME=/root/jdk1.8.0_131
export PATH=\$PATH:\$JAVA_HOME/bin
export CLASSPATH=\$JAVA_HOME/lib
export JAVA=\$JAVA_HOME/bin/java
EOF
