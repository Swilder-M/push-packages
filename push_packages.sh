#!/bin/bash
product="${1:-emqx}"
version="${2:-5.0.0}"

get_os_info() {
	os_version=$(echo ${1} | rev | cut -d'-' -f2 | rev)
	case $os_version in
	ubuntu16.04)
		os_name="ubuntu"
		os_version="xenial"
		;;
	ubuntu18.04)
		os_name="ubuntu"
		os_version="bionic"
		;;
	ubuntu20.04)
		os_name="ubuntu"
		os_version="focal"
		;;
	debian9)
		os_name="debian"
		os_version="stretch"
		;;
	debian10)
		os_name="debian"
		os_version="buster"
		;;
	debian11)
		os_name="debian"
		os_version="bullseye"
		;;
	el7)
		os_name="el"
		os_version="7"
		;;
	el8)
		os_name="el"
		os_version="8"
		;;
	*)
		echo "Unknown OS version: $os_version"
		exit 1
		;;
	esac
	os="$os_name/$os_version"
}

# for nanomq & neuron
push_packages() {
	assets=$(curl -s -H "Authorization: token $GIT_TOKEN" https://api.github.com/repos/emqx/$product/releases/tags/${version} | jq -r '.assets[] | .name' | grep -E '\.rpm$|\.deb$')
	download_prefix="https://github.com/emqx/$product/releases/download/${version}"
	folder_name="${product}-${version}"

	if [ ! -d $folder_name ]; then
		mkdir $folder_name
	else
		echo "> $folder_name folder already exists"
		exit 1
	fi

	for asset in ${assets[@]}; do
		if [[ $asset =~ "sqlite" ]]; then
			continue
		fi

		echo "> Downloading $asset"
		curl -s -L "${download_prefix}/${asset}" -o "${folder_name}/${asset}"

		case $asset in
		*.rpm)
			package_cloud push emqx/${product}/rpm_any/rpm_any ${folder_name}/${asset}
			;;
		*.deb)
			package_cloud push emqx/${product}/any/any ${folder_name}/${asset}
			;;
		*)
			echo "> Unknown asset type: $asset"
			exit 1
			;;
		esac
	done
}

push_emqx() {
	assets=$(curl -s -H "Authorization: token $GIT_TOKEN" https://api.github.com/repos/emqx/emqx/releases/tags/v${version} | jq -r '.assets[] | .name' | grep -E '\.rpm$|\.deb$')
	download_prefix="https://github.com/emqx/emqx/releases/download/v${version}"
	folder_name="emqx-${version}"

	if [ ! -d $folder_name ]; then
		mkdir $folder_name
	else
		echo "> $folder_name folder already exists"
		exit 1
	fi

	for asset in ${assets[@]}; do
		echo "> Downloading $asset"
		curl -s -L "${download_prefix}/${asset}" -o "${folder_name}/${asset}"
		get_os_info $asset
		package_cloud push emqx/emqx-community/$os ${folder_name}/${asset}
	done
}

main() {
	if [ $product == "emqx" ]; then
		push_emqx
	else
		push_packages
	fi
}

main
