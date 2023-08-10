//
//  HeadTagsSupport.swift
//  
//
//  Created by Noam Alffasy on 12/08/2020.
//

import Plot

extension HTML {
    enum BaseContext {}
}

extension Node where Context == HTML.HeadContext {
    static func base(_ attributes: Attribute<HTML.BaseContext>...) -> Node {
        .element(named: "base", attributes: attributes)
    }
}

extension Attribute where Context == HTML.BaseContext {
    /// Define the base URL to be used throughout the document for relative URLs
    ///- parameter baseUrl: The base URL to be used throughout the document for relative URLs
    static func href(_ baseUrl: String) -> Attribute {
        attribute(named: "href", value: baseUrl)
    }
    
    /// Define the default browsing context of the results of navigation from <a>, <area>, or <form> elements without explicit target attributes
    ///- parameter target: The keyword or author-defined name of the default browsing context
    static func type(_ target: HTMLAnchorTarget) -> Attribute {
        attribute(named: "target", value: target.rawValue)
    }
}
