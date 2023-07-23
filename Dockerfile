FROM jenkins/jenkins:lts

USER root

# install curl
RUN apt update && \
    apt install -y \
    curl

# install helm 
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" \
    > /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt update && \
    apt install -y helm

# install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

USER jenkins
