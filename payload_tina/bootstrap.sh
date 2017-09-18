#!/bin/sh
# version 2.0

yum -y install glibc.i686 unzip

WORK_DIR=`pwd`

TINA_PACKAGE_NAME=$(sed 's/TINA_PACKAGE_NAME=//' $WORK_DIR/package_metadata.txt)  
mv $WORK_DIR/$TINA_PACKAGE_NAME /opt
cd /opt
tar xzvf $TINA_PACKAGE_NAME

cd $WORK_DIR
