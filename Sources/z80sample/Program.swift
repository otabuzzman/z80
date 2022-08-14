#if os(Windows)

import Foundation
import z80

@main
extension Z80 {
    static func main() {
        var ram = Array<byte>(repeating: 0, count: 0x10000)
        let rom = NSData(contentsOfFile: "z80Sample/48.rom")
        ram.replaceSubrange(0..<rom!.count, with: rom!)

        let ports = SamplePorts()

        let mem = Memory(ram, 16384)
        var z80 = Z80(mem, ports)

        while (!z80.Halt)
        {
            z80.Parse()
        }

        print(z80.DumpState())
        for i in 0..<0x80
        {
            if i % 16 == 0 {
                print(String(format: "%04X | ", i), terminator: "")
            }
            print(String(format: "%02x ", ram[i]), terminator: "")
            if i % 8 == 7 {
                print("  ", terminator: "")
            }
            if (i % 16 == 15) {
                print("")
            }
        }
        print("")
        for i in 0x4000..<0x4100
        {
            if i % 16 == 0 {
                print(String(format: "%04X | ", i), terminator: "")
            }
            print(String(format: "%02x ", ram[i]), terminator: "")
            if i % 8 == 7 {
                print("  ", terminator: "")
            }
            if (i % 16 == 15) {
                print("")
            }
        }
    }
}

final class SamplePorts: IPorts
{
    func ReadPort(_ port: ushort) -> byte
    {
        print(String(format: "  \(#function) : IN 0x%04X", port))
        return 0
    }

    func WritePort(_ port: ushort, _ value: byte)
    {
        print(String(format: "  \(#function) : OUT 0x%04X, 0x%02X", port, value))
    }

    var NMI: Bool { false }
    var MI: Bool { false }
    var Data: byte { 0x00 }
}

#endif