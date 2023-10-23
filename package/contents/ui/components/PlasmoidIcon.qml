import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.1

Item {
    id: plasmoidIcon
    anchors.centerIn: parent
    property var engineIcon
    PlasmaCore.SvgItem {
        id: svgItem
        opacity: 1
        width: parent.width
        height: width
        property int sourceIndex: 0
        anchors.centerIn: parent
        // visible: engineIcon == ""
        smooth: true
        svg: PlasmaCore.Svg {
            id: svg
            colorGroup: PlasmaCore.ColorScope.colorGroup
            imagePath: Qt.resolvedUrl("../../icons/"+(engineIcon!==undefined?engineIcon:'state-unknown')+".svg")
        }
        // TODO: change those ids to something generic
        // elementId: "22-22-material-you"
    }

    // PlasmaCore.IconItem {
    //     anchors.centerIn: parent
    //     width: parent.width
    //     height: width
    //     visible: engineIcon != ""
    //     source: engineIcon
    //     smooth: true
    // }
}
