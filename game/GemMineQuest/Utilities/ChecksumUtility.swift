import Foundation
import CryptoKit

enum ChecksumUtility {
    /// Compute HMAC-SHA256 for data integrity verification.
    static func hmac(for data: Data, salt: String) -> String {
        let key = SymmetricKey(data: Data(salt.utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(mac).base64EncodedString()
    }
}
