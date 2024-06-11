import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "."

Item {
    id: root
    anchors.centerIn: parent
    property var source
    property var icon: Qt.resolvedUrl("../../icons/" + source).toString().replace("file://", "")

    Kirigami.Icon {
        anchors.centerIn: parent
        width: parent.width
        height: width
        source: icon
        active: compact.containsMouse
        isMask: true
        color: Kirigami.Theme.textColor
    }
}
