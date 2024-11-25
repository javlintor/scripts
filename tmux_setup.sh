#!/bin/bash

# Check if a directory is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Get absolute path of the directory
TARGET_DIR=$(realpath "$1")

# Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Get the directory name to use as the session name
SESSION_NAME=$(basename "$TARGET_DIR")

# Check if the tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Session '$SESSION_NAME' already exists. Attaching..."
  tmux attach-session -t "$SESSION_NAME"
  exit 0
fi

# Change to the target directory
cd "$TARGET_DIR" || exit

# Start a new tmux session with the name of the directory
tmux new-session -d -s "$SESSION_NAME" -c "$TARGET_DIR"

# Create the first window with nvim
tmux send-keys -t "$SESSION_NAME:0" "nvim" C-m

# Split the pane vertically, with 30% for the new pane
tmux split-window -t "$SESSION_NAME:0" -v -c "$TARGET_DIR"
tmux resize-pane -t "$SESSION_NAME:0" -D 15

# Focus back on the nvim pane
tmux select-pane -t "$SESSION_NAME:0.0"

# Execute the :Ex command in nvim
tmux send-keys -t "$SESSION_NAME:0.0" ":Ex" C-m

# Attach to the tmux session
tmux attach-session -t "$SESSION_NAME"

