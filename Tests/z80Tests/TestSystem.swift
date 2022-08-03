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

    private(set) var _ram: Memory
    private var _dumpedState: [byte]?
    private var _hasDump: bool = false
    private(set) var _myZ80: Z80

    public var AF: ushort { Reg16(_F) }
    public var BC: ushort { Reg16(_B) }
    public var DE: ushort { Reg16(_D) }
    public var HL: ushort { Reg16(_H) }
    public var IX: ushort { Reg16(_IX) }
    public var IY: ushort { Reg16(_IY) }
    public var SP: ushort { Reg16(_SP) }
    public var PC: ushort { Reg16(_PC) }
    public var AFp: ushort { Reg16(_Fp) }
    public var BCp: ushort { Reg16(_Bp) }
    public var DEp: ushort { Reg16(_Dp) }
    public var HLp: ushort { Reg16(_Hp) }

    public var A: byte { Reg8(_A) }
    public var B: byte { Reg8(_B) }
    public var C: byte { Reg8(_C) }
    public var D: byte { Reg8(_D) }
    public var E: byte { Reg8(_E) }
    public var F: byte { Reg8(_F) }
    public var H: byte { Reg8(_H) }
    public var L: byte { Reg8(_L) }
    public var I: byte { Reg8(_I) }
    public var R: byte { Reg8(_R) }

    public var Ap: byte { Reg8(_Ap) }
    public var Bp: byte { Reg8(_Bp) }
    public var Cp: byte { Reg8(_Cp) }
    public var Dp: byte { Reg8(_Dp) }
    public var Ep: byte { Reg8(_Ep) }
    public var Fp: byte { Reg8(_Fp) }
    public var Hp: byte { Reg8(_Hp) }
    public var Lp: byte { Reg8(_Lp) }

    // SZ-H-PNC
    public var FlagS: bool { (Reg8(_F) & 0x80) > 0 }
    public var FlagZ: bool { (Reg8(_F) & 0x40) > 0 }
    public var FlagH: bool { (Reg8(_F) & 0x10) > 0 }
    public var FlagP: bool { (Reg8(_F) & 0x04) > 0 }
    public var FlagN: bool { (Reg8(_F) & 0x02) > 0 }
    public var FlagC: bool { (Reg8(_F) & 0x01) > 0 }

    public var Iff1: bool { Reg8(_IFF1) > 0 }
    public var Iff2: bool { Reg8(_IFF2) > 0 }

    private(set) var testPorts = TestPorts()

    public func Reg8(_ reg: byte) -> byte
    {
        // if (!_hasDump) throw new InvalidOperationException("Don't have a state!")
        return _dumpedState![reg]
    }
    private func Reg16(_ reg: byte) -> ushort
    {
        // if (!_hasDump) throw new InvalidOperationException("Don't have a state!")
        let ret = (ushort)(_dumpedState![reg + 1]) + (ushort)(_dumpedState![reg]) * 256
        return ret
    }

    init(_ ram: Memory)
    {
        _ram = ram
        _myZ80 = Z80(_ram, testPorts)
    }

    public func Run()
    {
        var bailout: int = 1000

        while (!_myZ80.Halt && bailout > 0)
        {
            _myZ80.Parse()
            bailout -= 1
            //DumpCpu()
            //DumpRam()
            //Console.WriteLine(_myZ80.DumpState())
        }
        _dumpedState = _myZ80.GetState()
        _hasDump = true
        if (!_myZ80.Halt) {
            print("BAILOUT!")
        }
    }

    public func Step() -> bool
    {
        _myZ80.Parse()
        _dumpedState = _myZ80.GetState()
        _hasDump = true
        return _myZ80.Halt
    }

    public func Reset()
    {
        _dumpedState = nil
        _hasDump = false
        _myZ80.Reset()
    }

    public func DumpCpu()
    {
        print(_myZ80.DumpState())
    }

    public func DumpRam()
    {
        for addr: ushort in 0..<0x80
        {
            if (addr % 16 == 0) {
                print(String(format: "%04X | ", addr))
            }
            print(String(format: "%2X ", _ram[addr]))
            if (addr % 8 == 7) {
                print(String(format: "  "))
            }
            if (addr % 16 == 15) {
                print("")
            }
        }
        print("")
        for addr: ushort in 0x8080..<0x80A0
        {
            if (addr % 16 == 0) {
                print(String(format: "%04X | ", addr))
            }
            print(String(format: "%2X ", _ram[addr]))
            if (addr % 8 == 7) {
                print(String(format: "  "))
            }
            if (addr % 16 == 15) {
                print("")
            }
        }
    }

    public func RaiseInterrupt(_ maskable: bool, _ data: byte = 0x00)
    {
        if (maskable)
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
