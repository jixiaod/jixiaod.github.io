---
title: Kong 集群配置
date: 2016-08-01 15:27:53
tags:
    - kong
categories:
    - Nginx
---

### 先了解下几个 Kong 的关于集群的配置

- cluster_listen: "0.0.0.0:7946"
    - 跟集群中其他 Kong 节点通讯的 IP 地址和端口，使用 UDP 和 TCP 协议。所有集群中的节点都必须能够跟这个节点的这个地址进行通讯。只有 IPv4 地址是被允许的（不支持域名）。
- cluster_listen_rpc: "127.0.0.1:7373"
    - 节点用于本地集群代理通讯的 IP 地址和端口（只能是TCP，且只能在本地）。
    - 只能在这个 Kong 节点内部使用。只支持 IPv4 地址（不支持域名）。
- cluster
    - advertise: ""
        - 跟集群中其他 Kong 节点通讯的 IP 地址和端口，使用 UDP 和 TCP 协议。所有集群中的节点都必须能够跟这个节点的这个地址进行通讯。只有 IPv4 地址是被允许的（不支持域名）。
        - 只支持 IPv4 地址（不支持域名）。
        - advertise 配置项用来指定集群中其他节点跟该节点的通讯地址。默认情况下，跟其他节点通讯的地址就是 cluster_listen 的配置。如果cluster_listen 的 host 地址是 “0.0.0.0”，则得到的第一个本地的、无回路的 IPv4 地址就是跟其他节点通讯的地址。然后，在某些情况下（在通过有 NAT 网络地址转换时），或许有能够被网络路由到的地址，却不能被 Kong 集群中不能与其他节点通讯的情况。这时，advertise 配置的 IP 地址 能够解决这个问题。
    - encrypt: "foo"
        - Kong 网络传输加密的 key。必须是 base64 的16位 key 值。
    - ttl_on_failure: 3600
        - TTL (time to live)， 单位是秒，当集群中的一个节点因为故障，停止向发送心跳的 ping 检查。如果在这个配置的周期内，节点一直不能发送心跳检查，那么新加入到集群中的节点启动时，将会停止尝试连接它。这个配置的最小值是 60。

### Kong 集群配置

结合上问配置说明和Kong集群介绍，大概应该了解：配置在同一网断内的 Kong 集群，只需要把所有节点的数据存储配置到同一个数据库即可。节点会根据数据库中存储的节点信息，去自动做互相的通信。如何配置数据存储可参考 [Kong 安装与配置](http://blog.100dos.com/2016/07/25/the-installation-and-configuration-of-kong/)。

成功启动新的 Kong 节点，可以在这三个节点都能通过命令查看现在集群的状态

```
tiger➜~» kong cluster members                                                                                         [16:59:45]
[INFO] Using configuration: /etc/kong/kong.yml
tigerdeMacBook-Pro.local_0.0.0.0:7946_8add5ecc222c486ab6caadadf35afbfa  192.168.20.156:7946  alive
v194_0.0.0.0:7946_f8b6daf71a9f4906993ad1cc3f1ca6a2                      192.168.1.194:7946   alive
v5_0.0.0.0:7946_1da4f4fbcd2d467a8799ae1c7e056771                        192.168.1.75:7946    alive

[root@v5 ~]# /usr/local/bin/kong cluster members
[INFO] Using configuration: /etc/kong/kong.yml
v5_0.0.0.0:7946_1da4f4fbcd2d467a8799ae1c7e056771                        192.168.1.75:7946    alive
v194_0.0.0.0:7946_f8b6daf71a9f4906993ad1cc3f1ca6a2                      192.168.1.194:7946   alive
tigerdeMacBook-Pro.local_0.0.0.0:7946_8add5ecc222c486ab6caadadf35afbfa  192.168.20.156:7946  alive

[lan_dev@v194 ~]$ kong cluster members
[INFO] Using configuration: /etc/kong/kong.yml
v194_0.0.0.0:7946_f8b6daf71a9f4906993ad1cc3f1ca6a2                      192.168.1.194:7946   alive
tigerdeMacBook-Pro.local_0.0.0.0:7946_8add5ecc222c486ab6caadadf35afbfa  192.168.20.156:7946  alive
v5_0.0.0.0:7946_1da4f4fbcd2d467a8799ae1c7e056771                        192.168.1.75:7946    alive
```

能看到现在集群中已经有俩个状态是 alive 的节点。

如果夸多个机房的配置，一种方法是使用VPN，这样同样可以保证所有节点在同一网断下。或者是显示的配置 advertise 项指明节点去与哪个地址通讯。比如指定这三台服务器都去跟其中一个节点的地址去通信：

```
advertise: "192.168.1.75:7946"
```

同样启动 3 个节点，注意启动信息里会有这一行

[INFO] serf ..............-profile=wan -rpc-addr=127.0.0.1:7373 -event-handler=member-join,member-leave,member-failed,member-update,member-reap,user:kong=/usr/local/kong/serf_event.sh -bind=0.0.0.0:7946 -advertise=192.168.1.75:7946 -node=v194_0.0.0.0:7946_f8b6daf71a9f4906993ad1cc3f1ca6a2 -log-level=err

其中指明了 advertise=192.168.1.75:7946，通过该地址通讯。

同样可以在三台节点使用命令查看集群状态

```
[lan_dev@v194 ~]$ kong cluster members
[INFO] Using configuration: /etc/kong/kong.yml
v194_0.0.0.0:7946_f8b6daf71a9f4906993ad1cc3f1ca6a2                      192.168.1.75:7946  alive
v5_0.0.0.0:7946_1da4f4fbcd2d467a8799ae1c7e056771                        192.168.1.75:7946  alive
tigerdeMacBook-Pro.local_0.0.0.0:7946_8add5ecc222c486ab6caadadf35afbfa  192.168.1.75:7946  alive

[root@v5 ~]# /usr/local/bin/kong cluster members
[INFO] Using configuration: /etc/kong/kong.yml
tigerdeMacBook-Pro.local_0.0.0.0:7946_8add5ecc222c486ab6caadadf35afbfa  192.168.1.75:7946  alive
v194_0.0.0.0:7946_f8b6daf71a9f4906993ad1cc3f1ca6a2                      192.168.1.75:7946  alive
v5_0.0.0.0:7946_1da4f4fbcd2d467a8799ae1c7e056771                        192.168.1.75:7946  alive

tiger➜~» kong cluster members                                                                                                                                                                          [17:32:07]
[INFO] Using configuration: /etc/kong/kong.yml
tigerdeMacBook-Pro.local_0.0.0.0:7946_8add5ecc222c486ab6caadadf35afbfa  192.168.1.75:7946  alive
v5_0.0.0.0:7946_1da4f4fbcd2d467a8799ae1c7e056771                        192.168.1.75:7946  alive
v194_0.0.0.0:7946_f8b6daf71a9f4906993ad1cc3f1ca6a2                      192.168.1.75:7946  alive
```

