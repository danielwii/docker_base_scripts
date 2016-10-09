#!/usr/bin/env bash

##### Init

#set -e # Stop when error occurred
#set -xumk

##### Constants

VERSION=20161009
TITLE="System Information for $HOSTNAME"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"

##### Functions

function check_version() {
    echo -e "[X] Check remote version..."
    local remote_version=`curl -s https://raw.githubusercontent.com/danielwii/docker_base_scripts/master/entrypoint.sh`
    remote_version=${VERSION}
    if [[ remote_version =~ /^[0-9]+$/ ]]; then
        if ! [[ ${VERSION} -eq ${remote_version} ]]; then
            echo -e "[X] Try execute remote shell..."
            VERSION=${remote_version}
            curl -s https://raw.githubusercontent.com/danielwii/docker_base_scripts/master/entrypoint.sh | bash
            exit 0
        fi
    else
        echo -e "[X] No newest scripts found..."
    fi
}

function parse_yml() {
	local prefix=$2
	local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
	sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
    	-e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
	awk -F${fs} '{
		_indent = length($1)/2;
		_name[_indent] = $2;
		for (i in _name) {if (i > _indent) {delete _name[i]}}
		if (length($3) > 0) {
			vn=""; for (i=0; i<_indent; i++) {vn=(vn)(_name[i])("_")}
			printf("%s%s%s=\"%s\"\n", "'${prefix}'",vn, $2, $3);
		}
	}'
}

# ***
# Download files form github to dest
# ENV:
# 	- GITHUB_TOKEN			*****
# 	- GITHUB_FILE_{0}_SRC	zhulux/caerus-scripts/contents/elk/logstash/config/logstash.conf
# 	- GITHUB_FILE_{0}_DEST	/config-dir/logstash.conf
# ***
function download_github_file() {
	env | grep ^GITHUB_FILE
	local count=$((`env | grep '^GITHUB_FILE_[0-9]\+_\(SRC\|DEST\)' | wc -l` / 2))
    echo -e "[X] Will download \033[31m($count)\033[0m file(s) from github..."
	if [[ ${count} -gt 0 ]]; then
        if [[ ${GITHUB_TOKEN} != '' ]]; then
            for index in $(seq ${count}); do
                local _src_tag="GITHUB_FILE_$(($index - 1))_SRC"
                local _dst_tag="GITHUB_FILE_$(($index - 1))_DEST"
                local _src=`printenv ${_src_tag}`
                local _dst=`printenv ${_dst_tag}`
                if [[ ${_src} != '' && ${_dst} != '' ]]; then
                    mkdir -p $(dirname "$_dst") && touch "$_dst"
                    echo "[X] Download from $_src to $_dst ..."
                    curl --silent \
                        --header "Authorization: token $GITHUB_TOKEN" \
                        --header 'Accept: application/vnd.github.v3.raw' \
                        --location "https://api.github.com/repos/$_src" > ${_dst}
    #					--remote-name $_dst \
                    echo "[X] File downloaded...${_dst}"
                    echo '[X] ----------------------------------------'
                    cat ${_dst}
                    echo -e "\n[X] ----------------------------------------"
                else
                    echo "[X] Neither GITHUB_FILE_$(($index - 1))_SRC or GITHUB_FILE_$(($index - 1))_DEST defined..."
                fi
            done
        else
            echo '[X] Github token is empty...'
        fi
	fi
}

function download_url_file() {
	env | grep ^URL_FILE
	local count=$((`env | grep '^URL_FILE_[0-9]\+_\(SRC\|DEST\)' | wc -l` / 2))
	echo -e "[X] Will download \033[31m($count)\033[0m file(s) from url..."
	if [[ ${count} -gt 0 ]]; then
        for index in $(seq ${count}); do
            local _src_tag="URL_FILE_$(($index - 1))_SRC"
            local _dst_tag="URL_FILE_$(($index - 1))_DEST"
            local _src=`printenv ${_src_tag}`
            local _dst=`printenv ${_dst_tag}`
            if [[ ${_src} != '' && ${_dst} != '' ]]; then
                mkdir -p $(dirname "$_dst") && touch "$_dst"
                echo "[X] Download from $_src to $_dst ..."
                curl --silent \
                    --location ${_src} > ${_dst}
                echo "[X] File downloaded...${_dst}"
                echo '[X] ----------------------------------------'
                cat ${_dst}
                echo -e "\n[X] ----------------------------------------"
            else
                echo "[X] Neither URL_FILE_$(($index - 1))_SRC or URL_FILE_$(($index - 1))_DEST defined..."
            fi
        done
	fi
}

function load_env() {
	env | grep ^ENV_FILE
	local count=$((`env | grep '^ENV_FILE_[0-9]' | wc -l`))
	echo -e "[X] Will download \033[31m($count)\033[0m file(s) from url..."
	if [[ ${count} -gt 0 ]]; then
        for index in $(seq ${count}); do
            local _src_tag="ENV_FILE_$(($index - 1))"
            local _src=`printenv ${_src_tag}`
            if [[ ${_src} != '' ]]; then
                mkdir -p $(dirname "/envs/$_src") && touch "/envs/$_src"
                echo "[X] Download from $_src to /envs/$index ..."
                curl --silent \
                    --location ${_src} > /envs/${index}
                echo "[X] File downloaded...${_dst}"
                echo '[X] ----------------------------------------'
                echo /envs/${index}
                cat /envs/${index}
                . /envs/${index}
                echo -e '\n[X] ----------------------------------------'
            else
                echo "[X] ENV_FILE_$(($index - 1)) not defined..."
            fi
        done
	fi
}

##### Info

cat <<- _EOF_
[X] Title: ${TITLE}
[X] Uptime: ${TIME_STAMP}
_EOF_

eval $(parse_yml 'changelog.yml' 'changelog__')

##### Main

echo -e "[X] \033[31m*****************************************************************\033[0m"
echo -e "[X] \033[31m\033[0m"
echo -e "[X] \033[31m_________ .\033[0m"
echo -e "[X] \033[31m\_   ___ \_____    ___________ __ __  ______ .\033[0m"
echo -e "[X] \033[31m/    \  \/\__  \ _/ __ \_  __ \  |  \/  ___/ .\033[0m"
echo -e "[X] \033[31m\     \____/ __ \\  ___/|  | \/  |  /\___ \ .\033[0m"
echo -e "[X] \033[31m \______  (____  /\___  >__|  |____//____  > .\033[0m"
echo -e "[X] \033[31m        \/     \/     \/                 \/ .\033[0m"
echo -e "[X] \033[31m                                 - EntryPoint Version: ${VERSION}\033[0m"
echo -e "[X] \033[31m                                 - This: ${changelog__latest:-snapshot version}\033[0m"
echo -e "[X] \033[31m\033[0m"
echo -e "[X] \033[31m*****************************************************************\033[0m"

check_version
download_github_file
download_url_file

echo -e "[X] \033[44;37m Run... '\033[0m\033[44;31m$@\033[0m\033[44;37m' \033[0m"
echo -e "[X] -----------------------------------------------------------------"
exec "$@"
