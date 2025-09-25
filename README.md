<div align="center">

# asdf-buildx [![Build](https://github.com/rsvalerio/asdf-buildx/actions/workflows/build.yml/badge.svg)](https://github.com/rsvalerio/asdf-buildx/actions/workflows/build.yml) [![Lint](https://github.com/rsvalerio/asdf-buildx/actions/workflows/lint.yml/badge.svg)](https://github.com/rsvalerio/asdf-buildx/actions/workflows/lint.yml)

[Docker Buildx](https://github.com/docker/buildx) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [About](#about)
- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# About

Docker Buildx is a Docker CLI plugin that extends the build capabilities of Docker. This plugin allows you to manage different versions of Docker Buildx using asdf.

With Docker Buildx, you can:
- Build multi-platform images (AMD64, ARM64, etc.)
- Use advanced build features like cache mounts and secrets
- Build with different builders and contexts
- Create and manage builder instances
- Use BuildKit features for faster builds
- Integrate with CI/CD pipelines

For more information, visit [Docker Buildx documentation](https://docs.docker.com/buildx/).

# Dependencies

- `bash`, `curl`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- Supported platforms: macOS (ARM64 and AMD64) and Linux (AMD64 and ARM64)

# Install

Plugin:

```shell
asdf plugin add buildx
# or
asdf plugin add buildx https://github.com/rsvalerio/asdf-buildx.git
```

Docker Buildx:

```shell
# Show all installable versions
asdf list-all buildx

# Install specific version
asdf install buildx latest

# Set a version globally (on your ~/.tool-versions file)
asdf global buildx latest

# Now docker buildx commands are available
docker buildx version

# Create a new builder instance
docker buildx create --name mybuilder --use
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/rsvalerio/asdf-buildx/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Rodrigo Valeri](https://github.com/rsvalerio/)
