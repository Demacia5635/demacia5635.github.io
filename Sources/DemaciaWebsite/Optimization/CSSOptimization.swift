//
//  CSSOptimization.swift
//  
//
//  Created by Noam Alffasy on 12/08/2020.
//

import Foundation
import Publish
import Files

extension PublishingStep where Site == DemaciaWebsite {
    static func inlineCSS() -> Self {
        .step(named: "Inline critical CSS") { context in
            let output = try context.folder(at: "Output")
            let critical = try context.folder(at: "critical").file(at: "cli.js")
            
            for file in output.files.recursive {
                guard file.isHTML else { continue }

                shell("cat \(file.path) | '\(critical.path)' -b \(output.path) --inline -e > \(file.path).critical")
                
                let criticalFile = try file.parent!.file(at: file.name + ".critical")
                
                try file.write(criticalFile.read())
                try criticalFile.delete()
            }
        }
    }
    
    static func removeUnusedCSS(whitelist: [String] = []) -> Self {
        .step(named: "Remove unused CSS") { context in
            let output = try context.folder(at: "Output")
            let purify = try context.folder(at: "purifycss").file(at: "bin/purifycss")
            
            for file in output.files.recursive {
                guard file.isHTML else { continue }

                let html = try file.readAsString()
                let regex = try NSRegularExpression(pattern: #"styles\.([a-z0-9]+)\.css"#, options: .allowCommentsAndWhitespace)
                let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
                let styleId = String(html[Range(matches[0].range(at: 1), in: html)!])
                let styleFile = try output.file(at: "styles.\(styleId).css")
                
                shell("\(purify.path) \(styleFile.path) \(file.path) -m -i -w '\(whitelist.joined(separator: "' '"))' -o \(styleFile.path)")
            }
        }
    }
}

private extension File {
    private static let htmlFileExtensions: Set<String> = ["html"]
    
    var isHTML: Bool {
        self.extension.map(File.htmlFileExtensions.contains) ?? false
    }
}
