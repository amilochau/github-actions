# Inspired from: https://github.com/aws/aws-sam-build-images/blob/develop/build-image-src/Dockerfile-dotnet7
# .NET installation instructions: https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#scripted-install

FROM public.ecr.aws/lambda/provided:al2-x86_64

# Install dependencies

RUN yum groupinstall -y development && \
  yum install -d1 -y \
  yum \
  tar

# Set up .NET root

ENV DOTNET_ROOT=/var/lang/bin \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1

RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x ./dotnet-install.sh && \
    ./dotnet-install.sh -c 7.0 -i "${DOTNET_ROOT}"

RUN curl -L https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x ./dotnet-install.sh && \
    ./dotnet-install.sh -c 8.0 -i "${DOTNET_ROOT}"

ENV PATH=~/.dotnet/tools:$PATH \
    DOTNET_CLI_HOME=/tmp/dotnet \
    XDG_DATA_HOME=/tmp/xdg

ENTRYPOINT []
CMD ["/bin/bash"]
