//
//  Untitled.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation
import UniformTypeIdentifiers

enum MIMEType: String {
    // MARK: - Images
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case webp = "image/webp"
    case heic = "image/heic"
    case svg = "image/svg+xml"

    // MARK: - Video
    case mp4 = "video/mp4"
    case mov = "video/quicktime"

    // MARK: - Audio
    case mp3 = "audio/mpeg"
    case aac = "audio/aac"
    case wav = "audio/wav"

    // MARK: - Documents
    case pdf = "application/pdf"
    case json = "application/json"
    case zip = "application/zip"

    // MARK: - Binary (fallback)
    case octetStream = "application/octet-stream"

    /// The conventional file extension for this MIME type.
    var fileExtension: String {
        switch self {
        case .jpeg:
            "jpg"
        case .png:
            "png"
        case .gif:
            "gif"
        case .webp:
            "webp"
        case .heic:
            "heic"
        case .svg:
            "svg"
        case .mp4:
            "mp4"
        case .mov:
            "mov"
        case .mp3:
            "mp3"
        case .aac:
            "aac"
        case .wav:
            "wav"
        case .pdf:
            "pdf"
        case .json:
            "json"
        case .zip:
            "zip"
        case .octetStream:
            "bin"
        }
    }

    // MARK: - Detection from raw data via file signature (magic bytes)

    /// Attempts to detect the MIME type by inspecting the leading bytes of the data.
    /// Returns `nil` if the signature is not recognized.
    init?(data: Data) {
        guard data.count >= 12 else {
            return nil
        }
        let bytes = [UInt8](data.prefix(12))

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if bytes.starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
            self = .png
            return
        }
        // JPEG: FF D8 FF
        if bytes.starts(with: [0xFF, 0xD8, 0xFF]) {
            self = .jpeg
            return
        }
        // GIF: 47 49 46 38 ("GIF8")
        if bytes.starts(with: [0x47, 0x49, 0x46, 0x38]) {
            self = .gif
            return
        }
        // PDF: 25 50 44 46 ("%PDF")
        if bytes.starts(with: [0x25, 0x50, 0x44, 0x46]) {
            self = .pdf
            return
        }
        // ZIP: 50 4B 03 04
        if bytes.starts(with: [0x50, 0x4B, 0x03, 0x04]) {
            self = .zip
            return
        }
        // MP3: FF FB / FF F3 / FF F2 or ID3 tag (49 44 33)
        if bytes.starts(with: [0xFF, 0xFB]) ||
            bytes.starts(with: [0xFF, 0xF3]) ||
            bytes.starts(with: [0xFF, 0xF2]) ||
            bytes.starts(with: [0x49, 0x44, 0x33]) {
            self = .mp3
            return
        }
        // RIFF-based: WebP or WAV
        if bytes.starts(with: [0x52, 0x49, 0x46, 0x46]) { // "RIFF"
            let subtype = bytes[8...11]

            if subtype.elementsEqual([0x57, 0x45, 0x42, 0x50]) { // "WEBP"
                self = .webp
                return
            }
            if subtype.elementsEqual([0x57, 0x41, 0x56, 0x45]) { // "WAVE"
                self = .wav
                return
            }
        }
        // ISO Base Media File Format: MP4, MOV, HEIC — "ftyp" at offset 4
        if bytes[4...7].elementsEqual([0x66, 0x74, 0x79, 0x70]) { // "ftyp"
            let brand = bytes[8...11]
            // QuickTime: "qt  "
            if brand.elementsEqual([0x71, 0x74, 0x20, 0x20]) {
                self = .mov
                return
            }
            // HEIC: "heic", "heix", "mif1"
            if brand.elementsEqual([0x68, 0x65, 0x69, 0x63])
                || brand.elementsEqual([0x68, 0x65, 0x69, 0x78])
                || brand.elementsEqual([0x6D, 0x69, 0x66, 0x31]) {
                self = .heic
                return
            }
            // Default ISO BMFF → MP4
            self = .mp4
            return
        }
        return nil
    }

    // MARK: - Detection from file URL or extension via UTType

    /// Attempts to determine the MIME type from a file URL using `UTType`.
    static func from(fileURL: URL) -> MIMEType {
        if let utType = UTType(filenameExtension: fileURL.pathExtension),
           let mimeType = utType.preferredMIMEType,
           let resolved = MIMEType(rawValue: mimeType) {
            return resolved
        }
        return .octetStream
    }

    /// Attempts to determine the MIME type from a file extension string using `UTType`.
    static func from(fileExtension: String) -> MIMEType {
        if let utType = UTType(filenameExtension: fileExtension),
           let mimeType = utType.preferredMIMEType,
           let resolved = MIMEType(rawValue: mimeType) {
            return resolved
        }
        return .octetStream
    }
}
