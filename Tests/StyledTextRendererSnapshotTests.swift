//
//  StyledTextKitRendererSnapshotTests.swift
//  StyledTextKitTests
//
//  Created by Ryan Nystrom on 12/14/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import XCTest
import iOSSnapshotTestCase
import UIKit
@testable import StyledTextKit

extension UIView {

    func mount(width: CGFloat, renderer: StyledTextRenderer) -> UIView {
        frame = CGRect(origin: .zero, size: renderer.size(in: width))
        layer.contents = renderer.render(for: width).image
        return self
    }

}

extension Optional where Wrapped: OptionSet, Wrapped.Element == Wrapped {
    mutating func insert(_ newValue: Wrapped) {
        var existing = self ?? []
        existing.insert(newValue)
        self = .some(existing)
    }
}

extension NSTextAttachment: @unchecked @retroactive Sendable {}

extension AttributedString {
    init(_ string: String, body: (inout AttributeContainer) -> Void) {
        var container = AttributeContainer()
        body(&container)
        self.init(string, attributes: container)
    }

    init(attachment: NSTextAttachment) {
        self.init(
            String(UnicodeScalar(NSTextAttachment.character)!),
            attributes: AttributeContainer.attachment(attachment),
        )
    }
}

@MainActor
class SnapTests: FBSnapshotTestCase {

    let testScale: CGFloat = 2
    let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    let sizeCache = LRUCache<StyledTextRenderCacheKey, CGSize>(
        maxSize: 1000, // CGSize cache size always 1, treat as item count
        compaction: .default,
        clearOnWarning: true
    )
    let bitmapCache = LRUCache<StyledTextRenderCacheKey, CGImage>(
        maxSize: 1024 * 1024 * 20, // 20mb
        compaction: .default,
        clearOnWarning: true
    )
    var githubImage: UIImage {
        return UIImage(
            named: "octoface",
            in: Bundle.module,
            compatibleWith: nil
            )!.withRenderingMode(.alwaysTemplate)
    }

    override func setUp() {
        super.setUp()
//        recordMode = true
        sizeCache.clear()
        bitmapCache.clear()
        bundleResourcePath = URL(fileURLWithPath: "\(#filePath)", isDirectory: false)
            .deletingLastPathComponent()
            .path
        folderName = "Tests.SnapTests"
    }

    func test_lorem_100() {
        let string = AttributedString(lorem)
        let renderer = StyledTextRenderer(
            string: string,
            contentSizeCategory: .large,
            inset: .zero,
            backgroundColor: .white,
            layoutManager: NSLayoutManager(),
            scale: testScale,
            maximumNumberOfLines: 0,
            sizeCache: sizeCache,
            bitmapCache: bitmapCache
        )
        FBSnapshotVerifyView(UIView().mount(width: 100, renderer: renderer))
    }

    func test_lorem_200() {
        let string = AttributedString(lorem)
        let renderer = StyledTextRenderer(
            string: string,
            contentSizeCategory: .large,
            inset: .zero,
            backgroundColor: .white,
            layoutManager: NSLayoutManager(),
            scale: testScale,
            maximumNumberOfLines: 0,
            sizeCache: sizeCache,
            bitmapCache: bitmapCache
        )
        FBSnapshotVerifyView(UIView().mount(width: 200, renderer: renderer))
    }

    func test_lorem_300() {
        let string = AttributedString(lorem)
        let renderer = StyledTextRenderer(
            string: string,
            contentSizeCategory: .large,
            inset: .zero,
            backgroundColor: .white,
            layoutManager: NSLayoutManager(),
            scale: testScale,
            maximumNumberOfLines: 0,
            sizeCache: sizeCache,
            bitmapCache: bitmapCache
        )
        FBSnapshotVerifyView(UIView().mount(width: 300, renderer: renderer))
    }

    func test_complexBuilder() {
        var string = AttributedString("Hello, ")
        string += AttributedString("world!") {
            $0.inlinePresentationIntent.insert(.emphasized)
            $0.inlinePresentationIntent.insert(.stronglyEmphasized)
        }
        string += " Pop back. "
        string += AttributedString("Tiny text. ", attributes: AttributeContainer.font(.systemFont(ofSize: 6)))
        string += AttributedString("Big text. ", attributes: AttributeContainer.font(.systemFont(ofSize: 20)))
        string += AttributedString("Background color.") {
            $0.inlinePresentationIntent.insert(.stronglyEmphasized)
            $0.backgroundColor = UIColor.blue
            $0.foregroundColor = UIColor.white
        }
        let renderer = StyledTextRenderer(
            string: string,
            contentSizeCategory: .large,
            inset: .zero,
            backgroundColor: .white,
            layoutManager: NSLayoutManager(),
            scale: testScale,
            maximumNumberOfLines: 0,
            sizeCache: sizeCache,
            bitmapCache: bitmapCache
        )
        FBSnapshotVerifyView(UIView().mount(width: 300, renderer: renderer))
    }

    func test_clearBackground() {
        let string = AttributedString(lorem)
        let renderer = StyledTextRenderer(string: string, contentSizeCategory: .large, scale: testScale)
        let view = UIView()
        view.backgroundColor = .blue
        FBSnapshotVerifyView(UIView().mount(width: 300, renderer: renderer))
    }
    
    func test_maxNumberOfLinesUnlimited() {
        let string = AttributedString(lorem)
        let renderer = StyledTextRenderer(
            string: string,
            contentSizeCategory: .large,
            inset: .zero,
            backgroundColor: .white,
            layoutManager: NSLayoutManager(),
            scale: testScale,
            maximumNumberOfLines: 0,
            sizeCache: sizeCache,
            bitmapCache: bitmapCache
        )
        FBSnapshotVerifyView(UIView().mount(width: 300, renderer: renderer))
    }
    
    func test_maxNumberOfLinesLimited() {
        let string = AttributedString(lorem)
        let renderer = StyledTextRenderer(
            string: string,
            contentSizeCategory: .large,
            inset: .zero,
            backgroundColor: .white,
            layoutManager: NSLayoutManager(),
            scale: testScale,
            maximumNumberOfLines: 2,
            sizeCache: sizeCache,
            bitmapCache: bitmapCache
        )
        FBSnapshotVerifyView(UIView().mount(width: 300, renderer: renderer))
    }

    func test_addingImageWithTint_withNoOptions() {
        var string = AttributedString("Hello ")
        let attachment = NSTextAttachment(image: githubImage)
        string += AttributedString(attachment: attachment)
            .mergingAttributes(AttributeContainer.foregroundColor(UIColor.green))
        string += " world!"
        let renderer = StyledTextRenderer(
            string: string,
            contentSizeCategory: .large,
            inset: .zero,
            backgroundColor: .white,
            layoutManager: NSLayoutManager(),
            scale: testScale,
            maximumNumberOfLines: 2,
            sizeCache: sizeCache,
            bitmapCache: bitmapCache
        )
        FBSnapshotVerifyView(UIView().mount(width: 300, renderer: renderer))
    }
}
