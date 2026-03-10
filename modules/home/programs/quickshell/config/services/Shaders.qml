pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    
    readonly property string dir: "/home/calops/.config/quickshell/assets/shaders"
    
    property alias backdrop: backdropCompiler.compiledPath
    property alias backdropReady: backdropCompiler.ready
    
    property alias bubble: bubbleCompiler.compiledPath
    property alias bubbleReady: bubbleCompiler.ready
    
    property alias glass: glassCompiler.compiledPath
    property alias glassReady: glassCompiler.ready
    
    property alias curves: curvesCompiler.compiledPath
    property alias curvesReady: curvesCompiler.ready

    ShaderCompiler {
        id: backdropCompiler
        name: "backdrop"
        sourceFile: root.dir + "/backdrop.frag"
    }

    ShaderCompiler {
        id: bubbleCompiler
        name: "bubble"
        sourceFile: root.dir + "/bubble.frag"
    }

    ShaderCompiler {
        id: glassCompiler
        name: "glass"
        sourceFile: root.dir + "/glass.frag"
    }

    ShaderCompiler {
        id: curvesCompiler
        name: "curves"
        sourceFile: root.dir + "/curves.frag"
    }

}
