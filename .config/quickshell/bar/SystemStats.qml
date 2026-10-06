import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string cpu: "--"
    property string ram: "--"
    property string disk: "--"
    property string gpu: "--"
    property real cpuUsage: 0
    property real ramUsage: 0
    property real diskUsage: 0
    property real gpuUsage: 0

    property double previousTotal: 0
    property double previousIdle: 0

    readonly property real mebibyte: 1048576

    Timer {
        id: refreshTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!statsProcess.running)
                statsProcess.running = true;
            if (!gpuProcess.running)
                gpuProcess.running = true;
        }
    }

    Process {
        id: statsProcess
        command: ["sh", "-c", "cat /proc/stat /proc/meminfo; df -P /"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                const cpuLine = lines.find(line => line.startsWith("cpu "));
                if (cpuLine) {
                    const parts = cpuLine.trim().split(/\s+/).slice(1).map(Number);
                    const total = parts.reduce((a, b) => a + b, 0);
                    const idle = parts[3] + parts[4];
                    if (root.previousTotal) {
                        const usage = 1 - (idle - root.previousIdle) / (total - root.previousTotal);
                        root.cpuUsage = Math.max(0, Math.min(1, usage));
                        root.cpu = Math.round(root.cpuUsage * 100) + "%";
                    }
                    root.previousTotal = total;
                    root.previousIdle = idle;
                }

                const memTotal = lines.find(line => line.startsWith("MemTotal:"));
                const memAvailable = lines.find(line => line.startsWith("MemAvailable:"));
                if (memTotal && memAvailable) {
                    const total = Number(memTotal.match(/\d+/)[0]);
                    const available = Number(memAvailable.match(/\d+/)[0]);
                    const used = Math.max(0, total - available);
                    root.ramUsage = Math.max(0, Math.min(1, used / total));
                    root.ram = (used / root.mebibyte).toFixed(1) + " GB";
                }

                const diskLine = lines.find(line => /^\S+\s+\d+\s+\d+\s+\d+\s+\d+%\s+\/$/.test(line));
                if (diskLine) {
                    const fields = diskLine.trim().split(/\s+/);
                    root.disk = fields[4];
                    root.diskUsage = Math.max(0, Math.min(1, parseInt(fields[4]) / 100));
                }
            }
        }
    }

    Process {
        id: gpuProcess
        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim(), 10);
                if (!Number.isNaN(value)) {
                    root.gpuUsage = Math.max(0, Math.min(1, value / 100));
                    root.gpu = value + "%";
                }
            }
        }
    }
}
