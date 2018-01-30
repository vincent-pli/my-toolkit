#!/bin/sh
if [ $# != 2 ]; then
    echo "Need input tow parameters: 1: name of .spec 2: name of rpm package"	
    exit 1
fi

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

result=`grep "%install" ${tmp_spec}`
if [ -z ${result} ]; then
    echo -e '%install\ncp -rf %{_repacksourcedir}/* ${RPM_BUILD_ROOT}/\nexit 0' >> ${tmp_spec}
    cat ${tmp_spec} > ${intend_spec}
else
    awk '/%install/ { print; print "cp -rf %{_repacksourcedir}/* ${RPM_BUILD_ROOT}/\nexit 0"; next }1' ${tmp_spec} > ${intend_spec}
fi
rm -rf ${tmp_spec}

echo "Begin to pack rpm"
RELEASE_BUILD=`date '+%y%m%d'`
rm -rf BUILD BUILDROOT RPMS SPECS SRPMS
mkdir -p BUILD BUILDROOT RPMS SPECS SRPMS
mkdir -p buildroot
#cp -rf $(UNCOMPRESSDIR)/* buildroot/
rpmbuilddir="./RPMS/"
rm -f .rpmmacros;\
echo "%_topdir  `pwd`" > .rpmmacros;\
echo "%_builddir  %{_topdir}" >> .rpmmacros
HOME=`pwd`;rpmbuild -bb -v --define "_buildno ${RELEASE_BUILD}"  --define "_repacksourcedir ${UNCOMPRESSDIR}" --buildroot "`pwd`/buildroot" ${intend_spec}
#make build-lsfbeat

echo "Clean..."
rm -rf ${UNCOMPRESSDIR}
rm -rf ${intend_spec}
