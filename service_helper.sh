#!/bin/bash
service=$1
action=$2

# --- Helper Function ---
# Returns 0 if service exists, 1 if it doesn't
function service_exists() {
    local service=$1
    # systemctl list-unit-files checks if the service is known to systemd
    if systemctl list-unit-files "$service.service" &>/dev/null; then
        return 0 # True (Exists)
    else
        return 1 # False (Does not exist)
    fi
}

function check_status(){
    local service=$1
    local status_str=""
    local enable_str=""

    # 1. Check if the service exists first
    if ! systemctl list-unit-files "$service.service" &>/dev/null; then
        echo "not_found"
        return 1
    fi

    # 2. Check Active Status (Running vs Stopped)
    # --quiet returns 0 (true) if active, non-zero if inactive/failed
    if systemctl is-active --quiet "$service"; then
        status_str="active"
    else
        status_str="inactive"
    fi

    # 3. Check Enabled Status (Startup vs No Startup)
    # --quiet returns 0 (true) if enabled, non-zero if disabled
    if systemctl is-enabled --quiet "$service"; then
        enable_str="enabled"
    else
        enable_str="disabled"
    fi

    # 4. Return the combined string
    echo "$status_str $enable_str"
    
    
}

function install_service(){
	local service=$1

    # The Idempotent Check
    if service_exists "$service"; then
        echo "✅ Info: $service is already installed."
    else
        echo "⬇️ Installing $service..."
        sudo apt-get update && sudo apt-get install -y "$service"
    fi
}

function uninstall_service(){
	local service=$1

    # The Idempotent Check
    if service_exists "$service"; then
        echo "Uninstalling  $service"
	sudo apt-get purge -y "$service"
    else
        echo "Infor: Service not available or already uninstalled"
    fi
}







case $action in
	status) check_status $service ;;
	install) install_service $service ;;
	uninstall) uninstall_service $service ;;
	enable) enable_service $service;;
	disable) disable_service $service ;;
	*) echo enter a valid action ;;

esac
