import QtQuick 2.15

QtObject {
    id: tokens

    readonly property string fontFamily: "Exo 2"

    property QtObject space: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 18
        readonly property int xxl: 24
    }

    property QtObject layout: QtObject {
        readonly property int compactBreakpointWidth: 1100
        readonly property int compactBreakpointHeight: 760
        readonly property int panelMarginCompact: 14
        readonly property int panelMargin: 32
        readonly property int panelPaddingCompact: 14
        readonly property int panelPadding: 18
        readonly property int panelGapCompact: 10
        readonly property int panelGap: 14
        readonly property int panelTopMarginCompact: 72
        readonly property int panelTopMargin: 100
        readonly property int multiMonitorEdgeMargin: 24
        readonly property int multiMonitorTopMarginCompact: 48
        readonly property int multiMonitorTopMargin: 58
    }

    property QtObject radius: QtObject {
        readonly property int sm: 6
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 14
        readonly property int dock: 16
        readonly property int pill: 999
    }

    property QtObject border: QtObject {
        readonly property int hairline: 1
        readonly property color subtle: "#1e2d45"
        readonly property color muted: "#2a3a55"
        readonly property color strong: "#3b5170"
    }

    property QtObject motion: QtObject {
        readonly property int instant: 60
        readonly property int quick: 90
        readonly property int base: 140
        readonly property int expressive: 180
        readonly property int entrance: 240
        readonly property real panelSpring: 3.2
        readonly property real panelDamping: 0.34
        readonly property real panelEpsilon: 0.002
        readonly property real dockSpring: 4.8
        readonly property real dockDamping: 0.28
        readonly property real dockEpsilon: 0.002
        readonly property real controlSpring: 3.8
        readonly property real controlDamping: 0.32
    }

    property QtObject type: QtObject {
        readonly property int micro: 9
        readonly property int tiny: 10
        readonly property int small: 12
        readonly property int body: 13
        readonly property int ui: 15
        readonly property int lg: 16
        readonly property int title: 22
    }

    property QtObject surface: QtObject {
        readonly property color base: "#0e1520"
        readonly property color panel: "#111111"
        readonly property color raised: "#172233"
        readonly property color hover: "#1e2d45"
        readonly property color strongHover: "#2a3a55"
        readonly property color field: "#101927"
        readonly property color elevated: "#111a28"
    }

    property QtObject text: QtObject {
        readonly property color primary: "#ffffff"
        readonly property color secondary: "#aaaaaa"
        readonly property color muted: "#8ea4bd"
        readonly property color subtle: "#526a83"
        readonly property color inverse: "#050810"
    }

    property QtObject status: QtObject {
        readonly property color success: "#00ff88"
        readonly property color warning: "#ffbd7a"
        readonly property color danger: "#ff8a8a"
        readonly property color info: "#4d9eff"
        readonly property color idle: "#8ea4bd"
    }

    property QtObject shadow: QtObject {
        readonly property color soft: "#66000000"
        readonly property color strong: "#99000000"
    }
}
