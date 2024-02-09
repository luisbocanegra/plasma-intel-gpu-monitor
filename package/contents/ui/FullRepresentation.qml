import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import "components" as Components

ColumnLayout {
    id: root
    Layout.minimumWidth: Kirigami.Units.gridUnit * 19
    Layout.minimumHeight: Kirigami.Units.gridUnit * 19
    Layout.preferredWidth: rootRep.width
    Layout.preferredHeight: rootRep.height

    property bool autoHide: true

    property bool onDesktop: plasmoid.location === PlasmaCore.Types.Floating
    // property bool plasmoidExpanded: main.expanded
    // property bool autoReloadEnabled: onDesktop || plasmoidExpanded

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

            leftPadding: Kirigami.Units.smallSpacing

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
                    text: Plasmoid.internalAction("configure").text

                    onClicked: {
                        Plasmoid.internalAction("configure").trigger()
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
                        main.hideOnWindowDeactivate = autoHide
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

            PlasmaComponents3.ScrollView {
                id: scrollView
                Layout.fillHeight: true
                Layout.fillWidth: true

                topPadding: Kirigami.Units.smallSpacing
                bottomPadding: Kirigami.Units.smallSpacing

                PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff
                PlasmaComponents3.ScrollBar.vertical.policy: PlasmaComponents3.ScrollBar.AsNeeded

                contentWidth: availableWidth - contentItem.leftMargin - contentItem.rightMargin

                contentItem: ListView {
                    id: listView
                    // reserve space for the scrollbar
                    property var sideMargin: Kirigami.Units.smallSpacing +
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

                        PlasmaComponents3.Label {
                            text: plasmoid.configuration.card.split(",")[1];
                            opacity: .7
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

                        Loader {
                            sourceComponent: dividerComponent
                        }

                        RowLayout {
                            PlasmaComponents3.Label {
                                text: "IMC Reads";
                                opacity: 1
                            }
                            Item { Layout.fillWidth: true }
                            PlasmaComponents3.Label {
                                text: truncateNumber(usageNow["imc-bandwidth"].reads)+' '+usageNow["imc-bandwidth"].unit;
                                // opacity: .7
                            }
                        }

                        Loader {
                            sourceComponent: dividerComponent
                        }

                        RowLayout {
                            PlasmaComponents3.Label {
                                text: "IMC Writes";
                                opacity: 1
                            }
                            Item { Layout.fillWidth: true }
                            PlasmaComponents3.Label {
                                text: truncateNumber(usageNow["imc-bandwidth"].writes)+' '+usageNow["imc-bandwidth"].unit;
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
                                        text: truncateNumber(usageNow.engines["Render/3D"].busy)+' '+usageNow.engines["Render/3D"].unit;
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
                                        text: "Video Acceleration";
                                        opacity: 1
                                    }
                                    Item { Layout.fillWidth: true }
                                    PlasmaComponents3.Label {
                                        text: truncateNumber(usageNow.engines["Video"].busy)+' '+usageNow.engines["Video"].unit;
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
                                        text: truncateNumber(usageNow.engines["VideoEnhance"].busy)+' '+usageNow.engines["VideoEnhance"].unit;
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
                                        text: truncateNumber(usageNow.engines["Blitter"].busy)+' '+usageNow.engines["Blitter"].unit;
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
