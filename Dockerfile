FROM google/dart
# RUN apt -y update && apt -y upgrade
WORKDIR /app
COPY pubspec.* /app/
RUN dart pub get
COPY . /app
RUN dart pub get --offline
RUN dart compile exe /app/dcache/server.dart -o /app/bin/dcache

FROM subfuzion/dart-scratch
COPY --from=0 /app/pubspec.yaml /app/pubspec.yaml
COPY --from=0 /app/bin/dcache /app/dcache
COPY --from=0 /app/bin/dart.png /app/dart.png
COPY --from=0 /app/bin/index.html /app/index.html
COPY --from=0 /app/bin/favicon.ico /app/favicon.ico
COPY --from=0 /app/bin/monitor/monitor.md /app/monitor/monitor.md
WORKDIR /app
EXPOSE 8088
ENTRYPOINT ["/app/dcache"]
