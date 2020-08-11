//
//  JSOptimization.swift
//  
//
//  Created by Noam Alffasy on 12/08/2020.
//

import Publish
import Files

extension PublishingStep where Site == DemaciaWebsite {
    static func uglifyJS() -> Self {
        .step(named: "Uglify JavaScript") { context in
            let resources = try context.folder(at: "Resources")
            
            for file in resources.files.recursive {
                guard file.isJS else { continue }
                
                shell("terser -c -m -- \(file.path) > \(file.path.replacingOccurrences(of: "Resources", with: "Output"))")
            }
        }
    }
}

private extension File {
    private static let jsFileExtensions: Set<String> = ["js"]
    
    var isJS: Bool {
        self.extension.map(File.jsFileExtensions.contains) ?? false
    }
}
