#!/bin/sh -l

set -e

echo "."
echo "*********************************"
echo "** Current Enviornment"
echo "*********************************"

perl -v

echo "*********************************"
echo "** Start container: $0"
echo "*********************************"

####################################
## Environment Variables          ##
####################################

WORKDIR="$(pwd)"

MAJOR=5
MINOR=12
RELEASE=5

PERL_VERSION=${MAJOR}.${MINOR}.${RELEASE}
PERL_MAJOR_VERSION=${MAJOR}${MINOR}
PERL_DIR=${MAJOR}.${MINOR}.${RELEASE}
PERL_TAG=v${PERL_DIR}

PERL_NAME=perl${MAJOR}${MINOR}

PREFIX=/usr/local/perl/${PERL_MAJOR_VERSION}
PERL_LIB_ROOT=${PREFIX}/lib/perl5

SITE_PREFIX=/opt/${PERL_NAME}/perl5/${PERL_MAJOR_VERSION}

####################################

rpm -qf /etc/redhat-release
echo -n "# Runing from: "
pwd

echo "."
echo "*********************************"
echo "** Installing cpm"
echo "*********************************"

curl -fsSL --compressed https://git.io/cpm > /usr/bin/cpm
chmod +x /usr/bin/cpm
/usr/bin/cpm --version

# echo "."
# echo "*********************************"
# echo "** Cloning Perl Git Repository"
# echo "*********************************"

# git clone https://github.com/Perl/perl5.git
# cd perl5
# git checkout $PERL_TAG

echo "."
echo "*********************************"
echo "** Downloading Perl Tarball for $PERL_TAG"
echo "*********************************"

wget https://github.com/Perl/perl5/archive/$PERL_TAG.tar.gz
tar xzf $PERL_TAG.tar.gz
cd perl5-$PERL_DIR

PERL_SOURCE_DIR=$(pwd)

echo "."
echo "*********************************"
echo "** PatchPerl"
echo "*********************************"

# using system perl for patching
perl /usr/bin/cpm install -g --no-test File::pushd Module::Pluggable Getopt::Long IO::File
perl /usr/bin/cpm install -g --no-test Devel::PatchPerl
PERL5_PATCHPERL_PATCHLEVEL=1 perl -e "use Devel::PatchPerl; Devel::PatchPerl->patch_source( '${PERL_VERSION}', '${PERL_SOURCE_DIR}' );"

echo "."
echo "*********************************"
echo "** Configure"
echo "*********************************"

rm -f config.sh Policy.sh ||:

sh Configure -des \
   -Dprefix=${PREFIX} \
   -Dsiteprefix=${SITE_PREFIX} \
   -Dsitebin=${SITE_PREFIX}/bin \
   -Dsitelib=${SITE_PREFIX}/site_lib \
   -Dusevendorprefix=true \
   -Dvendorbin=${PREFIX}/bin \
   -Dvendorprefix=${PERL_LIB_ROOT} \
   -Dvendorlib=${PERL_LIB_ROOT}/vendor_lib \
   -Dprivlib=${PERL_LIB_ROOT}/${PERL_VERSION} \
   -Dscriptdir=${PREFIX}/bin -Dscriptdirexp=${PREFIX}/bin \
   -Dcc='/usr/bin/gcc' \
   -Dcpp='/usr/bin/cpp' \
   -Dusemymalloc='n' \
   -Uinstallusrbinperl \
   -Ui_db \
   -Dman1dir=none \
   -Dman3dir=none \
   -Dsiteman1dir=none \
   -Dsiteman3dir=none \
   -Dinstallman1dir=none \
   -Dusethreads \
   -Dinstallusrbinperl=no

echo "."
echo "*********************************"
echo "** Make"
echo "*********************************"

TEST_JOBS=4 make -j4

make install

# this will be in our PATH by default
echo "create symlink"
ln -s ${PREFIX}/bin/perl${PERL_VERSION} /usr/local/bin/perl
ls -l ${PREFIX}/bin/perl${PERL_VERSION}

${PREFIX}/bin/perl${PERL_VERSION} -v

echo "."
echo "*********************************"
echo "** Check"
echo "*********************************"

find ${PREFIX}/bin

echo "PATH: $PATH"

ls -la /usr/local/bin/perl

echo -n "which perl: "; which perl

echo "---------------------"
/usr/local/bin/perl -v
echo "---------------------"

# ensure we are going to use the current symlink with our PATH
[ "$(which perl)" == "/usr/local/bin/perl" ] || exit 127;

echo "."
echo "*********************************"
echo "** Done"
echo "*********************************"
echo ""
