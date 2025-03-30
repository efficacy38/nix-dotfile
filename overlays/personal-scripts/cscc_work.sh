#!/usr/bin/env bash

# exit if encounter any error
set -eu
set -o pipefail

# enable external modules
source "$(dirname "${BASH_SOURCE[0]}")/modules/logging.sh"

# ======================== error handling ====================================
ERR_GENERIC=1
ERR_USER_INT=2

ErrorHandling() {
    if [ $? -ne 0 ]; then
        error "exit with error, stop the VPN"
        vpn_string="$(get_vpn_string)"
        # ask whether disconnect VPN
        if [ "$vpn_string" != "" ]; then
            stop_all_vpn -s || true
            exit "$ERR_GENERIC"
        fi
    fi
    exit "$ERR_USER_INT"
}
# stop vpn for any interrupt
trap ErrorHandling EXIT SIGINT SIGTERM SIGQUIT
# ======================= end of error handling ==============================

# ======================= CONSTANTS ==========================================
TEST_MODE="test"
PRODUCTION_MODE="prod"

# configs
## log level
# LOG_LEVEL=$DEBUG
## VPN timeout interval and timeout
TIMEINTERVAL=0.1 # 100ms
TIMEOUT=30       # 3s
# =========================== end of CONSTANTS ===============================

# helper functions

fortivpn_invoke() {
    local operation="$1"
    local vpn_type="$2"
    local vpn_string vpn_interface
    vpn_string=$(get_vpn_string)
    vpn_interface=$(get_vpn_interface "$vpn_string")

    if [ "$operation" != "start" ] && [ "$operation" != "stop" ]; then
        error "Invalid operation: $operation, exiting..." && exit "$ERR_GENERIC"
    fi

    if [ "$operation" == "stop" ]; then
        # clear dns setting for systemd-resolved bug(don't clear resolv.conf
        # setting)
        sudo resolvectl revert "$vpn_interface"
    fi

    if sudo systemctl "$operation" "openfortivpn@cscc_$vpn_type.service"; then
        # wait until service is up
        if [ "$operation" == "start" ]; then
            for _ in $(seq 10); do
                get_vpn_status "$vpn_type" | grep -q 'healthy' && break
                sleep 1
            done
        fi
        debug "$vpn_type VPN is $(get_vpn_status "$vpn_type")"
    else
        error "$vpn_type VPN $operation failed, exiting..." && exit "$ERR_GENERIC"
    fi
}

# return current running VPN
# $TEST_MODE or $PRODUCTION_MODE
get_vpn_string() {
    get_vpn_status -s "$TEST_MODE" && echo "$TEST_MODE"
    get_vpn_status -s "$PRODUCTION_MODE" && echo "$PRODUCTION_MODE"
    return 0
}

# script's function
# prompt help
prompt_help() {
    echo "Usage: cscc_work [OPTION]..."
    echo "Connect to cscc VPN"
    echo ""
    echo "  -h, --help          display this help and exit"
    echo "  -s, --status        display current VPN status"
    echo "  -t, --test          connect to test VPN"
    echo "  -p, --production    connect to production VPN"
    echo "  -d, --toggle        toggle between acvite and inactive VPN"
    echo ""
}

get_vpn_status() {
    local OPTIND silent vpn_string
    silent=0
    while getopts "s" op; do
        case $op in
        s)
            silent=1
            ;;
        ?)
            error "unknown key: $op"
            ;;

        *)
            error "Invalid option: -${OPTARG}"
            exit "$ERR_GENERIC"
            ;;
        esac
    done
    shift $((OPTIND - 1))
    vpn_string="$1"

    if systemctl is-active --quiet "openfortivpn@cscc_$vpn_string.service"; then
        if [ "$silent" -eq 0 ]; then
            local status_string=""
            local dns_server=""
            [ "$1" = "$PRODUCTION_MODE" ] &&
                dns_server="10.1.1.1" || dns_server="10.2.1.1"

            connectivity_check "$vpn_string" >/dev/null &&
                status_string="healthy" || status_string="unhealthy"

            [ "$status_string" = "healthy" ] && dig @"$dns_server" \
                +timeout=1 +retry=1 cs.nctu.edu.tw -t SOA >/dev/null &&
                status_string="healthy" || status_string="degreded(dns failure)"

            [ "$silent" -eq 0 ] &&
                printf 'connected(%s, %s)' "$(get_vpn_ip "$vpn_string")" "$status_string"
        fi
        return 0
    else
        [ "$silent" -eq 0 ] && echo "disconnected"
        return 1
    fi
}

get_vpn_interface() {
    local vpn_string
    vpn_string="$1"
    if [[ $vpn_string == "$TEST_MODE" ]]; then
        echo "ppp0"
    elif [[ $vpn_string == "$PRODUCTION_MODE" ]]; then
        echo "ppp1"
    fi
}

_get_vpn_ip_raw() {
    ip addr show "$1" | grep -Po 'inet \K[\d.]+'
}

get_vpn_ip() {
    local target_interface
    target_interface="$(get_vpn_interface "$1")"
    while [ "$TIMEOUT" -gt 0 ]; do
        if [ "$(_get_vpn_ip_raw "$target_interface" 2>/dev/null)" != "" ]; then
            _get_vpn_ip_raw "$target_interface" 2>/dev/null
            return 0
        fi
        sleep "$TIMEINTERVAL"
        TIMEOUT=$((TIMEOUT - 1))
    done

    error "Get VPN IP timeout, exiting..."
    return 1
}

status() {
    # print status of VPN status
    printf "%s VPN status: %s\n" "$TEST_MODE" "$(get_vpn_status "$TEST_MODE")"
    printf "%s VPN status: %s\n" "$PRODUCTION_MODE" \
        "$(get_vpn_status "$PRODUCTION_MODE")"
}

stop_all_vpn() {
    local OPTIND short_opt silent_enabled vpn_string
    silent_enabled=""
    while getopts s short_opt; do
        case $short_opt in
        s)
            # make other command silent
            silent_enabled="true"
            ;;
        *)
            echo "Usage: stop_all_vpn [-s]"
            echo "Stop CSCC VPN"
            echo ""
            echo "  -s, --silent          silent mode"
            exit "$ERR_GENERIC"
            ;;
        esac
    done

    vpn_string="$(get_vpn_string)"
    if [[ -z "$vpn_string" ]]; then
        debug "No VPN enabled, just return!!"
        return
    fi

    # ask whether disconnect VPN
    if [[ -z "$silent_enabled" ]]; then
        warn "$vpn_string VPN is running, check whether user want to stop it..."
        printf "%s VPN(%s) service is running, do you want to disconnect? (Y/n) - " \
            "$vpn_string" "$(get_vpn_ip "$vpn_string")"
        read -r answer
        if [ "$answer" != "${answer#[Nn]}" ]; then
            info "answer is \`$answer\` $vpn_string VPN service would not stopped, exiting..."
            return
        fi
    fi

    # stop vpn service
    info "stopping $vpn_string VPN..."
    fortivpn_invoke stop "$vpn_string" || true
}

start_vpn() {
    local OPTIND short_opt ignore_enabled vpn_string
    ignore_enabled=""
    while getopts 'i' short_opt; do
        case $short_opt in
        i)
            # make other command silent
            ignore_enabled="true"
            ;;
        *)
            echo "Usage: start_vpn [-s]"
            echo "Start CSCC VPN"
            echo ""
            echo "  -i, --ignore          ignore asking current VPN status"
            exit "$ERR_GENERIC"
            ;;
        esac
        shift
    done
    local target_vpn_type="$1"

    info "check current used VPN type(if VPN is still running)..."
    vpn_string="$(get_vpn_string)"

    if [ "$vpn_string" = "$target_vpn_type" ]; then
        # if not healthy
        if ! connectivity_check "$vpn_string"; then
            warn "$vpn_string VPN is not healthy, remove unhealthy link"
            stop_all_vpn -s
        else
            info "$vpn_string VPN service is running, exiting..." && exit 0
        fi
    elif ! stop_all_vpn -s; then
        error "$vpn_string VPN stop failed, exiting..." && exit "$ERR_GENERIC"
    fi

    if [[ -z $ignore_enabled ]]; then
        read -r -p "$target_vpn_type VPN service is not running, do you want to start it? (Y/n) - " answer
        if [ "$answer" != "${answer#[Nn]}" ]; then
            info "answer is \`$answer\` VPN service would not not started, exiting..."
            exit 0
        else
            info "answer is \`$answer\` VPN service would start"
        fi
    fi

    # start VPN service
    info "starting $target_vpn_type vpn..."
    fortivpn_invoke start "$target_vpn_type"

    local target_interface
    target_interface=$(get_vpn_interface "$target_vpn_type")
    # setup dns naming service for VPN connection
    if [ "$target_vpn_type" == "$PRODUCTION_MODE" ]; then
        sudo resolvectl dns "$target_interface" 10.1.1.1 10.1.1.2
    else
        sudo resolvectl dns "$target_interface" 10.2.1.1 10.2.1.2
    fi

    # tailscale customize: add route to prevent exitnode ruins whole routing table
    if ! tailscale status >/dev/null; then
        info "tailscale is not enabled"
    else
        info "tailscale is enabled, add throw at routing table"
        tailscale_routing_table="$(ip r show table 52)"
        for cidr in $(ip r show dev "$target_interface" | cut -f 1 -d' '); do
            ip_cmd=$(printf 'throw %s' "$cidr")
            if grep -q "$ip_cmd" <(echo "$tailscale_routing_table"); then
                debug "table 52 has \`$ip_cmd\`, skipping"
                continue
            fi
            exec_cmd=$(printf "sudo ip route add %s table 52" "$ip_cmd")
            debug "add $ip_cmd into table 52, exec $exec_cmd"
            sh -c "$exec_cmd"
        done
    fi

    info "set search domain([cc].cs.nctu.edu.tw) for $1 vpn"
    # INFO: for security reason, only set the dns as routing-domain is good
    # check https://systemd.io/RESOLVED-VPNS/ for more information
    sudo resolvectl domain "$target_interface" '~test.cc.cs.nctu.edu.tw' \
        '~cc.cs.nctu.edu.tw' '~cs.nctu.edu.tw' '~test.cs.nctu.edu.tw'
    sudo resolvectl default-route "$target_interface" false

    # use original route to 140.113.0.0/16(for latency)
    ip route add throw 140.113.0.0/16 table 52 2>/dev/null || true
    info "activate $target_vpn_type VPN connection done"
}

toggle_vpn() {
    # check VPN service is running, if not ask to start it
    if get_vpn_status -s "$TEST_MODE" || get_vpn_status -s "$PRODUCTION_MODE"; then
        stop_all_vpn
    else
        start_vpn "$1"
    fi
}

restart_vpn() {
    target_vpn_type=$(get_vpn_string)
    stop_all_vpn -s
    start_vpn -i "$target_vpn_type"
}

connectivity_check() {
    local vpn_type="$1"
    local ping_dst_ip=""
    [[ $vpn_type == "$TEST_MODE" ]] &&
        ping_dst_ip="10.2.1.1" || ping_dst_ip="10.1.1.1"

    info "check $vpn_type VPN health..."
    if ! ping -c 1 -W 1 "$ping_dst_ip" &>/dev/null; then
        error "$vpn_type VPN is not healthy" && return 1
    fi
    info "$vpn_type VPN is healthy"
}

if [[ $# -le 0 ]]; then
    operation=""
else
    operation="$1"
fi

case "$operation" in
-t | --test)
    info "start test vpn..."
    start_vpn -i "$TEST_MODE"
    ;;
-p | --production)
    info "start production vpn..."
    start_vpn -i "$PRODUCTION_MODE"
    ;;
-s | --status)
    info "print VPN status..."
    status | boxes -p "h2v1"
    echo
    ;;
-h | --help)
    prompt_help
    ;;

-d | --toggle)
    info "toggle VPN..."
    toggle_vpn "$TEST_MODE"
    ;;
-x | --terminate)
    info "terminate VPN..."
    stop_all_vpn -s
    ;;

-r | --restart)
    info "restart VPN"
    restart_vpn
    ;;

*)
    # if no arguments are given, print status, else prompt help
    if [ $# -eq 0 ]; then
        info "no arguments given, fallback to toggle VPN..."
        info "print VPN status..."
        status | boxes -p "h2v1"
        echo ""
        toggle_vpn "$TEST_MODE"
    else
        prompt_help
        exit "$ERR_GENERIC"
    fi
    ;;
esac

# vim: ts=4:sw=4
