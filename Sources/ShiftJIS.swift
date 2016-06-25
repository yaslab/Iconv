//
//  ShiftJIS.swift
//  Iconv
//
//  Created by Yasuhiro Hatta on 2016/06/25.
//
//

import Foundation

public struct ShiftJIS: UnicodeCodec {
    
    var iconvDecoder = Iconv(to: .utf32LE, from: .cp932)
    static var iconvEncoder = Iconv(to: .cp932, from: .utf32LE)
    
    var buffer = [CodeUnit](repeating: 0, count: 2)
    var bufferPosition = 0
    
    var nextScalar: UnicodeScalar? = nil
    
    public init() {
        
    }
    
    // ShiftJIS to UnicodeScalar
    public mutating func decode<G : IteratorProtocol where G.Element == UInt8>(_ next: inout G) -> UnicodeDecodingResult {
        guard let iconv = iconvDecoder else {
            return .error
        }
        
        if nextScalar != nil {
            defer { nextScalar = nil }
            return .scalarValue(nextScalar!)
        }
        
        while bufferPosition < 2 {
            guard let c = next.next() else {
                break
            }
            buffer[bufferPosition] = c
            bufferPosition += 1
        }
        
        if bufferPosition == 0 {
            return .emptyInput
        }
        
        var target = [CChar](repeating: 0, count: 4)
        
        // Convert to Unicode
        var ilen = bufferPosition
        var rlen = 8
        var pin: UnsafeMutablePointer<CChar>? = UnsafeMutablePointer<CChar>(buffer)
        var pout: UnsafeMutablePointer<CChar>? = UnsafeMutablePointer<CChar>(target)
        
        let ret = iconv.convert(inBuffer: &pin, inBytesLeft: &ilen, outBuffer: &pout, outBytesLeft: &rlen)
        if (ret == -1) {
            return .error
        }
        
        let tmp = UnsafeMutablePointer<UInt32>(target)
        let scalar = UnicodeScalar(tmp[0])
        
        var newBufferPosition = 0
        
        if rlen == 0 {
            nextScalar = UnicodeScalar(tmp[1])
        }
        if ret == 1 {
            buffer[0] = buffer[1]
            newBufferPosition = 1
        }
        
        bufferPosition = newBufferPosition
        
        return .scalarValue(scalar)
    }
    
    // UnicodeScalar to ShiftJIS
    public static func encode(_ input: UnicodeScalar, sendingOutputTo processCodeUnit: @noescape (UInt8) -> Void) {
        guard let iconv = iconvEncoder else {
            return
        }
        
        var buffer = [UInt8](repeating: 0, count: 4)
        var value = CFSwapInt32HostToBig(input.value)
        memcpy(&buffer, &value, 4)
        
        var target = [UInt8](repeating: 0, count: 8)
        
        var ilen = 4
        var rlen = 8
        var pin: UnsafeMutablePointer<CChar>? = UnsafeMutablePointer<CChar>(buffer)
        var pout: UnsafeMutablePointer<CChar>? = UnsafeMutablePointer<CChar>(target)
        
        let ret = iconv.convert(inBuffer: &pin, inBytesLeft: &ilen, outBuffer: &pout, outBytesLeft: &rlen)
        if (ret == -1) {
            return
        }
        
        for i in 0..<(8-rlen) {
            processCodeUnit(target[i])
        }
    }
    
}
