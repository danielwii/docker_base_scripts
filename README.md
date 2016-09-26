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

- Add repo to /init

    RUN git clone https://github.com/danielwii/docker_base_scripts.git /init

- Add your custom program config to /init/conf

    ADD supervisor.app.conf /init/conf/

- Start with default supervisor config, all files defined in env will be download.

    CMD ["supervisord", "-c", "/init/supervisord.conf"]
