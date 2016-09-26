#!/usr/bin/env bash

##### Init

set -e
#set -exumk

##### Constants

TITLE="System Information for $HOSTNAME"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"

##### Config Support

CONFIG_FILE='caerus.conf'

##### Functions

function install_packages {
    echo '[X] Install packages...'
    npm i
}

function read_config {
	echo "[X] Read env file $CONFIG_FILE"
	while read line
	do
		echo "[C] $line"
		export ${line}
	done < ${CONFIG_FILE}
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
	echo "Will download $count file(s) from github..."
	if [[ ${GITHUB_TOKEN} != '' ]]; then
		for index in $(seq $count); do
			local _src_tag="GITHUB_FILE_$(($index - 1))_SRC"
			local _dst_tag="GITHUB_FILE_$(($index - 1))_DEST"
			local _src=`printenv $_src_tag`
			local _dst=`printenv $_dst_tag`
			echo src is $_src
			echo dest is $_dst
			if [[ ${_src} != '' && ${_dst} != '' ]]; then
				mkdir -p $(dirname "$_dst") && touch "$_dst"
				echo "download from $_src to $_dst ..."
				curl --silent \
					--header "Authorization: token $GITHUB_TOKEN" \
					--header 'Accept: application/vnd.github.v3.raw' \
					--location "https://api.github.com/repos/$_src" > $_dst
#					--remote-name $_dst \
				echo 'File downloaded...'
				echo '----------------------------------------'
				cat $_dst
				echo '----------------------------------------'
			else
				echo "Neither GITHUB_FILE_$(($index - 1))_SRC or GITHUB_FILE_$(($index - 1))_DEST defined..."
			fi
		done
	else
		echo 'Github token is empty...'
		exit 1
	fi
}

function download_url_file() {
	env | grep ^URL_FILE
	local count=$((`env | grep '^URL_FILE_[0-9]\+_\(SRC\|DEST\)' | wc -l` / 2))
	echo "Will download $count file(s) from url..."
	for index in $(seq $count); do
		local _src_tag="URL_FILE_$(($index - 1))_SRC"
		local _dst_tag="URL_FILE_$(($index - 1))_DEST"
		local _src=`printenv $_src_tag`
		local _dst=`printenv $_dst_tag`
		echo src is $_src
		echo dest is $_dst
		if [[ ${_src} != '' && ${_dst} != '' ]]; then
			mkdir -p $(dirname "$_dst") && touch "$_dst"
			echo "download from $_src to $_dst ..."
			curl --silent \
				--location $_src > $_dst
			echo 'File downloaded...'
			echo '----------------------------------------'
			cat $_dst
			echo '----------------------------------------'
		else
			echo "Neither URL_FILE_$(($index - 1))_SRC or URL_FILE_$(($index - 1))_DEST defined..."
		fi
	done
}

function load_env() {
	env | grep ^ENV_FILE
	local count=$((`env | grep '^ENV_FILE_[0-9]\' | wc -l`))
	echo "Will download $count file(s) from url..."
	for index in $(seq $count); do
		local _src_tag="ENV_FILE_$(($index - 1))"
		local _src=`printenv $_src_tag`
		echo src is $_src
		if [[ ${_src} != '' ]]; then
			mkdir -p $(dirname "/envs/$_src") && touch "/envs/$_src"
			echo "download from $_src to /envs/$_src ..."
			curl --silent \
				--location $_src > /envs/$_src
			echo 'File downloaded...'
			echo '----------------------------------------'
			cat /envs/$_src
			. /envs/$_src
			echo '----------------------------------------'
		else
			echo "ENV_FILE_$(($index - 1)) not defined..."
		fi
	done
}

##### Info

cat <<- _EOF_
[X] Title: ${TITLE}
[X] Uptime: ${TIME_STAMP}
_EOF_

eval $(parse_yml 'changelog.yml' 'changelog__')

##### Main

cat <<- _EOF_
*****************************************************************

_________ .
\_   ___ \_____    ___________ __ __  ______ .
/    \  \/\__  \ _/ __ \_  __ \  |  \/  ___/ .
\     \____/ __ \\  ___/|  | \/  |  /\___ \ .
 \______  (____  /\___  >__|  |____//____  > .
        \/     \/     \/                 \/ .
                                 - scripts ${changelog__latest:-demo version}

*****************************************************************
_EOF_

load_env
download_github_file
download_url_file
