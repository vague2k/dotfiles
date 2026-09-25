//@ pragma IconTheme hicolor
import Quickshell
import Quickshell.Services.Pipewire
import "theme"
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

    Bar {
        theme: Theme
    }

    AppLauncher {
        theme: Theme
    }

    AudioPanel {
        theme: Theme
    }

    BluetoothPanel {
        theme: Theme
    }

    SessionOverlay {
        theme: Theme
    }

    WallpaperManager {
        theme: Theme
    }

    Switcher {
        theme: Theme
    }

    NotificationPopup {
        theme: Theme
    }
}
