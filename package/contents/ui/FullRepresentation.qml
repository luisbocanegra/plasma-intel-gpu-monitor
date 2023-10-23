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

    property var usageNow;
    property var clients3d;
    property var clientsVideo;
    property var clientsVideoEnhance;
    property var clientsBlitter;
    property var dividerColor: Kirigami.Theme.textColor;
    property var dividerOpacity: 0.12;


    function truncateString(str, n) {
        if (str.length > n) {
            return str.slice(0, n) + "...";
        } else {
            return str;
        }
    }

    function truncateNumber(number, decimals = 2) {
        var factor = Math.pow(10, decimals);
        return Math.floor(number * factor) / factor;
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

            // RowLayout {
            //     Item { implicitWidth: PlasmaCore.Units.gridUnit / 2}
            //     PlasmaComponents3.Label {
            //         text: "Files are still being transferred...";
            //         opacity: .7
            //     }
            // }

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
                    model: 1
                    // width: rootContent.width

                    delegate: ColumnLayout {
                        id: mainLayout
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Component {
                            id: dividerComponent
                            Item {
                                width: mainLayout.width
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: root.dividerColor
                                    opacity: root.dividerOpacity
                                }
                            }
                        }

                        PlasmaExtras.Heading {
                            level: 3
                            text: "Usage";
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            PlasmaComponents3.Label {
                                text: "Load";
                                opacity: 1
                            }
                            Item { Layout.fillWidth: true }
                            PlasmaComponents3.Label {
                                text: truncateNumber(100-root.usageNow.rc6.value)+' '+root.usageNow.rc6.unit;
                                // opacity: .7
                            }
                        }

                        Loader {
                            sourceComponent: dividerComponent
                        }

                        RowLayout {
                            PlasmaComponents3.Label {
                                text: "Frequency";
                                opacity: 1
                            }
                            Item { Layout.fillWidth: true }
                            PlasmaComponents3.Label {
                                text: truncateNumber(usageNow.frequency.actual)+' '+usageNow.frequency.unit;
                                // opacity: .7
                            }
                        }
                        
                        // ---------------------------------------------------------

                        

                        // ---------------------------------------------------------

                        PlasmaExtras.Heading {
                            level: 3
                            text: "Power";
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            PlasmaComponents3.Label {
                                text: "GPU";
                                opacity: 1
                            }
                            Item { Layout.fillWidth: true }
                            PlasmaComponents3.Label {
                                text: truncateNumber(usageNow.power.GPU)+' '+usageNow.power.unit;
                                // opacity: .7
                            }
                        }

                        Loader {
                            sourceComponent: dividerComponent
                        }

                        RowLayout {
                            PlasmaComponents3.Label {
                                text: "Package";
                                opacity: 1
                            }
                            Item { Layout.fillWidth: true }
                            PlasmaComponents3.Label {
                                text: truncateNumber(usageNow.power.Package)+' '+usageNow.power.unit;
                                // opacity: .7
                            }
                        }
                        

                        PlasmaExtras.Heading {
                            level: 3
                            text: "Engine Utilization";
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // *****************************************************************

                        ColumnLayout {
                            spacing: 5
                            ColumnLayout {
                                RowLayout {
                                    PlasmaComponents3.Label {
                                        text: "Render/3D";
                                        opacity: 1
                                    }
                                    Item { Layout.fillWidth: true }
                                    PlasmaComponents3.Label {
                                        text: truncateNumber(usageNow.engines["Render/3D/0"].busy)+' '+usageNow.engines["Render/3D/0"].unit;
                                        // opacity: .7
                                    }
                                }

                                Components.ClientsList {
                                    clientsList: clients3d
                                    engineName: 'Render/3D'
                                }
                            }

                            Loader { sourceComponent: dividerComponent }

                            ColumnLayout {
                                RowLayout {
                                    PlasmaComponents3.Label {
                                        text: "Video";
                                        opacity: 1
                                    }
                                    Item { Layout.fillWidth: true }
                                    PlasmaComponents3.Label {
                                        text: truncateNumber(usageNow.engines["Video/0"].busy)+' '+usageNow.engines["Video/0"].unit;
                                        // opacity: .7
                                    }
                                }

                                Components.ClientsList {
                                    clientsList: clientsVideo
                                    engineName: 'Video'
                                }
                            }

                            Loader { sourceComponent: dividerComponent }

                            ColumnLayout {
                                RowLayout {
                                    PlasmaComponents3.Label {
                                        text: "Video Enhance";
                                        opacity: 1
                                    }
                                    Item { Layout.fillWidth: true }
                                    PlasmaComponents3.Label {
                                        text: truncateNumber(usageNow.engines["VideoEnhance/0"].busy)+' '+usageNow.engines["VideoEnhance/0"].unit;
                                        // opacity: .7
                                    }
                                }

                                Components.ClientsList {
                                    clientsList: clientsVideoEnhance
                                    engineName: 'VideoEnhance'
                                }
                            }

                            Loader { sourceComponent: dividerComponent }

                            ColumnLayout {
                                RowLayout {
                                    PlasmaComponents3.Label {
                                        text: "Blitter";
                                        opacity: 1
                                    }
                                    Item { Layout.fillWidth: true }
                                    PlasmaComponents3.Label {
                                        text: truncateNumber(usageNow.engines["Blitter/0"].busy)+' '+usageNow.engines["Blitter/0"].unit;
                                        // opacity: .7
                                    }
                                }

                                Components.ClientsList {
                                    clientsList: clientsBlitter
                                    engineName: 'Blitter'
                                }
                            }


                        }

                        // *****************************************************************
                    }
                }
            }
        }
    }
}
