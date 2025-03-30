ERROR=1
WARN=2
INFO=3
DEBUG=4

function error() {
    log "$ERROR" "ERROR" "$*"
}

function warn() {
    log "$WARN" "WARN" "$*"
}

function info() {
    log "$INFO" "INFO" "$*"
}

function debug() {
    local message=$1
    log "$DEBUG" "DEBUG" "$message"
}

log(){
    local log_level_int=$1
    local log_level_str=$2
    local message=${@:3}

    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    local log_message="[$timestamp] [$log_level_str] - $message"

    if [[ $log_level_int -le $LOG_LEVEL ]]; then
        echo "$log_message"
    fi    
}

LOG_LEVEL=${LOG_LEVEL:-$INFO}
