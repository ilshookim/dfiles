# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* /app/
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . /app

# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe /app/src/server.dart -o /app/bin/dfiles

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/pubspec.yaml /app/pubspec.yaml
COPY --from=build /app/bin/dfiles /app/dfiles
COPY --from=build /app/bin/dart.png /app/dart.png
COPY --from=build /app/bin/index.html /app/index.html
COPY --from=build /app/bin/favicon.ico /app/favicon.ico
COPY --from=build /app/bin/monitor/monitor.md /app/monitor/monitor.md

WORKDIR /app
EXPOSE 8088
ENTRYPOINT ["/app/dfiles"]
