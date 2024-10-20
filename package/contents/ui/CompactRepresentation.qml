import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.components as WorkspaceComponents
import "components" as Components

Loader {
    id: compactRoot

    property var engineIcon
    property color badgeColor
    property var currentUsage

    readonly property bool vertical: (Plasmoid.formFactor == PlasmaCore.Types.Vertical)
    // 0: disable, 1: badge, 2: beside icon
    readonly property int showUsageMode: Plasmoid.configuration.showUsageMode
    // 0: percentage, 1: color
    readonly property int badgeStyle: Plasmoid.configuration.badgeStyle
    // 0: current engine, 1: total (rc6)
    readonly property int usageSource: Plasmoid.configuration.usageSource
    readonly property bool useBadge: showUsageMode === 1 || Plasmoid.configuration.needsToBeSquare

    sourceComponent: (showUsageMode !== 0 && !useBadge) ? iconAndTextComponent : iconComponent
    // sourceComponent: iconComponent
    Layout.fillWidth: compactRoot.vertical
    Layout.fillHeight: !compactRoot.vertical
    Layout.minimumWidth: item.Layout.minimumWidth
    Layout.minimumHeight: item.Layout.minimumHeight

    MouseArea {
        id: compactMouseArea
        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            main.expanded = !main.expanded
        }
    }

    Component {
        id: iconComponent

        Kirigami.Icon {
            id: plasmoidIcon
            readonly property int minIconSize: Math.max((compactRoot.vertical ? compactRoot.width : compactRoot.height), Kirigami.Units.iconSizes.small)

            source: Plasmoid.icon
            active: compactMouseArea.containsMouse
            // reset implicit size, so layout in free dimension does not stop at the default one
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            Layout.minimumWidth: compactRoot.vertical ? Kirigami.Units.iconSizes.small : minIconSize
            Layout.minimumHeight: compactRoot.vertical ? minIconSize : Kirigami.Units.iconSizes.small

            WorkspaceComponents.BadgeOverlay {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                visible: showUsageMode === 1 && badgeStyle === 0
                text: parseInt(currentUsage) + "%"
                icon: parent
            }

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(plasmoidIcon.width, plasmoidIcon.height) * 0.7
                height: width
                color: "transparent"
                Rectangle {
                    anchors {
                        horizontalCenter: parent.right
                        verticalCenter: parent.bottom
                    }
                    visible: showUsageMode === 1 && badgeStyle === 1
                    
                    property Item icon: plasmoidIcon
                    property real scaling: 1
                    color: badgeColor
                    width: Math.min(parseInt(icon.height / 2.5) , 10)
                    height: width
                    radius: width / 2
                    opacity: 1
                    border.width: 1
                    border.color: Kirigami.Theme.backgroundColor
                    smooth: true
                }
            }
        }
    }

    Component {
        id: iconAndTextComponent

        IconAndTextItem {
            vertical: compactRoot.vertical
            iconSource: Plasmoid.icon
            active: compactMouseArea.containsMouse
            text: parseInt(currentUsage) + "%"
        }
    }
}
