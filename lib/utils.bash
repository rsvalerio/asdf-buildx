#!/usr/bin/env bash

set -euo pipefail

export BUILDX_REPO="https://github.com/docker/buildx"
export TOOL_NAME="buildx"
export TOOL_TEST="docker buildx version"

# Print error message and exit with status 1
fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

# Fetch and parse Docker Buildx release tags from GitHub API
list_github_tags() {
	releases_url="https://api.github.com/repos/docker/buildx/releases"
	curl "${curl_opts[@]}" "$releases_url" | grep -o '"tag_name": "v[^"]*"' | sed 's/"tag_name": "v//g' | sed 's/"//g'
}

# Sort versions in descending order (newest first)
sort_versions() {
	sort -V -r
}

# List all available Docker Buildx versions
list_all_versions() {
	list_github_tags
}

# Download Docker Buildx binary for specified version and platform
download_release() {
	local version filename url
	version="$1"
	filename="$2"

	# Resolve "latest" to actual version number
	if [[ "$version" == "latest" ]]; then
		latest_url="https://api.github.com/repos/docker/buildx/releases/latest"
		version=$(curl "${curl_opts[@]}" "$latest_url" | grep -o '"tag_name": "v[^"]*"' | sed 's/"tag_name": "v//g' | sed 's/"//g')
	fi

	os=$(uname -s | tr '[:upper:]' '[:lower:]')
	arch=$(uname -m)

	case "$os" in
	darwin)
		case "$arch" in
		arm64) arch_suffix="arm64" ;;
		x86_64) arch_suffix="amd64" ;;
		*) fail "Unsupported macOS architecture: $arch" ;;
		esac
		os_suffix="darwin"
		;;
	linux)
		case "$arch" in
		x86_64) arch_suffix="amd64" ;;
		arm64) arch_suffix="arm64" ;;
		*) fail "Unsupported Linux architecture: $arch" ;;
		esac
		os_suffix="linux"
		;;
	*)
		fail "Unsupported operating system: $os"
		;;
	esac

	url="https://github.com/docker/buildx/releases/download/v${version}/buildx-v${version}.${os_suffix}-${arch_suffix}"

	echo "* Downloading Docker Buildx v${version} for ${os_suffix} ${arch_suffix}..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

# Install Docker Buildx binary to specified path and verify installation
install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"

		# Find the downloaded buildx binary
		buildx_binary=$(find "${ASDF_DOWNLOAD_PATH}" -maxdepth 1 -name "buildx-v*" -type f | head -1)
		if [[ -z "$buildx_binary" ]]; then
			fail "Could not find downloaded buildx binary"
		fi

		cp "$buildx_binary" "${install_path}/docker-buildx"

		chmod +x "${install_path}/docker-buildx"

		if "${install_path}/docker-buildx" version >/dev/null 2>&1; then
			echo "Docker Buildx $version installation was successful!"
		else
			fail "Installation verification failed"
		fi
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
