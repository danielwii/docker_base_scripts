## Usage
用于从外部拉去配置文件信息，及控制容器内运行时进程。

### Tips

- Version

脚本内置了通过 VERSION 文件检查线上更新，即在容器启动时会自动检查线上脚本是否有更新。
私有使用建议 fork。

- Init Scripts
初始化脚本，放置于容器内的 /init/scripts 下，该文件夹下的 sh 文件在启动式自动加载。

### Env 环境变量配置

- download private github file 从私有 github 仓库拉去代码


        # private token
        GITHUB_TOKEN
        # org/project/contents/..../file?
        GITHUB_FILE_{index}_SRC
        # /store/file/to
        GITHUB_FILE_{index}_DEST

- download file from url 通过 url 拉取代码


        # http src
        URL_FILE_{index}_SRC
        # dest
        URL_FILE_{index}_DEST

### Dockerfile 容器配置

#### Caerus Script Version 基于 shell 脚本的启动管理

- Add script

        ADD https://raw.githubusercontent.com/danielwii/docker_base_scripts/master/entrypoint.sh /entrypoint.sh
        RUN chmod +x entrypoint.sh
    
- Add custom init scripts to /init/scripts
    
        Add 0.init.sh /init/scripts/
    
- Setup entrypoint

        ENTRYPOINT ["/entrypoint.sh"]

#### Supervisor Version 基于 Supervisor 的启动管理

- Add repo and dependencies to /init

        # ubuntu
        RUN apt-get update && apt-get install -y supervisor curl \
            && rm -rf /var/lib/apt/lists/*
        
        # alpine
        RUN apk --no-cache add supervisor curl bash tar
        
        ADD https://github.com/danielwii/docker_base_scripts/archive/0.1.0.tar.gz /init/archive.tar.gz
        RUN tar zxvf /init/archive.tar.gz -C /init --xform='s|docker_base_scripts-0.1.0||S' --verbose --show-transformed-names
        # RUN git clone --depth=1 https://github.com/danielwii/docker_base_scripts.git /init

- Add init scripts to /init/scripts folder

        Add 0.init.sh /init/scripts/

- Add your custom program config to /init/conf

        ADD supervisor.app.conf /init/conf/

- Start with default supervisor config, all files defined in env will be download.

        CMD ["supervisord", "-c", "/init/supervisord.conf"]
