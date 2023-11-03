import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.workspace.components 2.0 as WorkspaceComponents
import "components" as Components

Item {
    id: root

    property bool isPanelVertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    property real itemSize: Math.min(root.height, root.width)

    property var engineIcon
    property color badgeColor


    Item {
        id: container
        height: root.itemSize
        width: root.width
        anchors.centerIn: parent

        Components.PlasmoidIcon {
            id: plasmoidIcon
            height: PlasmaCore.Units.roundToIconSize(Math.min(parent.width, parent.height))
            width: height
            source: engineIcon
        }

        Item {
            id: innerRectangle
            width: plasmoidIcon.width * 0.7
            height: plasmoidIcon.height * 0.7
            anchors.centerIn: parent
        }

        Rectangle {
            visible: true
            anchors {
                horizontalCenter: innerRectangle.right
                verticalCenter: innerRectangle.bottom
            }
            // visible: !isPanelVertical
            
            property Item icon: plasmoidIcon
            property real scaling: 1
            color: badgeColor
            width: Math.min(parseInt(icon.height / 2.5) ,PlasmaCore.Units.devicePixelRatio * 10)
            height: width
            radius: width / 2
            opacity: 1
            border.width: 1
            border.color: PlasmaCore.Theme.backgroundColor //PlasmaCore.ColorScope.backgroundColor
            smooth: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: plasmoid.expanded = !plasmoid.expanded
        }
    }

}
