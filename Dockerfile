FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install less \
    && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
ADD install.sh install.sh
RUN sh ./install.sh && rm install.sh
RUN useradd -ms /bin/bash octave
ADD *.m /home/octave/
RUN chown -R octave:octave /home/octave/
RUN cd /home/octave \ 
    && wget -O control-3.2.0.tar.gz https://octave.sourceforge.io/download.php?package=control-3.2.0.tar.gz \
    && wget -O statistics-1.4.1.tar.gz https://octave.sourceforge.io/download.php?package=statistics-1.4.1.tar.gz \
    && wget -O io-2.4.12.tar.gz https://octave.sourceforge.io/download.php?package=io-2.4.12.tar.gz \
    && wget -O signal-1.4.1.tar.gz https://octave.sourceforge.io/download.php?package=signal-1.4.1.tar.gz \
    && wget -O mapping-1.2.1.tar.gz https://octave.sourceforge.io/download.php?package=mapping-1.2.1.tar.gz \
    && chmod 755 package_install.m \
    && ./package_install.m


USER octave
WORKDIR /home/octave

VOLUME ["/source"]
# ENTRYPOINT ["octave"] # When this is uncommented the container runs ocatave when accesing to it   