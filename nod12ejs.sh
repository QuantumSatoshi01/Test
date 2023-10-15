if ! command -v nvm &> /dev/null; then
  echo "NVM не знайдено, встановлюємо..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  source ~/.bashrc
fi

nvm install --lts
nvm install stable
