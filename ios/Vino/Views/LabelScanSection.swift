import SwiftUI
import PhotosUI
import UIKit

/// Form section that scans a label photo and fills in the wine's details.
struct LabelScanSection: View {
    @Bindable var wine: Wine

    @State private var showCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var isScanning = false
    @State private var message: String?

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                if let data = wine.labelImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityLabel("Photo of the wine label")
                }

                HStack {
                    if cameraAvailable {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Scan label", systemImage: "camera.viewfinder")
                        }
                        .buttonStyle(GoldButtonStyle())
                    }
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(cameraAvailable ? "Photo library" : "Choose label photo", systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(OutlineButtonStyle())
                }

                if isScanning {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Reading label…").font(.subheadline)
                    }
                }
                if let message {
                    Text(message).font(.footnote).foregroundStyle(.secondary)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    Task { await process(image) }
                }
                .ignoresSafeArea()
            }
            .onChange(of: pickerItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await process(image)
                    } else {
                        message = "Couldn't open that photo."
                    }
                    pickerItem = nil
                }
            }
        } header: {
            SerifHeader(text: "Label")
        } footer: {
            Text("Take a clear, well-lit photo of the front label. Text is read on your phone and fills in blank fields, so check the result.")
        }
        .vinoRows()
    }

    @MainActor
    private func process(_ image: UIImage) async {
        isScanning = true
        message = nil
        defer { isScanning = false }

        let prepared = image.normalized(maxDimension: 1600)
        wine.labelImageData = prepared.jpegData(compressionQuality: 0.7)

        do {
            let lines = try await LabelScanner.recognize(prepared)
            wine.labelCropData = LabelScanner.labelCrop(from: prepared, lines: lines)?
                .jpegData(compressionQuality: 0.85)
            let scanned = LabelParser.parse(lines)
            if scanned.isEmpty {
                message = "Couldn't pick out wine details. Try better light or a straighter angle, or fill it in by hand."
            } else {
                scanned.fillEmptyFields(of: wine)
                message = "Filled in from the label. Please double-check the details below."
            }
        } catch {
            message = "Couldn't read that photo. Fill the details in by hand."
        }
    }
}

/// Minimal wrapper around the system camera.
struct CameraPicker: UIViewControllerRepresentable {
    let onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage { parent.onImage(image) }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
