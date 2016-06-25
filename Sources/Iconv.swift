import CIconv 

struct IconvEncoding: RawRepresentable {
    
    var rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    // supported encodings
    // https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man3/iconv_open.3.html
    
    // Japanese
    static let eucJP = IconvEncoding(rawValue: "EUC-JP")
    static let shiftJIS = IconvEncoding(rawValue: "SHIFT_JIS")
    static let cp932 = IconvEncoding(rawValue: "CP932")
    static let iso2022JP = IconvEncoding(rawValue: "ISO-2022-JP")
    
    // Full Unicode
    static let utf8 = IconvEncoding(rawValue: "UTF-8")
    static let utf16BE = IconvEncoding(rawValue: "UTF-16BE")
    static let utf16LE = IconvEncoding(rawValue: "UTF-16LE")
    static let utf32BE = IconvEncoding(rawValue: "UTF-32BE")
    static let utf32LE = IconvEncoding(rawValue: "UTF-32LE")
    
}

class Iconv {
    
    private var cd: iconv_t
    private var closed = false
    
    init?(to: IconvEncoding, from: IconvEncoding) {
        guard let cd = iconv_open(to.rawValue, from.rawValue) else {
            return nil
        }
        if cd == (iconv_t)(bitPattern: -1) {
            return nil
        }
        self.cd = cd
    }
    
    deinit {
        _ = close()
    }
    
    func convert(
        inBuffer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
        inBytesLeft: UnsafeMutablePointer<Int>,
        outBuffer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
        outBytesLeft: UnsafeMutablePointer<Int>)
        -> Int
    {
        return iconv(cd, inBuffer, inBytesLeft, outBuffer, outBytesLeft)
    }
    
    func close() -> Bool {
        var result = false
        if !closed {
            result = (iconv_close(cd) == 0)
            closed = true
        }
        return result
    }
    
}
