########################################################################################################################
# simplehttpserver build stage
########################################################################################################################

FROM ubuntu:24.10 AS build

RUN apt-get clean && apt-get update -y && \
    apt-get --fix-broken install -y \
    build-base \
    cmake \
    libboost-dev \
    libboost-program-options-dev

WORKDIR /simplehttpserver

COPY src/ ./src/
COPY CMakeLists.txt .

WORKDIR /simplehttpserver/build

RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --parallel 8

########################################################################################################################
# simplehttpserver image
########################################################################################################################

FROM ubuntu:24.10

RUN apt-get clean && apt-get update -y && \
    apt-get --fix-broken install -y \
    libstdc++14 \
    libboost-dev \
    libboost-program-options-dev

RUN addgroup -S shs && adduser -S shs -G shs
USER shs

COPY --chown=shs:shs --from=build \
    ./simplehttpserver/build/src/simplehttpserver \
    ./app/

ENTRYPOINT [ "./app/simplehttpserver" ]