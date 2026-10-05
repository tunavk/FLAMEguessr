# Serves the game's static files with a small web server.
# Build:  docker build -t flameguessr .
# Run:    docker run -d -p 8080:80 --name flameguessr flameguessr
# Open:   http://localhost:8080  (admin panel at /admin.html)

FROM nginx:alpine
COPY index.html admin.html config.js /usr/share/nginx/html/
EXPOSE 80
