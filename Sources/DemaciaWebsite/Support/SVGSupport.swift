//
//  SVGSupport.swift
//  
//
//  Created by Noam Alffasy on 10/08/2020.
//

import Plot

extension HTML {
    enum SVGContext {}
    enum PathContext {}
}

enum HTMLPathFillRule: String {
    case nonZero = "nonzero"
    case evenOdd = "evenodd"
    case inherit = "inherit"
}

enum HTMLPathStrokeLineCap: String {
    case butt = "butt"
    case round = "round"
    case square = "square"
}

enum HTMLPathStrokeLineJoin: String {
    case arcs = "arcs"
    case bevel = "bevel"
    case miter = "miter"
    case miterClip = "miter-clip"
    case round = "round"
}

extension Node where Context == HTML.BodyContext {
    static func svg(_ nodes: Node<HTML.SVGContext>...) -> Node {
        .element(named: "svg", nodes: nodes)
    }
}

extension Node where Context == HTML.AnchorContext {
    static func svg(_ nodes: Node<HTML.SVGContext>...) -> Node {
        .element(named: "svg", nodes: nodes)
    }
}

extension Node where Context == HTML.SVGContext {
    static func viewbox(_ viewBox: String) -> Self {
        .attribute(named: "viewbox", value: viewBox)
    }
    
    static func xmlns(_ xmlns: String) -> Self {
        .attribute(named: "xmlns", value: xmlns)
    }
    
    static func title(_ text: String) -> Self {
        .element(named: "title", nodes: [.text(text)])
    }
    
    static func path(_ attributes: Attribute<HTML.PathContext>...) -> Self {
        .element(named: "path", attributes: attributes)
    }
}

extension Attribute where Context == HTML.PathContext {
    static func d(_ d: String) -> Attribute {
        .attribute(named: "d", value: d)
    }
    
    static func fill(_ fill: String) -> Attribute {
        .attribute(named: "fill", value: fill)
    }
    
    static func fillRule(_ rule: HTMLPathFillRule) -> Attribute {
        .attribute(named: "fill-rule", value: rule.rawValue)
    }
    
    static func stroke(_ stroke: String) -> Attribute {
        .attribute(named: "stroke", value: stroke)
    }
    
    static func strokeWidth(_ width: Double) -> Attribute {
        .attribute(named: "stroke-width", value: String(width))
    }
    
    static func strokeLinecap(_ linecap: HTMLPathStrokeLineCap) -> Attribute {
        .attribute(named: "stroke-linecap", value: linecap.rawValue)
    }
    
    static func strokeLinejoin(_ linejoin: HTMLPathStrokeLineJoin) -> Attribute {
        .attribute(named: "stroke-linejoin", value: linejoin.rawValue)
    }
}
