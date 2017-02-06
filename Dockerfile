FROM oraclelinux:7
MAINTAINER Andrew Pryde <andrew@rocketpod.co.uk>

# Pass in --build-arg http_proxy=$http_proxy
ARG http_proxy=""
ENV http_proxy=${http_proxy}
ENV HTTP_PROXY=${http_proxy}

RUN yum-config-manager --enable ol7_optional_latest && \
	yum clean metadata && \
	yum -y update && \
	yum -y install ruby ruby-devel rubygems libffi libffi-devel gnupg2 @"Development Tools" rsync golang

RUN gem install fpm

ADD . /build
WORKDIR /build
