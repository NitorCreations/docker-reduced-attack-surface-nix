# Minimal Docker Java Example

This project demonstrates how to create a minimal, security-focused Docker container for a Java application by replacing busybox with custom static binaries built using Nix.

## The Idea

Traditional Alpine-based containers include busybox, which provides many shell utilities but also increases the attack surface. This project shows how to:

1. Remove busybox from the container
2. Use Nix to build only the minimal static binaries you actually need
3. Create a more secure container with a reduced attack surface

## Usage

### Build and Run

```bash
# Build the Docker image
docker build -t minimal-java .

# Run the container
docker run minimal-java
```

The application will output: `Hello World from Java 21!`

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

## Reverting to Busybox

To revert back to using the standard busybox setup, remove all sections marked with:

```dockerfile
## --- MINIMAL IMAGE SETUP STEP START ---
...
## --- MINIMAL IMAGE SETUP STEP END ---
```

This will restore the standard Alpine busybox behavior while maintaining the non-root user security.

## Security Benefits

- **Reduced attack surface**: Only includes `sh`, `su-exec`, and `chmod` binaries
- **Static binaries**: No dynamic library dependencies
- **Non-root execution**: Runs as `appuser` with minimal privileges
- **Minimal base**: Uses `scratch` for the Nix-built binaries layer