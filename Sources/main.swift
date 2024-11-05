import ArgumentParser

@main
struct HTMLTagClassGenerator: ParsableCommand {
    
    @Argument(help: "The css files to parse.")
    var inputFiles: [String]
    
    @Option(name: .shortAndLong, help: "The output file.")
    var outputFile: String
    
    func run() throws {
        
        var classes = Set<String>()
        
        // just find all strings that start with a . until any whitespace, : or newline
        for inputFile in inputFiles {
            
            let lines = try String(contentsOfFile: inputFile, encoding: .utf8).split(whereSeparator: \.isNewline)
            
            for line in lines {
                
                let tokens = line.split(whereSeparator: { [" ", "\t", ":"].contains($0) })
                
                for token in tokens {
                    if token.starts(with: ".") {
                        classes.insert(String(token.dropFirst()))
                    }
                }
            }
        }
        
        let code =
        #"""
        // Generated code, don't edit.
        
        enum HTMLTagClass: String {
            case \#(classes.joined(separator: "\n    case "))
        }
        
        """#
        
        try code.write(toFile: outputFile, atomically: true, encoding: .utf8)
    }
}
