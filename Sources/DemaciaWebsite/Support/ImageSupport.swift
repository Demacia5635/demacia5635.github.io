//
//  ImageSupport.swift
//  
//
//  Created by Noam Alffasy on 12/08/2020.
//

import Plot

public extension Attribute where Context == HTML.PictureSourceContext {
    /// Define a set of media conditions and indicates which source should be used.
    ///- parameter query: The media condition that the browser should evaluate.
    static func sizes(_ query: String) -> Attribute {
        attribute(named: "sizes", value: query)
    }
    
    /// Define the source's type.
    ///- parameter type: The source's type
    static func type(_ type: String) -> Attribute {
        attribute(named: "type", value: type)
    }
}
