FROM ubuntu:14.04
RUN apt-get update && apt-get install -y \
	autoconf \
	automake \
	make \
	g++ \
	gcc \
	build-essential \ 
	zlib1g-dev \
	libgsl0-dev \
	perl \
	curl \
	git \
	wget \
	unzip \
	tabix \
	libncurses5-dev \
	libpng-dev \
	perl-base \
	cpanminus \
	libmysqlclient-dev
#RUN apt-get install -y cpanminus
#RUN apt-get install -y libmysqlclient-dev
RUN cpanm CPAN::Meta \
	Archive::Zip \
	DBI \
	DBD::mysql \ 
	JSON \
	DBD::SQLite \
	Set::IntervalTree \
	LWP \
	LWP::Simple \
	Archive::Extract \
	Archive::Tar \
	Archive::Zip \
	CGI \
	Time::HiRes \
	Encode \
	File::Copy::Recursive \
	Perl::OSType \
	Module::Metadata version \
	Bio::Root::Version \
	TAP::Harness \
	Module::Build

WORKDIR /opt
ENV MAKEFLAGS="-j 7"
RUN wget https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2 && tar jxf samtools-1.3.tar.bz2 && cd /opt/samtools-1.3 && make && make install && cd .. && rm samtools-1.3.tar.bz2

RUN wget https://github.com/Ensembl/ensembl-tools/archive/release/86.zip
RUN mkdir variant_effect_predictor_86
RUN mkdir variant_effect_predictor_86/cache
RUN unzip 86.zip -d variant_effect_predictor_86 && rm 86.zip
#RUN rm 85.zip 
WORKDIR /opt/variant_effect_predictor_86/ensembl-tools-release-86/scripts/variant_effect_predictor/
RUN perl INSTALL.pl --AUTO ap --PLUGINS LoF --CACHEDIR /opt/variant_effect_predictor_86/cache
WORKDIR /opt/variant_effect_predictor_86/cache/Plugins
RUN wget https://raw.githubusercontent.com/konradjk/loftee/v0.3-beta/splice_module.pl

WORKDIR /opt
ADD . /opt/vcf2maf 

COPY Dockerfile /opt/

MAINTAINER Michele Mattioni, Seven Bridges, <michele.mattioni@sbgenomics.com>
# Set up vep
# Based on https://hub.docker.com/r/ensemblorg/ensembl-vep/dockerfile and
# https://gist.github.com/ckandoth/f265ea7c59a880e28b1e533a6e935697

ENV VEP_PATH=/opt/variant_effect_predictor_86/ensembl-tools-release-86/scripts/variant_effect_predictor
ENV VEP_DATA=/root/.vep


ENV PERL5LIB=$VEP_PATH:${PERL5LIB}
ENV PATH=$VEP_PATH/htslib:${PATH}


WORKDIR /opt/variant_effect_predictor_86/ensembl-tools-release-86/scripts/variant_effect_predictor/
WORKDIR /opt/vcf2maf

