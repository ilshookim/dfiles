FROM google/dart
# RUN apt -y update && apt -y upgrade
WORKDIR /app
COPY pubspec.* /app/
RUN dart pub get
COPY . /app
RUN dart pub get --offline
RUN dart compile exe /app/bin/server.dart -o /app/bin/server

FROM subfuzion/dart-scratch
COPY --from=0 /app/pubspec.yaml /app/pubspec.yaml
COPY --from=0 /app/bin/dart.png /app/bin/dart.png
COPY --from=0 /app/bin/favicon.ico /app/bin/favicon.ico
COPY --from=0 /app/bin/index.html /app/bin/index.html
COPY --from=0 /app/bin/server /app/bin/server
EXPOSE 8088
ENTRYPOINT ["/app/bin/server"]
