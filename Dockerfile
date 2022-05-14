
# docker build --force-rm=true -t "khb07334/jupyter_edu" -f ./Dockerfile .

#### docker-compose.yml #####################v
#version: "3"
#services:
#  jlab:
#    build:
#      context: .
#      dockerfile: Dockerfile
#    restart: always
#    environment:
#      TZ: Asia/Tokyo
#    tty: true
#    entrypoint: >
#      jupyter-lab
#      --allow-root
#      --ip=0.0.0.0
#      --port=8888
#      --no-browser
#      --NotebookApp.token=''
#      --notebook-dir=/workspace
#    expose:
#      - "8888"
#    ports:
#      - "8888:8888"
#    volumes:
#      - ./:/root/.jupyter
#      - ./workspace:/workspace
#    working_dir: /workspace
#########################################################
# Continuumio/anaconda JupyterNotebook 更新日　2022年4月14日 
# FROM bitnami/jupyterhub:latest  
# FROM ubuntu:20.04 
# FROM continuumio/miniconda3 
# FROM jupyter/minimal-notebook 

###############################################
##### https://www.idnet.co.jp/column/page_187.html
FROM python:3.9.7-slim-buster
ARG DEBIAN_FRONTEND=noninteractive
##### パッケージの追加とタイムゾーンの設定
##### 必要に応じてインストールするパッケージを追加してください
RUN apt-get update && apt-get install -y \
    tzdata \
&&  ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Tokyo
#################################################

# ENTRYPOINT ["bash"]  
# SHELL ["/bin/bash", "-l", "-c"]  
# ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8 LC_ALL=C.UTF-8  
ENV ORACLE_HOME=/opt/oracle  
ENV LD_RUN_PATH=$ORACLE_HOME  
ENV LD_LIBRARY_PATH=$ORACLE_HOME:$ORACLE_HOME/lib  
ENV PATH /opt/conda/bin:/opt/conda/bin::/opt/mssql-tools/bin:$PATH:$ORACLE_HOME  
ENV GRANT_SUDO=yes  

# USER root 

RUN apt-get update \
 && apt-get -y install \
	wget \
	bzip2 \
	unzip \
	curl \
	grep \
	sed \
	dpkg \
	make \
	gcc \
	g++ \
	dpkg \  
   	ca-certificates \
	git \
	mercurial \
	subversion \
	tk-dev \
	openssl \
	libffi-dev \  
	unixodbc-dev \
	unixodbc \
	gfortran \
	apt-utils 

##### Dockerコンテナのメジャーな問題である「The PID 1 Problem」を解決の為の処理  
# RUN TINI_VERSION=`curl https://github.com/krallin/tini/releases3e/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \  
#     curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini  
# RUN apt-get -y install --no-cache tini && \  
# RUN apt-get -y install --no-install-recommends  tini && \  
#     rm tini  

##### 日本語フォントの組み込み  
RUN apt-get update \  
#    && apt-get install -y --no-install-recommends fonts-takao-gothic \  
    && apt-get install -y fonts-takao-gothic \  
    && apt-get clean \  
    && rm -rf /var/lib/apt/lists/   

#RUN echo -e "\nfont.family: TakaoPGothic" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \  
#    && rm -f ~/.cache/matplotlib/font*  

##### -----Build start!! ------  
##### データベース接続ライブラリの組み込み  
##### DBドライバーインストール  
##### MSSQL DB  
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -  
# --proxy http://10432252:3ekibata04@obprx02.intra.hitachi.co.jp:8080 | apt-key add -  

##### Download appropriate package for the OS version  
##### Choose only ONE of the following, corresponding to your OS version  

##### Ubuntu20.04  
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list  

##### Debian 8  
# curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list  

##### Debian 9  
# curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list  

##### Debian 10  
# RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list  

#####
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17  
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \  
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc  

#---------- pip ---------------------------------------  

##### Pythonのパッケージ管理システムpipのインストール  

WORKDIR /workspace  

# RUN wget https://bootstrap.pypa.io/get-pip.py \  
#     && python get-pip.py pip --user \  
#     # && python get-pip.py pip --user --proxy="http://10432252:3ekibata04@obprx02.intra.hitachi.co.jp:8080" \  
#     && python -m pip install -U pip  

RUN python3 -m pip install --upgrade pip \
&&  pip install --no-cache-dir \
    black \
    jupyterlab \
    jupyterlab_code_formatter \
    jupyterlab-git \
    lckr-jupyterlab-variableinspector \
    jupyterlab_widgets \
    ipywidgets \
    import-ipynb
# 追加パッケージ（必要に応じて）各環境に特化したパッケージがある場合、この部分に追加します
RUN pip install --no-cache-dir \
    pydeps \
    graphviz \
    pandas_profiling \
    shap \
    umap \
    xgboost \
    lightgbm

##### データベース接続ライブラリの組み込み  
##### DBドライバーインストール  
##### cx_Oracle SQLAlchemy pyodbc  
RUN wget --quiet https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basiclite-linux.x64-21.1.0.0.0.zip   
#RUN wget --quiet https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip  
RUN unzip instantclient-*.zip   
RUN ls -al && cd instantclient_* && pwd  
RUN mkdir -p $ORACLE_HOME \  
    && mv instantclient_21_1 $ORACLE_HOME/lib \  
    && rm -f /instantclient-*.zip  

#RUN python3 -m pip install cx_Oracle SQLAlchemy pyodbc --user  
RUN python3 -m pip install cx_Oracle SQLAlchemy  --user  

#会社環境だと上記ではうまくいかなかいので先にDLしてから組込む  
#● COPY dbdriver/* /workspace/  

###### 描画&数値ライブラリの組み込み  (debian だとpip install がうまく動かない  
# RUN apt-get update --fix-missing && apt-get install -y graphviz \  
RUN python3 -m pip install \
	dtreeviz \
	japanize-matplotlib \
	changefinder \
	pyper \
	arch \
#	six --user

##### variableinspector インストール -----  
# RUN pip install lckr-jupyterlab-variableinspector  
	lckr-jupyterlab-variableinspector \

##### NeuralProphet インストール -----  
# NeuralProphetのインストール  
# RUN pip install neuralprophet  
	neuralprophet \

##### streamlitのインストール  
# Port8501解放要
# RUN pip install streamlit  
	streamlit  

#--------- conda -------------------------------------  
##### Anaconda インストール From pythonの場合
#RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh \  
##    && wget --quiet https://repo.continuum.io/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh  
#   && wget -c --quiet https://repo.continuum.io/archive/Anaconda3-2021.05-Linux-x86_64.sh -O ~/anaconda.sh   
#RUN /bin/bash ~/anaconda.sh -u -b -p /opt/conda \  
## RUN sh ~/anaconda.sh -b -p /opt/conda \  
#   && rm ~/anaconda.sh  
#
#RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \  
#    && echo "conda activate base" >> ~/.bashrc  
#
#--------- Miniconda ------------------------------------- 
WORKDIR /opt
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh \
 && sh /opt/Miniconda3-4.5.4-Linux-x86_64.sh -b -p /opt/miniconda3 \
 && rm -f Miniconda3-4.5.4-Linux-x86_64.sh 
ENV PATH=/opt/miniconda3/bin:$PATH
##### conda create & Update
RUN conda install conda=4.8.3=py36_0
RUN conda create -n GSC_Edu_model python==3.7
RUN conda update -c default conda

##### 仮想環境"GSC_Edu_model"にインストール開始
SHELL ["conda", "run", "-n", "GSC_Edu_model", "/bin/bash", "-c"] 

##### jupyterExtension導入の下準備  
RUN conda config --append channels conda-forge
RUN conda config --get channels

##### nodejsのインストール  
RUN conda install -c conda-forge nodejs==12.1.0
#RUN conda install -c conda-forge nodejs && node -v

##### 標準ライブラリの組み込み  
RUN conda install -c conda-forge \
	scikit-learn \
	scipy \
	pandas \
	matplotlib \
	seaborn \
	numpy \
    mlxtend \
    requests \
    beautifulsoup4 \
    Pillow \
	cython \
plotly

#RUN conda install -c conda-forge \
#    opencv-python
#    pycaret \
#    japanize_matplotlib 


##### 拡張ライブラリの組み込み(-c conda-forge)
RUN conda install -c conda-forge \
jupyter_contrib_nbextensions \
python-graphviz \
pydotplus \
ipywidgets \
&& conda clean --all -f -y  

##### PyTorchのインストール(-c conda-forge)
# RUN conda install -c conda-forge \
# pytorch \
# torchvision \
# && conda clean --all -f -y 

##### fbprophet及び依存関係のインストール  
RUN conda install -c anaconda ephem
RUN conda install -c conda-forge pystan fbprophet

#-------------------------------------------------  
##### jupyterlab拡張機能  
# SHELL ["/bin/bash", "-l", "-c"]  

# RUN jupyter serverextension enable --py jupyterlab --sys-prefix  

##### nbextensions インストール  
RUN jupyter contrib nbextension install --user \  
   && jupyter nbextensions_configurator enable --user  

##### labextensions インストール  
##### nodejsのバージョン指定有り。LTSで10以上  
##### @jupyter-widgets/jupyterlab-manager  
# RUN jupyter labextension install @lckr/jupyterlab_variableinspector 
# RUN jupyter labextension install jupyterlab-drawio  
# RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager  
# RUN jupyter labextension install jupyterlab-chart-editor  
# RUN jupyter labextension install @jupyterlab/plotly-extension  
# RUN jupyter labextension install @jupyterlab/toc  

##### jupyterlab_code_formatter  
# RUN jupyter labextension install @ryantam626/jupyterlab_code_formatter \  
#     && jupyter serverextension enable --py jupyterlab_code_formatter  

##### jupyterlab-nvdashboard  
# RUN jupyter labextension install jupyterlab-nvdashboard  


#--------------------------------------------------------

##### Jupyter Notebookの起動 ------  
#  CMDは一度しか使えないのでコマンドを複数実行させる場合は下記のように  
#  行う。今回は上手くできなかったのでコメントアウトした。  
#
#●COPY ./startup.sh /startup.sh  
#●RUN chmod 744 /startup.sh  
#●CMD ["/startup.sh"]  

##### 環境再現のためのリストを出力  
#   https://qiita.com/WestRiver/items/cce9c99076d59abd3f69  
RUN conda list --export > conda_package_list.txt  
WORKDIR /root

##### Jupyter Notebookの起動  
#CMD jupyter-lab --no-browser \ 
#    --port=8888 --ip=0.0.0.0 --allow-root \ 
#    --NotebookApp.token=''  


