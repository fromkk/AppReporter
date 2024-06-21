//
//  File.swift
//
//
//  Created by Kazuya Ueoka on 2024/06/21.
//

import Foundation
import zlib

func gunzip(data: Data) -> Data? {
  guard data.count > 0 else {
    return nil
  }

  var stream = z_stream()
  var status: Int32

  status = inflateInit2_(&stream, 16 + MAX_WBITS, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
  guard status == Z_OK else {
    return nil
  }

  var decompressedData = Data(capacity: data.count * 2)
  data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
    stream.next_in = UnsafeMutablePointer<Bytef>(
      mutating: bytes.bindMemory(to: Bytef.self).baseAddress!)
    stream.avail_in = uint(data.count)

    while stream.avail_in > 0 {
      if Int(stream.total_out) >= decompressedData.count {
        decompressedData.count += data.count / 2
      }

      stream.next_out = decompressedData.withUnsafeMutableBytes {
        $0.bindMemory(to: Bytef.self).baseAddress! + Int(stream.total_out)
      }
      stream.avail_out = uint(decompressedData.count) - uint(stream.total_out)

      status = inflate(&stream, Z_SYNC_FLUSH)
      guard status == Z_OK || status == Z_STREAM_END else {
        inflateEnd(&stream)
        return
      }
    }
  }

  inflateEnd(&stream)
  decompressedData.count = Int(stream.total_out)

  return decompressedData
}
