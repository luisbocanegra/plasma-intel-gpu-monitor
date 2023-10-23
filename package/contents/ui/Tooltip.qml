import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

ColumnLayout {
    id: root;
    property var usageNow;
    property var dividerColor: Kirigami.Theme.textColor;
    property var dividerOpacity: 0.1;

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

    ColumnLayout {
        id: mainLayout;
        Layout.topMargin: PlasmaCore.Units.gridUnit / 2
        Layout.leftMargin: PlasmaCore.Units.gridUnit / 2
        Layout.bottomMargin: PlasmaCore.Units.gridUnit / 2
        Layout.rightMargin: PlasmaCore.Units.gridUnit / 2
        Layout.preferredWidth: PlasmaCore.Units.gridUnit * 50

        PlasmaExtras.Heading {
            id: tooltipMaintext
            level: 3
            elide: Text.ElideRight
            text: Plasmoid.metaData.name
        }

        Component {
            id: dividerComponent
            Rectangle {
                width: mainLayout.width
                height: 1
                color: root.dividerColor
                opacity: root.dividerOpacity
            }
        }

        ColumnLayout {

            // ---------------------------------------------------------

            // RowLayout {
            //     PlasmaComponents3.Label {
            //         text: "Period";
            //         opacity: 1
            //     }
            //     Item { Layout.fillWidth: true }
            //     PlasmaComponents3.Label {
            //         text: truncateString(usageNow.period.duration)+' '+usageNow.period.unit;
            //         opacity: .7
            //     }
            // }

            // Loader {
            //     sourceComponent: dividerComponent
            // }

            // ---------------------------------------------------------

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
                    text: truncateNumber(100-usageNow.rc6.value)+' '+usageNow.rc6.unit;
                    opacity: .7
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
                    opacity: .7
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
                    opacity: .7
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
                    opacity: .7
                }
            }
            
            // ---------------------------------------------------------

            PlasmaExtras.Heading {
                level: 3
                text: "Engine Utilization";
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                PlasmaComponents3.Label {
                    text: "Render/3D";
                    opacity: 1
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents3.Label {
                    text: truncateNumber(usageNow.engines["Render/3D/0"].busy)+' '+usageNow.engines["Render/3D/0"].unit;
                    opacity: .7
                }
            }

            Loader {
                sourceComponent: dividerComponent
            }

            RowLayout {
                PlasmaComponents3.Label {
                    text: "Blitter";
                    opacity: 1
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents3.Label {
                    text: truncateNumber(usageNow.engines["Blitter/0"].busy)+' '+usageNow.engines["Blitter/0"].unit;
                    opacity: .7
                }
            }
            
            Loader {
                sourceComponent: dividerComponent
            }

            RowLayout {
                PlasmaComponents3.Label {
                    text: "Video";
                    opacity: 1
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents3.Label {
                    text: truncateNumber(usageNow.engines["Video/0"].busy)+' '+usageNow.engines["Video/0"].unit;
                    opacity: .7
                }
            }
            
            Loader {
                sourceComponent: dividerComponent
            }

            RowLayout {
                PlasmaComponents3.Label {
                    text: "Video Enhance";
                    opacity: 1
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents3.Label {
                    text: truncateNumber(usageNow.engines["VideoEnhance/0"].busy)+' '+usageNow.engines["VideoEnhance/0"].unit;
                    opacity: .7
                }
            }

            // ---------------------------------------------------------
        }
    }
}
