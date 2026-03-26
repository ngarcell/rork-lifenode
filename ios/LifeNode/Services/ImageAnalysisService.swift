import Foundation
import Vision
import Photos
import UIKit

@Observable
@MainActor
final class ImageAnalysisService {

    func analyzeDominantColor(for assetIdentifier: String) async -> String? {
        guard let image = await loadThumbnail(for: assetIdentifier) else { return nil }
        return await extractDominantColor(from: image)
    }

    func generateBlurhash(for assetIdentifier: String) async -> String {
        guard let image = await loadThumbnail(for: assetIdentifier),
              let cgImage = image.cgImage else { return "" }

        let width = cgImage.width
        let height = cgImage.height
        let size = min(width, height, 32)

        guard let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return "" }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size, height: size))

        guard let data = context.data else { return "" }
        let pointer = data.bindMemory(to: UInt8.self, capacity: size * size * 4)

        var r: Int = 0, g: Int = 0, b: Int = 0
        let totalPixels = size * size
        for i in 0..<totalPixels {
            r += Int(pointer[i * 4])
            g += Int(pointer[i * 4 + 1])
            b += Int(pointer[i * 4 + 2])
        }

        let avgR = r / totalPixels
        let avgG = g / totalPixels
        let avgB = b / totalPixels

        return String(format: "%02X%02X%02X", avgR, avgG, avgB)
    }

    private nonisolated func extractDominantColor(from image: UIImage) async -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let extent = ciImage.extent
        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: extent)
        ])

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        return String(format: "#%02X%02X%02X", bitmap[0], bitmap[1], bitmap[2])
    }

    private nonisolated func loadThumbnail(for identifier: String) async -> UIImage? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = assets.firstObject else { return nil }

        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.isSynchronous = false
            options.resizeMode = .fast

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 100, height: 100),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
