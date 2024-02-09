import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "."

Item {
    id: root
    anchors.centerIn: parent
    property var source
    KSvg.SvgItem {
        id: svgItem
        opacity: 1
        width: parent.width
        height: width
        property int sourceIndex: 0
        anchors.centerIn: parent
        smooth: true
        svg: KSvg.Svg {
            id: svg
            colorSet: Kirigami.Theme.colorSet
            imagePath: Qt.resolvedUrl("../../icons/" + source)
        }
    }

    // Kirigami.Icon {
    //     anchors.centerIn: parent
    //     width: parent.width
    //     height: width
    //     visible: engineIcon != ""
    //     source: engineIcon
    //     smooth: true
    // }
}
