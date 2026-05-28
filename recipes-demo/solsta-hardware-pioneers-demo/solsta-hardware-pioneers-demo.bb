SUMMARY = "Solsta Hardware Pioneers demo autostart"
LICENSE = "CLOSED"

SRC_URI = " \
    file://solsta-hardware-pioneers-demo.sh \
    file://solsta-hardware-pioneers-demo.service \
    file://ezurio-nitrogen95-smarc-highlights.mp4 \
"

inherit systemd

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "solsta-hardware-pioneers-demo.service"

RDEPENDS:${PN} += "bash coreutils gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good"

FILES:${PN} += " \
    /home/weston/ezurio-nitrogen95-smarc-highlights.mp4 \
    ${systemd_system_unitdir}/solsta-hardware-pioneers-demo.service \
    ${bindir}/solsta-hardware-pioneers-demo.sh \
"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/solsta-hardware-pioneers-demo.sh \
        ${D}${bindir}/solsta-hardware-pioneers-demo.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/solsta-hardware-pioneers-demo.service \
        ${D}${systemd_system_unitdir}/solsta-hardware-pioneers-demo.service

    install -d ${D}/home/weston
    install -m 0644 \
        ${WORKDIR}/ezurio-nitrogen95-smarc-highlights.mp4 \
        ${D}/home/weston/ezurio-nitrogen95-smarc-highlights.mp4
}
