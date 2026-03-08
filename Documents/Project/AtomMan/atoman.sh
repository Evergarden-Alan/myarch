sudo mkdir -p /opt/atomman
sudo cp screen.py /opt/atomman/

sudo cp atomman.service /etc/systemd/system/

# 重新加载配置文件
sudo systemctl daemon-reload

# 重启服务
sudo systemctl restart atomman.service

# 查看状态
systemctl status atomman.service
