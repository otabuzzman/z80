@testable import z80

final class TestSystem
{
    private let _B: Byte = 0
    private let _C: Byte = 1
    private let _D: Byte = 2
    private let _E: Byte = 3
    private let _H: Byte = 4
    private let _L: Byte = 5
    private let _F: Byte = 6
    private let _A: Byte = 7
    private let _Bp: Byte = 8
    private let _Cp: Byte = 9
    private let _Dp: Byte = 10
    private let _Ep: Byte = 11
    private let _Hp: Byte = 12
    private let _Lp: Byte = 13
    private let _Fp: Byte = 14
    private let _Ap: Byte = 15
    private let _I: Byte = 16
    private let _R: Byte = 17
    private let _IX: Byte = 18
    private let _IY: Byte = 20
    private let _SP: Byte = 22
    private let _PC: Byte = 24
    private let _IFF1: Byte = 26
    private let _IFF2: Byte = 27

    private(set) var mem: Memory
    private var z80State: [Byte]?
    private(set) var z80: Z80

    var AF: UShort { Reg16(_F) }
    var BC: UShort { Reg16(_B) }
    var DE: UShort { Reg16(_D) }
    var HL: UShort { Reg16(_H) }
    var IX: UShort { Reg16(_IX) }
    var IY: UShort { Reg16(_IY) }
    var SP: UShort { Reg16(_SP) }
    var PC: UShort { Reg16(_PC) }
    var AFp: UShort { Reg16(_Fp) }
    var BCp: UShort { Reg16(_Bp) }
    var DEp: UShort { Reg16(_Dp) }
    var HLp: UShort { Reg16(_Hp) }

    var A: Byte { Reg8(_A) }
    var B: Byte { Reg8(_B) }
    var C: Byte { Reg8(_C) }
    var D: Byte { Reg8(_D) }
    var E: Byte { Reg8(_E) }
    var F: Byte { Reg8(_F) }
    var H: Byte { Reg8(_H) }
    var L: Byte { Reg8(_L) }
    var I: Byte { Reg8(_I) }
    var R: Byte { Reg8(_R) }

    var Ap: Byte { Reg8(_Ap) }
    var Bp: Byte { Reg8(_Bp) }
    var Cp: Byte { Reg8(_Cp) }
    var Dp: Byte { Reg8(_Dp) }
    var Ep: Byte { Reg8(_Ep) }
    var Fp: Byte { Reg8(_Fp) }
    var Hp: Byte { Reg8(_Hp) }
    var Lp: Byte { Reg8(_Lp) }

    // SZ-H-PNC
    var FlagS: Bool { (Reg8(_F) & 0x80) > 0 }
    var FlagZ: Bool { (Reg8(_F) & 0x40) > 0 }
    var FlagH: Bool { (Reg8(_F) & 0x10) > 0 }
    var FlagP: Bool { (Reg8(_F) & 0x04) > 0 }
    var FlagN: Bool { (Reg8(_F) & 0x02) > 0 }
    var FlagC: Bool { (Reg8(_F) & 0x01) > 0 }

    var Iff1: Bool { Reg8(_IFF1) > 0 }
    var Iff2: Bool { Reg8(_IFF2) > 0 }

    private(set) var testPorts = TestPorts()

    func Reg8(_ reg: Byte) -> Byte
    {
        return z80State![reg]
    }

    private func Reg16(_ reg: Byte) -> UShort
    {
        return UShort(z80State![reg + 1]) + UShort(z80State![reg]) * 256
    }

    init(_ mem: Memory)
    {
        self.mem = mem
        z80 = Z80(mem, testPorts)
        { addr, data in
            print(String(format: "  %04X %02X ", addr, data))
        }
        traceOpcode:
        { prefix, opcode, imm, imm16, dimm in
            print(Z80Mne.mnemonic(prefix, opcode, imm, imm16, dimm))
        }
        traceTiming:
        { sleep, CLK in
            print(String(format: "%d T states late", Int(abs(sleep * Double(CLK)))))
        }
        traceNmiInt:
        { interrupt, addr, instruction in
            switch interrupt {
                case .Nmi:
                    print(String(format: "NMI addr: 0x%04X", addr))
                case .Int0:
                    print(String(format: "IM0 instruction: 0x%02X", instruction))
                case .Int1:
                    print(String(format: "IM1 addr: 0x%04X", addr))
                case .Int2:
                    print(String(format: "IM2 addr: 0x%04X", addr))
            }
        }
    }

    func Run()
    {
        var bailout: Int = 1000

        while !z80.Halt && bailout > 0
        {
            z80.parse()
            bailout -= 1
            // DumpZ80()
            // DumpRam()
        }
        z80State = z80.getState()
        if !z80.Halt {
            print("Bailout!")
        }
    }

    func Step() -> Bool
    {
        z80.parse()
        z80State = z80.getState()
        return z80.Halt
    }

    func Reset()
    {
        z80State = nil
        z80.reset()
    }

    func DumpZ80()
    {
        print(z80.dumpState())
    }

    func DumpRam()
    {
        for addr: UShort in 0..<0x80
        {
            if addr % 16 == 0 {
                print(String(format: "%04X | ", addr))
            }
            print(String(format: "%2X ", mem[addr]))
            if addr % 8 == 7 {
                print(String(format: "  "))
            }
            if addr % 16 == 15 {
                print("")
            }
        }
        print("")
        for addr: UShort in 0x8080..<0x80A0
        {
            if addr % 16 == 0 {
                print(String(format: "%04X | ", addr))
            }
            print(String(format: "%2X ", mem[addr]))
            if addr % 8 == 7 {
                print(String(format: "  "))
            }
            if addr % 16 == 15 {
                print("")
            }
        }
    }

    func RaiseInterrupt(_ maskable: Bool, _ data: Byte = 0x00)
    {
        if maskable
        {
            testPorts.NMI = false
            testPorts.INT = true
            testPorts.data = data
        }
        else
        {
            testPorts.NMI = true
            testPorts.INT = false
            testPorts.data = data
        }
    }
}
