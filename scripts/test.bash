#!/usr/bin/env bash

# Test script for asdf-buildx plugin
set -euo pipefail

echo "Testing asdf-buildx plugin..."

# Check if asdf is available
if ! command -v asdf >/dev/null 2>&1; then
	echo "Error: asdf is not installed"
	exit 1
fi

# Remove existing plugins if present
echo "Removing existing buildx plugin..."
asdf plugin remove buildx || true

echo "Removing existing asdf-test-buildx plugin..."
asdf plugin remove asdf-test-buildx || true

# Create a temporary directory for the plugin
TEMP_PLUGIN_DIR=$(mktemp -d)
echo "Creating temporary plugin directory: $TEMP_PLUGIN_DIR"

# Copy plugin files to temporary directory
cp -r bin "$TEMP_PLUGIN_DIR/"
cp -r lib "$TEMP_PLUGIN_DIR/"
cp version.txt "$TEMP_PLUGIN_DIR/"

# Initialize git repository in temporary directory (required by asdf)
cd "$TEMP_PLUGIN_DIR"
git init
git add .
git commit -m "Initial commit for testing"
cd - >/dev/null

# Add plugin from temporary directory
echo "Adding buildx plugin from temporary directory..."
asdf plugin add buildx "$TEMP_PLUGIN_DIR"

# Test the plugin
echo "Testing plugin..."

# Test listing versions
echo "Testing version listing..."
if asdf list all buildx | head -5; then
	echo "Version listing successful!"
else
	echo "Version listing failed!"
	exit 1
fi

# Test installing a specific version
echo "Installing version 0.27.0..."
if asdf install buildx 0.27.0; then
	echo "Installation successful!"

	# Set the version for testing
	echo "Setting version for testing..."
	asdf set buildx 0.27.0

	# Now test the installed version
	echo "Testing installed version..."
	# Check if the docker-buildx binary was installed and is executable
	BUILDX_BINARY=$(asdf where buildx)/bin/docker-buildx
	if [[ -f "$BUILDX_BINARY" && -x "$BUILDX_BINARY" ]]; then
		echo "Docker Buildx binary found at: $BUILDX_BINARY"
		# Test the binary directly
		if "$BUILDX_BINARY" version >/dev/null 2>&1; then
			echo "Plugin test passed! Docker Buildx binary is working."
		else
			echo "Plugin test failed - Docker Buildx binary not working!"
			exit 1
		fi
	else
		echo "Plugin test failed - Docker Buildx binary not found or not executable!"
		exit 1
	fi
else
	echo "Plugin test failed - installation failed!"
	exit 1
fi

# Cleanup: remove all buildx versions
echo "Cleaning up buildx versions..."
if asdf list buildx 2>/dev/null; then
	asdf list buildx | while read -r version; do
		if [[ -n "$version" && "$version" != " " ]]; then
			asdf uninstall buildx "$version" || true
		fi
	done
fi

# Remove version setting from .tool-versions
echo "Removing version setting..."
asdf set -u buildx || true

# Remove buildx line from .tool-versions file if it exists
echo "Cleaning up .tool-versions file..."
if [[ -f .tool-versions ]]; then
	sed -i '' '/^buildx /d' .tool-versions || true
fi

# Remove the plugins
echo "Removing buildx plugin..."
asdf plugin remove buildx || true

echo "Removing asdf-test-buildx plugin..."
asdf plugin remove asdf-test-buildx || true

# Clean up temporary directory
echo "Cleaning up temporary plugin directory..."
rm -rf "$TEMP_PLUGIN_DIR"

echo "Test completed successfully!"
