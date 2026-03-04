import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../services"
import "../components"

Scope {
    id: root

    PanelWindow {
        id: runnerWindow
        // Show on the first screen
        screen: Quickshell.screens[0]

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        // This is a full-screen transparent overlay
        color: "transparent"
        visible: AnyrunService.runnerVisible
        
        // Don't reserve space for other windows
        exclusionMode: ExclusionMode.Ignore

        // Request keyboard focus from the compositor
        focusable: true
        WlrLayershell.keyboardFocus: WlrLayershell.Exclusive

        onVisibleChanged: {
            if (visible) {
                searchInput.forceActiveFocus();
                searchInput.text = "";
                AnyrunService.query("");
            }
        }

        // The background click-to-dismiss overlay
        MouseArea {
            anchors.fill: parent
            onClicked: AnyrunService.toggleRunner(false)
        }

        // Animated blur mask region for the glassmorphic effect
        property var blurRegion
        property var mask

        function updateWaylandEffects() {
            if (!runnerWindow.visible) return;
            
            var blurStr = "import Quickshell; import Quickshell.Wayland; Region {\n" +
                          "    Region { item: runnerContainer; radius: 10 }\n" +
                          "}";
            if (runnerWindow.BackgroundEffect.blurRegion) runnerWindow.BackgroundEffect.blurRegion.destroy();
            runnerWindow.BackgroundEffect.blurRegion = Qt.createQmlObject(blurStr, runnerWindow, "runnerBlurRegion");
            
            var maskStr = "import Quickshell; import Quickshell.Wayland; Region {\n" +
                          "    Region { item: runnerContainer; radius: 10 }\n" +
                          "}";
            if (runnerWindow.mask) runnerWindow.mask.destroy();
            runnerWindow.mask = Qt.createQmlObject(maskStr, runnerWindow, "runnerMask");
        }

        Item {
            anchors.fill: parent
            focus: true
            
            onActiveFocusChanged: {
                if (!activeFocus && runnerWindow.visible) {
                    AnyrunService.toggleRunner(false);
                }
            }

            Item {
                id: runnerContainer
                width: 600
                
                // Debounced height update to prevent jitter
                property real actualTargetHeight: 80 + (AnyrunService.resultsModel.count > 0 ? Math.min(AnyrunService.resultsModel.count * 48, 500) + 20 : 0)
                property real targetHeight: 80
                height: targetHeight
                
                Timer {
                    id: heightDebounce
                    interval: 100
                    onTriggered: runnerContainer.targetHeight = runnerContainer.actualTargetHeight
                }
                
                onActualTargetHeightChanged: {
                    if (actualTargetHeight > targetHeight) {
                        // Grow immediately for better responsiveness
                        targetHeight = actualTargetHeight;
                        heightDebounce.stop();
                    } else {
                        // Debounce shrinking to avoid flicker
                        heightDebounce.restart();
                    }
                }
                
                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animationDuration
                        easing.type: Easing.OutQuad
                        onRunningChanged: if (!running) runnerWindow.updateWaylandEffects();
                    }
                }
                
                onHeightChanged: {
                    runnerWindow.updateWaylandEffects();
                }
                
                anchors.centerIn: parent

                // Glassmorphic background
                ShaderEffect {
                    id: glassBackground
                    anchors.fill: parent
                    
                property real radius: 10
                property color baseColor: Colors.alpha(Colors.light.teal, 0.50)
                property real uWidth: width
                property real uHeight: height

                    fragmentShader: Qt.resolvedUrl("../components/shaders/glass.frag.qsb")

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "black"
                        shadowBlur: 1.0
                        shadowOpacity: 0.5
                        shadowVerticalOffset: 2
                        shadowHorizontalOffset: 2
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        spacing: 10
                        
                        StyledText {
                            text: ""
                            font.pixelSize: 16
                            color: Colors.palette.text
                        }
                        
                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: 18
                            color: Colors.palette.text
                            selectionColor: Colors.palette.surface2
                            selectedTextColor: Colors.palette.text
                            
                            onTextChanged: {
                                AnyrunService.query(text);
                                resultsList.currentIndex = 0;
                            }
                            
                            Keys.onDownPressed: {
                                if (resultsList.count > 0) {
                                    resultsList.currentIndex = (resultsList.currentIndex + 1) % resultsList.count;
                                }
                            }
                            Keys.onUpPressed: {
                                if (resultsList.count > 0) {
                                    resultsList.currentIndex = (resultsList.currentIndex - 1 + resultsList.count) % resultsList.count;
                                }
                            }
                            Keys.onReturnPressed: {
                                if (resultsList.count > 0 && resultsList.currentIndex >= 0) {
                                    const match = AnyrunService.resultsModel.get(resultsList.currentIndex);
                                    AnyrunService.execute(match.rawPlugin, match.rawMatch);
                                }
                            }
                            Keys.onEscapePressed: {
                                AnyrunService.toggleRunner(false);
                            }
                            Keys.onTabPressed: {
                                if (resultsList.count > 0) {
                                    resultsList.currentIndex = (resultsList.currentIndex + 1) % resultsList.count;
                                }
                            }
                            Keys.onBacktabPressed: {
                                if (resultsList.count > 0) {
                                    resultsList.currentIndex = (resultsList.currentIndex - 1 + resultsList.count) % resultsList.count;
                                }
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.palette.surface1
                        visible: AnyrunService.resultsModel.count > 0
                    }
                    
                    ListView {
                        id: resultsList
                        Layout.fillWidth: true
                        Layout.preferredHeight: AnyrunService.resultsModel.count > 0 ? Math.min(AnyrunService.resultsModel.count * 48, 500) : 0
                        model: AnyrunService.resultsModel
                        clip: true
                        interactive: false
                        
                        delegate: Item {
                            width: ListView.view.width
                            height: 48
                            
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: 6
                                color: ListView.isCurrentItem ? Colors.palette.surface0 : "transparent"
                                
                                Behavior on color {
                                    ColorAnimation { duration: Theme.animationDurationFast }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: resultsList.currentIndex = index
                                    onClicked: {
                                        resultsList.currentIndex = index;
                                        const match = AnyrunService.resultsModel.get(index);
                                        AnyrunService.execute(match.rawPlugin, match.rawMatch);
                                    }
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 12
                                    
                                    Image {
                                        source: model.iconPath || ""
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        sourceSize: Qt.size(24, 24)
                                        fillMode: Image.PreserveAspectFit
                                        visible: source != ""
                                    }
                                    
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: (model.title || "").replace(/&/g, '')
                                            font.pixelSize: 14
                                            color: Colors.palette.text
                                            elide: Text.ElideRight
                                        }
                                        
                                        StyledText {
                                            Layout.fillWidth: true
                                            text: (model.description || "").replace(/&/g, '')
                                            font.pixelSize: 11
                                            color: Colors.palette.subtext0
                                            visible: text !== ""
                                            elide: Text.ElideRight
                                        }
                                    }
                                    
                                    StyledText {
                                        text: model.pluginName
                                        font.pixelSize: 10
                                        color: Colors.palette.overlay0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
