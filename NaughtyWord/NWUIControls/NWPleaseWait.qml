pragma Singleton
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import com.glovisdom.UserSettings 0.1
import "qrc:/../../UIControls"

PleaseWait { id: window
    property int proportion: 4
    externalFontSize: UserSettings.fontPointSize
    visible: false;
    opacity: 1
    //TODO Shadow: make waiting fit NaughtyWord style
    function setAsDefault(app){
        setStyle(indicator);        
        window.width = app.width* 0.85; window.height = app.height/2.5
        proportion = 4
        color = "transparent"
        visible = false
        state = "running"
        message = ""
    }

    property Component indicator: BusyIndicatorStyle {
        indicator: Image { id: image
            visible: true
            height: window.height/proportion
            width: height
            source: "qrc:/NWUIControls/crown.png"
            RotationAnimator on rotation {
                running: window.visible && window.state == "running"
                loops: Animation.Infinite
                duration: 2000
                from: 0 ; to: 360
            }
        }
    }
}

