//
//  SlideshowFileHandler.swift
//  
//
//  Created by Noam Alffasy on 10/08/2020.
//

import Publish
import Files

var slides: [String] = []

struct SlideshowFileHandler {
    func addSlideshowFiles(in folder: Folder, to context: inout PublishingContext<DemaciaWebsite>) throws {
        for file in folder.files.recursive {
            guard file.isImage else { continue }
            
            do {
                let path = file.path(relativeTo: folder)
                
                context.addSlide(at: path)
            }
        }
    }
}

private extension File {
    private static let imageFileExtensions: Set<String> = ["png", "jpg", "jpeg", "webp"]
    
    var isImage: Bool {
        self.extension.map(File.imageFileExtensions.contains) ?? false
    }
}

extension PublishingContext where Site == DemaciaWebsite {
    mutating func addSlide(at path: String) {
        slides.append("/img/slideshow/" + path)
    }
}

extension PublishingStep where Site == DemaciaWebsite {
    static func addSlides(at path: Path = "Resources/img/slideshow") -> Self {
        .step(named: "Add slides from '\(path)' folder") { context in
            let folder = try context.folder(at: path)
            try SlideshowFileHandler().addSlideshowFiles(in: folder, to: &context)
        }
    }
}

