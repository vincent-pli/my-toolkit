#!/bin/sh
curr_dir=`pwd`
# set up env and complier for lsfbeat
dirname=$(cd "$(dirname "$0")"; pwd)
cd $dirname

target_spec=$1
tmp_spec=tmp_$1
intend_spec=intend_$1
target_rpm=$2

echo "Uncompress target rpm package"
UNCOMPRESSDIR=`pwd`/rpmSource
mkdir -p ${UNCOMPRESSDIR}
cd ${UNCOMPRESSDIR}
rpm2cpio ../${target_rpm} | cpio -div
cd ..

echo "Invoke provided script"

echo "Enhance the spec for repack"
keywords="%description %prep %build %install %clean %files %pre %post %preun %postun %changelog"
focuskeywords="%prep %build %install"
iswrite=y
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [ -z "${line}" ]; then
        :
    elif [[ ${line} == "%"* && ${keywords} == *"${line}"* && ${iswrite} == n ]]; then
        iswrite=y
	echo ${line} >> ${tmp_spec}
        continue
    elif [[ ${line} == "%"* && ${focuskeywords} == *"${line}"* ]]; then
        iswrite=n
        echo ${line} >> ${tmp_spec}
        continue
    fi
    if [ ${iswrite} == y ]; then
        echo ${line} >> ${tmp_spec}
    fi
    
done < ${target_spec}

awk '/%install/ { print; print "cp -rf %{_repacksourcedir}/* ${RPM_BUILD_ROOT}/"; next }1' ${tmp_spec} > ${intend_spec}
rm -rf ${tmp_spec}


echo "Begin to pack rpm"
RELEASE_BUILD=`date '+%y%m%d'`
rm -rf BUILD BUILDROOT RPMS SPECS SRPMS
mkdir -p BUILD BUILDROOT RPMS SPECS SRPMS
mkdir -p buildroot
#cp -rf $(BUILDTMP)/* buildroot/
rpmbuilddir="./RPMS/"
rm -f .rpmmacros;\
echo "%_topdir  `pwd`" > .rpmmacros;\
echo "%_builddir  %{_topdir}" >> .rpmmacros
HOME=`pwd`;rpmbuild -bb --define "_buildno ${RELEASE_BUILD}"  --define "_repacksourcedir ${UNCOMPRESSDIR}" --buildroot "`pwd`/buildroot" ${intend_spec}
#make build-lsfbeat

echo "Clean..."
rm -rf ${UNCOMPRESSDIR}
rm -rf ${intend_spec}