//
//  ImageOptimization.swift
//  
//
//  Created by Noam Alffasy on 12/08/2020.
//

import Publish
import Files

extension PublishingStep where Site == DemaciaWebsite {
    static func optimizeImages() -> Self {
        .step(named: "Optimize images") { context in
            let output = try context.folder(at: "Output")
            
            for file in output.files.recursive {
                guard file.isImage else { continue }
                
                let fileNoExt = file.path.replacingOccurrences(of: "." + file.extension!, with: "")
                let sizes = [768, 1024, 1216, 1408]
                
                if file.extension! != "webp" {
                    sizes.forEach { size in
                        shell("cwebp \(file.path) -resize \(size) 0 -o \(fileNoExt)-\(size)px.webp")
                    }
                    shell("cwebp \(file.path) -o \(fileNoExt).webp")
                } else {
                    shell("dwebp \(file.path) -o \(fileNoExt).png")
                    shell("imagemin \(file.path) -p=jpegtran > \(fileNoExt).jpg")
                    sizes.forEach { size in
                        shell("cwebp \(fileNoExt).png -resize \(size) 0 -o \(fileNoExt)-\(size)px.webp")
                    }
                }
            }
        }
    }
}
