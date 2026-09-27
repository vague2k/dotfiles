import Quickshell.Io
import QtQuick

QtObject {
    id: root

    property string cpu: "--"
    property string ram: "--"
    property string disk: "--"
    property string gpu: "--"
    // Usage fractions (0..1) used to drive the per-stat progress bars.
    property real cpuUsage: 0
    property real ramUsage: 0
    property real diskUsage: 0
    property real gpuUsage: 0

    property double previousTotal: 0
    property double previousIdle: 0

    readonly property real mebibyte: 1048576

    property Timer refreshTimer: Timer {
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

    property Process statsProcess: Process {
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

    // i have an nvidia gpu
    property Process gpuProcess: Process {
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
