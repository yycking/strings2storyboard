# Overview
merge all string from Localizable.strings to storyboard/xib

# Install
1. `Build Phases`
2. `+`
3. `New Run Script Phase`
4. Shell: `/usr/bin/env xcrun --sdk macosx swift`
5. Paste code of main.swift to exit view
6. `Input File`
7. `+`
8. input $(SRCROOT)/folder that have en.lproj/Localizable.strings
9. `+`
10. input $(SRCROOT)/folder that want to process
