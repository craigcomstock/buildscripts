yum -q -y install epel-release
yum -q -y update
yum -q -y install '@Development tools' pkgconfig pam-devel
# TODO no-deps build: yum -q -y install lmdb-devel pcre-devel openssl-devel libyaml-devel libxml2-devel
# TODO pull these bits from core/INSTALL! :O
yum -q -y install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-1.noarch.rpm || true
yum -q -y install 'perl(ExtUtils::MakeMaker)' 'perl(Digest::MD5)' 'perl(Module::Load::Conditional)' 'perl(IO::Uncompress::Gunzip)' 'perl(JSON::PP)' ncurses-devel rpm-build
yum -q -y install psmisc # for fuser command
yum -q -y install wget
