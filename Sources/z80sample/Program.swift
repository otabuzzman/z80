#if os(Windows)

import Foundation
import z80

@main
extension Z80 {
    static func main() {
        var ram = Array<Byte>(repeating: 0, count: 0x10000)
        let rom = NSData(contentsOfFile: "z80Sample/48.rom")
        ram.replaceSubrange(0..<rom!.count, with: rom!)

        let ports = SamplePorts()

        let mem = Memory(ram, 16384)
        var z80 = Z80(mem, ports)

        while (!z80.Halt)
        {
            z80.parse()
        }

        print(z80.dumpState())
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
    func rdPort(_ port: UShort) -> Byte
    {
        print(String(format: "  \(#function) : IN 0x%04X", port))
        return 0
    }

    func wrPort(_ port: UShort, _ data: Byte)
    {
        print(String(format: "  \(#function) : OUT 0x%04X, 0x%02X", port, data))
    }

    var NMI: Bool { false }
    var INT: Bool { false }
    var data: Byte { 0x00 }
}

#endif