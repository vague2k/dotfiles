import QtQuick
import QtQuick.Controls
import "../theme"

ComboBox {
    id: select

    implicitHeight: 30
    leftPadding: 8
    rightPadding: 26
    spacing: 0
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    hoverEnabled: true
    activeFocusOnTab: false

    background: Rectangle {
        color: select.hovered ? Theme.bgSurface : Theme.bgSurfaceLow
        border.width: 1
        border.color: select.activeFocus || select.popup.visible ? Theme.accentPrimary : Theme.bgBorder
    }

    contentItem: Text {
        leftPadding: select.leftPadding
        rightPadding: select.rightPadding
        text: select.displayText
        color: Theme.textPrimary
        font: select.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Text {
        x: select.width - width - 8
        anchors.verticalCenter: parent.verticalCenter
        text: "⌄"
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    delegate: ItemDelegate {
        required property int index
        width: select.popup.width
        height: 28

        contentItem: Text {
            leftPadding: 8
            rightPadding: 8
            text: select.textAt(index)
            color: select.highlightedIndex === index ? Theme.bgBase : Theme.textPrimary
            font: select.font
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            color: select.highlightedIndex === index ? Theme.accentPrimary : Theme.bgInset
        }
    }

    popup: Popup {
        y: select.height
        width: select.width
        implicitHeight: Math.min(contentItem.implicitHeight + 2, 240)
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: select.popup.visible ? select.delegateModel : null
            currentIndex: select.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: Theme.bgInset
            border.width: 1
            border.color: Theme.bgBorder
        }
    }
}
