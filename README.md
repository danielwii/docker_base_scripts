## Usage

### Env

- download private github file

        # private token
        GITHUB_TOKEN
        # org/project/contents/..../file?
        GITHUB_FILE_{index}_SRC
        # /store/file/to
        GITHUB_FILE_{index}_DEST

- download file from url

        # http src
        URL_FILE_{index}_SRC
        # dest
        URL_FILE_{index}_DEST

### Dockerfile

- Add repo and dependencies to /init

        # ubuntu
        RUN apt-get update && apt-get install -y supervisor curl \
            && rm -rf /var/lib/apt/lists/*
        
        # alpine
        RUN apk --no-cache add supervisor curl bash tar
        
        ADD https://github.com/danielwii/docker_base_scripts/archive/0.1.0.tar.gz /init/archive.tar.gz
        RUN tar zxvf /init/archive.tar.gz -C /init --xform='s|docker_base_scripts-0.1.0||S' --verbose --show-transformed-names
        # RUN git clone --depth=1 https://github.com/danielwii/docker_base_scripts.git /init

- Add your custom program config to /init/conf

        ADD supervisor.app.conf /init/conf/

- Start with default supervisor config, all files defined in env will be download.

        CMD ["supervisord", "-c", "/init/supervisord.conf"]
