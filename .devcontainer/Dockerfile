FROM mcr.microsoft.com/devcontainers/base:ubuntu
# Install Flutter dependencies
RUN sudo apt-get update && sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
# Install Flutter
USER vscode
RUN git clone https://github.com/flutter/flutter.git -b stable /home/vscode/flutter
ENV PATH="/home/vscode/flutter/bin:${PATH}"
