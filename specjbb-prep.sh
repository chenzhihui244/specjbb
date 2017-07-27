#!/bin/bash

yum install -y fontconfig, libXfont, libfontenc, ttmkfdir, xorg-x11-font-utils,xorg-x11-fonts-Type1
yum install -y freetype-devel
yum install -y numactl

cp run_multi_4groupok.sh ..
cp run_multi_1groupok.sh ..
cp specjbb-test.sh ..

cat <<-EOF > ../env.sh
#!/bin/bash

export JAVA_HOME=/root/jdk1.8.0_131
export PATH=\$JAVA_HOME/bin:\$PATH
export CLASSPATH=.:\${JAVA_HOME}/lib/dt.jar:\${JAVA_HOME}/lib/tools.jar:\$JAVA_HOME/lib
EOF
