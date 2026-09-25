import Quickshell.Io
import QtQuick

QtObject {
    id: root

    property string cpu: "--"
    property string ram: "--"
    property string disk: "--"
    property double previousTotal: 0
    property double previousIdle: 0

    property Timer refreshTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!statsProcess.running) statsProcess.running = true;
        }
    }

    property Process statsProcess: Process {
        command: ["sh", "-c", "cat /proc/stat /proc/meminfo; df -P / | tail -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                const cpuLine = lines.find(line => line.startsWith("cpu "));
                if (cpuLine) {
                    const parts = cpuLine.trim().split(/\s+/).slice(1).map(Number);
                    const total = parts.reduce((a, b) => a + b, 0);
                    const idle = parts[3] + parts[4];
                    if (root.previousTotal)
                        root.cpu = Math.round(100 * (1 - (idle - root.previousIdle) / (total - root.previousTotal))) + "%";
                    root.previousTotal = total;
                    root.previousIdle = idle;
                }

                const memTotal = lines.find(line => line.startsWith("MemTotal:"));
                const memAvailable = lines.find(line => line.startsWith("MemAvailable:"));
                if (memTotal && memAvailable) {
                    const total = Number(memTotal.match(/\d+/)[0]);
                    const available = Number(memAvailable.match(/\d+/)[0]);
                    root.ram = Math.round(100 * (total - available) / total) + "%";
                }

                const diskLine = lines.find(line => /^\S+\s+\d+\s+\d+\s+\d+\s+\d+%\s+\/$/.test(line));
                if (diskLine) root.disk = diskLine.trim().split(/\s+/)[4];
            }
        }
    }
}
