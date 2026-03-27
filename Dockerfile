FROM ghcr.io/cirruslabs/flutter:3.41.6 AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

FROM caddy:alpine

RUN addgroup -g 1000 app \
    && adduser -u 1000 -G app -s /bin/bash -D app \
    && chown -R app:app /data /srv

USER app

COPY --from=build /app/build/web /srv

EXPOSE 8080

CMD ["caddy", "file-server", "--root", "/srv", "--listen", ":8080"]
