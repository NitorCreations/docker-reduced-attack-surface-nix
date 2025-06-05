# to remove all Nix stuff, just remove all MINIMAL IMAGE SETUP sections, and image will use busybox provided in alpine image instead

## --- MINIMAL IMAGE SETUP STEP START ---

FROM nixos/nix:latest AS minimal-pkgs-builder

WORKDIR /build
COPY flake.nix flake.lock /build

RUN nix --extra-experimental-features 'nix-command flakes' build -o result


FROM scratch AS minimal-pkgs
COPY --link=false --from=minimal-pkgs-builder /build/result /

## --- MINIMAL IMAGE SETUP STEP END ---

# Build stage
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Install Maven
RUN apk add --no-cache maven

# Copy pom.xml first for dependency caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source files
COPY src/ src/

# Build the application
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine AS prod


# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

## --- MINIMAL IMAGE SETUP STEP START ---

# remove busybox and all its symlinks to reduce attack surface
RUN find /bin /sbin /usr/bin /usr/sbin -type l -exec sh -c 'readlink "$1" | grep -q busybox' _ {} \; -delete && rm -f /bin/busybox
COPY --from=minimal-pkgs /bin/ /bin/

## --- MINIMAL IMAGE SETUP STEP END ---

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

# inside entrypoint.sh we can run our startup stuff as root
ENTRYPOINT ["/entrypoint.sh"]

# su equivalent of su-exec command below
CMD ["su", "-", "appuser", "-c", "java -jar app.jar"]

## --- MINIMAL IMAGE SETUP STEP START ---

# sanity check that our static binaries work
RUN sh -c "true" && chmod --version && su-exec appuser:appgroup /bin/sh -c "true"

CMD ["su-exec", "appuser", "/bin/sh", "-c", "java -jar app.jar"]

## --- MINIMAL IMAGE SETUP STEP END ---
