import QtQuick 2.4
import QtMultimedia 5.5
import com.glovisdom.WordSpeaker 0.1

AnkiOps { id: root
    property bool soundON: true
    property var mediaAudio
    //property bool picOnly: false

    Audio { id: mediaAudio
        property bool commanded: false
        autoPlay: false
        onStatusChanged: {
            if(status==Audio.Loaded) {
                if (commanded == true) {
                    play();
                    commanded = false
                }
            }
        }
        function playSource(resource) {
            if(!WordSpeaker.playFile(path + resource)) {
                var res = "file://" + path + resource
                mediaAudio.source = res
                mediaAudio.commanded = true
                mediaAudio.play()
            }
        }
    }


    function speechClicked(resource) {
        if (soundON){
            mediaAudio.playSource(resource)
        }
    }
}
