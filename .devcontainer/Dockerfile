# Official Flutter devcontainer image (includes Android SDK & web toolchain)
FROM mcr.microsoft.com/devcontainers/flutter:latest


# Pre-accept Android licenses to make builds smoother
RUN yes | sdkmanager --licenses


# Enable Chrome for Flutter web runs inside Codespaces
RUN sudo apt-get update \
&& sudo apt-get install -y chromium-browser \
&& sudo rm -rf /var/lib/apt/lists/*


ENV CHROME_EXECUTABLE=chromium-browser