import QtQuick 2.0

import QtQuick.Layouts 1.0

import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3


ColumnLayout {
    id: clientsRoot
    property var clientsList: []
    property var engineName

    property var dividerColor: Kirigami.Theme.textColor;
    property var dividerOpacity: 0.05;

    spacing: 1

    Repeater {
        model: clientsList
        delegate: ColumnLayout {
            spacing: 1
            
            RowLayout {

                Item { implicitWidth: units.mediumSpacing }
                
                ColumnLayout {
                    spacing: 1
                    PlasmaComponents3.Label {
                        text: '• ' + truncateString(modelData.name,30);
                        opacity: .65
                    }
                    
                    PlasmaComponents3.Label {
                        text: '  PID: ' + modelData.pid + '';
                        opacity: .65
                    }
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents3.Label {
                    // Layout.alignment: Qt.AlignBottom
                    text: truncateNumber(modelData.engines[engineName].busy) + ' ' + modelData.engines[engineName].unit;
                    opacity: .65
                }
            }

            RowLayout {
                visible: clientsList.length - 1 != index
                width: clientsRoot.width
                Item { implicitWidth: units.mediumSpacing }
                Rectangle {
                    width: parent.width - units.mediumSpacing - 5
                    height: 1
                    color: clientsRoot.dividerColor
                    opacity: clientsRoot.dividerOpacity
                }
            }
        }
    }
}
