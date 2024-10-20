import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid

import "code/utils.js" as Utils
import "code/globals.js" as Globals

PlasmoidItem {
    id:main
    width: Kirigami.Units.gridUnit * 10
    height: Kirigami.Units.gridUnit * 4
    property var usageNow: Globals.baseStats
    property var usageLast: Globals.baseStats
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
    property string commandEerror: ""

    compactRepresentation: CompactRepresentation {
        engineIcon: main.engineIcon
        badgeColor: main.badgeColor
        usageNow: main.usageNow
    }

    toolTipItem: Tooltip {
        usageNow: main.usageNow
        Layout.minimumWidth: item ? item.implicitWidth : 0
        Layout.maximumWidth: item ? item.implicitWidth : 0
        Layout.minimumHeight: item ? item.implicitHeight : 0
        Layout.maximumHeight: item ? item.implicitHeight : 0
    }

    fullRepresentation: FullRepresentation {
        usageNow: main.usageNow
        clients3d: main.clients3d
        clientsVideo: main.clientsVideo
        clientsVideoEnhance: main.clientsVideoEnhance
        clientsBlitter: main.clientsBlitter
        commandEerror: main.commandEerror
    }

    property string statsString: ""
    // intel_gpu_top returns a constant stream when using JSON format
    // the first object doesn't seem to be very accurate so we let it run three times
    // and later use just the last one
    property string statsCommand: "timeout 1.5s intel_gpu_top " + (card != "" ? "-d drm:/dev/dri/" + card.split(",")[0] : "") + " -J -s 500"

    P5Support.DataSource {
        id: getStats
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source) // cmd finished
        }

        function exec(cmd) {
            getStats.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: getStats
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            if (exitCode !== 124) {
                commandEerror = `command: ${cmd}\nexit code: ${exitCode}\nexit status: ${exitStatus}\nstdout: ${stdout}\nstderr: ${stderr}\n`
                return
            }
            statsString = stdout.trim();
            usageNow = Utils.getCurrentUsage(statsString);
            if (usageNow) {
                usageLast = usageNow
            } else {
                usageNow = usageLast
            }
            if (!usageNow || Object.keys(usageNow).length === 0) {
                return
            }
            commandEerror = ""
            usageNow = Utils.mergeObjects(Globals.baseStats, usageNow)
            usageNow = Utils.renameEngines(usageNow);
            clients3d = Utils.getSortedClients(usageNow,'Render/3D')
            clientsVideo = Utils.getSortedClients(usageNow,'Video')
            clientsVideoEnhance = Utils.getSortedClients(usageNow,'VideoEnhance')
            var activeEngine = Utils.getActiveEngineIcon(usageNow, threshold3d, thresholdVideo, thresholdVideoEnhance, thresholdBlitter)
            engineIcon = activeEngine.icon
            badgeColor = activeEngine.color
        }
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
