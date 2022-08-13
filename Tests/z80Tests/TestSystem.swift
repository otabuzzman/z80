@testable import z80

final class TestSystem
{
    private let _B: byte = 0
    private let _C: byte = 1
    private let _D: byte = 2
    private let _E: byte = 3
    private let _H: byte = 4
    private let _L: byte = 5
    private let _F: byte = 6
    private let _A: byte = 7
    private let _Bp: byte = 8
    private let _Cp: byte = 9
    private let _Dp: byte = 10
    private let _Ep: byte = 11
    private let _Hp: byte = 12
    private let _Lp: byte = 13
    private let _Fp: byte = 14
    private let _Ap: byte = 15
    private let _I: byte = 16
    private let _R: byte = 17
    private let _IX: byte = 18
    private let _IY: byte = 20
    private let _SP: byte = 22
    private let _PC: byte = 24
    private let _IFF1: byte = 26
    private let _IFF2: byte = 27

    private(set) var mem: Memory
    private var z80State: [byte]?
    private(set) var z80: Z80

    var AF: ushort { Reg16(_F) }
    var BC: ushort { Reg16(_B) }
    var DE: ushort { Reg16(_D) }
    var HL: ushort { Reg16(_H) }
    var IX: ushort { Reg16(_IX) }
    var IY: ushort { Reg16(_IY) }
    var SP: ushort { Reg16(_SP) }
    var PC: ushort { Reg16(_PC) }
    var AFp: ushort { Reg16(_Fp) }
    var BCp: ushort { Reg16(_Bp) }
    var DEp: ushort { Reg16(_Dp) }
    var HLp: ushort { Reg16(_Hp) }

    var A: byte { Reg8(_A) }
    var B: byte { Reg8(_B) }
    var C: byte { Reg8(_C) }
    var D: byte { Reg8(_D) }
    var E: byte { Reg8(_E) }
    var F: byte { Reg8(_F) }
    var H: byte { Reg8(_H) }
    var L: byte { Reg8(_L) }
    var I: byte { Reg8(_I) }
    var R: byte { Reg8(_R) }

    var Ap: byte { Reg8(_Ap) }
    var Bp: byte { Reg8(_Bp) }
    var Cp: byte { Reg8(_Cp) }
    var Dp: byte { Reg8(_Dp) }
    var Ep: byte { Reg8(_Ep) }
    var Fp: byte { Reg8(_Fp) }
    var Hp: byte { Reg8(_Hp) }
    var Lp: byte { Reg8(_Lp) }

    // SZ-H-PNC
    var FlagS: bool { (Reg8(_F) & 0x80) > 0 }
    var FlagZ: bool { (Reg8(_F) & 0x40) > 0 }
    var FlagH: bool { (Reg8(_F) & 0x10) > 0 }
    var FlagP: bool { (Reg8(_F) & 0x04) > 0 }
    var FlagN: bool { (Reg8(_F) & 0x02) > 0 }
    var FlagC: bool { (Reg8(_F) & 0x01) > 0 }

    var Iff1: bool { Reg8(_IFF1) > 0 }
    var Iff2: bool { Reg8(_IFF2) > 0 }

    private(set) var testPorts = TestPorts()

    func Reg8(_ reg: byte) -> byte
    {
        return z80State![reg]
    }

    private func Reg16(_ reg: byte) -> ushort
    {
        return ushort(z80State![reg + 1]) + ushort(z80State![reg]) * 256
    }

    init(_ mem: Memory)
    {
        self.mem = mem
        z80 = Z80(mem, testPorts)
    }

    func Run()
    {
        var bailout: int = 1000

        while !z80.Halt && bailout > 0
        {
            z80.Parse()
            bailout -= 1
            // DumpZ80()
            // DumpRam()
        }
        z80State = z80.GetState()
        if !z80.Halt {
            print("Bailout!")
        }
    }

    func Step() -> bool
    {
        z80.Parse()
        z80State = z80.GetState()
        return z80.Halt
    }

    func Reset()
    {
        z80State = nil
        z80.Reset()
    }

    func DumpZ80()
    {
        print(z80.DumpState())
    }

    func DumpRam()
    {
        for addr: ushort in 0..<0x80
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
        for addr: ushort in 0x8080..<0x80A0
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

    func RaiseInterrupt(_ maskable: bool, _ data: byte = 0x00)
    {
        if maskable
        {
            testPorts.MI = true
            testPorts.NMI = false
            testPorts.Data = data
        }
        else
        {
            testPorts.MI = false
            testPorts.NMI = true
            testPorts.Data = data
        }
    }
}
