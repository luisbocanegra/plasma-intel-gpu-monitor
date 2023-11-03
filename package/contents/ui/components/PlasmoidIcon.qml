import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.1
import org.kde.plasma.workspace.components 2.0 as WorkspaceComponents
import "."

Item {
    id: root
    anchors.centerIn: parent
    property var source
    PlasmaCore.SvgItem {
        id: svgItem
        opacity: 1
        width: parent.width
        height: width
        property int sourceIndex: 0
        anchors.centerIn: parent
        smooth: true
        svg: PlasmaCore.Svg {
            id: svg
            colorGroup: PlasmaCore.ColorScope.colorGroup
            imagePath: Qt.resolvedUrl("../../icons/" + source)
        }
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
