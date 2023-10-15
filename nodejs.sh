LATEST_VERSION=$(curl -sL https://nodejs.org/download/release/latest-v20.x/ | grep -o 'node-v[0-9.]*-linux-x64.tar.xz' | head -n 1)

if [ -n "$LATEST_VERSION" ]; then
    curl -o "$LATEST_VERSION" "https://nodejs.org/download/release/latest-v20.x/$LATEST_VERSION"
    tar -xvf "$LATEST_VERSION"
    cd "${LATEST_VERSION%.tar.xz}"
    
    rm "$LATEST_VERSION"
else
    echo "Не вдалось знайти останню версію Node.js."
fi
