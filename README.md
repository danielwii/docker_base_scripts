## Usage

### Env

- download private github file

    GITHUB_TOKEN				# private token
    GITHUB_FILE_{index}_SRC 	# org/project/contents/..../file?
    GITHUB_FILE_{index}_DEST 	# /store/file/to

- download file from url

    URL_FILE_{index}_SRC 		# http src
    URL_FILE_{index}_DEST 		# dest

### Dockerfile

- Add repo to /init

    RUN git clone https://github.com/danielwii/docker_base_scripts.git /init

- Add your custom program config to /init/conf

    ADD supervisor.app.conf /init/conf/

- Start with default supervisor config, all files defined in env will be download.

    CMD ["supervisord", "-c", "/init/supervisord.conf"]