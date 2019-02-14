FROM microsoft/dotnet:2.2.103-sdk

ENV SONAR_SCANNER_MSBUILD_VERSION 4.5.0.1761
# reviewing this choice
ENV DOCKER_VERSION 18.06.1~ce~3-0~debian
# Install Java 8
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y openjdk-8-jre

# Install docker binaries
RUN apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && apt-key fingerprint 0EBFCD88 \
    && add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
        $(lsb_release -cs) \
        stable" \
    && apt-get update \
    && apt-get install -y docker-ce=$DOCKER_VERSION

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && apt-get install -y nodejs autoconf libtool nasm

# Install Sonar Scanner
RUN apt-get install -y unzip \
    && wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp2.0.zip \
    && unzip sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp2.0.zip -d /sonar-scanner \
    && rm sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp2.0.zip \
    && chmod +x -R /sonar-scanner

# Cleanup
RUN apt-get -q autoremove \
    && apt-get -q clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*.bin

RUN rm -rf /sonar-scanner/SonarQube.Analysis.xml
RUN echo "<?xml version="1.0" encoding=\"utf-8\" ?>" >> /sonar-scanner/SonarQube.Analysis.xml
RUN echo "<SonarQubeAnalysisProperties  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"http://www.sonarsource.com/msbuild/integration/2015/1\">">> /sonar-scanner/SonarQube.A
nalysis.xml
RUN echo "<Property Name=\"sonar.host.url\">https://i.ci.build.ge.com/8glfai4m/sq</Property>">>/sonar-scanner/SonarQube.Analysis.xml
RUN echo "<Property Name=\"sonar.login\">0ab4f6fa8704778dcdf1f54837caef3d7686a4fe</Property>">>/sonar-scanner/SonarQube.Analysis.xml
