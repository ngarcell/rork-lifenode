import SwiftUI
import SwiftData
import Photos
import UIKit
import AVFoundation

@Observable
@MainActor
final class LifeReelViewModel {
    var selectedTimeRange: ReelTimeRange = .lastMonth
    var selectedTheme: ReelTheme = .highlights
    var isGenerating: Bool = false
    var generationProgress: Double = 0
    var generationStatus: String = ""
    var generatedImages: [UIImage] = []
    var reelNodes: [MemoryNode] = []
    var smartTemplates: [SmartTemplate] = []
    var showPreview: Bool = false
    var showShareSheet: Bool = false
    var exportedVideoURL: URL?

    func loadSmartTemplates(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<MemoryNode>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        guard let allNodes = try? modelContext.fetch(descriptor) else { return }

        var templates: [SmartTemplate] = []

        let workoutNodes = allNodes.filter { $0.type == .workout }
        if workoutNodes.count >= 5 {
            templates.append(SmartTemplate(
                title: "Your Fitness Journey",
                subtitle: "\(workoutNodes.count) workouts tracked",
                theme: .fitness,
                timeRange: .last3Months,
                icon: "figure.run",
                nodeCount: workoutNodes.count
            ))
        }

        let musicNodes = allNodes.filter { $0.type == .music }
        if musicNodes.count >= 5 {
            templates.append(SmartTemplate(
                title: "Your Soundtrack",
                subtitle: "\(musicNodes.count) songs remembered",
                theme: .musicMemories,
                timeRange: .last3Months,
                icon: "music.note.list",
                nodeCount: musicNodes.count
            ))
        }

        let photoNodes = allNodes.filter { $0.type == .photo }
        if photoNodes.count >= 5 {
            templates.append(SmartTemplate(
                title: "Photo Memories",
                subtitle: "\(photoNodes.count) moments captured",
                theme: .photoAlbum,
                timeRange: .lastMonth,
                icon: "photo.on.rectangle.angled",
                nodeCount: photoNodes.count
            ))
        }

        let geoNodes = allNodes.filter { $0.latitude != 0 || $0.longitude != 0 }
        let uniquePlaces = Set(geoNodes.map { "\(Int($0.latitude * 10))-\(Int($0.longitude * 10))" })
        if uniquePlaces.count >= 3 {
            templates.append(SmartTemplate(
                title: "Travel Highlights",
                subtitle: "\(uniquePlaces.count) places visited",
                theme: .adventure,
                timeRange: .last3Months,
                icon: "map.fill",
                nodeCount: geoNodes.count
            ))
        }

        if templates.isEmpty {
            templates.append(SmartTemplate(
                title: "All Highlights",
                subtitle: "\(allNodes.count) memories",
                theme: .highlights,
                timeRange: .allTime,
                icon: "sparkles",
                nodeCount: allNodes.count
            ))
        }

        smartTemplates = templates
    }

    func applyTemplate(_ template: SmartTemplate) {
        selectedTheme = template.theme
        selectedTimeRange = template.timeRange
    }

    func generateReel(modelContext: ModelContext) async {
        isGenerating = true
        generationProgress = 0
        generationStatus = "Gathering memories..."
        generatedImages = []

        let startDate = selectedTimeRange.startDate
        var descriptor = FetchDescriptor<MemoryNode>(
            predicate: #Predicate<MemoryNode> { $0.timestamp >= startDate },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        descriptor.fetchLimit = 50

        guard let nodes = try? modelContext.fetch(descriptor), !nodes.isEmpty else {
            generationStatus = "No memories found for this period"
            isGenerating = false
            return
        }

        let filteredNodes: [MemoryNode]
        switch selectedTheme {
        case .fitness:
            filteredNodes = nodes.filter { $0.type == .workout }
        case .musicMemories:
            filteredNodes = nodes.filter { $0.type == .music }
        case .photoAlbum:
            filteredNodes = nodes.filter { $0.type == .photo }
        case .adventure:
            filteredNodes = nodes.filter { $0.latitude != 0 || $0.longitude != 0 }
        default:
            filteredNodes = nodes
        }

        let reelContent = filteredNodes.isEmpty ? Array(nodes.prefix(20)) : Array(filteredNodes.prefix(20))
        reelNodes = reelContent

        generationProgress = 0.2
        generationStatus = "Creating visual story..."
        try? await Task.sleep(for: .seconds(0.5))

        for (index, node) in reelContent.enumerated() {
            let progress = 0.2 + (Double(index) / Double(reelContent.count)) * 0.6
            generationProgress = progress
            generationStatus = "Rendering frame \(index + 1) of \(reelContent.count)..."

            let image = renderNodeFrame(node, index: index, total: reelContent.count)
            generatedImages.append(image)
            try? await Task.sleep(for: .milliseconds(150))
        }

        generationProgress = 0.85
        generationStatus = "Composing reel..."
        try? await Task.sleep(for: .seconds(0.5))

        await exportVideo()

        generationProgress = 1.0
        generationStatus = "Reel ready!"
        try? await Task.sleep(for: .seconds(0.3))

        isGenerating = false
        showPreview = true
    }

    private func renderNodeFrame(_ node: MemoryNode, index: Int, total: Int) -> UIImage {
        let size = CGSize(width: 1080, height: 1920)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { ctx in
            let context = ctx.cgContext

            let themeColors = themeGradientUIColors
            let startColor = themeColors.0
            let endColor = themeColors.1

            let colors = [startColor.cgColor, endColor.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) {
                context.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            let iconText: String
            switch node.type {
            case .photo: iconText = "📷"
            case .workout: iconText = "🏃"
            case .music: iconText = "🎵"
            case .checkin: iconText = "📍"
            }

            let iconAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 120)
            ]
            let iconStr = NSString(string: iconText)
            let iconSize = iconStr.size(withAttributes: iconAttrs)
            iconStr.draw(
                at: CGPoint(x: (size.width - iconSize.width) / 2, y: size.height * 0.25),
                withAttributes: iconAttrs
            )

            let titleText: String
            switch node.type {
            case .workout:
                titleText = node.workoutData?.activityType ?? "Workout"
            case .music:
                if let music = node.musicData {
                    titleText = "\(music.songTitle)\n\(music.artistName)"
                } else {
                    titleText = "Music"
                }
            case .photo:
                titleText = "Photo Memory"
            case .checkin:
                titleText = node.note ?? "Check-in"
            }

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 64, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleRect = CGRect(x: 80, y: size.height * 0.45, width: size.width - 160, height: 300)
            let titleNS = NSString(string: titleText)
            titleNS.draw(in: titleRect, withAttributes: titleAttrs)

            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let dateText = node.timestamp.formatted(date: .long, time: .omitted)
            let dateNS = NSString(string: dateText)
            dateNS.draw(
                at: CGPoint(x: 80, y: size.height * 0.65),
                withAttributes: dateAttrs
            )

            if node.type == .workout, let workout = node.workoutData {
                let statsText = "\(Int(workout.caloriesBurned)) cal · \(Int(workout.duration / 60)) min"
                let statsAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 32, weight: .regular),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.7)
                ]
                NSString(string: statsText).draw(
                    at: CGPoint(x: 80, y: size.height * 0.70),
                    withAttributes: statsAttrs
                )
            }

            let counterText = "\(index + 1) / \(total)"
            let counterAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            let counterNS = NSString(string: counterText)
            let counterSize = counterNS.size(withAttributes: counterAttrs)
            counterNS.draw(
                at: CGPoint(x: (size.width - counterSize.width) / 2, y: size.height * 0.88),
                withAttributes: counterAttrs
            )

            let watermark = "#LifeNodeApp — Private & On-Device"
            let wmAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.4)
            ]
            let wmNS = NSString(string: watermark)
            let wmSize = wmNS.size(withAttributes: wmAttrs)
            wmNS.draw(
                at: CGPoint(x: (size.width - wmSize.width) / 2, y: size.height * 0.94),
                withAttributes: wmAttrs
            )
        }
    }

    private var themeGradientUIColors: (UIColor, UIColor) {
        switch selectedTheme {
        case .highlights: return (UIColor.systemPurple, UIColor.systemBlue)
        case .adventure: return (UIColor.systemOrange, UIColor.systemRed)
        case .relaxation: return (UIColor.systemGreen, UIColor.systemTeal)
        case .fitness: return (UIColor.systemGreen, UIColor.systemYellow)
        case .musicMemories: return (UIColor.systemPurple, UIColor.systemPink)
        case .photoAlbum: return (UIColor.systemBlue, UIColor.systemCyan)
        }
    }

    private func exportVideo() async {
        guard !generatedImages.isEmpty else { return }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("LifeReel_\(UUID().uuidString).mp4")

        try? FileManager.default.removeItem(at: outputURL)

        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else { return }

        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1080,
            AVVideoHeightKey: 1920
        ]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: 1080,
                kCVPixelBufferHeightKey as String: 1920
            ]
        )

        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        let frameDuration = CMTime(value: 90, timescale: 30)

        for (index, image) in generatedImages.enumerated() {
            while !writerInput.isReadyForMoreMediaData {
                try? await Task.sleep(for: .milliseconds(10))
            }

            if let buffer = pixelBuffer(from: image) {
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(index))
                adaptor.append(buffer, withPresentationTime: presentationTime)
            }
        }

        writerInput.markAsFinished()
        await writer.finishWriting()

        if writer.status == .completed {
            exportedVideoURL = outputURL
        }
    }

    private nonisolated func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let width = 1080
        let height = 1920

        var pixelBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width, height,
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        let data = CVPixelBufferGetBaseAddress(buffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }

        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)

        UIGraphicsPushContext(context)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }

    func shareItems() -> [Any] {
        var items: [Any] = []
        if let url = exportedVideoURL {
            items.append(url)
        } else if let first = generatedImages.first {
            items.append(first)
        }
        items.append("#LifeNodeApp — Private & On-Device")
        return items
    }
}
