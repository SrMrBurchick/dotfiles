import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "root:"
import "root:./Components/Base/"

Module {
    width: clockStr.width + 20
    BaseText {
        id: clockStr
        anchors.centerIn: parent
        text: "Notifications"
    }

    // create a process management object
    Process {
        id: dateProc
        // the command it will run, every argument is its own string
        command: ["date", "+%A %H:%M:%S %D"]

        // run the command immediately
        running: true

        // process the stdout stream using a StdioCollector
        // Use StdioCollector to retrieve the text the process sends
        // to stdout.
        stdout: StdioCollector {
            // Listen for the streamFinished signal, which is sent
            // when the process closes stdout or exits.
            // onStreamFinished: clockStr.text = this.text // `this` can be omitted
        }
    }

    // use a timer to rerun the process at an interval
    Timer {
        // 1000 milliseconds is 1 second
        interval: 1000

        // start the timer immediately
        running: true

        // run the timer again when it ends
        repeat: true

        // when the timer is triggered, set the running property of the
        // process to true, which reruns it if stopped.
        onTriggered: dateProc.running = true
    }
}

