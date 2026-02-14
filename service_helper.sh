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
    local svc=$1
    # 2>&1 redirects 'Standard Error' to 'Standard Output' so we can capture it
    sudo systemctl status $svc 2>&1
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
