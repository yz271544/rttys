FROM node:12 AS ui
WORKDIR /rttys-ui
COPY ui .
RUN npm install && npm run build

FROM golang:latest AS rttys
WORKDIR /rttys-build
COPY . .
COPY --from=ui /rttys-ui/dist ui/dist
ENV GOPROXY=https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,https://yz271544:UbFWoA20KLRShpM@goproxy.io,direct
RUN CGO_ENABLED=0 \
    VersionPath="rttys/version" \
    GitCommit=$(git log --pretty=format:"%h" -1) \
    BuildTime=$(date +%FT%T%z) \
    go build -ldflags="-s -w -X $VersionPath.gitCommit=$GitCommit -X $VersionPath.buildTime=$BuildTime" -o rabbits

FROM alpine:latest
COPY --from=rttys /rttys-build/rabbits /usr/bin/rabbits
ENTRYPOINT ["/usr/bin/rabbits"]
