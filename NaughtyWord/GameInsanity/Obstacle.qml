import QtQuick 2.0
import Box2D 2.0
import "qrc:/../UIControls"

Item {
    id: obstacle
    smooth: true
    property alias obsBody:obsBody
    property alias collidesWith: obsFixtures.collidesWith
    property point initVelocity
    property point lastVelocity
    property real accelerateScale
    property bool working: false
    property alias imageUrl: image.source
    property size imgSize : Qt.size(0,0)
    property variant imgShape : []

    onWidthChanged: {
        updateVertices()
    }

    onHeightChanged: {
        updateVertices()
    }

    function start(){
        lastVelocity = initVelocity
        working = true
    }

    onWorkingChanged: {
        if(working){
            obsBody.linearVelocity = lastVelocity
        }else{
            lastVelocity = obsBody.linearVelocity
            obsBody.linearVelocity = Qt.point(0,0)
        }
    }
    AutoImage{id: image
        autoCalculateSize: false
        anchors.fill: parent
        fillMode:  Image.Stretch
    }

    Body {
        id: obsBody
        target: obstacle
        bodyType: Body.Dynamic
        world: physicsWorld
        fixedRotation: true
        linearVelocity: Qt.point(0,0)

        fixtures: Polygon {
            id: obsFixtures
            vertices: [Qt.point(0,0), Qt.point(0,10), Qt.point(10,0)]   //init to get rid of warning
            density: 1
            friction: 0
            restitution: 0
            categories: Box.Category1
            collidesWith: Box.Category2 | Box.Category16
        }
    }
    function updateVertices(){
        if(width > 0 && height > 0){
            var vertices = []
            for(var i = 0; i < imgShape.length; i++){
                var point = Qt.point(imgShape[i].x/imgSize.width*width, imgShape[i].y/imgSize.height*height)
                vertices.push(point)
            }
            obsFixtures.vertices = vertices
        }
    }

    Timer{
        interval: 1000
        running: working
        repeat: true
        onTriggered: {
            obsBody.linearVelocity.x += Math.abs(initVelocity.x)/accelerateScale*(obsBody.linearVelocity.x>0? 1: -1)
            obsBody.linearVelocity.y += Math.abs(initVelocity.y)/accelerateScale*(obsBody.linearVelocity.y>0? 1: -1)
            if(Math.abs(obsBody.linearVelocity.y) < 0.3 ){
                //This is for an unknown bug. It always happen on the top of screen
                obsBody.linearVelocity.y = Math.abs(obsBody.linearVelocity.x)*(0.8 + Math.random()*0.4)   // 0.8~1.2*x
                console.log("obsBody.linearVelocity.y == 0")
            }

        }
    }
}

