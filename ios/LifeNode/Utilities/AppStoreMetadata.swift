import Foundation

enum AppStoreMetadata {
    static let appName = "LifeNode"
    static let subtitle = "Your Private Digital Twin & Memory Cartographer (On-Device)"
    static let version = "1.0.0"
    static let buildNumber = "1"
    static let bundleIdentifier = "app.rork.lifenode"

    static let keywords = [
        "Private", "Digital Twin", "Memory", "Journal", "Health",
        "Music", "Photo", "Map", "Life", "Reel", "On-Device",
        "Privacy-First", "Free", "AI", "Productivity", "Wellness"
    ]

    static let shortDescription = "Transform your scattered memories into an interactive, private Memory Graph — 100% free and on-device."

    static let fullDescription = """
    LifeNode transforms your scattered digital memories into a stunning, interactive 3D Memory Graph — entirely on your device.

    YOUR PRIVATE DIGITAL TWIN
    LifeNode weaves together your photos, workouts, music, and locations into a rich tapestry of interconnected memories. Explore your life's journey on a beautiful 3D map, discover hidden connections between moments, and relive your most meaningful experiences.

    FREE TO START — PREMIUM TO UNLOCK
    Explore up to 1,000 Memory Nodes and create 3 Life Reels per month for free. Upgrade to Premium ($29.99/year) for unlimited nodes, unlimited Pro Reels with advanced themes, and deeper analytics.

    PRIVACY-FIRST BY DESIGN
    • All data stays on your device — zero cloud uploads
    • No accounts, logins, or registration required
    • No tracking, advertising, or data collection
    • No third-party analytics or SDKs
    • Works fully offline

    INTERACTIVE 3D MEMORY MAP
    Explore your memories plotted on a stunning satellite map. Tap nodes to reveal rich Memory Cards with photos, workout stats, music details, and location context. Pinch, zoom, and pan through your life's geography.

    LIFE REEL GENERATOR
    Create shareable video compilations of your memories with smart templates, custom themes, and beautiful transitions. Share your story on TikTok, Instagram, or with friends.

    INTELLIGENT CONNECTIONS
    On-device AI discovers hidden connections between your memories — linking workouts with the music you listened to, photos with the places you visited, and moments that share a deeper connection.

    FEATURES
    • 3D satellite Memory Map with clustering
    • Multi-Sensory Memory Cards
    • Life Reel video generator with themes
    • Smart Templates based on your data
    • Activity insights and trend analysis
    • Daily memory highlight notifications
    • Achievement system
    • Full HealthKit, MusicKit, and PhotoKit integration
    • Background data synchronization
    • Dark mode optimized
    """

    static let reviewNote = """
    LifeNode is a privacy-first application with a freemium model. All data processing occurs entirely on-device — the app makes no network requests for core functionality and collects zero user data. Premium subscription ($29.99/year) unlocks unlimited Memory Nodes, unlimited Life Reels, and advanced analytics. A 7-day free trial is included.

    The app requires HealthKit, MusicKit, and Photo Library access to build the user's Memory Graph. All permissions are optional and clearly explained during onboarding. Sample data can be generated from Settings for testing without granting permissions.

    To test: Launch the app → Complete onboarding → Go to Settings → Tap "Generate Sample Data" to populate the Memory Graph with test nodes. Then explore the 3D map, timeline, insights, and Life Reel generator.
    """
}
