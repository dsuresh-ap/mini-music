import SwiftUI
import UIKit
import MediaPlayer
import AVKit

enum PlatformHaptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

struct PlatformVolumeView: View {
    var accentColor: Color = .accentColor
    var textColor: Color = .secondary
    var backgroundColor: Color = Color(.secondarySystemBackground).opacity(0.8)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Volume")
                .font(.subheadline)
                .foregroundStyle(textColor)
            HStack(spacing: 12) {
                VolumeSliderRepresentable(tintColor: UIColor(accentColor))
                    .frame(height: 36)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(backgroundColor)
                    )
                RoutePickerRepresentable(tintColor: UIColor(accentColor))
                    .frame(width: 44, height: 36)
            }
        }
    }
}

private struct VolumeSliderRepresentable: UIViewRepresentable {
    let tintColor: UIColor

    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView(frame: .zero)
        if let thumb = UIImage(systemName: "circle.fill") {
            view.setVolumeThumbImage(thumb, for: .normal)
        }
        view.tintColor = tintColor
        return view
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}

private struct RoutePickerRepresentable: UIViewRepresentable {
    let tintColor: UIColor

    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView(frame: .zero)
        picker.prioritizesVideoDevices = false
        picker.activeTintColor = tintColor
        picker.tintColor = tintColor.withAlphaComponent(0.6)
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
