FROM jupyter/r-notebook

MAINTAINER Jupyter Project <jupyter@googlegroups.com>

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

# R packages
#RUN conda config --add channels r && \
#    conda install --quiet --yes \
#    'r-base=3.3.1*' \
#    'r-irkernel=0.7*' \
#    'r-plyr=1.8*' \
#    'r-devtools=1.11*' \
#    'r-dplyr=0.4*' \
#    'r-ggplot2=2.1*' \
#    'r-tidyr=0.5*' \
#    'r-shiny=0.13*' \
#    'r-rmarkdown=0.9*' \
#    'r-forecast=7.1*' \
#    'r-stringr=1.0*' \
#    'r-rsqlite=1.0*' \
#    'r-reshape2=1.4*' \
#    'r-nycflights13=0.2*' \
#    'r-caret=6.0*' \
#    'r-rcurl=1.95*' \
#    'r-crayon=1.3*' \
#    'r-randomforest=4.6*' && conda clean -tipsy

RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite(c('limma','GSA','Biobase','edgeR','locfit','RCy3'))"
RUN Rscript -e "install.packages(c('pheatmap','RColorBrewer','gProfileR','RJSONIO','httr','ggplot2'))"

#update the irkernel to fix issue with pdf output - need to have
# at least 0.9 and latex issue is fixed
#
# reverted back to IRkernel 0.5 because plotting was not working 
# in IRkernel 0.6
#RUN Rscript -e "devtools::install_github('IRkernel/repr')"


#RUN curl https://bioconductor.org/packages/release/bioc/src/contrib/RCy3_1.2.0.tar.gz -s -o /home/jovyan/RCy3_1.2.0.tar.gz
#RUN Rscript -e "install.packages("RCy3_1.2.0.tar.gz", repos=NULL)
#RUN R CMD INSTALL /home/jovyan/RCy3_1.2.0.tar.gz


USER root

RUN apt-get update
RUN apt-get install -y python python-dev python-distribute python-pip
RUN apt-get -y install libreadline-dev
RUN pip install networkx bokeh requests py2cytoscape biopython rpy2


# Accept Oracle JDK license 
#RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" |  debconf-set-selections 

#ENV DEBIAN_FRONTEND noninteractive
#RUN apt-get install -y software-properties-common

#RUN \
#    echo "===> add webupd8 repository..."  && \
#    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
#    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
#    apt-get update


#RUN echo "===> install Java"  && \
#    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
#    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
#    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default


#RUN echo "===> clean up..."  && \
#    rm -rf /var/cache/oracle-jdk8-installer  && \
#    apt-get clean  && \
#    rm -rf /var/lib/apt/lists/*

#ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

#install missing library that gives error when launching cytoscape
#RUN apt-get update
#RUN apt-get install libxtst6

USER jovyan

#get the numpy library
RUN conda install --yes psutil

RUN cd /home/$NB_USER && \
	git clone https://github.com/ipython-contrib/IPython-notebook-extensions.git #&& \
	#mkdir /home/$NB_USER/.local/share && \
	#mkdir /home/$NB_USER/.local/share/jupyter 

#install it
RUN cd ~/IPython-notebook-extensions && \
	python setup.py install


