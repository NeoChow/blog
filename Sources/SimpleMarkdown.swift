//
//  ContentParser.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/24/16.
//
//

import Foundation
import TextTransformers

class SimpleMarkdown: StreamMapper {
    enum ParsedCharacter {
        case start
        case whitespace
        case weakNewLine
        case strongNewLine
        case header(count: Int)
        case listStart(wasWeak: Bool, bothCharacters: Bool)
        case other(Character)
        case end
    }

    fileprivate var structure = Structure.none
    fileprivate var mode = Mode.none
    fileprivate var previousStructuredCharacter = StructuredCharacter.start
    fileprivate var possibleStyle = PossibleStyle.none

    // TOOD: Add support for
    // • Headings
    // • Quotes
    // • Code Blocks

    func map(_ input: CharacterInputStream, to output: CharacterOutputStream) throws {
        var previousCharacer = ParsedCharacter.start

        func cancelParsedCharacter() {
            switch previousCharacer {
            case .end, .other, .start, .strongNewLine, .weakNewLine, .whitespace:
                break
            case .header(let count):
                for _ in 0 ..< count {
                    self.structure(parsed: .other("#"), to: output)
                }
            case let .listStart(_, bothCharacters):
                self.structure(parsed: .other("-"), to: output)
                if bothCharacters {
                    self.structure(parsed: .whitespace, to: output)
                }
            }
        }

        while let character = input.read() {
            switch character {
            case " ":
                switch previousCharacer {
                case .whitespace:
                    continue
                case .listStart(let wasWeak, false):
                    self.structure(parsed: wasWeak ? .weakNewLine : .strongNewLine, to: output)
                    self.structure(parsed: .listStart(wasWeak: wasWeak, bothCharacters: true), to: output)
                    previousCharacer = .listStart(wasWeak: wasWeak, bothCharacters: true)
                case .header(count: _):
                    self.structure(parsed: previousCharacer, to: output)
                    previousCharacer = .whitespace
                default:
                    previousCharacer = .whitespace
                }
            case "-", "•":
                switch previousCharacer {
                case .weakNewLine:
                    previousCharacer = .listStart(wasWeak: true, bothCharacters: false)
                case .start, .end, .strongNewLine:
                    previousCharacer = .listStart(wasWeak: false, bothCharacters: false)
                case .listStart:
                    cancelParsedCharacter()
                    self.structure(parsed: .other(character), to: output)
                    previousCharacer = .other(character)
                case .other, .whitespace:
                    self.structure(parsed: .other(character), to: output)
                    previousCharacer = .other(character)
                case .header:
                    cancelParsedCharacter()
                }
            case "\n":
                switch previousCharacer {
                case .weakNewLine:
                    previousCharacer = .strongNewLine
                default:
                    previousCharacer = .weakNewLine
                }
            case "#":
                var shouldFallThrough = false

                switch previousCharacer {
                case .weakNewLine, .strongNewLine:
                    previousCharacer = .header(count: 1)
                case .header(let count):
                    previousCharacer = .header(count: count + 1)
                default:
                    shouldFallThrough = true
                }
                if shouldFallThrough {
                    fallthrough
                }
            default:
                switch previousCharacer {
                case .end:
                    fatalError()
                case .listStart(true, false):
                    self.structure(parsed: .weakNewLine, to: output)
                    self.structure(parsed: .other("-"), to: output)
                case .listStart(false, false):
                    self.structure(parsed: .strongNewLine, to: output)
                    self.structure(parsed: .other("-"), to: output)
                case .start, .other, .listStart:
                    break
                case .whitespace:
                    self.structure(parsed: .whitespace, to: output)
                case .weakNewLine:
                    self.structure(parsed: .weakNewLine, to: output)
                case .strongNewLine:
                    self.structure(parsed: .strongNewLine, to: output)
                case .header:
                    cancelParsedCharacter()
                }
                self.structure(parsed: .other(character), to: output)
                previousCharacer = .other(character)
            }
        }

        self.structure(parsed: .end, to: output)
    }
}

private extension SimpleMarkdown {
    enum Structure {
        case none
        case paragraph
        case list
        case listElement
        case header(level: Int)
    }

    enum StructuredCharacter {
        case start
        case other(Character)
        case end
    }

    func structure(parsed parsedCharacter: ParsedCharacter, to output: CharacterOutputStream) {

        func endStructure() {
            switch self.structure {
            case .header(let level):
                output.write("</h\(level)>")
            case .list:
                output.write("</ul>")
            case .listElement:
                output.write("</li></ul>")
            case .none:
                break
            case .paragraph:
                output.write("</p>")
            }
            self.structure = .none
        }

        switch parsedCharacter {
        case .start:
            self.style(structured: .start, to: output)
        case .whitespace:
            self.style(structured: .other(" "), to: output)
        case .weakNewLine:
            switch self.structure {
            case .list, .none, .paragraph:
                self.style(structured: .other(" "), to: output)
            case .listElement:
                self.style(structured: .end, to: output)
                output.write("</li>")
                self.structure = .list
            case let .header(level):
                self.style(structured: .end, to: output)
                output.write("</h\(level)>")
            }
        case .strongNewLine, .end:
            self.style(structured: .end, to: output)
            endStructure()
        case .header(let count):
            endStructure()
            output.write("<h\(count)>")
            self.structure = .header(level: count)
        case .listStart:
            switch self.structure {
            case .none:
                output.write("<ul><li>")
                self.structure = .listElement
            case .list:
                output.write("<li>")
                self.structure = .listElement
            case .paragraph, .header:
                endStructure()
            case .listElement:
                self.style(structured: .other("-"), to: output)
                self.style(structured: .other(" "), to: output)
            }
        case .other(let character):
            switch self.structure {
            case .none:
                output.write("<p>")
                self.style(structured: .start, to: output)
                self.style(structured: .other(character), to: output)
                self.structure = .paragraph
            case .paragraph, .list, .listElement, .header:
                self.style(structured: .other(character), to: output)
            }
        }
    }

    enum PossibleStyle {
        case none
        case strong([StructuredCharacter])
        case emphasis([StructuredCharacter])
        case code([StructuredCharacter])
    }

    func style(structured structuredCharacter: StructuredCharacter, to output: CharacterOutputStream) {
        func cancelStyle() {
            switch self.possibleStyle {
            case .strong(let characters):
                self.convertElements(fromStyled: .other("*"), to: output)
                self.convertElements(fromStyled: .other("*"), to: output)
                for character in characters {
                    self.convertElements(fromStyled: character, to: output)
                }
            case .emphasis(let characters):
                self.convertElements(fromStyled: .other("*"), to: output)
                for character in characters {
                    self.convertElements(fromStyled: character, to: output)
                }
            case .code(let characters):
                self.convertElements(fromStyled: .other("`"), to: output)
                for character in characters {
                    self.convertElements(fromStyled: character, to: output)
                }
            case .none:
                break
            }
            self.possibleStyle = .none
        }

        func commitStyle() {
            switch self.possibleStyle {
            case .code(let characters):
                self.convertElements(fromStyled: .start, to: output)
                self.convertElements(fromStyled: "<code>", to: output)
                for character in characters {
                    self.convertElements(fromStyled: character, to: output)
                }
                self.convertElements(fromStyled: "</code>", to: output)
                self.convertElements(fromStyled: .end, to: output)
            case .emphasis(let characters):
                self.convertElements(fromStyled: .start, to: output)
                self.convertElements(fromStyled: "<em>", to: output)
                for character in characters {
                    self.convertElements(fromStyled: character, to: output)
                }
                self.convertElements(fromStyled: "</em>", to: output)
                self.convertElements(fromStyled: .end, to: output)
            case .strong(let characters):
                self.convertElements(fromStyled: .start, to: output)
                self.convertElements(fromStyled: "<strong>", to: output)
                for (index, character) in characters.enumerated() {
                    guard index != characters.count - 1 else {
                        break
                    }
                    self.convertElements(fromStyled: character, to: output)
                }
                self.convertElements(fromStyled: "</strong>", to: output)
                self.convertElements(fromStyled: .end, to: output)
            case .none:
                break
            }
            self.possibleStyle = .none
        }

        switch structuredCharacter {
        case .start, .end:
            cancelStyle()
        case .other("*"):
            switch self.possibleStyle {
            case .code(let characters):
                self.possibleStyle = .code(characters + [.other("*")])
            case .emphasis(let characters) where characters.isEmpty:
                self.possibleStyle = .strong([])
            case .emphasis:
                commitStyle()
            case .strong(let characters) where !characters.isEmpty && characters.last! == .other("*"):
                commitStyle()
            case .strong(let characters):
                self.possibleStyle = .strong(characters + [.other("*")])
            case .none:
                self.possibleStyle = .emphasis([])
            }
        case .other("`"):
            switch self.possibleStyle {
            case .code:
                commitStyle()
            case .emphasis, .strong, .none:
                cancelStyle()
                self.possibleStyle = .code([])
            }
        case .other(let character):
            switch self.possibleStyle {
            case .code(let characters):
                self.possibleStyle = .code(characters + [.other(character)])
            case .emphasis(let characters):
                self.possibleStyle = .emphasis(characters + [.other(character)])
            case .strong(let characters):
                self.possibleStyle = .strong(characters + [.other(character)])
            case .none:
                self.convertElements(fromStyled: .other(character), to: output)
            }
        }
    }

    enum Mode {
        case none
        case linkTitle(String)
        case linkAddress(title: String, address: String)
    }

    func convertElements(fromStyled string: String, to output: CharacterOutputStream) {
        for character in string.characters {
            self.convertElements(fromStyled: .other(character), to: output)
        }
    }

    func convertElements(fromStyled structuredCharacter: StructuredCharacter, to output: CharacterOutputStream) {
        func cancelMode() {
            switch self.mode {
            case .linkTitle(let title):
                output.write("[\(title)")
            case let .linkAddress(title, address):
                output.write("[\(title)](\(address)")
            case .none:
                break
            }
            self.mode = .none
        }

        switch structuredCharacter {
        case .start, .end:
            cancelMode()
        case .other("["):
            switch self.mode {
            case .none:
                self.mode = .linkTitle("")
            case .linkTitle, .linkAddress:
                cancelMode()
            }
        case .other("]"):
            switch self.mode {
            case .none:
                output.write("]")
            case .linkTitle(let title):
                self.mode = .linkAddress(title: title, address: "")
            case .linkAddress:
                cancelMode()
            }
        case .other("("):
            switch self.mode {
            case .none:
                output.write("(")
            case .linkTitle:
                cancelMode()
            case let .linkAddress(_, address) where address.isEmpty:
                break
            default:
                cancelMode()
            }
        case .other(")"):
            switch self.mode {
            case .none:
                output.write(")")
            case .linkTitle:
                cancelMode()
            case let .linkAddress(title, address):
                output.write("<a href=\"\(address)\">\(title)</a>")
                self.mode = .none
            }
        case .other(let character):
            switch self.mode {
            case .none:
                output.write(character)
            case .linkTitle(let title):
                self.mode = .linkTitle(title + "\(character)")
            case let .linkAddress(title, address):
                self.mode = .linkAddress(title: title, address: address + "\(character)")
            }
        }
    }
}

extension SimpleMarkdown.ParsedCharacter: Equatable {
    static func ==(lhs: SimpleMarkdown.ParsedCharacter, rhs: SimpleMarkdown.ParsedCharacter) -> Bool {
        switch lhs {
        case .end:
            switch rhs {
            case .end:
                return true
            default:
                return false
            }
        case .start:
            switch rhs {
            case .start:
                return true
            default:
                return false
            }
        case .strongNewLine:
            switch rhs {
            case .strongNewLine:
                return true
            default:
                return false
            }
        case .weakNewLine:
            switch rhs {
            case .weakNewLine:
                return true
            default:
                return false
            }
        case .whitespace:
            switch rhs {
            case .whitespace:
                return true
            default:
                return false
            }
        case let .listStart(lWasWeak, lBothCharacters):
            switch rhs {
            case let .listStart(rWasWeak, rBothCharacters):
                return (lWasWeak == rWasWeak) && (lBothCharacters == rBothCharacters)
            default:
                return false
            }
        case .header(let lCount):
            switch rhs {
            case .header(let rCount):
                return lCount == rCount
            default:
                return false
            }
        case .other(let lCharacter):
            switch rhs {
            case .other(let rCharacter):
                return lCharacter == rCharacter
            default:
                return false
            }
        }
    }
}

extension SimpleMarkdown.StructuredCharacter: Equatable {
    static func ==(lhs: SimpleMarkdown.StructuredCharacter, rhs: SimpleMarkdown.StructuredCharacter) -> Bool {
        switch lhs {
        case .start:
            switch rhs {
            case .start:
                return true
            case .end, .other:
                return false
            }
        case .end:
            switch rhs {
            case .end:
                return true
            case .start, .other:
                return false
            }
        case .other(let character):
            switch rhs {
            case .other(let otherCharacter):
                return character == otherCharacter
            case .end, .start:
                return false
            }
        }
    }
}
