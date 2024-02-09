import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

Item {
    id: tooltipContentItem;
    property int preferredTextWidth: Kirigami.Units.gridUnit * 10

    implicitWidth: mainLayout.implicitWidth + Kirigami.Units.gridUnit
    implicitHeight: mainLayout.implicitHeight + Kirigami.Units.gridUnit

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
        anchors {
            left: parent.left
            top: parent.top
            margins: Kirigami.Units.largeSpacing
        }
        Layout.preferredWidth: Math.min(implicitWidth, preferredTextWidth)
        Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
        Layout.maximumWidth: preferredTextWidth

        PlasmaExtras.Heading {
            id: tooltipMaintext
            level: 3
            elide: Text.ElideRight
            text: Plasmoid.metaData.name
            Layout.fillWidth: true
        }

        Component {
            id: dividerComponent
            Rectangle {
                width: mainLayout.width
                height: 1
                color: tooltipContentItem.dividerColor
                opacity: tooltipContentItem.dividerOpacity
            }
        }

        ColumnLayout {
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
                    opacity: .7
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
                    text: truncateNumber(usageNow.engines["Render/3D"].busy)+' '+usageNow.engines["Render/3D"].unit;
                    opacity: .7
                }
            }
            
            Loader {
                sourceComponent: dividerComponent
            }

            RowLayout {
                PlasmaComponents3.Label {
                    text: "Video Acceleration";
                    opacity: 1
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents3.Label {
                    text: truncateNumber(usageNow.engines["Video"].busy)+' '+usageNow.engines["Video"].unit;
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
                    text: truncateNumber(usageNow.engines["VideoEnhance"].busy)+' '+usageNow.engines["VideoEnhance"].unit;
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
                    text: truncateNumber(usageNow.engines["Blitter"].busy)+' '+usageNow.engines["Blitter"].unit;
                    opacity: .7
                }
            }

            // ---------------------------------------------------------
        }
    }
}
