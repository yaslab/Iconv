import CIconv 

public struct IconvEncoding: RawRepresentable {
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    // supported encodings
    // https://developer.apple.com/library/ios/documentation/System/Conceptual/ManPages_iPhoneOS/man3/iconv_open.3.html
    
    // Japanese
    public static let eucJP = IconvEncoding(rawValue: "EUC-JP")
    public static let shiftJIS = IconvEncoding(rawValue: "SHIFT_JIS")
    public static let cp932 = IconvEncoding(rawValue: "CP932")
    public static let iso2022JP = IconvEncoding(rawValue: "ISO-2022-JP")
    
    // Full Unicode
    public static let utf8 = IconvEncoding(rawValue: "UTF-8")
    public static let utf16BE = IconvEncoding(rawValue: "UTF-16BE")
    public static let utf16LE = IconvEncoding(rawValue: "UTF-16LE")
    public static let utf32BE = IconvEncoding(rawValue: "UTF-32BE")
    public static let utf32LE = IconvEncoding(rawValue: "UTF-32LE")
    
}

public enum IconvError: ErrorProtocol {
    case iconv_open
    case iconv(Int32)
    case iconv_close
}

public class Iconv {
    
    private var cd: iconv_t
    private var closed = false
    
    public init(to: IconvEncoding, from: IconvEncoding) throws {
        let cd = iconv_open(to.rawValue, from.rawValue)!
        if cd == (iconv_t)(bitPattern: -1) {
            throw IconvError.iconv_open
        }
        self.cd = cd
    }
    
    deinit {
        _ = try? close()
    }
    
    public func convert(
        inBuffer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
        inBytesLeft: UnsafeMutablePointer<Int>,
        outBuffer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>,
        outBytesLeft: UnsafeMutablePointer<Int>)
        throws
        -> Int
    {
        let ret = iconv(cd, inBuffer, inBytesLeft, outBuffer, outBytesLeft)
        if ret == -1 {
            throw IconvError.iconv(errno)
        }
        return ret
    }
    
    public func close() throws {
        if !closed {
            let ret = iconv_close(cd)
            closed = true
            if ret == -1 {
                throw IconvError.iconv_close
            }
        }
    }
    
}
