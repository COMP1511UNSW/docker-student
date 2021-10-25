
# bitnami provides compact docker images of debian releases

FROM bitnami/minideb:bullseye
ENV DEBIAN_FRONTEND noninteractive


# set language variable to appropriate values for Australia

ENV LANG en_AU.UTF-8
ENV LANGUAGE en_AU:en
ENV LC_ALL en_AU.UTF-8


# config our timezone for Sydney 
# and install ca-certificates so curl will work

RUN \
	rm  /etc/localtime &&\
	cp /usr/share/zoneinfo/Australia/Sydney  /etc/localtime &&\
	echo Australia/Sydney >/etc/timezone &&\
	apt-get remove --purge  -y tzdata &&\
	install_packages locales ca-certificates  &&\
    localedef -i en_AU -c -f UTF-8 -A /usr/share/locale/locale.alias en_AU.UTF-8


# install packages needed by dcc & autotest
# plus some miscellaneous utilities

RUN \
    install_packages \
		clang \
		clang-tidy \
		clang-format \
		curl \
		gcc \
		gdb \
		gedit \
		python3 \
		python3-clang \
		python3-termcolor \
		valgrind \
		nano \
		rsync \
        ssh \
        unzip \
        vim \
        wget \
        xz-utils \
        zip


# install latest version of dcc
   
RUN \
	latest_dcc_version=$(curl --silent "https://api.github.com/repos/COMP1511UNSW/dcc/releases/latest"|grep tag_name|cut -d'"' -f4) &&\
	curl -L --silent "https://github.com/COMP1511UNSW/dcc/releases/download/$latest_dcc_version/dcc" -o /usr/local/bin/dcc &&\
	chmod 755 /usr/local/bin/dcc


# install latest version of autotest

RUN \
	mkdir -p -m 755 /usr/local/lib/ &&\
	cd /usr/local/lib/ &&\
	curl -L --silent https://github.com/COMP1511UNSW/autotest/archive/refs/heads/main.zip -o autotest.zip &&\
	unzip autotest.zip &&\
	rm autotest.zip && \
	mv autotest-main autotest && \
	chmod -R o+rX autotest


# install latest version of c_check

RUN \
	mkdir -p -m 755 /usr/local/lib/ &&\
	cd /usr/local/lib/ &&\
	curl -L --silent https://github.com/COMP1511UNSW/c_check/archive/refs/heads/main.zip -o c_check.zip &&\
	unzip c_check.zip &&\
	rm c_check.zip && \
	mv c_check-main c_check && \
	chmod -R o+rX c_check

# 
ADD c_check /usr/local/bin/c_check 

# install datafiles for autotest & wrapper shell scripts
	
RUN \
	course=cs1511 &&\
	term=21T2 &&\
	cd /usr/local/lib &&\
 
    curl -L  --silent https://cgi.cse.unsw.edu.au/~${course}/$term/cgi/download_autotests.cgi | \
    	tar -Jxf - activities &&\
    mv activities 1511_activities &&\

    echo $'#!/bin/sh\n\
exec "$@"' >/usr/local/bin/1511 &&\
 
    chmod 755 /usr/local/bin/1511 &&\

    echo $'#!/bin/sh\n\
exec /usr/local/lib/autotest/autotest.py --exercise_directory /usr/local/lib/1511_activities "$@"' >>/usr/local/bin/autotest &&\

    chmod 755 /usr/local/bin/autotest

	

ADD entrypoint /entrypoint

ENTRYPOINT ["/entrypoint"]
