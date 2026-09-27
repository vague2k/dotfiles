//@ pragma IconTheme hicolor
import Quickshell
import Quickshell.Services.Pipewire
import "bar"
import "launcher"
import "audio"
import "bluetooth"
import "session"
import "wallpaper"
import "switcher"
import "notifications"

ShellRoot {
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Bar {}

    AppLauncher {}

    AudioPanel {}

    BluetoothPanel {}

    SessionOverlay {}

    WallpaperManager {}

    NotificationPopup {}
}
