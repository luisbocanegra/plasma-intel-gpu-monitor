import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

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
    property var clientsVideoEnhance: []
    property var clientsBlitter: []
    property var engineIcon: "icon-idle.svg"
    property color idleColor: Kirigami.ColorUtils.tintWithAlpha(PlasmaCore.Theme.backgroundColor, PlasmaCore.Theme.textColor, .5)
    property string badgeLightness: Kirigami.ColorUtils.brightnessForColor(PlasmaCore.Theme.backgroundColor) ===
                                Kirigami.ColorUtils.Dark ?
                                0.5 : 0.38
    property color badgeColor: idleColor
    property var card: plasmoid.configuration.card
    property int maxClients: plasmoid.configuration.max_clients
    property int threshold3d: plasmoid.configuration.threshold_3d
    property int thresholdVideo: plasmoid.configuration.threshold_video
    property int thresholdVideoEnhance: plasmoid.configuration.threshold_video_enhance
    property int thresholdBlitter: plasmoid.configuration.threshold_blitter

    Plasmoid.compactRepresentation: CompactRepresentation {
        engineIcon: root.engineIcon
        badgeColor: root.badgeColor
        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainItem: Tooltip {
                width: PlasmaCore.Units.gridUnit * 10
                usageNow: root.usageNow
            }
        }
    }

    Plasmoid.fullRepresentation: FullRepresentation {
        usageNow: root.usageNow
        clients3d: root.clients3d
        clientsVideo: root.clientsVideo
        clientsVideoEnhance: root.clientsVideoEnhance
        clientsBlitter: root.clientsBlitter
    }

    // Plasmoid.status: //usageNow.length>0 ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.HiddenStatus
    // Plasmoid.busy: true

    property string statsString: ""
    property string statsCommand: "timeout 1.5s intel_gpu_top " + (card != "" ? "-d drm:/dev/dri/" + card.split(",")[0] : "") + " -J -s 500"

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
            statsString = stdout.trim();
            usageNow = getCurrentUsage(statsString);
            renameEngines(usageNow.engines);
            clients3d = getSortedClients(usageNow,'Render/3D')
            clientsVideo = getSortedClients(usageNow,'Video')
            clientsVideoEnhance = getSortedClients(usageNow,'VideoEnhance')
            var activeEngine = getActiveEngineIcon(usageNow, threshold3d, thresholdVideo, thresholdVideoEnhance, thresholdBlitter)
            engineIcon = activeEngine.icon
            badgeColor = activeEngine.color
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

        //console.log(goodObjects.length);

        if (goodObjects.length>1) {
            var stats = goodObjects[goodObjects.length -1];
            usageLast = stats
            return stats

            // if (stats.frequency.actual != 0) {
            //     usageLast = stats
            //     return stats
            // } else {
            //     return usageLast
            // }
        } else {
            return usageLast
        }
    }

    // convert pysical engines to classes (removes /NUMBER at the end)
    function renameEngines(obj) {
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                
                let parts = key.split("/")

                if ( !isNaN(Number(parts[parts.length-1])) ) {
                    let newKey = key.split("/")
                    newKey.pop()
                    newKey = newKey.join("/")

                    obj[newKey] = obj[key];
                    delete obj[key];
                }
            }
        }
    }

    function getSortedClients(usageNow, engineClass, count=-maxClients) {

        // Filter out clients based on 'busy' value of the specified engine class
        var filteredClients = Object.keys(usageNow.clients).filter(function (clientId) {
            var clientData = usageNow.clients[clientId];
            return engineClass in clientData['engine-classes'] && parseFloat(clientData['engine-classes'][engineClass]['busy']) > 0;
        }).map(function (clientId) {
            // Include client info in the list
            var clientData = usageNow.clients[clientId];
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

    function getActiveEngineIcon(usageNow, threshold3d, thresholdVideo, thresholdVideoEnhance, thresholdBlitter) {
        var engines = {
            'VideoEnhance': {threshold: thresholdVideoEnhance, icon: "icon-hwe.svg"},
            'Video': {threshold: thresholdVideo, icon: "icon-hw.svg"},
            'Blitter': {threshold: thresholdBlitter, icon: "icon-blitter.svg"},
            'Render/3D': {threshold: threshold3d, icon: "icon-3d.svg"}
        };

        var engineInfo = {icon: "icon-idle.svg", busy: 100-usageNow.rc6.value, color: idleColor};

        for (var engine in engines) {
            var busyEngine = usageNow.engines[engine];
            if (busyEngine.busy > engines[engine].threshold) {
                engineInfo.icon = engines[engine].icon;
                engineInfo.busy = busyEngine.busy;
                engineInfo.color = getBadeColor(engineInfo.busy, engines[engine].threshold);
                break;
            }
        }

        return engineInfo;
    }

    function getBadeColor(load, dimThreshold, dimm = false) {
        load = Math.max(0, Math.min(100, load));
        // Map the load to a hue value (subtract from 120 for 0 to be green and 100 to be red)
        var hue = 120 - (load * 1.2);
        var lightness = root.badgeLightness
        var staturation = 1.0
        // Return the color using HSL
        if (load < dimThreshold && dimm) {
            hue = 193
            staturation = .6
            lightness = 0.3
        }
        return Qt.hsla(hue/360, staturation, lightness, 1)
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Timer {
        interval: 2000;
        running: true;
        repeat: true;
        onTriggered: {
            getStats.exec(statsCommand);
        }
    }
}
