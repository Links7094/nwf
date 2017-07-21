#!/bin/bash

#####################################################################################
# nwf application init script
# author: elvin
# date: 2017-2-27
# desc: this script will initialize nwf application automatically
#####################################################################################


if [ $# -ne 1 ] ; then
	echo "USAGE: sh nwf_init.sh 'project-name'"
	exit 1;
fi
pn=$1

cd $(cd $(dirname $0) && pwd -P)
if [ ! -d "$pn" ]; then
        mkdir "$pn"
fi
cd $pn
if [ -f ".nwf/init_flag" ]; then
	cat .nwf/init_flag
	exit 1
fi

echo start initialize NPL Web application...
echo project name: $pn

if [ ! -d ".git" ]; then
	git init 
fi
if [ ! -d "npl_packages" ]; then
	mkdir "npl_packages"
fi

echo detecting the current location...
country_flag=$(curl "http://ip.taobao.com/service/getIpInfo.php?ip=$(curl http://ipecho.net/plain)" | grep '"country_id":"CN"' | wc -l)
if [ $country_flag -ge 1 ]; then
    echo "We have detected that you are currently in China, so we will use the mirror repository located in China."
    if [ ! -f "npl_packages/main/README.md" ]; then
        git submodule add https://git.oschina.net/elvinzeng/npl-main-packages.git npl_packages/main
    fi
    if [ ! -f "npl_packages/nwf/README.md" ]; then
        git submodule add https://git.oschina.net/elvinzeng/nwf.git npl_packages/nwf
    fi
else
    echo "We have detected that you are not currently in China, so we will use github repository directly."
    if [ ! -f "npl_packages/main/README.md" ]; then
        git submodule add https://github.com/NPLPackages/main npl_packages/main
    fi
    if [ ! -f "npl_packages/nwf/README.md" ]; then
        git submodule add https://github.com/elvinzeng/nwf.git npl_packages/nwf
    fi
fi

cd npl_packages/main && git pull
cd ../nwf && git pull
cd ../../

cp npl_packages/nwf/resources/config/gitignore .gitignore
cp npl_packages/nwf/resources/config/module_source_repos.conf module_source_repos.conf
cp npl_packages/nwf/resources/config/dependencies.conf dependencies.conf
find npl_packages/nwf/resources/scripts/ ! -name "_*" -type f -exec cp {} . \;

if [ ! -d "www" ]; then
	mkdir "www"
fi

if [ ! -d "lib/so" ]; then
	mkdir "lib/so" -p
fi

if [ ! -d "lib/dll" ]; then
	mkdir "lib/dll" -p
fi

cp npl_packages/nwf/resources/lua/* www/
cp npl_packages/nwf/resources/config/webserver.config.xml www/
if [ ! -d "www/modules" ]; then
	mkdir www/modules
fi
cp -r npl_packages/nwf/resources/demo/* www/

mkdir .nwf
echo "do not run init script again! project already initialized at: $(date '+%F %T')" > .nwf/init_flag

bash npl_packages/nwf/resources/scripts/_hide_file_on_win.sh npl_packages
bash npl_packages/nwf/resources/scripts/_hide_file_on_win.sh ".nwf"
bash npl_packages/nwf/resources/scripts/_hide_file_on_win.sh ".gitmodules"
bash npl_packages/nwf/resources/scripts/_hide_file_on_win.sh ".gitignore"
bash npl_packages/nwf/resources/scripts/_hide_file_on_win.sh "restart_debug.sh"
bash npl_packages/nwf/resources/scripts/_hide_file_on_win.sh "shutdown.sh"
bash npl_packages/nwf/resources/scripts/_hide_file_on_win.sh "start.sh"

find . -path './.git' -prune -o -path './npl_packages' -prune -o -path './.nwf' -prune -o -type f -print | xargs md5sum > .nwf/md5sum

echo NPL Web application initialization done.

cat npl_packages/nwf/resources/scripts/_msg_init.txt