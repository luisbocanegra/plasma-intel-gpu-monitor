import QtQuick 2.0
import QtQuick.Controls 2.15
import org.kde.kirigami 2.20 as Kirigami


Kirigami.FormLayout {
    id: comboForm
    property string configValue: ""
    property string configName: ""
    property string formLabel: ""
    property var model: []
    property string textRole: ""
    
    ComboBox {
        id: customComboBox

        model: comboForm.model
        textRole: comboForm.textRole

        onCurrentIndexChanged: {
            configValue = model[currentIndex].dri + "," + model[currentIndex].name;
        }

        Kirigami.FormData.label: formLabel + ":"


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
    }

}
