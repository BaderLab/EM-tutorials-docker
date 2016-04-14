FROM jupyter/r-notebook

RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite(c('limma','GSA','Biobase','edgeR','locfit'))"
RUN Rscript -e "install.packages(c('pheatmap','RColorBrewer','gProfileR','RJSONIO','httr'))"

USER root

RUN apt-get update
RUN apt-get install -y python python-dev python-distribute python-pip
#RUN pip install networkx bokeh requests py2cytoscape biopython


# Accept Oracle JDK license 
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" |  debconf-set-selections 

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y software-properties-common

RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update


RUN echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default


RUN echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

#install missing library that gives error when launching cytoscape
RUN apt-get update
RUN apt-get install libxtst6

# Cytoscape Retrieval
#WORKDIR /root 
#ADD http://chianti.ucsd.edu/cytoscape-3.3.0/cytoscape-3.3.0.tar.gz /root/cytoscape-3.3.0.tar.gz
#ADD PACKAGE/enrichmentmap-2.1.0.jar /root/CytoscapeConfiguration/3/apps/installed/enrichmentmap-2.1.0.jar

#RUN tar -zxvf cytoscape-3.3.0.tar.gz 
#RUN rm /root/cytoscape-3.3.0.tar.gz

USER jovyan

#get the numpy library
RUN conda install --yes psutil

RUN cd /home/$NB_USER && \
	git clone https://github.com/ipython-contrib/IPython-notebook-extensions.git && \
	mkdir /home/$NB_USER/.local/share && \
	mkdir /home/$NB_USER/.local/share/jupyter 

#install it
RUN cd ~/IPython-notebook-extensions && \
	python setup.py install


#USER root
#RUN echo '/root/cytoscape-unix-3.3.0/cytoscape.sh - R 1234' > /root/start.sh

# Run Script on entrance
#CMD sh /root/start.sh
