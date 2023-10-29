import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kirigami 2.20 as Kirigami
import Qt.labs.settings 1.0
import "components" as Components
ColumnLayout {
    
    id:root
    anchors.fill: parent
    property var textAreaPadding: 10 * PlasmaCore.Units.devicePixelRatio
    property var controlWidth: 48 * PlasmaCore.Units.devicePixelRatio
    property string cfg_card: "" //plasmoid.configuration.card
    property alias cfg_max_clients: maxClients.text
    signal configurationChanged

    property var cardsList: []
    property string getCardsCommand: "intel_gpu_top -L"
    property string cardsString: ""


    PlasmaCore.DataSource {
        id: getCards
        engine: "executable"
        connectedSources: []

        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }

        function exec(cmd) {
            getCards.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: getCards
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            cardsString = stdout.trim();
            cardsList = getCardsList(cardsString)
        }
    }

    function getCardsList(cardsString) {

        var lines = cardsString.split("\n")

        var devices = []

        lines.forEach((line) => {
            if (line.startsWith("card")) {
                var parts = line.split(/\s+/);
                var device = {}
                device.dri = parts[0]
                device.name = parts.slice(1, -1).join(" ")
                device.ids = {}

                var partsId = parts[parts.length - 1].split(":")[1].split(",")

                partsId.forEach((identifier) => {
                    var parts = identifier.split("=")
                    device.ids[parts[0]] = parts[1]
                })

                device.label = "/dev/dri/" + device.dri + " "+ device.name + " " + device.ids.vendor + ":"+device.ids.device + " (card "+device.ids.card+")"
                devices.push(device)
            }
        });

        return devices
    }

    Component.onCompleted: {
        getCards.exec(getCardsCommand);
        // console.log("aaaaaaaaaaaaaaaaaaaaaaaa");
        // startupTimer.start()
    }

    property var myDataArray: []

    Kirigami.FormLayout {
        id: generalPage
        Layout.alignment: Qt.AlignTop


        // Make card selection a component so we can load after cardsList is ready
        Loader {
            id: myLoader
            asynchronous: true
        }

        Component {
            id: comboBoxComponent
            Components.MyComboBox {
                id: cardCombo
                model: root.cardsList
                configName: "card"
                textRole: "label"
                formLabel: "Card"
                onConfigValueChanged: {
                    cfg_card = configValue
                }
            }
        }

        Component.onCompleted: {
            startupTimer.start()
        }
        
        Timer {
            id: startupTimer
            interval: 250
            repeat: false

            onTriggered: {
                myLoader.sourceComponent = comboBoxComponent
            }
        }

        TextField {
            id: maxClients
            // Layout.preferredWidth: controlWidth
            Kirigami.FormData.label: "Max shown programs:"
            topPadding: textAreaPadding
            bottomPadding: textAreaPadding
            leftPadding: textAreaPadding
            rightPadding: textAreaPadding
            placeholderText: "0-?"
            horizontalAlignment: TextInput.AlignHCenter
            text: parseInt(plasmoid.configuration.max_clients)
            // Layout.fillWidth: true
            validator: IntValidator {
                bottom: 0
            }

            onAccepted: {
                cfg_max_clients = parseInt(text)
            }
        }
    }
}
