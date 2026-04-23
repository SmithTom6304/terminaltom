# Stage 1 — build
FROM hugomods/hugo:latest AS builder
WORKDIR /site
COPY . .
RUN hugo --minify

# Stage 2 — serve
FROM nginx:alpine
COPY --from=builder /site/public /usr/share/nginx/html
COPY build/nginx-container.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
