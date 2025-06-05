# Minimal Docker Java Example

This project demonstrates how to create a minimal, security-focused Docker container for a Java application by replacing busybox with custom static binaries built using Nix.

## The Idea

Traditional Alpine-based containers include busybox, which provides many shell utilities but also increases the attack surface. This project shows how to:

1. Remove busybox from the container
2. Use Nix to build only the minimal static binaries you actually need
3. Create a more secure container with a reduced attack surface

## Usage

### Build and Run

The Dockerfile includes two build targets:

**Minimal secure image (default):**
```bash
# Build with reduced attack surface (no busybox)
docker build -t minimal-java .

# Run the container
docker run minimal-java
```

**Standard Alpine image:**
```bash
# Build standard Alpine with busybox utilities
docker build --target prod-alpine -t minimal-java-standard .

# Run the container
docker run minimal-java-standard
```

Both images output: `Hello World from Java 21!`

### Local Development

```bash
# Compile the Java application
mvn clean package

# Run locally
java -jar target/hello-world-1.0.0.jar
```

### Updating Nix Flake

To update the Nix dependencies to the latest versions:

```bash
# Update flake.lock to latest nixpkgs
nix flake update

# Or using Docker if you don't have Nix installed locally
docker run --rm -v $(pwd):/workspace -w /workspace nixos/nix:latest nix --extra-experimental-features 'nix-command flakes' flake update
```

## Build Targets Explained

The Dockerfile uses multi-stage builds with two final production targets:

- **`prod-minimal` (default)**: Removes busybox and uses Nix-built static binaries for minimal attack surface
- **`prod-alpine`**: Standard Alpine Linux with busybox utilities for broader compatibility

Use `--target prod-alpine` to build without the security hardening if you need standard shell utilities.

## Security Benefits

- **Reduced attack surface**: Only includes `sh`, `su-exec`, and `chmod` binaries
- **Static binaries**: No dynamic library dependencies
- **Non-root execution**: Runs as `appuser` with minimal privileges
- **Minimal base**: Uses `scratch` for the Nix-built binaries layer