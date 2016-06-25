import PackageDescription

let package = Package(
    name: "Iconv",
    dependencies: [
        .Package(url: "https://github.com/yaslab/Iconv-support.git", majorVersion: 0, minor: 1)
    ]
)
