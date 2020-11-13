FROM google/dart
# RUN apt -y update && apt -y upgrade
WORKDIR /app
COPY pubspec.* /app/
RUN dart pub get
COPY . /app
RUN dart pub get --offline
RUN dart compile exe /app/bin/server.dart -o /app/bin/server

FROM subfuzion/dart-scratch
COPY --from=0 /app/pubspec.* /app/
COPY --from=0 /app/bin /app/bin
EXPOSE 8088
ENTRYPOINT ["/app/bin/server"]
