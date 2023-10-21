import QtQuick 2.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

import "components" as Components
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kquickcontrols 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

ColumnLayout {
    id: root
    Layout.minimumWidth: PlasmaCore.Units.gridUnit * 19
    Layout.minimumHeight: PlasmaCore.Units.gridUnit * 19
    Layout.preferredWidth: rootRep.width
    Layout.preferredHeight: rootRep.height

    property bool autoHide: true

    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating
    property bool plasmoidExpanded: plasmoid.expanded
    property bool autoReloadEnabled: onDesktop || plasmoidExpanded
    property var dividerColor: Kirigami.Theme.textColor
    property var dividerOpacity: 0.1

    property var busyList;

    function truncateString(str, n) {
        if (str.length > n) {
            return str.slice(0, n) + "...";
        } else {
            return str;
        }
    }

    PlasmaExtras.Representation {
        collapseMarginsHint: true
        id: rootRep

        Layout.fillWidth: true
        Layout.fillHeight: true

        header: PlasmaExtras.PlasmoidHeading {
            id:heading
            visible: !(plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentDrawsPlasmoidHeading)

            leftPadding: PlasmaCore.Units.smallSpacing

            RowLayout {
                anchors.fill: parent

                PlasmaExtras.Heading {
                    Layout.fillWidth: true
                    level: 1
                    text: Plasmoid.metaData.name
                }

                PlasmaComponents3.ToolButton {
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    visible: !onDesktop
                    icon.name: 'configure'
                    text: Plasmoid.action("configure").text

                    onClicked: {
                        plasmoid.action("configure").trigger()
                    }

                    PlasmaComponents3.ToolTip {
                        text: parent.text
                    }
                }

                PlasmaComponents3.ToolButton {
                    display: PlasmaComponents3.AbstractButton.IconOnly

                    visible: !onDesktop

                    icon.name: 'pin'

                    text: i18n("Keep Open")

                    checked: !autoHide

                    onClicked: {
                        autoHide = !autoHide
                        plasmoid.hideOnWindowDeactivate = autoHide
                    }

                    PlasmaComponents3.ToolTip {
                        text: parent.text
                    }
                }
            }
        }

        ColumnLayout {
            id: rootContent
            anchors.fill: parent

            RowLayout {

                Item { implicitWidth: PlasmaCore.Units.gridUnit / 2}
                PlasmaComponents3.Label {
                    text: "Files are still being transferred...";
                    opacity: .7
                }
            }

            PlasmaComponents3.ScrollView {
                id: scrollView
                Layout.fillHeight: true
                Layout.fillWidth: true

                topPadding: PlasmaCore.Units.smallSpacing
                bottomPadding: PlasmaCore.Units.smallSpacing

                PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff
                PlasmaComponents3.ScrollBar.vertical.policy: PlasmaComponents3.ScrollBar.AsNeeded

                contentWidth: availableWidth - contentItem.leftMargin - contentItem.rightMargin

                contentItem: ListView {
                    id: listView
                    // reserve space for the scrollbar
                    property var sideMargin: PlasmaCore.Units.smallSpacing +
                                            scrollView.ScrollBar.vertical.width

                    leftMargin: sideMargin - (scrollView.ScrollBar.vertical.visible ?
                                            scrollView.ScrollBar.vertical.width : 0)
                    rightMargin: sideMargin
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    model: busyList
                    // width: rootContent.width

                    delegate: ColumnLayout {
                        id: mainLayout
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Rectangle {
                            Layout.preferredWidth: mainLayout.width
                            height: 1
                            color: dividerColor
                            opacity: dividerOpacity
                        }

                        RowLayout {
                            Layout.preferredWidth: mainLayout.width
                            ColumnLayout {
                                PlasmaComponents3.Label {
                                    text: truncateString(modelData.deviceName,30);
                                    opacity: 1
                                }
                                PlasmaComponents3.Label {
                                    text: truncateString(modelData.blockName,30);
                                    opacity: .7
                                }
                            }
                            Item { Layout.fillWidth: true }
                            PlasmaComponents3.Label {
                                text: "In flight: " + modelData.inFlight;
                                opacity: .7
                                //color: Kirigami.Theme.neutralTextColor
                            }
                        }
                    }
                }
            }
        }
    }
}
