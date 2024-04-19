在开始阅读这篇教程之前，我们假设你已经拥有了一个AWS(Amazon Web Services)的账户，如果熟悉一些基础操作会更好。

想要在亚马逊云上启动一个开启了AMD SEV-SNP保护的服务器，必须要使用他们提供的命令行接口。控制面板创建实例的部分没有开启加密保护的选项（咨询工作人员的结果：“没看到那可能确实没有吧”）

#### AWS CLI

如果你还没有下载aws-cli（AWS Command-Line-Interface），请参照这个连接：[安装或更新 AWS CLI 的最新版本 - AWS Command Line Interface (amazon.com)](https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/getting-started-install.html)

尽量下载较新的版本，老旧的版本会无法识别我们的启动命令。

安装好后，请依照这个连接的设置对账户进行配置，以便与AWS进行交互： [设置 AWS CLI - AWS Command Line Interface (amazon.com)](https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/getting-started-quickstart.html)

特别的，在配置账户的过程中，请将地区配置为美国东部（俄亥俄州）或者欧洲地区（爱尔兰）区域。这是仅有的两个支持创建带有AMD SEV-SNP加密保护的区域。

相应的区域代码为：

```
美国东部（俄亥俄州）: us-east-2
欧洲地区（爱尔兰）: eu-west-2
```

配置完成后，尝试使用如下命令

```
aws ec2 describe-instance-types \
--filters Name=processor-info.supported-features,Values=amd-sev-snp \
--query 'InstanceTypes[*].InstanceType'
```

此命令返回当前所有支持AMD SEV-SNP的实例类型

```
[
    "r6a.2xlarge", 
    "m6a.large", 
    "m6a.2xlarge", 
    "r6a.xlarge", 
    "c6a.16xlarge", 
    "c6a.8xlarge", 
    "m6a.4xlarge", 
    "c6a.12xlarge", 
    "r6a.4xlarge", 
    "c6a.xlarge", 
    "c6a.4xlarge", 
    "c6a.2xlarge", 
    "m6a.xlarge", 
    "c6a.large", 
    "r6a.large", 
    "m6a.8xlarge"
]
```

关于这些实例的详细信息可以在AWS的官网中查阅到

[实例类型 - Amazon Elastic Compute Cloud](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/instance-types.html#instance-type-names)

除此之外，在官网控制台的创建实例区域，也可以直接查询到实例的相关信息

我个人偏好使用第二种方式，除开实例类型之外，后续配置中有许多需要用到的信息也可以在创建实例的面板处十分方便的查询。

#### Start one Server

接下来，我们尝试使用命令行启动一个开启了 AMD SEV-SNP保护的服务器实例。

```
aws ec2 run-instances \
--image-id supported_ami_id \
--instance-type supported_instance_type \
--key-name key_pair_name \
--subnet-id subnet_id \
--cpu-options AmdSevSnp=enabled
```

这是一个由AWS提供的创建命令范例。我们逐行解释并配置其中的每一个选项

```
aws ec2 run-instances
```

**aws** 是命令的标准开头，**ec2**  代表我们要启动的是一个服务器， **run-instances** 代表我们要启动并运行一个实例。

这行命令中的前两个参数基本不会变动，第三个参数可替代选项包括

```
describe-instances		描述实例信息
stop-instances			暂停实例运行
start-instances			开启实例运行
terminate-instances		终止实例并回收全部资源
```

值得注意的是，AMD SEV-SNP只能在启动实例的时候开启。如果在启动实例的时候开启了该选项，他将在实例的整个生命周期内保持开启状态。在开启的时候不支持休眠和Nitro Enclaves。

这意味着 **stop-instances** 和 **start-instances** 基本用不到，你需要做的只有启动和删除 ：）

```
--image-id supported_ami_id
```

这里指定了所用的操作系统镜像。支持AMD SEV-SNP的只有 Amazon Linux 2023 和 Ubuntu 23.04两个，且后者尚未有通过了AWS审查的版本，只能在社区中找（控制台-创建实例-Application and OS Images 选择镜像的右边有一个 Browse more AMIs）。不过找到了也用不了，因为没有支持该镜像的实例。

在 控制台-创建实例-Application and OS Images 处选择镜像和架构，架构选项右边的AMI ID即为此处需要填入的ID。

```
--instance-type supported_instance_type
```

此处指定创建的镜像实例。此处所能选择的实例均在上文有所提及。值得一提的是，在 控制台-创建实例-Instance type 处可以看到该实例的费用。开启AMD SEV-SNP会有额外百分之十的开销。

不过我想在获得账号前应该就有人和你强调这一点了。

```
--key-name key_pair_name
```

此处用于指定密钥组，以完成登录。如果此时你尚未有一个，可以在 控制台-创建实例-Key pair (login) 处生成一个新的，随后他会给你一个pem文件，用于后续使用命令行登录实例时的身份认证。

或者也可以在 控制台-Network & Security- Key Pairs 处生成并进行管理

```
--subnet-id subnet_id
```

此处指定子网组和防火墙规则，在创建实例的地方似乎不能创建安全组，只能查看并选择已有的安全组。如果需要创建或修改防火墙规则，请在 控制台-Network & Security- Security Groups 处进行。该处同样可以查看安全组的编号。

```
--cpu-options AmdSevSnp=enabled
```

这一选项指示开启加密保护。删除这个选项或者将**enabled**修改为**disabled**均可选择不开启加密保护。

到此即可完成一个创建的命令了。在 控制台-Launch Instances-Configure storage 处可以配置服务器存储大小，不过我在使用的过程中没有涉及。控制台-Launch Instances-Advanced details 处有一个Nitro Enclaves 选项，这个是亚马逊自研的TEE，不是我们需要的。

使用该命令创建实例成功后，会返回一个json格式的数据，指示该实例的相关信息。在其中搜索 **CpuOptions** 选项，可在其中看到 **AmdSevSnp:enabled** 。除此之外，登录到远程服务器中，查看相关日志也可以看到类似信息。

至于在主机上试图查看虚拟机内存。我不太确定亚马逊会不会给这方面的权限或者接口。

#### Cloud Deployment

我在这里提供一个简单的脚本，用于演示大规模部署时所可能用到的部分内容

```shell
#!/bin/bash

# 节点主机的配置
IMAGE_ID=ami-069d73f3235b535bd          #   选择的镜像，此处为 Amazon Linux 2023
USER=ec2-user                           #   亚马逊Linux默认用户为ec2-user
INSTANCE_TYPE=m6a.xlarge                #   节点选择的实例
KEY_NAME=tex                            #   密钥组
KEY_FILE=tex.pem                        #   密钥文件
SUBNET_ID=subnet-008f3181aceb024ed      #   子网组，决定分配的IP地址
SECURITY=sg-0491bfb2d28087f26           #   安全分组，决定防火墙规则

# 选择是否开启加密保护并部署节点
deploy_function() {
    local enable=$1
    local num=$2

    new_instance_info=$(aws ec2 run-instances \
        --image-id $IMAGE_ID \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --subnet-id $SUBNET_ID \
        --security-group-ids $SECURITY \
        --associate-public-ip-address \
        --count $num \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=\"TEX-instance\"}]" \
        --cpu-options AmdSevSnp=$enable \
        --output json)
    echo $new_instance_info > createResult.json

    # 上述代码中的 --count 参数指定启动节点的数目
    # --tag-specifications 参数为开启的节点添加标签，便于后续查询信息

    # 等待一段时间，使得所有节点完成初始启动
    # 不然获取到的实例ID和IP地址可能有缺损
    sleep 30

    # 获取到所有节点的公网IP地址， 用于后续访问各个节点
    public_ip=$(aws ec2 describe-instances   \
            --filters "Name=tag:Name,Values=TEX-instance" "Name=instance-state-name,Values=running" \
            --query "Reservations[*].Instances[*].PublicIpAddress"   \
            --output=text)
    public_ip_arr=(`echo $public_ip | tr ',' ' '`)
    echo "${public_ip_arr[@]}" > public_ip.txt

    # 获取到所有节点的内网IP地址，用于节点间互相通信
    private_ip=$(aws ec2 describe-instances   \
            --filters "Name=tag:Name,Values=TEX-instance" "Name=instance-state-name,Values=running" \
            --query "Reservations[*].Instances[*].PrivateIpAddress"   \
            --output=text)
    private_ip_arr=(`echo $private_ip | tr ',' ' '`)
    echo "${private_ip_arr[@]}" > private_ip.txt

    # 获取到所有节点的实例ID，用于删除该实例
    instance_id=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=TEX-instance" "Name=instance-state-name,Values=running" \
            --query "Reservations[*].Instances[*].InstanceId" \
            --output=text)
    instance_id_num=(`echo $instance_id | tr ',' ' '`)
    echo "${instance_id_num[@]}" > instance_id.txt
}

# 终止所有节点
terminate_function() {
    # 读取节点ID
    read -ra instance_ids <<< $(cat instance_id.txt)
    for instance_id in "${instance_ids[@]}"; do
        aws ec2 terminate-instances --instance-ids "$instance_id" >> terminateResult.json &
    done
}

# 将运行程序所需要的文件复制至云端服务器
######################################TODO: 修改test.txt为需要的文件########################################
copy_file_function() {
    read -ra public_ip_addrs <<< $(cat public_ip.txt)
    for public_ip in "${public_ip_addrs[@]}"; do
        scp -i $KEY_FILE -o StrictHostKeyChecking=no\
            test.txt $USER@$public_ip:~ &
    done
    wait
}


if [ "$1" ]; then
    case "$1" in
        --deploy-sev)
            if [ "$2" ]; then
                echo "准备开启 $2 个带有加密保护的节点"
                deploy_function enabled "$2"
            else
                echo "缺少参数。使用说明: $0 --deploy-sev <数值>"
            fi
            ;;
        --deploy)
            if [ "$2" ]; then
                echo "准备开启 $2 个不带有加密保护的节点"
                deploy_function disabled "$2"
            else
                echo "缺少参数。使用说明: $0 --deploy <数值>"
            fi
            ;;
        --terminate)
            terminate_function
            ;;
        --copy-file)
            copy_file_function
            ;;


        --help)
            sh script.sh
            ;;
        *)
            echo "未知参数: $1 请查看使用说明"
            sh script.sh
            ;;
    esac
else
    echo "使用说明: $0"
    echo "--deploy-sev <部署机器数目>  |  部署指定数目的含有加密保护的节点     "
    echo "--deploy     <部署机器数目>  |  部署指定数目的不含有加密保护的节点   "
    echo "--copyfile                  |  将指定文件复制到所有的节点上         "
    echo "--terminate                 |  关闭所有开启了的节点                "
fi
```

需要注意的是，分配到的部分IP在中国境内可能访问不了，这在大规模部署的时候十分常见。这份脚本中不包含面临这种情况时的处理逻辑。

如果你认为配置实例类型，镜像等内容较为麻烦，可以在AWS官网提供的 实例模板（Launch Templates）中配置相关信息，随后在启动命令中使用 **--launch-template LaunchTemplateId=your-template-id** 替代掉原有的配置

#### Remote Attestation

To be continue ... 