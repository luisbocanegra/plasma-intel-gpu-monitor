import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id:root

    // Allow full view on the desktop
    Plasmoid.preferredRepresentation: plasmoid.location ===
                                    PlasmaCore.Types.Floating ?
                                    Plasmoid.fullRepresentation :
                                    Plasmoid.compactRepresentation

    property var usageNow: {}
    property var usageLast: {}
    property var clients3d: []
    property var clientsVideo: []

    Plasmoid.compactRepresentation: CompactRepresentation {
        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainItem: Tooltip {
                width: PlasmaCore.Units.gridUnit * 10
                usageNow: root.usageNow
                clients3d: root.clients3d
                clientsVideo: root.clientsVideo
            }
            visible: true
        }
    }

    // Plasmoid.fullRepresentation: FullRepresentation {
    //     usageNow: root.usageNow
    // }

    // Plasmoid.status: //usageNow.length>0 ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
    // Plasmoid.busy: true

    property string statsString: ""
    
    // for file in /sys/block/*; do if [[ $(cat "${file}/removable") -eq 1 ]]; then; echo "$file $(cat ${file}/stat) $(cat ${file}/device/vendor) $(cat ${file}/device/model)"; fi; done
    property string statsCommand: "timeout 1s intel_gpu_top -d drm:/dev/dri/card1 -J -s 200"
    //property string statsCommand: "for file in /sys/block/*; do echo \"$file $(cat ${file}/stat) $(cat ${file}/device/vendor) $(cat ${file}/device/model)\"; done"

    // Plasmoid.fullRepresentation: FullRepresentation {
    // }

    PlasmaCore.DataSource {
        id: getStats
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
            getStats.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }


    Connections {
        target: getStats
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            console.log("CHECK STATS");
            console.log("cmd:",cmd);
            //console.log("exitCode:",exitCode);
            //console.log("stdout:",stdout);
            console.log("stderr:",stderr);
            statsString = stdout.trim(); //.replace('\n', '')
            usageNow = getCurrentUsage(statsString);
            clients3d = getSortedClients(usageNow,'Render/3D')
            clientsVideo = getSortedClients(usageNow,'Video')
        }
    }

    function getCurrentUsage(statsString) {

        var lines = statsString.split("\n");
        let jsonObject = '';
        let goodObjects = [];

        lines.forEach((line) => {
            // If the line starts with '{', it's the start of a new object
            if (line.startsWith('{')) {
                jsonObject = line;
            }

            // If the line starts with '},', it's the end of an object
            else if (line.startsWith('},')) {
                jsonObject += '}';

                try {
                    // Try to parse the string
                    let parsedObject = JSON.parse(jsonObject);

                    goodObjects.push(parsedObject);
                } catch (error) {
                    console.error('Broken object:', jsonObject);
                }

                // Reset for the next object
                jsonObject = '';
            }
            // Otherwise, add the line to the current object
            else {
                jsonObject += line;
            }
        });

        console.log(goodObjects.length);

        if (goodObjects.length>1) {
            var stats = goodObjects[goodObjects.length -1];

            if (stats.frequency.actual != 0) {
                usageLast = stats
                return stats
            } else {
                return usageLast
            }
        } else {
            return usageLast
        }
    }

    function getSortedClients(data, engineClass, count=-3) {

        // Filter out clients based on 'busy' value of the specified engine class
        var filteredClients = Object.keys(data.clients).filter(function (clientId) {
            var clientData = data.clients[clientId];
            return engineClass in clientData['engine-classes'] && parseFloat(clientData['engine-classes'][engineClass]['busy']) != 0;
        }).map(function (clientId) {
            // Include client info in the list
            var clientData = data.clients[clientId];
            return {
            id: clientId,
            name: clientData.name,
            pid: clientData.pid,
            engines: clientData['engine-classes']
            };
        });

        // Sort clients by 'busy' value
        var sortedClients = filteredClients.sort(function (a, b) {
            return parseFloat(b.engines[engineClass]['busy']) - parseFloat(a.engines[engineClass]['busy']);
        });

        return sortedClients.slice(count);
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Timer {
        interval: 2000;
        running: true;//autoReloadEnabled
        repeat: true;
        onTriggered: {
            getStats.exec(statsCommand);
        }
    }
}
