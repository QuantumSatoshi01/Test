URL="https://nodejs.org/download/release/v20.8.0/node-v20.8.0-linux-x64.tar.xz"
DIRECTORY="/root"

curl -o "$DIRECTORY/node-v20.8.0-linux-x64.tar.xz" "$URL"
tar -xvf "$DIRECTORY/node-v20.8.0-linux-x64.tar.xz" -C "$DIRECTORY"
cd "$DIRECTORY/node-v20.8.0-linux-x64"
rm "$DIRECTORY/node-v20.8.0-linux-x64.tar.xz"
