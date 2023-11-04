#!/bin/bash

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

npmInstall(){
	echo "${release}"
	if [[ "${release}" == "centos" ]];then
 		yum update -y
   		yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
     		yum install glibc.i686 libstdc++.i686 libcurl.i686 screen -y
		sleep 5
	elif [[ "${release}" == "ubuntu" ]];then
		sudo add-apt-repository multiverse
  		sudo dpkg --add-architecture i386
    		sudo apt update -y
      		sudo apt install lib32gcc1 libcurl4-gnutls-dev:i386 lib32stdc++6 lib32z1 -y
		sleep 5
	else
		echo -e "${Error} 安装系统环境出错!!!" && exit 1
	fi

}

###安装 SteamCMD
installSteamCMD(){
	
	mkdir -p  $HOME/steamcmd
	wget -P   $HOME/steamcmd https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
	cd $HOME/steamcmd
	tar -xvzf $HOME/steamcmd/steamcmd_linux.tar.gz
}

####安装饥荒服务端
installDSTServer(){
	bash $HOME/steamcmd/steamcmd.sh +force_install_dir ../dontstarvetogether_dedicated_server +login anonymous +app_update 343050 validate +quit
	if [[ "${release}" == "centos" ]];then
		cd $HOME/dontstarvetogether_dedicated_server/bin/lib32
		ln -s /usr/lib/libcurl.so.4 libcurl-gnutls.so.4
	elif [[ "${release}" == "ubuntu" ]];then
		echo "-------------"
	else
		echo -e "${Error} 本机系统为${Green_font_prefix}[${release}]${Font_color_suffix},一键脚本不支持“centos”，“ubuntu”之外的系统。" && exit 1
	fi
	mkdir -p $HOME/.klei/DoNotStarveTogether
}

####更新饥荒服务端
updateDSTServer(){
	
	mkdir -p $HOME/dontstarvetogether_dedicated_server/mods/temp && cp $HOME/dontstarvetogether_dedicated_server/mods/dedicated_server_mods_setup.lua $HOME/dontstarvetogether_dedicated_server/mods/temp/dedicated_server_mods_setup_temp.lua
	bash $HOME/steamcmd/steamcmd.sh +force_install_dir ../dontstarvetogether_dedicated_server +login anonymous +app_update 343050 validate +quit
	cp $HOME/dontstarvetogether_dedicated_server/mods/temp/dedicated_server_mods_setup_temp.lua $HOME/dontstarvetogether_dedicated_server/mods/dedicated_server_mods_setup.lua
	rm -rf $HOME/dontstarvetogether_dedicated_server/mods/temp
	echo -e "${Info} 饥荒服务端已更新到最新版本"
}

###启动地上世界
stratMaster(){
	steamcmd_dir="$HOME/steamcmd"
	install_dir="$HOME/dontstarvetogether_dedicated_server"
	cluster_name="World1"
	dontstarve_dir="$HOME/.klei/DoNotStarveTogether"
	
	function fail()
	{
	        echo Error: "$@" >&2
	        exit 1
	}
	
	function check_for_file()
	{
	    if [ ! -e "$1" ]; then
	            fail "Missing file: $1"
	    fi
	}
	
	cd "$steamcmd_dir" || fail "Missing $steamcmd_dir directory!"
	
	check_for_file "steamcmd.sh"
	check_for_file "$dontstarve_dir/$cluster_name/cluster.ini"
	check_for_file "$dontstarve_dir/$cluster_name/cluster_token.txt"
	check_for_file "$dontstarve_dir/$cluster_name/Master/server.ini"
	#check_for_file "$dontstarve_dir/$cluster_name/Caves/server.ini"
	
	
	check_for_file "$install_dir/bin"
	
	cd "$install_dir/bin" || fail 
	
	run_shared=(./dontstarve_dedicated_server_nullrenderer)
	run_shared+=(-console)
	run_shared+=(-cluster "$cluster_name")
	run_shared+=(-monitor_parent_process $$)
	
	#"${run_shared[@]}" -shard Caves  | sed 's/^/Caves:  /' &
	"${run_shared[@]}" -shard Master | sed 's/^/Master: /'
}

###启动洞穴世界
stratCaves(){
	steamcmd_dir="$HOME/steamcmd"
	install_dir="$HOME/dontstarvetogether_dedicated_server"
	cluster_name="World1"
	dontstarve_dir="$HOME/.klei/DoNotStarveTogether"
	
	function fail()
	{
	        echo Error: "$@" >&2
	        exit 1
	}
	
	function check_for_file()
	{
	    if [ ! -e "$1" ]; then
	            fail "Missing file: $1"
	    fi
	}
	
	cd "$steamcmd_dir" || fail "Missing $steamcmd_dir directory!"
	
	check_for_file "steamcmd.sh"
	check_for_file "$dontstarve_dir/$cluster_name/cluster.ini"
	check_for_file "$dontstarve_dir/$cluster_name/cluster_token.txt"
	#check_for_file "$dontstarve_dir/$cluster_name/Master/server.ini"
	check_for_file "$dontstarve_dir/$cluster_name/Caves/server.ini"
	
	
	check_for_file "$install_dir/bin"
	
	cd "$install_dir/bin" || fail 
	
	run_shared=(./dontstarve_dedicated_server_nullrenderer)
	run_shared+=(-console)
	run_shared+=(-cluster "$cluster_name")
	run_shared+=(-monitor_parent_process $$)
	
	"${run_shared[@]}" -shard Caves  | sed 's/^/Caves:  /' 
	#"${run_shared[@]}" -shard Master | sed 's/^/Master: /'
}

###创建地上世界初始化存档
initFileMaster(){
		
	mkdir -p $HOME/.klei/DoNotStarveTogether/World1/Master
	
	echo -e "token" > $HOME/.klei/DoNotStarveTogether/World1/cluster_token.txt
	echo -e "[GAMEPLAY]
game_mode = endless
max_players = 8
pvp = false
pause_when_empty = true


[NETWORK]
lan_only_cluster = false
cluster_intention = cooperative
cluster_password = 123456
cluster_description = This is the clean server.
cluster_name = 11227 萌新欢乐档
offline_cluster = false
cluster_language = zh


[MISC]
console_enabled = true


[SHARD]
shard_enabled = true
bind_ip = 0.0.0.0
master_ip = 127.0.0.1
master_port = 11000
cluster_key = dst15946
	
	" > $HOME/.klei/DoNotStarveTogether/World1/cluster.ini
	echo -e "[NETWORK]
server_port = 11001


[SHARD]
is_master = true
name = Master1
id = 1


[ACCOUNT]
encode_user_path = true
	
	" > $HOME/.klei/DoNotStarveTogether/World1/Master/server.ini
	echo -e "return {
  desc="标准《饥荒》体验。",
  hideminimap=false,
  id="SURVIVAL_TOGETHER",
  location="forest",
  max_playlist_position=999,
  min_playlist_position=0,
  name="标准森林",
  numrandom_set_pieces=4,
  override_level_string=false,
  overrides={
    alternatehunt="default",
    angrybees="default",
    antliontribute="default",
    autumn="default",
    bats_setting="default",
    bearger="default",
    beefalo="default",
    beefaloheat="default",
    beequeen="default",
    bees="default",
    bees_setting="default",
    berrybush="default",
    birds="default",
    boons="default",
    branching="default",
    brightmarecreatures="default",
    bunnymen_setting="default",
    butterfly="default",
    buzzard="default",
    cactus="default",
    carrot="default",
    carrots_regrowth="default",
    catcoon="default",
    catcoons="default",
    chess="default",
    cookiecutters="default",
    crabking="default",
    day="default",
    deciduousmonster="default",
    deciduoustree_regrowth="default",
    deerclops="default",
    dragonfly="default",
    dropeverythingondespawn="default",
    evergreen_regrowth="default",
    extrastartingitems="default",
    fishschools="default",
    flint="default",
    flowers="default",
    flowers_regrowth="default",
    frograin="default",
    frogs="default",
    fruitfly="default",
    gnarwail="default",
    goosemoose="default",
    grass="default",
    grassgekkos="default",
    has_ocean=true,
    hound_mounds="default",
    houndmound="default",
    hounds="default",
    hunt="default",
    keep_disconnected_tiles=true,
    klaus="default",
    krampus="default",
    layout_mode="LinkNodesByKeys",
    liefs="default",
    lightning="default",
    lightninggoat="default",
    loop="default",
    lureplants="default",
    malbatross="default",
    marshbush="default",
    merm="default",
    merms="default",
    meteorshowers="default",
    meteorspawner="default",
    moles="default",
    moles_setting="default",
    moon_berrybush="default",
    moon_bullkelp="default",
    moon_carrot="default",
    moon_fissure="default",
    moon_fruitdragon="default",
    moon_hotspring="default",
    moon_rock="default",
    moon_sapling="default",
    moon_spider="default",
    moon_spiders="default",
    moon_starfish="default",
    moon_tree="default",
    moon_tree_regrowth="default",
    mosquitos="default",
    mushroom="default",
    mutated_hounds="default",
    no_joining_islands=true,
    no_wormholes_to_disconnected_tiles=true,
    ocean_bullkelp="default",
    ocean_seastack="ocean_default",
    ocean_shoal="default",
    ocean_waterplant="ocean_default",
    ocean_wobsterden="default",
    penguins="default",
    penguins_moon="default",
    perd="default",
    petrification="default",
    pigs="default",
    pigs_setting="default",
    ponds="default",
    prefabswaps_start="default",
    rabbits="default",
    rabbits_setting="default",
    reeds="default",
    regrowth="default",
    roads="default",
    rock="default",
    rock_ice="default",
    saltstack_regrowth="default",
    sapling="default",
    season_start="default",
    seasonalstartingitems="default",
    shadowcreatures="default",
    sharks="default",
    spawnprotection="default",
    specialevent="default",
    spider_warriors="default",
    spiderqueen="default",
    spiders="default",
    spiders_setting="default",
    spring="default",
    squid="default",
    start_location="default",
    summer="default",
    tallbirds="default",
    task_set="default",
    tentacles="default",
    touchstone="default",
    trees="default",
    tumbleweed="default",
    twiggytrees_regrowth="default",
    walrus="default",
    walrus_setting="default",
    wasps="default",
    weather="default",
    wildfires="default",
    winter="default",
    wobsters="default",
    world_size="default",
    wormhole_prefab="wormhole" 
  },
  random_set_pieces={
    "Sculptures_2",
    "Sculptures_3",
    "Sculptures_4",
    "Sculptures_5",
    "Chessy_1",
    "Chessy_2",
    "Chessy_3",
    "Chessy_4",
    "Chessy_5",
    "Chessy_6",
    "Maxwell1",
    "Maxwell2",
    "Maxwell3",
    "Maxwell4",
    "Maxwell6",
    "Maxwell7",
    "Warzone_1",
    "Warzone_2",
    "Warzone_3" 
  },
  required_prefabs={ "multiplayer_portal" },
  required_setpieces={ "Sculptures_1", "Maxwell5" },
  settings_desc="标准《饥荒》体验。",
  settings_id="SURVIVAL_TOGETHER",
  settings_name="标准森林",
  substitutes={  },
  version=4,
  worldgen_desc="标准《饥荒》体验。",
  worldgen_id="SURVIVAL_TOGETHER",
  worldgen_name="标准森林" 
}
	" > $HOME/.klei/DoNotStarveTogether/World1/Master/leveldataoverride.lua

	read -p "请输入你的主机令牌：" token
	
	sed -i 's/token/'${token}'/' $HOME/.klei/DoNotStarveTogether/World1/cluster_token.txt
	waiting
	echo -e "${info} 地上世界存档初始化完成。。。"
}

waiting(){
    i=0
    str=""
    label=('|' '/' '-' '\\')
    index=0
    while [ $i -le 50 ]
    do
        let index=i%4
        let jinshu=$i*2
        printf "\e[47m\e[31m[%-50s]\e[0m\e[47;32m[%c]\e[1;0m\e[47;35m[%-3d%%]\e[1;0m\r" $str ${label[$index]} $jinshu
        let i++
        str+="#"
        sleep 0.1
    done
    echo

} 

####检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	
#处理ca证书
	if [[ "${release}" == "centos" ]]; then
		yum install ca-certificates -y
		update-ca-trust force-enable
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		sudo apt-get install ca-certificates -y
		sudo update-ca-certificates
	fi	
}
###检查Linux版本
check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

start_menu(){
clear
echo && echo -e " 基于腾讯云轻量服务器搭建饥荒服务器的一键脚本 ${Red_font_prefix}[v1.0.1]${Font_color_suffix}
  

————————————安装选项————————————
 ${Green_font_prefix}1.${Font_color_suffix} 下载steamCMD并安装DST服务端
 ${Green_font_prefix}2.${Font_color_suffix} 更新DST服务端 
 ${Green_font_prefix}3.${Font_color_suffix} 启动地上世界
 ${Green_font_prefix}4.${Font_color_suffix} 启动洞穴世界
 ${Green_font_prefix}5.${Font_color_suffix} 创建地上世界初始化存档${Red_font_prefix}（仅适用于地上和洞穴分服务器搭建）${Font_color_suffix}
 
 ${Green_font_prefix}6.${Font_color_suffix} 退出脚本
————————————————————————————————" && echo

read -p " 请输入数字 :" num
case "$num" in
	1)
	npmInstall
	installSteamCMD
	installDSTServer
	echo -e "${Tip} DST服务端安装安装完毕，请将存档放在 ${Red_font_prefix}$HOME/.klei/DoNotStarveTogether${Font_color_suffix} 路径下, 且存档文件夹名字必须是 ${Red_font_prefix}World1${Font_color_suffix}"
	;;
	2)
	updateDSTServer
	;;	
	3)
	stratMaster
	;;
	4)
	stratCaves
	;;
	5)
	initFileMaster
	;;
	6)
	exit 1
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-5]"
	sleep 5s
	start_menu
	;;
esac
}
#############系统检测组件#############
check_sys
check_version
[[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "本脚本不支持当前系统 ${release} !" && exit 1
start_menu
