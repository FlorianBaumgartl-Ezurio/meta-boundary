# Solsta: Hardware Pioneers (Demo).
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://solsta-hardware-pioneers-demo.sh \
    file://solsta-hardware-pioneers-demo.service \
    file://ezurio-nitrogen95-smarc-highlights.mp4 \
"

inherit systemd

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "solsta-hardware-pioneers-demo.service"

RDEPENDS:${PN} += "bash coreutils evtest gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good"

do_install() {
    install -d ${D}/home/weston
    install -m 0755 ${WORKDIR}/solsta-hardware-pioneers-demo.sh \
        ${D}/home/weston/solsta-hardware-pioneers-demo.sh

    install -m 0644 ${WORKDIR}/ezurio-nitrogen95-smarc-highlights.mp4 \
        ${D}/home/weston/ezurio-nitrogen95-smarc-highlights.mp4

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/solsta-hardware-pioneers-demo.service \
        ${D}${systemd_system_unitdir}/solsta-hardware-pioneers-demo.service
}

FILES:${PN} += " \
    /home/weston/solsta-hardware-pioneers-demo.sh \
    /home/weston/ezurio-nitrogen95-smarc-highlights.mp4 \
    ${systemd_system_unitdir}/solsta-hardware-pioneers-demo.service \
"
