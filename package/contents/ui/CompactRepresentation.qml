import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "components" as Components

Item {
    id: compact
    anchors.fill: parent
    property bool isPanelVertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    property real itemSize: Math.min(compact.height, compact.width)

    property var engineIcon
    property color badgeColor
    property var usageNow


    Item {
        id: container
        height: compact.itemSize
        width: compact.width
        anchors.centerIn: parent

        Components.PlasmoidIcon {
            id: plasmoidIcon
            height: Kirigami.Units.iconSizes.roundedIconSize(Math.min(parent.width, parent.height))
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
            width: Math.min(parseInt(icon.height / 2.5) , 10)
            height: width
            radius: width / 2
            opacity: 1
            border.width: 1
            border.color: Kirigami.Theme.backgroundColor //PlasmaCore.ColorScope.backgroundColor
            smooth: true
        }
    }

}
