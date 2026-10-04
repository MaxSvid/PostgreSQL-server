# run chmod +x any file.sh for use on VPS 

set -e
set -u

# env load
if [ ! -f .env ]; then
  echo "ERROR: .env file not found. Copy .env.example"
  exit 1
fi

source .env
