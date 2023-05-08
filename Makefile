OUT_ZIP=Manjaro-wsl2.zip
WSLDL_ZIP=icons.zip
WSLDL_URL=https://github.com/yuk7/wsldl/releases/download/22020900/$(WSLDL_ZIP)
WSLDL_EXE=Manjaro.exe

all: $(OUT_ZIP)

zip: $(OUT_ZIP)

$(OUT_ZIP): ziproot
	@echo -e 'Building $(OUT_ZIP)...'
	cd ziproot; bsdtar -a -cf ../$(OUT_ZIP) *

ziproot: $(WSLDL_EXE) rootfs.tar.gz
	@echo -e 'Building ziproot...'
	mkdir ziproot
	cp $(WSLDL_EXE) ziproot/
	cp rootfs.tar.gz ziproot

$(WSLDL_EXE): $(WSLDL_ZIP)
	@echo -e 'Extracting wsldl exe...'
	unzip $(WSLDL_ZIP) $(WSLDL_EXE)

$(WSLDL_ZIP):
	@echo -e 'Downloading $(WSLDL_ZIP)...'
	curl -L $(WSLDL_URL) -o $(WSLDL_ZIP)

rootfs.tar.gz: rootfs
	@echo -e 'Building rootfs.tar.gz...'
	cd rootfs; sudo bsdtar -zcpf ../rootfs.tar.gz `sudo ls`
	sudo chown `id -un` rootfs.tar.gz

rootfs: base.tar
	@echo -e 'Building rootfs...'
	mkdir rootfs
	sudo bsdtar -zxpf base.tar -C rootfs
	sudo cp bash_profile rootfs/root/.bash_profile
	sudo cp wsl.conf rootfs/etc/wsl.conf
	sudo chmod +x rootfs

base.tar:
	@echo -e 'Exporting base.tar using docker...'
	docker build . -t manjarolinux/wsl:latest
	docker run --name manjarolinux manjarolinux/wsl:latest echo > /dev/null 2>&1
	docker export --output base.tar manjarolinux > /dev/null 2>&1
	docker rm -f manjarolinux > /dev/null 2>&1

clean:
	@echo -e 'Cleaning files...'
	-rm ${OUT_ZIP} > /dev/null 2>&1
	-rm -r ziproot > /dev/null 2>&1
	-rm $(WSLDL_EXE) > /dev/null 2>&1
	-rm $(WSLDL_ZIP) > /dev/null 2>&1
	-rm rootfs.tar.gz > /dev/null 2>&1
	-rm base.tar > /dev/null 2>&1
	-docker rmi -f manjarolinux/wsl:latest > /dev/null 2>&1
	-sudo rm -r rootfs > /dev/null 2>&1
