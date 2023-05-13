#!/bin/bash

# Function to get the current timestamp as a string
getCurrentTimestamp() {
    date +"%Y-%m-%d_%H-%M-%S"
}

# Function to launch the subprocess and capture its stdout
launchSubprocess() {
    command="$1"
    logFile="$2"
    
    # Execute the command in the background, redirecting the output to both the console and the log file
    $command 2>&1 | tee -a "$logFile" &

    # Store the subprocess pid
    subprocessPid=$!

    # Wait for the subprocess to finish
    wait $subprocessPid

    # Reset the subprocess pid
    subprocessPid=0
}

# Function to handle the SIGTERM signal
sigtermHandler() {
    if [ $subprocessPid -ne 0 ]; then
        # Send SIGTERM to the subprocess
        kill -TERM $subprocessPid

        # Wait for the subprocess to finish
        wait $subprocessPid

        # Reset the subprocess pid
        subprocessPid=0
    fi

    # Exit the wrapper
    exit 0
}

# Set up the signal handler for SIGTERM
trap 'sigtermHandler' TERM

if [ $# -lt 2 ]; then
    echo "Usage: $0 <logDir> <command> [args...]" >&2
    exit 1
fi

# Generate the log file name with a timestamp
timestamp=$(getCurrentTimestamp)

# Use the log directory path provided as the first argument
logDir="$1"
logFile="$logDir/log_$timestamp.log"

# Create the log directory if it doesn't exist
mkdir -p "$logDir"

# Join the command and arguments into a single string
command="$2"
shift 2
args="$*"
fullCommand="$command $args"

# Launch the subprocess and capture its stdout
launchSubprocess "$fullCommand" "$logFile"

exit 0
