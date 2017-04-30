import LicensePlistCore
import Commander

let main = command(Argument<String>("input"),
                   Option("suffix", "(　´･‿･｀)", flag: "s"),
                   Option("length", -1, flag: "l")) { input, suffix, length in
                    let tool = LicensePlist()
                    tool.run()
}

main.run()
