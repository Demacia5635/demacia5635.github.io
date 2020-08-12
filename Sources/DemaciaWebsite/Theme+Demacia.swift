//
//  Theme+Foundation.swift
//  
//
//  Created by Noam Alffasy on 09/08/2020.
//

import Foundation
import Publish
import Plot
import Files

extension Theme where Site == DemaciaWebsite {
    static var demacia: Self {
        Theme(htmlFactory: DemaciaHTMLFactory())
    }
    
    private struct DemaciaHTMLFactory: HTMLFactory {
        func makeIndexHTML(for index: Index, context: PublishingContext<DemaciaWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: index, on: context.site),
                .body(
                    .navbar(for: context, selectedSection: nil),
                    .section(.class("hero is-primary is-bold"),
                             .div(.class("hero-body px-0 py-0 is-block"),
                                  .slideshow(for: context)
                             )
                    ),
                    .section(.class("text container has-text-centered"), .contentBody(index.body)),
                    .footer(for: context.site),
                    .script(.src("/js/logoAnimation.js"))
                )
            )
        }
        
        func makeSectionHTML(for section: Section<DemaciaWebsite>, context: PublishingContext<DemaciaWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: section, on: context.site),
                .body(.class("has-navbar-fixed-top"),
                      .navbar(for: context, selectedSection: section.id),
                      .section(.class("text container has-text-centered"), .contentBody(section.body)),
                      .footer(for: context.site)
                )
            )
        }
        
        func makeItemHTML(for item: Item<DemaciaWebsite>, context: PublishingContext<DemaciaWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: item, on: context.site),
                .body(
                    .class("item-page"),
                    .header(for: context, selectedSection: item.sectionID),
                    .wrapper(
                        .article(
                            .div(
                                .class("content"),
                                .contentBody(item.body)
                            ),
                            .span("Tagged with: "),
                            .tagList(for: item, on: context.site)
                        )
                    ),
                    .footer(for: context.site)
                )
            )
        }
        
        func makePageHTML(for page: Page, context: PublishingContext<DemaciaWebsite>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body(
                    .header(for: context, selectedSection: nil),
                    .wrapper(.contentBody(page.body)),
                    .footer(for: context.site)
                )
            )
        }
        
        func makeTagListHTML(for page: TagListPage, context: PublishingContext<DemaciaWebsite>) throws -> HTML? {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body(
                    .header(for: context, selectedSection: nil),
                    .wrapper(
                        .h1("Browse all tags"),
                        .ul(
                            .class("all-tags"),
                            .forEach(page.tags.sorted()) { tag in
                                .li(
                                    .class("tag"),
                                    .a(
                                        .href(context.site.path(for: tag)),
                                        .text(tag.string)
                                    )
                                )
                            }
                        )
                    ),
                    .footer(for: context.site)
                )
            )
        }
        
        func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<DemaciaWebsite>) throws -> HTML? {
            HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body(
                    .header(for: context, selectedSection: nil),
                    .wrapper(
                        .h1(
                            "Tagged with ",
                            .span(.class("tag"), .text(page.tag.string))
                        ),
                        .a(
                            .class("browse-all"),
                            .text("Browse all tags"),
                            .href(context.site.tagListPath)
                        ),
                        .itemList(
                            for: context.items(
                                taggedWith: page.tag,
                                sortedBy: \.date,
                                order: .descending
                            ),
                            on: context.site
                        )
                    ),
                    .footer(for: context.site)
                )
            )
        }
    }
}

extension Node where Context == HTML.DocumentContext {
    static func head(
        for location: Publish.Location,
        on site: DemaciaWebsite,
        titleSeparator: String = " | ",
        stylesheetPaths: [Path] = ["/styles.css"],
        rssFeedPath: Path? = .defaultForRSSFeed,
        rssFeedTitle: String? = nil
    ) -> Node {
        var title = location.title
        
        if title.isEmpty {
            title = site.name
        } else {
            title.append(titleSeparator + site.name)
        }
        
        var description = location.description
        
        if description.isEmpty {
            description = site.description
        }
        
        return .head(
            .encoding(.utf8),
            .siteName(site.name),
            .url(site.url(for: location)),
            .link(.rel(.preconnect), .href("https://fonts.gstatic.com")),
            .title(title),
            .description(description),
            .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
            .forEach(stylesheetPaths, { .stylesheet($0) }),
            .meta(.name("viewport"), .content("initial-scale=1, viewport-fit=cover")),
            .base(.href(site.url.absoluteString)),
            .unwrap(site.favicon, { .favicon($0) }),
            .unwrap(location.imagePath ?? site.imagePath, { path in
                let url = site.url(for: path)
                return .socialImageLink(url)
            })
        )
    }
}

extension Node where Context == HTML.BodyContext {
    static func figure(_ nodes: Node...) -> Self {
        .element(named: "figure", nodes: nodes)
    }
    
    static func slideshow(for context: PublishingContext<DemaciaWebsite>) -> Node {
        .div(.class("slideshow"),
             .div(.class("slides"),
                  .forEach(slides) { slide in
                    let className = slides.firstIndex(of: slide) == 0 ? "slide active" : "slide"
                    
                    return .image(for: context, at: slide, widthPercentageOnPage: 100, class: className, alt: "Slideshow")
                  }
             ),
             .div(.class("controls"),
                  .forEach(slides) { slide in
                    .div(.class(slides.firstIndex(of: slide) == 0 ? "control active" : "control"))
                  }
             ),
             .script(.src("/js/slides.js"))
        )
    }
    
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }
    
    static func header(
        for context: PublishingContext<DemaciaWebsite>,
        selectedSection: DemaciaWebsite.SectionID?
    ) -> Node {
        let sectionIDs = DemaciaWebsite.SectionID.allCases
        
        return .header(
            .wrapper(
                .a(.class("site-name"), .href("/"), .text(context.site.name)),
                .if(sectionIDs.count > 1,
                    .nav(
                        .ul(.forEach(sectionIDs) { section in
                            .li(.a(
                                .class(section == selectedSection ? "selected" : ""),
                                .href(context.sections[section].path),
                                .text(context.sections[section].title)
                            ))
                        })
                    )
                )
            )
        )
    }
    
    static func navbar(for context: PublishingContext<DemaciaWebsite>, selectedSection: DemaciaWebsite.SectionID?) -> Node {
        let sectionIDs = DemaciaWebsite.SectionID.allCases
        
        return .div(.class(selectedSection == nil ? "navbar is-fixed-top animate-start" : "navbar is-fixed-top"),
                    .a(.href("/"),
                        .div(.class("has-text-centered logo-outer"),
                             .figure(
                                .image(for: context, at: "/img/logo.png", widthPercentageOnPage: 50, class: "logo", alt: "Demacia#5635")
                             ),
                             .h1(.class("title is-1"), .style("text-transform: uppercase;"), .text("Demacia")),
                             .h2(.class("subtitle is-2"), .text("Ness Ziona"))
                        )
                    ),
                    .div(.class("navbar-menu"), .id("navbar"),
                         .div(.class("navbar-start"),
                              .forEach(sectionIDs, { section in
                                .a(.class(section == selectedSection ? "navbar-item is-active" : "navbar-item"),
                                   .href(context.sections[section].path),
                                   .text(context.sections[section].title)
                                )
                              })
                         )
                    )
        )
    }
    
    static func image(for context: PublishingContext<DemaciaWebsite>, at filePath: String, widthPercentageOnPage: Int, class className: String = "", alt: String = "") -> Node {
        let fileExt = filePath.split(separator: ".").last!
        let fileNoExtPath = filePath.replacingOccurrences(of: "." + fileExt, with: "")
        let screenSizes = [768, 1024, 1216, 1408]
        let fileSizes = screenSizes.map { Int(round(Double($0 * widthPercentageOnPage) * 0.01)) }
        let srcset = screenSizes.enumerated().map { "\(fileNoExtPath)-\($1)px.webp \(fileSizes[$0])w" }.joined(separator: ", ")
        let sizes = screenSizes.enumerated().map { screenSizes.last == $1 ? "\(widthPercentageOnPage)vw": "(max-width: \($1)px) \(widthPercentageOnPage)vw" }.joined(separator: ", ")
        
        images.append(Image(path: filePath, width: widthPercentageOnPage))
        
        return .picture(.class(className),
                        .source(.srcset(srcset), .sizes(sizes), .type("image/webp")),
                        .img(.src(fileExt == "png" ? filePath : fileNoExtPath + ".jpg"), .alt(alt))
        )
    }
    
    static func itemList(for items: [Item<DemaciaWebsite>], on site: DemaciaWebsite) -> Node {
        .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(.article(
                    .h1(.a(
                        .href(item.path),
                        .text(item.title)
                    )),
                    .tagList(for: item, on: site),
                    .p(.text(item.description))
                ))
            }
        )
    }
    
    static func tagList(for item: Item<DemaciaWebsite>, on site: DemaciaWebsite) -> Node {
        .ul(.class("tag-list"), .forEach(item.tags) { tag in
            .li(.a(
                .href(site.path(for: tag)),
                .text(tag.string)
            ))
        })
    }
    
    static func footer(for site: DemaciaWebsite) -> Node {
        .footer(
                .p("Demacia FRC 2020"),
                .div(.class("social-media"),
                     .a(.href("https://youtube.com/c/NoamAlffasy"), .youtubeIcon()),
                     .a(.href("https://instagram.com/NoamAlffasy"), .instagramIcon()),
                     .a(.href("https://facebook.com/NoamAlffasy"), .facebookIcon()),
                     .a(.href("https://github.com/noamalffasy"), .githubIcon()),
                     .a(.href("mailto:demacia5635@gmail.com"), .mailIcon())
                )
        )
    }
}

extension Node where Context == HTML.AnchorContext {
    static func youtubeIcon() -> Node {
        .svg(.viewbox("0 0 24 24"), .xmlns("http://www.w3.org/2000/svg"),
             .title("Go to our YouTube channel"),
             .path(
                .d("M23.495 6.205a3.007 3.007 0 0 0-2.088-2.088c-1.87-.501-9.396-.501-9.396-.501s-7.507-.01-9.396.501A3.007 3.007 0 0 0 .527 6.205a31.247 31.247 0 0 0-.522 5.805 31.247 31.247 0 0 0 .522 5.783 3.007 3.007 0 0 0 2.088 2.088c1.868.502 9.396.502 9.396.502s7.506 0 9.396-.502a3.007 3.007 0 0 0 2.088-2.088 31.247 31.247 0 0 0 .5-5.783 31.247 31.247 0 0 0-.5-5.805zM9.609 15.601V8.408l6.264 3.602z"),
                .fill("#fff")
             )
        )
    }
    
    static func instagramIcon() -> Node {
        .svg(.viewbox("0 0 24 24"), .xmlns("http://www.w3.org/2000/svg"),
             .title("Go to our Instagram page"),
             .path(
                .d("M12 0C8.74 0 8.333.015 7.053.072 5.775.132 4.905.333 4.14.63c-.789.306-1.459.717-2.126 1.384S.935 3.35.63 4.14C.333 4.905.131 5.775.072 7.053.012 8.333 0 8.74 0 12s.015 3.667.072 4.947c.06 1.277.261 2.148.558 2.913.306.788.717 1.459 1.384 2.126.667.666 1.336 1.079 2.126 1.384.766.296 1.636.499 2.913.558C8.333 23.988 8.74 24 12 24s3.667-.015 4.947-.072c1.277-.06 2.148-.262 2.913-.558.788-.306 1.459-.718 2.126-1.384.666-.667 1.079-1.335 1.384-2.126.296-.765.499-1.636.558-2.913.06-1.28.072-1.687.072-4.947s-.015-3.667-.072-4.947c-.06-1.277-.262-2.149-.558-2.913-.306-.789-.718-1.459-1.384-2.126C21.319 1.347 20.651.935 19.86.63c-.765-.297-1.636-.499-2.913-.558C15.667.012 15.26 0 12 0zm0 2.16c3.203 0 3.585.016 4.85.071 1.17.055 1.805.249 2.227.415.562.217.96.477 1.382.896.419.42.679.819.896 1.381.164.422.36 1.057.413 2.227.057 1.266.07 1.646.07 4.85s-.015 3.585-.074 4.85c-.061 1.17-.256 1.805-.421 2.227-.224.562-.479.96-.899 1.382-.419.419-.824.679-1.38.896-.42.164-1.065.36-2.235.413-1.274.057-1.649.07-4.859.07-3.211 0-3.586-.015-4.859-.074-1.171-.061-1.816-.256-2.236-.421-.569-.224-.96-.479-1.379-.899-.421-.419-.69-.824-.9-1.38-.165-.42-.359-1.065-.42-2.235-.045-1.26-.061-1.649-.061-4.844 0-3.196.016-3.586.061-4.861.061-1.17.255-1.814.42-2.234.21-.57.479-.96.9-1.381.419-.419.81-.689 1.379-.898.42-.166 1.051-.361 2.221-.421 1.275-.045 1.65-.06 4.859-.06l.045.03zm0 3.678c-3.405 0-6.162 2.76-6.162 6.162 0 3.405 2.76 6.162 6.162 6.162 3.405 0 6.162-2.76 6.162-6.162 0-3.405-2.76-6.162-6.162-6.162zM12 16c-2.21 0-4-1.79-4-4s1.79-4 4-4 4 1.79 4 4-1.79 4-4 4zm7.846-10.405c0 .795-.646 1.44-1.44 1.44-.795 0-1.44-.646-1.44-1.44 0-.794.646-1.439 1.44-1.439.793-.001 1.44.645 1.44 1.439z"),
                .fill("#fff")
             )
        )
    }
    
    static func facebookIcon() -> Node {
        .svg(.viewbox("0 0 24 24"), .xmlns("http://www.w3.org/2000/svg"),
             .title("Go to our Facebook page"),
             .path(
                .d("M23.9981 11.9991C23.9981 5.37216 18.626 0 11.9991 0C5.37216 0 0 5.37216 0 11.9991C0 17.9882 4.38789 22.9522 10.1242 23.8524V15.4676H7.07758V11.9991H10.1242V9.35553C10.1242 6.34826 11.9156 4.68714 14.6564 4.68714C15.9692 4.68714 17.3424 4.92149 17.3424 4.92149V7.87439H15.8294C14.3388 7.87439 13.8739 8.79933 13.8739 9.74824V11.9991H17.2018L16.6698 15.4676H13.8739V23.8524C19.6103 22.9522 23.9981 17.9882 23.9981 11.9991Z"),
                .fill("#fff")
             )
        )
    }

    static func githubIcon() -> Node {
        .svg(.viewbox("0 0 24 24"), .xmlns("http://www.w3.org/2000/svg"),
             .title("Go to our GitHub page"),
             .path(
                .d("M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"),
                .fill("#fff")
             )
        )
    }
    
    static func mailIcon() -> Node {
        .svg(.viewbox("0 0 180 180"), .xmlns("https://www.w3.org/20000/svg"),
             .title("Send us a mail"),
             .path(.d("M11.59+37.3942C11.59+37.3942+66.3584+104.209+90.1385+104.209C113.919+104.209+168.41+37.4147+168.41+37.4147"), .fill("none"), .stroke("#fff"), .strokeWidth(18)),
             .path(.d("M21.7744+25.8155L158.226+25.8155C163.982+25.8155+168.648+30.3655+168.648+35.9782L168.648+135.466C168.648+141.078+163.982+145.628+158.226+145.628L21.7744+145.628C16.0181+145.628+11.3517+141.078+11.3517+135.466L11.3517+35.9782C11.3517+30.3655+16.0181+25.8155+21.7744+25.8155Z"), .fill("none"), .stroke("#fff"), .strokeWidth(18))
        )
    }
}
