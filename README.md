## quick start
```
# 配置 files/hadoopHost.txt  ansible_host.txt
ansible-playbook -i ansible_host.txt -e ambari_server=ambari.hdprepo.com -e hadoop=datanode deploy_ambari.yml --tags=config_etc_hosts
ansible-playbook -i ansible_host.txt -e ambari_server=ambari.hdprepo.com -e hadoop=datanode deploy_ambari.yml --tags=ready_init
ansible-playbook -i ansible_host.txt -e ambari_server=ambari01.bigdata.rc.com -e hadoop=datanode deploy_ambari.yml --tags=deploy_java

ambari-server start

```

## 部署组件版本说明
```
ambari 2.7.3.0
HDFS  3.1.0
YARN  3.1.0
MapReduce2  3.0.0.3.0
Tez   0.9.0.3.0
Hive  3.0.0.3.0
Pig   0.16.1.3.0
Sqoop  1.4.7
ZooKeeper  3.4.9.3.0
Ambari Metrics 0.1.0
SmartSense  1.5.1.2.7.3.0-139
Spark2  2.3.0
HDP-3.0.0.0   (3.0.0.0-1634)
````

## 1 创建数据库dba
提供以下sql语句给dba创建，dba完成后返回数据库主机等访问信息
```
  create database ambari default character set utf8;
  grant all on ambari.* to ambari@localhost identified by 'Bigdata_123';
  grant all on ambari.* to ambari@'%' identified by 'Bigdata_123';
  create database hive default character set utf8;
  grant all on hive.* to hive@localhost identified by 'Hive_123';
  grant all on hive.* to hive@'%' identified by 'Hive_123';
```

## 2 安装ansible
在ambari-server 主机上，安装ansible，并配置资产
做免密登陆，ambari-server 公钥分发到集群各个节点
目标ambari-server 使用私key，各个节点使用公key就能通信。
```
# ambari server节点部署
yum install -y ansible
cd ./files && nohup python3 -m http.server 12345 & 
vi ansible_host.txt

# 使用提供自动化工具操作，登陆各个节点操作
httpHost=10.74.101.6:12345
curl -sfL ${httpHost}/init_ssh.sh | bash -
```

## 3 配置files目录 hadoopHosts
hadoop 根据域名通信，必须配置, 会分发到/etc/hosts各个节点
注意 ambari.hdprepo.com，已固化，需安装在ambari-server主机上，部署namenode节点上
```
vi hadopHost.txt
# 如果不配置，使用默认变量。
vi vars.yml
```

## 4 运行playbooks 部署 ambari 
```
ansible-playbook -i ansible_hosts.txt -e ambari_server=ambari.hdprepo.com -e hadoop=hadoop deploy_ambari.yml
```

## 5 启动ambari setup 配置
```
ambari-server setup
```

## 6 创建ambari db库，跑sql 工具
ambari setup 配置完成，会生成数据库ddl sql语句
```
bash init_ambari_db_sql.sh
```

## 7 启动ambari start 完成页面化安装hadoop组件
```
ambari-server  start
```


## 异常提供工具处理
### 临时处理repo仓库异常问题
如果repo 仓库有异常，请使用工具清理repo
```
bash clear_repo_and_rebuild
```

## 查询 ambari 页面配置 repo 在数据库字段
```
# 查询 repo 字段
bash update_repo_definition_sql.sh query
# 更新 repo 字段
bash update_repo_definition_sql.sh update
```

