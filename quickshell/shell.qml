//@ pragma IconTheme hicolor
import Quickshell
import Quickshell.Services.Pipewire
import "bar"
import "launcher"
import "audio"
import "bluetooth"
import "wallpaper"
import "notifications"

ShellRoot {
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Bar {}

    AppLauncher {}

    AudioPanel {}

    BluetoothPanel {}

    WallpaperManager {}

    NotificationPopup {}
}
