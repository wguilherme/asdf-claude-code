#!/usr/bin/env bash

set -euo pipefail

TOOL_NAME="claude-code"

# Base URL for Claude Code releases
CLAUDE_CODE_BASE_URL="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

fail() {
	printf "asdf-%s: %s\n" "$TOOL_NAME" "$*" >&2
	exit 1
}

curl_opts=(-fsSL)

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
	if command -v jq &>/dev/null; then
		curl "${curl_opts[@]}" "https://registry.npmjs.org/@anthropic-ai/claude-code" 2>/dev/null |
			jq -r '.versions | keys[]'
	else
		curl "${curl_opts[@]}" "https://registry.npmjs.org/@anthropic-ai/claude-code" 2>/dev/null |
			sed -n 's/.*"versions":\({[^}]*}\).*/\1/p' |
			grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' |
			tr -d '"' |
			sort -u
	fi
}

get_platform() {
	local os arch

	os="$(uname -s | tr '[:upper:]' '[:lower:]')"
	arch="$(uname -m)"

	case "$os" in
	darwin) ;;
	linux)
		if ldd --version 2>&1 | grep -q musl; then
			arch="${arch}-musl"
		fi
		;;
	*)
		fail "Unsupported operating system: $os"
		;;
	esac

	case "$arch" in
	x86_64)
		arch="x64"
		;;
	aarch64 | arm64)
		arch="arm64"
		;;
	x86_64-musl)
		arch="x64-musl"
		;;
	aarch64-musl | arm64-musl)
		arch="arm64-musl"
		;;
	*)
		fail "Unsupported architecture: $arch"
		;;
	esac

	echo "${os}-${arch}"
}

get_download_url() {
	local version platform
	version="$1"
	platform=$(get_platform)

	echo "${CLAUDE_CODE_BASE_URL}/${version}/${platform}/claude"
}

get_checksum_url() {
	local version
	version="$1"
	echo "${CLAUDE_CODE_BASE_URL}/${version}/manifest.json"
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url=$(get_download_url "$version")

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" "$url" || fail "Could not download $url"
}

verify_checksum() {
	local version filename manifest_url platform expected_checksum actual_checksum
	version="$1"
	filename="$2"

	manifest_url=$(get_checksum_url "$version")
	platform=$(get_platform)

	echo "* Verifying checksum..."

	if command -v jq &>/dev/null; then
		expected_checksum=$(curl "${curl_opts[@]}" "$manifest_url" | jq -r ".platforms.\"${platform}\".checksum")
	else
		expected_checksum=$(curl "${curl_opts[@]}" "$manifest_url" |
			grep -A2 "\"${platform}\"" |
			grep "checksum" |
			sed 's/.*"checksum"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
	fi

	if [ -z "$expected_checksum" ] || [ "$expected_checksum" = "null" ]; then
		echo "* Warning: Could not fetch checksum, skipping verification" >&2
		return 0
	fi

	if command -v sha256sum &>/dev/null; then
		actual_checksum=$(sha256sum "$filename" | awk '{print $1}')
	elif command -v shasum &>/dev/null; then
		actual_checksum=$(shasum -a 256 "$filename" | awk '{print $1}')
	else
		echo "* Warning: No sha256sum or shasum available, skipping verification" >&2
		return 0
	fi

	if [ "$expected_checksum" != "$actual_checksum" ]; then
		fail "Checksum verification failed!\nExpected: $expected_checksum\nActual: $actual_checksum"
	fi

	echo "* Checksum verified successfully"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	mkdir -p "$install_path"

	if ! cp "$ASDF_DOWNLOAD_PATH/claude-code" "$install_path/claude"; then
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	fi

	chmod +x "$install_path/claude"
	test -x "$install_path/claude" || fail "Expected $install_path/claude to be executable."

	echo "$TOOL_NAME $version installation was successful!"
}
