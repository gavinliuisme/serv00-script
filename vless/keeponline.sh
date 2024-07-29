pm2_path=$(which /home/$USER/.npm-global/bin/pm2)

process_count=$($pm2_path list | grep "vless" | wc -l)
if [ "$process_count" -gt 1 ]; then
    process_list=$($pm2_path  jlist | jq -r --arg name "vless" '.[] | select(.name == $name) | .pm_id')
    first_process_id=$(echo "$process_list" | head -n 1)
    echo "$process_list" | tail -n +2 | while read -r process_id; do
        $pm2_path delete "$process_id"
    done
    $pm2_path save
    echo "清理多余的vless进程"
fi
status=$($pm2_path  info vless | grep "status" | awk '{print $4}')
if [ "$status" == "" ]; then
    if [[ -f /home/$USER/.pm2/dump.pm2 ]]; then
        $pm2_path  resurrect
        echo "还原vless进程"
    else
        if [[ -f /home/$USER/domains/$USER.serv00.net/vless/app.js ]]; then
            $pm2_path start /home/$USER/domains/$USER.serv00.net/vless/app.js --name vless
            $pm2_path save
        fi
        if [[ -f /home/$USER/domains/$USER.ct8.pl/vless/app.js ]]; then
            $pm2_path start /home/$USER/domains/$USER.ct8.pl/vless/app.js --name vless
            $pm2_path save
        fi
        echo "未检测到pm2 vless快照，启动vless进程...,并保存快照"
    fi
elif [ "$status" != "online" ]; then
    $pm2_path  restart vless
    echo "重启vless进程"
else
    echo "vless进程正常"
fi
