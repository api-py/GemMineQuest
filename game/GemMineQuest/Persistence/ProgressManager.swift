import SwiftUI
import CryptoKit

class ProgressManager: ObservableObject {
    @Published var progress: PlayerProgress

    private static let storageKey = "playerProgress"
    private static let checksumKey = "playerProgressChecksum"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey) {
            let storedChecksum = UserDefaults.standard.string(forKey: Self.checksumKey)
            let computedChecksum = Self.checksum(for: data)

            if storedChecksum == computedChecksum {
                do {
                    let decoded = try JSONDecoder().decode(PlayerProgress.self, from: data)
                    self.progress = decoded
                    return
                } catch {
                    print("[ProgressManager] Decode error: \(error.localizedDescription)")
                }
            } else {
                print("[ProgressManager] Data integrity check failed — resetting to defaults")
            }
        }
        self.progress = PlayerProgress()
    }

    func saveLevelResult(level: Int, stars: Int, score: Int) {
        progress.recordResult(level: level, stars: stars, score: score)
        save()
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        progress.isUnlocked(level)
    }

    func resetProgress() {
        progress = PlayerProgress()
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
        UserDefaults.standard.set(Self.checksum(for: data), forKey: Self.checksumKey)
    }

    private static func checksum(for data: Data) -> String {
        let key = SymmetricKey(data: Data("GemMineQuest.progress.salt.v1".utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(mac).base64EncodedString()
    }
}
