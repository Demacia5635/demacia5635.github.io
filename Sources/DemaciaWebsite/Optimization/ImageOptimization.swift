//
//  ImageOptimization.swift
//  
//
//  Created by Noam Alffasy on 12/08/2020.
//

import Foundation
import Publish
import Ink
import Files

struct Image {
    let path: String
    let width: Int
}

var images = [Image]()

extension Plugin {
    static var prepareImagesForOptimization: Self {
        Plugin(name: "Prepare images for optimization") { context in
            context.markdownParser.addModifier(Modifier(target: .images) { html, markdown in
                let src = html.split(separator: "\"")[1]
                let widthPercentageOnPage = Int(src.split(separator: "?")[1].replacingOccurrences(of: "width=", with: "")) ?? 100
                let filePath = String(src.split(separator: "?").first!)
                let fileExt = filePath.split(separator: ".").last!
                let fileNoExtPath = filePath.replacingOccurrences(of: "." + fileExt, with: "")
                let screenSizes = [768, 1024, 1216, 1408]
                let fileSizes = screenSizes.map { Int(round(Double($0 * widthPercentageOnPage) * 0.01)) }
                let srcset = screenSizes.enumerated().map { "\(fileNoExtPath)-\($1)px.webp \(fileSizes[$0])w" }.joined(separator: ", ")
                let sizes = screenSizes.enumerated().map { screenSizes.last == $1 ? "\(widthPercentageOnPage)vw": "(max-width: \($1)px) \(widthPercentageOnPage)vw" }.joined(separator: ", ")
                
                images.append(Image(path: filePath, width: widthPercentageOnPage))

                return "<picture><source srcset=\"\(srcset)\" sizes=\"\(sizes)\" type=\"image/webp\">\(html.replacingOccurrences(of: ">", with: "width=\"\(widthPercentageOnPage)%\">"))</picture>"
            })
        }
    }
}

extension PublishingStep where Site == DemaciaWebsite {
    static func optimizeImages() -> Self {
        .step(named: "Optimize images") { context in
            let output = try context.folder(at: "Output")
            
            for file in output.files.recursive {
                guard file.isImage else { continue }
                guard images.contains(where: { $0.path == "/" + file.path(relativeTo: output) }) else { continue }
                
                let image = images.first(where: { $0.path == "/" + file.path(relativeTo: output) })!
                let fileNoExt = file.path.replacingOccurrences(of: "." + file.extension!, with: "")
                let sizes = [768, 1024, 1216, 1408]
                
                if file.extension! != "webp" {
                    sizes.forEach { size in
                        shell("cwebp \(file.path) -resize \(round(Double(size * image.width) * 0.01)) 0 -o \(fileNoExt)-\(size)px.webp")
                    }
                    shell("cwebp \(file.path) -o \(fileNoExt).webp")
                } else {
                    shell("dwebp \(file.path) -o \(fileNoExt).png")
                    shell("imagemin \(file.path) -p=jpegtran > \(fileNoExt).jpg")
                    sizes.forEach { size in
                        shell("cwebp \(fileNoExt).png -resize \(round(Double(size * image.width) * 0.01)) 0 -o \(fileNoExt)-\(size)px.webp")
                    }
                }
            }
        }
    }
}
