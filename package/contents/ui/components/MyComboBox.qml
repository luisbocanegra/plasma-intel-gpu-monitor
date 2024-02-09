import QtQuick
import QtQuick.Controls


ComboBox {
    id: customComboBox
    property string configValue: ""
    property string configName: ""
    property string formLabel: ""

    onCurrentIndexChanged: {
        configValue = model[currentIndex].dri + "," + model[currentIndex].name;
    }

    function updateSelected() {
        var index = 0
        if (model.length > 0) {
            for (var i= 0; i < model.length; i++) {
                console.log("mi",model[i].dri);
                if (model[i].dri===plasmoid.configuration[configName].split(",")[0]){
                    index = i;
                    break;
                }
            }
            customComboBox.currentIndex = index;
        }
    }

    // HACK: Prevent starting scrolling on collapsed combobox
    // for the sole reason there are so many
    // IDEA: Scroll parent or use another kind of collapsed view instead??
    MouseArea {
        anchors.fill: customComboBox
        hoverEnabled: true

        onWheel: {
            // Do nothing :)
        }

        onClicked: {
            customComboBox.popup.open()
        }
    }

    Component.onCompleted: {
        updateSelected()
    }

    onModelChanged: {
        updateSelected()
    }
}
