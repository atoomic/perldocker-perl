FROM centos:7

#ADD . /build-perl/
#ADD patches /build-perl/patches

COPY build-perl.sh /build-perl/build-perl.sh
COPY entrypoint.sh /build-perl/entrypoint.sh

COPY cpanfile /build-perl/cpanfile

WORKDIR /build-perl

RUN yum clean all

RUN yum install -y \
	expat \
	expat-devel \
	gcc \
	git \
	less \
	libidn \
	libidn-devel \
	make \
	openssl \
	openssl-devel \
	patch \
	which \
	wget \
	perl-Data-Dumper \
	perl-Digest-MD5 \
	perl-ExtUtils-Install

VOLUME [ "/build-perl" ]

RUN /build-perl/build-perl.sh

ENTRYPOINT ["/build-perl/entrypoint.sh"]
