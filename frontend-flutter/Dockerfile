# Flutter Web development with hot reload
FROM ghcr.io/cirruslabs/flutter:latest

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY lib ./lib
COPY web ./web
COPY analysis_options.yaml ./

# Expose port for web dev server
EXPOSE 5000

# Enable web
RUN flutter config --enable-web

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5000 || exit 1

# Run Flutter web with hot reload
CMD ["flutter", "run", "-d", "web-server", "--web-port", "5000", "--dart-define=API_URL=http://backend:3000"]
