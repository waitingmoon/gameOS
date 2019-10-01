import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9

Item {
  id: root
  property var gameData//: currentCollection.games.get(gameList.currentIndex)
  property real storedDimOpacity: 0.7
  property real dimopacity: storedDimOpacity

  property string bgDefault: '../assets/images/defaultbg.jpg'
  property string bgSource: gameData ? gameData.assets.background || gameData.assets.screenshots[0] || bgDefault : bgDefault
  property string bgImage1
  property string bgImage2
  property bool firstBG: true
  property bool showVideo: false
  property bool muteVideo: true

  onBgSourceChanged: swapImage(bgSource)

  /////////////////
  // Video Stuff //
  function toggleVideo() {
      if (showVideo)
      {
        // Turn off video
        showVideo = false;
        bg.opacity = 1;
        videoPreviewLoader.sourceComponent = undefined;
        fadescreenshot.stop();
      } else {
        // Turn on video
        showVideo = true;
        videoDelay.restart();
      }
  }

  // NOTE: Start the countdown to load the video behind the bg
  Timer {
    id: videoDelay
    interval: 500
    onTriggered: {
      if (gameData.assets.videos.length) {
        videoPreviewLoader.sourceComponent = videoPreviewWrapper;
        fadescreenshot.restart();
      }
    }
  }

  // NOTE: Next fade out the bg so there is a smooth transition into the video
  Timer {
    id: fadescreenshot
    interval: 500
    onTriggered: {
      bg.opacity = 0;
    }
  }

  // NOTE: Video Preview
  Component {
    id: videoPreviewWrapper
    Video {
      source: gameData.assets.videos.length ? gameData.assets.videos[0] : ""
      anchors.fill: parent
      fillMode: VideoOutput.PreserveAspectCrop
      muted: muteVideo
      loops: MediaPlayer.Infinite
      autoPlay: true
    }

  }

  // Video
  Loader {
    id: videoPreviewLoader
    asynchronous: true
    anchors {
      fill: parent
    }
  }

  // End Video Stuff //
  /////////////////////

  Item {
    id: bg

    anchors.fill: parent

    opacity: 1
    Behavior on opacity { NumberAnimation { duration: 500 } }

    states: [
        State { // this will fade in rect2 and fade out rect
            name: "fadeInRect2"
            PropertyChanges { target: rect; opacity: 0}
            PropertyChanges { target: rect2; opacity: 1}
        },
        State   { // this will fade in rect and fade out rect2
            name:"fadeOutRect2"
            PropertyChanges { target: rect;opacity:1}
            PropertyChanges { target: rect2;opacity:0}
        }
    ]

    transitions: [
        Transition {
            NumberAnimation { property: "opacity"; easing.type: Easing.InOutQuad; duration: 300  }
        }
    ]

    Image {
        id: rect2
        anchors.fill: parent
        visible: gameData
        asynchronous: true
        source: bgImage1
        sourceSize { width: 1920; height: 1080 }
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Image {
        id: rect
        anchors.fill: parent
        visible: gameData
        asynchronous: true
        source: bgImage2
        sourceSize { width: 1920; height: 1080 }
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    state: "fadeInRect2"

  }

  function swapImage(newSource) {
    if (firstBG) {
      // Go to second image
      if (newSource)
        bgImage2 = newSource

      firstBG = false
    } else {
      // Go to first image
      if (newSource)
        bgImage1 = newSource

      firstBG = true
    }
    bg.state = bg.state == "fadeInRect2" ? "fadeOutRect2" : "fadeInRect2"
  }

  Image
  {
    id: overlay
    anchors.fill: parent
    source: (gameData.assets.videos[0].height > gameData.assets.videos[0].width) ? "../assets/images/scanlines-vert.png" : "../assets/images/scanlines.png"
    sourceSize { width: 1920; height: 1080 }
    opacity: 0.3
    smooth: true
  }

  LinearGradient {
    id: bggradient
    z: parent.z + 1
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top; topMargin: vpx(200)
      right: parent.right
      bottom: parent.bottom
    }
    start: Qt.point(0, 0)
    end: Qt.point(0, height)
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#00000000" }
      GradientStop { position: 0.7; color: "#ff000000" }
    }
    opacity: (muteVideo) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 100 } }

  }

  Rectangle {
    id: backgrounddim
    anchors.fill: parent
    color: "#15181e"

    opacity: dimopacity

    Behavior on opacity { NumberAnimation { duration: 100 } }
  }



}
