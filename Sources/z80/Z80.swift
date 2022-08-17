import Foundation

public typealias Byte = UInt8
public typealias SByte = Int8

public typealias Short = Int16
public typealias UShort = UInt16

public struct Z80
{
    private let B: Byte = 0
    private let C: Byte = 1
    private let D: Byte = 2
    private let E: Byte = 3
    private let H: Byte = 4
    private let L: Byte = 5
    private let F: Byte = 6
    private let A: Byte = 7
    private let Bp: Byte = 8
    private let Cp: Byte = 9
    private let Dp: Byte = 10
    private let Ep: Byte = 11
    private let Hp: Byte = 12
    private let Lp: Byte = 13
    private let Fp: Byte = 14
    private let Ap: Byte = 15
    private let I: Byte = 16
    private let R: Byte = 17
    private let IX: Byte = 18
    private let IY: Byte = 20
    private let SP: Byte = 22
    private let PC: Byte = 24

    private var cfreq: UInt

    private(set) var mem: Memory!
    private(set) var registers = Array<Byte>(repeating: 0, count: 26)

    private var clock = Date().timeIntervalSinceReferenceDate

    private var IFF1 = false
    private var IFF2 = false
    private var IM: Int = 0 // interrupt mode

    private(set) var ports: IPorts!

    public init(_ mem: Memory, _ ports: IPorts, _ cfreq: UInt = 4_000_000)
    {
        self.mem = mem
        self.ports = ports
        self.cfreq = cfreq
        reset()
    }

    private var Bc: UShort { (UShort(registers[B]) << 8) + registers[C] }
    private var De: UShort { (UShort(registers[D]) << 8) + registers[E] }
    private var Hl: UShort { (UShort(registers[H]) << 8) + registers[L] }
    private var Sp: UShort { (UShort(registers[SP]) << 8) + registers[SP + 1] }
    private var Ix: UShort { (UShort(registers[IX]) << 8) + registers[IX + 1] }
    private var Iy: UShort { (UShort(registers[IY]) << 8) + registers[IY + 1] }
    private var Pc: UShort { (UShort(registers[PC]) << 8) + registers[PC + 1] }

    public var Halt = false

    public mutating func parse()
    {
        if ports.NMI
        {
            var addr = Sp
            addr = addr &- 1
            mem[addr] = Byte(Pc >> 8)
            addr = addr &- 1
            mem[addr] = Byte(Pc & 0xFF)
            registers[SP] = Byte(addr >> 8)
            registers[SP + 1] = Byte(addr & 0xFF)
            registers[PC] = 0x00
            registers[PC + 1] = 0x66
            IFF1 = IFF2
            IFF1 = false
#if DEBUG
            print("NMI")
#endif
            Wait(17)
            Halt = false
            return
        }
        if IFF1 && ports.INT
        {
            IFF1 = false
            IFF2 = false
            switch IM
            {
                case 0:
                    // This is not quite correct, as it only runs a RST xx
                    // Instead, it should also support any other instruction
                    let instruction = ports.data
                    var addr = Sp
                    addr = addr &- 1
                    mem[addr] = Byte(Pc >> 8)
                    addr = addr &- 1
                    mem[addr] = Byte(Pc & 0xFF)
                    registers[SP] = Byte(addr >> 8)
                    registers[SP + 1] = Byte(addr & 0xFF)
                    registers[PC] = 0x00
                    registers[PC + 1] = instruction & 0x38
                    Wait(17)
#if DEBUG
                    print("IM 0")
#endif
                    Halt = false
                    return
                case 1:
                    var addr = Sp
                    addr = addr &- 1
                    mem[addr] = Byte(Pc >> 8)
                    addr = addr &- 1
                    mem[addr] = Byte(Pc & 0xFF)
                    registers[SP] = Byte(addr >> 8)
                    registers[SP + 1] = Byte(addr & 0xFF)
                    registers[PC] = 0x00
                    registers[PC + 1] = 0x38
#if DEBUG
                    print("IM 1")
#endif
                    Wait(17)
                    Halt = false
                    return
                case 2:
                    let vector = ports.data
                    var addr = Sp
                    addr = addr &- 1
                    mem[addr] = Byte(Pc >> 8)
                    addr = addr &- 1
                    mem[addr] = Byte(Pc & 0xFF)
                    registers[SP] = Byte(addr >> 8)
                    registers[SP + 1] = Byte(addr & 0xFF)
                    var dest = (UShort(registers[I]) << 8) + vector
                    registers[PC] = mem[dest]
                    dest = dest &+ 1
                    registers[PC + 1] = mem[dest]
#if DEBUG
                    print("IM 2")
#endif
                    Wait(17)
                    Halt = false
                    return
                default:
                    break
            }
            return
        }
        if Halt {
            return
        }
        let mc = Fetch()
        let hi = mc >> 6
        let lo = mc & 0x07
        let r = (mc >> 3) & 0x07
        if hi == 1
        {
            let useHL1 = r == 6
            let useHL2 = lo == 6
            if useHL2 && useHL1
            {
#if DEBUG
                print("HALT")
#endif
                Halt = true
                return
            }
            let reg = useHL2 ? mem[Hl] : registers[lo]
            if useHL1 {
                mem[Hl] = reg
            } else {
                registers[r] = reg
            }
            Wait(useHL1 || useHL2 ? 7 : 4)
#if DEBUG
            print(String(format: "LD %@, %@", useHL1 ? "(HL)" : Z80.RegName(r), useHL2 ? "(HL)" : Z80.RegName(lo)))
#endif
            return
        }
        switch mc
        {
            case 0xCB:
                ParseCB()
                return
            case 0xDD:
                ParseDD()
                return
            case 0xED:
                ParseED()
                return
            case 0xFD:
                ParseFD()
                return
            case 0x00:
                // NOP
#if DEBUG
                print("NOP")
#endif
                Wait(4)
                return
            case 0x01, 0x11, 0x21:
                // LD dd, nn
                registers[r + 1] = Fetch()
                registers[r] = Fetch()
#if DEBUG
                print(String(format: "LD %@%@, 0x%02X%02X", Z80.RegName(r), Z80.RegName(Byte(r + 1)), registers[r], registers[r + 1]))
#endif
                Wait(10)
                return
            case 0x31:
                // LD SP, nn
                registers[SP + 1] = Fetch()
                registers[SP] = Fetch()
#if DEBUG
                print(String(format: "LD SP, 0x%02X%02X", registers[SP], registers[SP + 1]))
#endif
                Wait(10)
                return
            case 0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x3E:
                // LD r, n
                let n = Fetch()
                registers[r] = n
#if DEBUG
                print(String(format: "LD %@, 0x%02X", Z80.RegName(r), n))
#endif
                Wait(7)
                return
            case 0x36:
                // LD (HL), n
                let n = Fetch()
                mem[Hl] = n
#if DEBUG
                print(String(format: "LD (HL), 0x%02X", n))
#endif
                Wait(10)
                return
            case 0x0A:
                // LD A, (BC)
                registers[A] = mem[Bc]
#if DEBUG
                print("LD A, (BC)")
#endif
                Wait(7)
                return
            case 0x1A:
                // LD A, (DE)
                registers[A] = mem[De]
#if DEBUG
                print("LD A, (DE)")
#endif
                Wait(7)
                return
            case 0x3A:
                // LD A, (nn)
                let addr = Fetch16()
                registers[A] = mem[addr]
#if DEBUG
                print(String(format: "LD A, (0x%04X)", addr))
#endif
                Wait(13)
                return
            case 0x02:
                // LD (BC), A
                mem[Bc] = registers[A]
#if DEBUG
                print("LD (BC), A")
#endif
                Wait(7)
                return
            case 0x12:
                // LD (DE), A
                mem[De] = registers[A]
#if DEBUG
                print("LD (DE), A")
#endif
                Wait(7)
                return
            case 0x32:
                // LD (nn), A 
                let addr = Fetch16()
                mem[addr] = registers[A]
#if DEBUG
                print(String(format: "LD (0x%04X), A", addr))
#endif
                Wait(13)
                return
            case 0x2A:
                // LD HL, (nn) 
                var addr = Fetch16()
                registers[L] = mem[addr]
                addr = addr &+ 1
                registers[H] = mem[addr]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD HL, (0x%04X)", addr))
#endif
                Wait(16)
                return
            case 0x22:
                // LD (nn), HL
                var addr = Fetch16()
                mem[addr] = registers[L]
                addr = addr &+ 1
                mem[addr] = registers[H]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD (0x%04X), HL", addr))
#endif
                Wait(16)
                return
            case 0xF9:
                // LD SP, HL
                registers[SP + 1] = registers[L]
                registers[SP] = registers[H]
#if DEBUG
                print("LD SP, HL")
#endif
                Wait(6)
                return
            case 0xC5:
                // PUSH BC
                var addr = Sp
                addr = addr &- 1
                mem[addr] = registers[B]
                addr = addr &- 1
                mem[addr] = registers[C]
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("PUSH BC")
#endif
                Wait(11)
                return
            case 0xD5:
                // PUSH DE
                var addr = Sp
                addr = addr &- 1
                mem[addr] = registers[D]
                addr = addr &- 1
                mem[addr] = registers[E]
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("PUSH DE")
#endif
                Wait(11)
                return
            case 0xE5:
                // PUSH HL
                var addr = Sp
                addr = addr &- 1
                mem[addr] = registers[H]
                addr = addr &- 1
                mem[addr] = registers[L]
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("PUSH HL")
#endif
                Wait(11)
                return
            case 0xF5:
                // PUSH AF
                var addr = Sp
                addr = addr &- 1
                mem[addr] = registers[A]
                addr = addr &- 1
                mem[addr] = registers[F]
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("PUSH AF")
#endif
                Wait(11)
                return
            case 0xC1:
                // POP BC
                var addr = Sp
                registers[C] = mem[addr]
                addr = addr &+ 1
                registers[B] = mem[addr]
                addr = addr &+ 1
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("POP BC")
#endif
                Wait(10)
                return
            case 0xD1:
                // POP DE
                var addr = Sp
                registers[E] = mem[addr]
                addr = addr &+ 1
                registers[D] = mem[addr]
                addr = addr &+ 1
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("POP DE")
#endif
                Wait(10)
                return
            case 0xE1:
                // POP HL
                var addr = Sp
                registers[L] = mem[addr]
                addr = addr &+ 1
                registers[H] = mem[addr]
                addr = addr &+ 1
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("POP HL")
#endif
                Wait(10)
                return
            case 0xF1:
                // POP AF
                var addr = Sp
                registers[F] = mem[addr]
                addr = addr &+ 1
                registers[A] = mem[addr]
                addr = addr &+ 1
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("POP AF")
#endif
                Wait(10)
                return
            case 0xEB:
                // EX DE, HL
                SwapReg(D, H)
                SwapReg(E, L)
#if DEBUG
                print("EX DE, HL")
#endif
                Wait(4)
                return
            case 0x08:
                // EX AF, AF'
                SwapReg(Ap, A)
                SwapReg(Fp, F)
#if DEBUG
                print("EX AF, AF'")
#endif
                Wait(4)
                return
            case 0xD9:
                // EXX
                SwapReg(B, Bp)
                SwapReg(C, Cp)
                SwapReg(D, Dp)
                SwapReg(E, Ep)
                SwapReg(H, Hp)
                SwapReg(L, Lp)
#if DEBUG
                print("EXX")
#endif
                Wait(4)
                return
            case 0xE3:
                // EX (SP), HL
                var addr = Sp
                var tmp = registers[L]
                registers[L] = mem[addr]
                mem[addr] = tmp
                addr = addr &+ 1
                tmp = registers[H]
                registers[H] = mem[addr]
                mem[addr] = tmp
#if DEBUG
                print("EX (SP), HL")
#endif
                Wait(19)
                return
            case 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x87:
                // ADD A, r
                Add(registers[lo])
#if DEBUG
                print(String(format: "ADD A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xC6:
                // ADD A, n
                let b = Fetch()
                Add(b)
#if DEBUG
                print(String(format: "ADD A, 0x%02X", b))
#endif
                Wait(7)
                return
            case 0x86:
                // ADD A, (HL)
                Add(mem[Hl])
#if DEBUG
                print("ADD A, (HL)")
#endif
                Wait(7)
                return
            case 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F:
                // ADC A, r
                Adc(registers[lo])
#if DEBUG
                print(String(format: "ADC A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xCE:
                // ADC A, n
                let b = Fetch()
                Adc(b)
#if DEBUG
                print(String(format: "ADC A, 0x%02X", b))
#endif
                Wait(4)
                return
            case 0x8E:
                // ADC A, (HL)
                Adc(mem[Hl])
#if DEBUG
                print("ADC A, (HL)")
#endif
                Wait(7)
                return
            case 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x97:
                // SUB A, r
                Sub(registers[lo])
#if DEBUG
                print(String(format: "SUB A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xD6:
                // SUB A, n
                let b = Fetch()
                Sub(b)
#if DEBUG
                print(String(format: "SUB A, 0x%02X", b))
#endif
                Wait(4)
                return
            case 0x96:
                // SUB A, (HL)
                Sub(mem[Hl])
#if DEBUG
                print("SUB A, (HL)")
#endif
                Wait(7)
                return
            case 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9F:
                // SBC A, r
                Sbc(registers[lo])
#if DEBUG
                print(String(format: "SBC A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xDE:
                // SBC A, n
                let b = Fetch()
                Sbc(b)
#if DEBUG
                print(String(format: "SBC A, 0x%02X", b))
#endif
                Wait(4)
                return
            case 0x9E:
                // SBC A, (HL)
                Sbc(mem[Hl])
#if DEBUG
                print("SBC A, (HL)")
#endif
                Wait(7)
                return
            case 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA7:
                // AND A, r
                And(registers[lo])
#if DEBUG
                print(String(format: "AND A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xE6:
                // AND A, n
                let b = Fetch()
                And(b)
#if DEBUG
                print(String(format: "AND A, 0x%02X", b))
#endif
                Wait(4)
                return
            case 0xA6:
                // AND A, (HL)
                And(mem[Hl])
#if DEBUG
                print("AND A, (HL)")
#endif
                Wait(7)
                return
            case 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB7:
                // OR A, r
                Or(registers[lo])
#if DEBUG
                print(String(format: "OR A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xF6:
                // OR A, n
                let b = Fetch()
                Or(b)
#if DEBUG
                print(String(format: "OR A, 0x%02X", b))
#endif
                Wait(4)
                return
            case 0xB6:
                // OR A, (HL)
                Or(mem[Hl])
#if DEBUG
                print("OR A, (HL)")
#endif
                Wait(7)
                return
            case 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF:
                // XOR A, r
                Xor(registers[lo])
#if DEBUG
                print(String(format: "XOR A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xEE:
                // XOR A, n
                let b = Fetch()
                Xor(b)
#if DEBUG
                print(String(format: "XOR A, 0x%02X", b))
#endif
                Wait(4)
                return
            case 0xAE:
                // XOR A, (HL)
                Xor(mem[Hl])
#if DEBUG
                print("XOR A, (HL)")
#endif
                Wait(7)
                return
            case 0xF3:
                // DI
                IFF1 = false
                IFF2 = false
#if DEBUG
                print("DI")
#endif
                Wait(4)
                return
            case 0xFB:
                // EI
                IFF1 = true
                IFF2 = true
#if DEBUG
                print("EI")
#endif
                Wait(4)
                return
            case 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBF:
                // CP A, r
                Cmp(registers[lo])
#if DEBUG
                print(String(format: "CP A, %@", Z80.RegName(lo)))
#endif
                Wait(4)
                return
            case 0xFE:
                // CP A, n
                let b = Fetch()
                Cmp(b)
#if DEBUG
                print(String(format: "CP A, 0x%02X", b))
#endif
                Wait(4)
                return
            case 0xBE:
                // CP A, (HL)
                Cmp(mem[Hl])
#if DEBUG
                print("CP A, (HL)")
#endif
                Wait(7)
                return
            case 0x04, 0x0C, 0x14, 0x1C, 0x24, 0x2C, 0x3C:
                // INC r
                registers[r] = Inc(registers[r])
#if DEBUG
                print(String(format: "INC %@", Z80.RegName(r)))
#endif
                Wait(4)
                return
            case 0x34:
                // INC (HL)
                mem[Hl] = Inc(mem[Hl])
#if DEBUG
                print("INC (HL)")
#endif
                Wait(7)
                return
            case 0x05, 0x0D, 0x15, 0x1D, 0x25, 0x2D, 0x3D:
                // DEC r
                registers[r] = Dec(registers[r])
#if DEBUG
                print(String(format: "DEC %@", Z80.RegName(r)))
#endif
                Wait(7)
                return
            case 0x35:
                // DEC (HL)
                mem[Hl] = Dec(mem[Hl])
#if DEBUG
                print("DEC (HL)")
#endif
                Wait(7)
                return
            case 0x27:
                // DAA
                var a = registers[A]
                let f = registers[F]
                if (a & 0x0F) > 0x09 || (f & Flags.H.rawValue) > 0
                {
                    Add(0x06)
                    a = registers[A]
                }
                if (a & 0xF0) > 0x90 || (f & Flags.C.rawValue) > 0
                {
                    Add(0x60)
                }
#if DEBUG
                print("DAA")
#endif
                Wait(4)
                return
            case 0x2F:
                // CPL
                registers[A] ^= 0xFF
                registers[F] |= Flags.H.rawValue | Flags.N.rawValue
#if DEBUG
                print("CPL")
#endif
                Wait(4)
                return
            case 0x3F:
                // CCF
                registers[F] &= ~Flags.N.rawValue
                registers[F] ^= Flags.C.rawValue
#if DEBUG
                print("CCF")
#endif
                Wait(4)
                return
            case 0x37:
                // SCF
                registers[F] &= ~Flags.N.rawValue
                registers[F] |= Flags.C.rawValue
#if DEBUG
                print("SCF")
#endif
                Wait(4)
                return
            case 0x09:
                AddHl(Bc)
#if DEBUG
                print("ADD HL, BC")
#endif
                Wait(4)
                return
            case 0x19:
                AddHl(De)
#if DEBUG
                print("ADD HL, DE")
#endif
                Wait(4)
                return
            case 0x29:
                AddHl(Hl)
#if DEBUG
                print("ADD HL, HL")
#endif
                Wait(4)
                return
            case 0x39:
                AddHl(Sp)
#if DEBUG
                print("ADD HL, SP")
#endif
                Wait(4)
                return
            case 0x03:
                let val = Bc &+ 1
                registers[B] = Byte(val >> 8)
                registers[C] = Byte(val & 0xFF)
#if DEBUG
                print("INC BC")
#endif
                Wait(4)
                return
            case 0x13:
                let val = De &+ 1
                registers[D] = Byte(val >> 8)
                registers[E] = Byte(val & 0xFF)
#if DEBUG
                print("INC DE")
#endif
                Wait(4)
                return
            case 0x23:
                let val = Hl &+ 1
                registers[H] = Byte(val >> 8)
                registers[L] = Byte(val & 0xFF)
#if DEBUG
                print("INC HL")
#endif
                Wait(4)
                return
            case 0x33:
                let val = Sp &+ 1
                registers[SP] = Byte(val >> 8)
                registers[SP + 1] = Byte(val & 0xFF)
#if DEBUG
                print("INC SP")
#endif
                Wait(4)
                return
            case 0x0B:
                let val = Bc &- 1
                registers[B] = Byte(val >> 8)
                registers[C] = Byte(val & 0xFF)
#if DEBUG
                print("DEC BC")
#endif
                Wait(4)
                return
            case 0x1B:
                let val = De &- 1
                registers[D] = Byte(val >> 8)
                registers[E] = Byte(val & 0xFF)
#if DEBUG
                print("DEC DE")
#endif
                Wait(4)
                return
            case 0x2B:
                let val = Hl &- 1
                registers[H] = Byte(val >> 8)
                registers[L] = Byte(val & 0xFF)
#if DEBUG
                print("DEC HL")
#endif
                Wait(4)
                return
            case 0x3B:
                let val = Sp &- 1
                registers[SP] = Byte(val >> 8)
                registers[SP + 1] = Byte(val & 0xFF)
#if DEBUG
                print("DEC SP")
#endif
                Wait(4)
                return
            case 0x07:
                var a = registers[A]
                let c = (a & 0x80) >> 7
                a <<= 1
                registers[A] = a
                registers[F] &= ~(Flags.H.rawValue | Flags.N.rawValue | Flags.C.rawValue)
                registers[F] |= c
#if DEBUG
                print("RLCA")
#endif
                Wait(4)
                return
            case 0x17:
                var a = registers[A]
                let c = (a & 0x80) >> 7
                a <<= 1
                var f = registers[F]
                a |= f & Flags.C.rawValue
                registers[A] = a
                f &= ~(Flags.H.rawValue | Flags.N.rawValue | Flags.C.rawValue)
                f |= c
                registers[F] = f
#if DEBUG
                print("RLA")
#endif
                Wait(4)
                return
            case 0x0F:
                var a = registers[A]
                let c = a & 0x01
                a >>= 1
                registers[A] = a
                registers[F] &= ~(Flags.H.rawValue | Flags.N.rawValue | Flags.C.rawValue)
                registers[F] |= c
#if DEBUG
                print("RRCA")
#endif
                Wait(4)
                return
            case 0x1F:
                var a = registers[A]
                let c = a & 0x01
                a >>= 1
                var f = registers[F]
                a |= (f & Flags.C.rawValue) << 7
                registers[A] = a
                f &= ~(Flags.H.rawValue | Flags.N.rawValue | Flags.C.rawValue)
                f |= c
                registers[F] = f
#if DEBUG
                print("RRA")
#endif
                Wait(4)
                return
            case 0xC3:
                let addr = Fetch16()
                registers[PC] = Byte(addr >> 8)
                registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                print(String(format: "JP 0x%04X", addr))
#endif
                Wait(10)
                return
            case 0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA:
                let addr = Fetch16()
                if JpCondition(is: r)
                {
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
                }
#if DEBUG
                print(String(format: "JP %@, 0x%04X", Z80.JpConditionName(r), addr))
#endif
                Wait(10)
                return
            case 0x18:
                // order is important here
                let d = SByte(truncatingIfNeeded: Fetch())
                let addr = Pc + d
                registers[PC] = Byte(addr >> 8)
                registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                print(String(format: "JR 0x%04X", addr))
#endif
                Wait(12)
                return
            case 0x20, 0x28, 0x30, 0x38:
                // order is important here
                let d = SByte(truncatingIfNeeded: Fetch())
                let addr = Pc + d
                if JpCondition(is: r & 0x03)
                {
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
                    Wait(12)
                }
                else
                {
                    Wait(7)
                }
#if DEBUG
                print(String(format: "JR %@, 0x%04X", Z80.JpConditionName(r & 0x03), addr))
#endif
                return
            case 0xE9:
                let addr = Hl
                registers[PC] = Byte(addr >> 8)
                registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                print("JP HL")
#endif
                Wait(4)
                return
            case 0x10:
                // order is important here
                let d = SByte(truncatingIfNeeded: Fetch())
                let addr = Pc + d
                var b = registers[B]
                b -= 1
                registers[B] = b
                if b != 0
                {
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
                    Wait(13)
                }
                else
                {
                    Wait(8)
                }
#if DEBUG
                print(String(format: "DJNZ 0x%04X", addr))
#endif
                return
            case 0xCD:
                let dest = Fetch16()
                var addr = Sp
                addr = addr &- 1
                mem[addr] = Byte(Pc >> 8)
                addr = addr &- 1
                mem[addr] = Byte(Pc & 0xFF)
                registers[SP] = Byte(addr >> 8)
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[PC] = Byte(dest >> 8)
                registers[PC + 1] = Byte(dest & 0xFF)
#if DEBUG
                print(String(format: "CALL 0x%04X", dest))
#endif
                Wait(17)
                return
            case 0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC:
                let dest = Fetch16()
                if JpCondition(is: r)
                {
                    var addr = Sp
                    addr = addr &- 1
                    mem[addr] = Byte(Pc >> 8)
                    addr = addr &- 1
                    mem[addr] = Byte(Pc & 0xFF)
                    registers[SP] = Byte(addr >> 8)
                    registers[SP + 1] = Byte(addr & 0xFF)
                    registers[PC] = Byte(dest >> 8)
                    registers[PC + 1] = Byte(dest & 0xFF)
                    Wait(17)
                }
                else
                {
                    Wait(10)
                }
#if DEBUG
                print(String(format: "CALL %@, 0x%04X", Z80.JpConditionName(r), dest))
#endif
                return
            case 0xC9:
                var addr = Sp
                registers[PC + 1] = mem[addr]
                addr = addr &+ 1
                registers[PC] = mem[addr]
                addr = addr &+ 1
                registers[SP] = Byte(addr >> 8)
                registers[SP + 1] = Byte(addr & 0xFF)
#if DEBUG
                print("RET")
#endif
                Wait(10)
                return
            case 0xC0, 0xC8, 0xD0, 0xD8, 0xE0, 0xE8, 0xF0, 0xF8:
                if JpCondition(is: r)
                {
                    var addr = Sp
                    registers[PC + 1] = mem[addr]
                    addr = addr &+ 1
                    registers[PC] = mem[addr]
                    addr = addr &+ 1
                    registers[SP] = Byte(addr >> 8)
                    registers[SP + 1] = Byte(addr & 0xFF)
                    Wait(11)
                }
                else
                {
                    Wait(5)
                }
#if DEBUG
                print(String(format: "RET %@", Z80.JpConditionName(r)))
#endif
                return
            case 0xC7, 0xCF, 0xD7, 0xDF, 0xE7, 0xEF, 0xF7, 0xFF:
                var addr = Sp
                addr = addr &- 1
                mem[addr] = Byte(Pc >> 8)
                addr = addr &- 1
                mem[addr] = Byte(Pc & 0xFF)
                registers[SP] = Byte(addr >> 8)
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[PC] = 0
                registers[PC + 1] = Byte(mc & 0x38)
#if DEBUG
                print(String(format: "RST 0x%04X", mc & 0x38))
#endif
                Wait(17)
                return
            case 0xDB:
                let port = (UShort(registers[A]) << 8) + Fetch()
                registers[A] = ports.rdPort(port)
#if DEBUG
                print(String(format: "IN A, (0x%02X)", port))
#endif
                Wait(11)
                return
            case 0xD3:
                let port = (UShort(registers[A]) << 8) + Fetch()
                ports.wrPort(port, registers[A])
#if DEBUG
                print(String(format: "OUT (0x%04X), A", port))
#endif
                Wait(11)
                return
            default:
                break
        }
#if DEBUG
        print(String(format: "Invalid Opcode %2X: %02X %02X %02X", mc, hi, lo, r))
#endif
        Halt = true
    }

    private static func JpConditionName(_ condition: Byte) -> String
    {
        switch condition
        {
            case 0:
                return "NZ"
            case 1:
                return "Z"
            case 2:
                return "NC"
            case 3:
                return "C"
            case 4:
                return "PO"
            case 5:
                return "PE"
            case 6:
                return "P"
            case 7:
                return "M"
            default:
                break
        }
        return ""
    }

    private mutating func ParseCB(_ mode: Byte = 0)
    {
        var d: SByte = 0
        if mode != 0
        {
            d = SByte(truncatingIfNeeded: Fetch())
        }
        if Halt {
            return
        }
        let mc = Fetch()
        let hi = mc >> 6
        let lo = mc & 0x07
        let r = (mc >> 3) & 0x07
        let useHL = lo == 6
        let useIX = mode == 0xDD
        let useIY = mode == 0xFD
        var reg = useHL ? useIX ? mem[Ix + d] : useIY ? mem[Iy + d] : mem[Hl] : registers[lo]
        switch hi
        {
            case 0:
                var c: Byte
                if (r & 1) == 1
                {
                    c = reg & 0x01
                    reg >>= 1
                }
                else
                {
                    c = (reg & 0x80) >> 7
                    reg <<= 1
                }
                var f = registers[F]
                switch r
                {
                    case 0:
                        reg |= c
#if DEBUG
                        print(String(format: "RLC \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    case 1:
                        reg |= c << 7
#if DEBUG
                        print(String(format: "RRC \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    case 2:
                        reg |= f & Flags.C.rawValue
#if DEBUG
                        print(String(format: "RL \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    case 3:
                        reg |= (f & Flags.C.rawValue) << 7
#if DEBUG
                        print(String(format: "RR \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    case 4:
#if DEBUG
                        print(String(format: "SLA \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    case 5:
                        reg |= (reg & 0x40) << 1
#if DEBUG
                        print(String(format: "SRA \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    case 6:
                        reg |= 1
#if DEBUG
                        print(String(format: "SLL \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    case 7:
#if DEBUG
                        print(String(format: "SRL \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))"))
#endif
                        break
                    default:
                        break
                }
                f &= ~(Flags.H.rawValue | Flags.N.rawValue | Flags.C.rawValue | Flags.PV.rawValue | Flags.S.rawValue | Flags.Z.rawValue)
                f |= reg & Flags.S.rawValue
                if reg == 0 {
                    f |= Flags.Z.rawValue
                }
                if Z80.Parity(reg) {
                    f |= Flags.PV.rawValue
                }
                f |= c
                registers[F] = f
                break
            case 1:
                Bit(r, reg)
#if DEBUG
                print(String(format: "BIT %d, \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))", r))
#endif
                Wait(useHL ? 12 : 8)
                return
            case 2:
                reg &= ~(0x01 << r)
#if DEBUG
                print(String(format: "RES %d, \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))", r))
#endif
                Wait(useHL ? 12 : 8)
                break
            case 3:
                reg |= 0x01 << r
#if DEBUG
                print(String(format: "SET %d, \(useHL ? (useIX ? String(format: "(IX%+d)", d) : useIY ? String(format: "(IY%+d)", d) : "(HL)") : (useIX ? String(format: "(IX%+d), %@", d, Z80.RegName(lo)) : useIY ? String(format: "(IY%+d), %@", d, Z80.RegName(lo)) : Z80.RegName(lo)))", r))
#endif
                Wait(useHL ? 12 : 8)
                break
            default:
                break
        }
        if useHL
        {
            if useIX
            {
                mem[Ix + d] = reg
                Wait(23)
            }
            else if (useIY)
            {
                mem[Iy + d] = reg
                Wait(23)
            }
            else
            {
                mem[Hl] = reg
                Wait(15)
            }
        }
        else
        {
            if useIX
            {
                mem[Ix + d] = reg
                Wait(23)
            }
            else if (useIY)
            {
                mem[Iy + d] = reg
                Wait(23)
            }
            registers[lo] = reg
            Wait(8)
        }
    }

    private mutating func Bit(_ bit: Byte, _ val: Byte)
    {
        var f = registers[F] & ~(Flags.Z.rawValue | Flags.H.rawValue | Flags.N.rawValue)
        if (val & (0x01 << bit)) == 0 {
            f |= Flags.Z.rawValue
        }
        f |= Flags.H.rawValue
        registers[F] = f
    }

    private mutating func AddHl(_ val: UShort)
    {
        let sum = Add(Hl, val)
        registers[H] = Byte(sum >> 8)
        registers[L] = Byte(sum & 0xFF)
    }

    private mutating func AddIx(_ val: UShort)
    {
        let sum = Add(Ix, val)
        registers[IX] = Byte(sum >> 8)
        registers[IX + 1] = Byte(sum & 0xFF)
    }

    private mutating func AddIy(_ val: UShort)
    {
        let sum = Add(Iy, val)
        registers[IY] = Byte(sum >> 8)
        registers[IY + 1] = Byte(sum & 0xFF)
    }

    private mutating func Add(_ a: UShort, _ b: UShort) -> UShort
    {
        let sum = Int(a) + Int(b)
        var f = registers[F] & ~(Flags.H.rawValue | Flags.N.rawValue | Flags.C.rawValue)
        if (a & 0x0FFF) + (b & 0x0FFF) > 0x0FFF {
            f |= Flags.H.rawValue
        }
        if sum > 0xFFFF {
            f |= Flags.C.rawValue
        }
        registers[F] = f
        return UShort(truncatingIfNeeded: sum)
    }

    private mutating func AdcHl(_ val: UShort)
    {
        let sum = Adc(Hl, val)
        registers[H] = Byte(sum >> 8)
        registers[L] = Byte(sum & 0xFF)
    }

    private mutating func Adc(_ a: UShort, _ b: UShort) -> UShort
    {
        let sum = Int(a) + Int(b) + Int((registers[F] & Flags.C.rawValue))
        var f = registers[F] & ~(Flags.S.rawValue | Flags.Z.rawValue | Flags.H.rawValue | Flags.PV.rawValue | Flags.N.rawValue | Flags.C.rawValue)
        if sum < 0 {
            f |= Flags.S.rawValue
        }
        if sum == 0 {
            f |= Flags.Z.rawValue
        }
        if (a & 0x0FFF) + (b & 0x0FFF) + Flags.C.rawValue > 0x0FFF {
            f |= Flags.H.rawValue
        }
        if sum > 0x7FFF {
            f |= Flags.PV.rawValue
        }
        if sum > 0xFFFF {
            f |= Flags.C.rawValue
        }
        registers[F] = f
        return UShort(truncatingIfNeeded: sum)
    }

    private mutating func SbcHl(_ val: UShort)
    {
        let sum = Sbc(Hl, val)
        registers[H] = Byte(sum >> 8)
        registers[L] = Byte(sum & 0xFF)
    }

    private mutating func Sbc(_ a: UShort, _ b: UShort) -> UShort
    {
        let dif = Int(a) - Int(b) - Int(registers[F] & Flags.C.rawValue)
        var f = registers[F] & ~(Flags.S.rawValue | Flags.Z.rawValue | Flags.H.rawValue | Flags.PV.rawValue | Flags.N.rawValue | Flags.C.rawValue)
        if dif < 0 {
            f |= Flags.S.rawValue
        }
        if dif == 0 {
            f |= Flags.Z.rawValue
        }
        if (a & 0xFFF) < (b & 0xFFF) + (registers[F] & Flags.C.rawValue) {
            f |= Flags.H.rawValue
        }
        if dif > Short.max || dif < Short.min {
            f |= Flags.PV.rawValue
        }
        if UShort(truncatingIfNeeded: dif) > a {
            f |= Flags.C.rawValue
        }
        registers[F] = f
        return UShort(truncatingIfNeeded: dif)
    }

    private mutating func ParseED()
    {
        if Halt {
            return
        }
        let mc = Fetch()
        let r = (mc >> 3) & 0x07
        switch mc
        {
            case 0x47:
                // LD I, A
                registers[I] = registers[A]
#if DEBUG
                print("LD I, A")
#endif
                Wait(9)
                return
            case 0x4F:
                // LD R, A
                registers[R] = registers[A]
#if DEBUG
                print("LD R, A")
#endif
                Wait(9)
                return
            case 0x57:
                // LD A, I
                let i = registers[I]
                registers[A] = i
                var f = registers[F] & ~(Flags.H.rawValue | Flags.PV.rawValue | Flags.N.rawValue | Flags.S.rawValue | Flags.Z.rawValue)
                if i >= 0x80
                {
                    f |= Flags.S.rawValue
                }
                else if (i == 0x00)
                {
                    f |= Flags.Z.rawValue
                }
                if IFF2
                {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print("LD A, I")
#endif
                Wait(9)
                return
            case 0x5F:
                // LD A, R
                let reg = registers[R]
                registers[A] = reg
                var f = registers[F] & ~(Flags.H.rawValue | Flags.PV.rawValue | Flags.N.rawValue | Flags.S.rawValue | Flags.Z.rawValue)
                if reg >= 0x80
                {
                    f |= Flags.S.rawValue
                }
                else if (reg == 0x00)
                {
                    f |= Flags.Z.rawValue
                }
                if IFF2
                {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print("LD A, R")
#endif
                //Wait(9)
                return
            case 0x4B:
                // LD BC, (nn)
                var addr = Fetch16()
                registers[C] = mem[addr]
                addr = addr &+ 1
                registers[B] = mem[addr]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD BC, (0x%04X)", addr))
#endif
                Wait(20)
                return
            case 0x5B:
                // LD DE, (nn)
                var addr = Fetch16()
                registers[E] = mem[addr]
                addr = addr &+ 1
                registers[D] = mem[addr]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD DE, (0x%04X)", addr))
#endif
                Wait(20)
                return
            case 0x6B:
                // LD HL, (nn)
                var addr = Fetch16()
                registers[L] = mem[addr]
                addr = addr &+ 1
                registers[H] = mem[addr]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD HL, (0x%04X)", addr))
#endif
                Wait(20)
                return
            case 0x7B:
                // LD SP, (nn)
                var addr = Fetch16()
                registers[SP + 1] = mem[addr]
                addr = addr &+ 1
                registers[SP] = mem[addr]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD SP, (0x%04X)", addr))
#endif
                Wait(20)
                return
            case 0x43:
                // LD (nn), BC
                var addr = Fetch16()
                mem[addr] = registers[C]
                addr = addr &+ 1
                mem[addr] = registers[B]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD (0x%04X), BC", addr))
#endif
                Wait(20)
                return
            case 0x53:
                // LD (nn), DE
                var addr = Fetch16()
                mem[addr] = registers[E]
                addr = addr &+ 1
                mem[addr] = registers[D]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD (0x%04X), DE", addr))
#endif
                Wait(20)
                return
            case 0x63:
                // LD (nn), HL
                var addr = Fetch16()
                mem[addr] = registers[L]
                addr = addr &+ 1
                mem[addr] = registers[H]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD (0x%04X), HL", addr))
#endif
                Wait(20)
                return
            case 0x73:
                // LD (nn), SP
                var addr = Fetch16()
                mem[addr] = registers[SP + 1]
                addr = addr &+ 1
                mem[addr] = registers[SP]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD (0x%04X), SP", addr))
#endif
                Wait(20)
                return
            case 0xA0:
                // LDI
                var bc = Bc
                var de = De
                var hl = Hl
                mem[de] = mem[hl]
                de += 1
                hl += 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[D] = Byte(de >> 8)
                registers[E] = Byte(de & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                var f = registers[F] & 0xE9
                if bc != 0 {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print("LDI")
#endif
                Wait(16)
                return
            case 0xB0:
                // LDIR
                var bc = Bc
                var de = De
                var hl = Hl
                mem[de] = mem[hl]
                de += 1
                hl += 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[D] = Byte(de >> 8)
                registers[E] = Byte(de & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                registers[F] = registers[F] & 0xE9
                if bc != 0
                {
                    var addr = (UShort(registers[PC]) << 8) + registers[PC + 1]
                    // jumps back to itself
                    addr -= 2
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
                    Wait(21)
                    return
                }
#if DEBUG
                print("LDIR")
#endif
                Wait(16)
                return
            case 0xA8:
                // LDD
                var bc = Bc
                var de = De
                var hl = Hl
                mem[de] = mem[hl]
                de -= 1
                hl -= 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[D] = Byte(de >> 8)
                registers[E] = Byte(de & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                var f = registers[F] & 0xE9
                if bc != 0 {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print("LDD")
#endif
                Wait(16)
                return
            case 0xB8:
                // LDDR
                var bc = Bc
                var de = De
                var hl = Hl
                mem[de] = mem[hl]
                de -= 1
                hl -= 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[D] = Byte(de >> 8)
                registers[E] = Byte(de & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                registers[F] = registers[F] & 0xE9
                if bc != 0
                {
                    var addr = (UShort(registers[PC]) << 8) + registers[PC + 1]
                    // jumps back to itself
                    addr -= 2
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
                    Wait(21)
                    return
                }
#if DEBUG
                print("LDDR")
#endif
                Wait(16)
                return
            case 0xA1:
                // CPI
                var bc = Bc
                var hl = Hl
                let a = registers[A]
                let b = mem[hl]
                hl += 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                var f = registers[F] & 0x2A
                if a < b {
                    f |= Flags.S.rawValue
                }
                if a == b {
                    f |= Flags.Z.rawValue
                }
                if (a & 8) < (b & 8) {
                    f |= Flags.H.rawValue
                }
                if bc != 0 {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f | Flags.N.rawValue
#if DEBUG
                print("CPI")
#endif
                Wait(16)
                return
            case 0xB1:
                // CPIR
                var bc = Bc
                var hl = Hl
                let a = registers[A]
                let b = mem[hl]
                hl += 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                if a == b || bc == 0
                {
                    var f = registers[F] & 0x2A
                    if a < b {
                        f |= Flags.S.rawValue
                    }
                    if a == b {
                        f |= Flags.Z.rawValue
                    }
                    if (a & 8) < (b & 8) {
                        f |= Flags.H.rawValue
                    }
                    if bc != 0 {
                        f |= Flags.PV.rawValue
                    }
                    registers[F] = f | Flags.N.rawValue
#if DEBUG
                    print("CPIR")
#endif
                    Wait(16)
                    return
                }
                var addr = (UShort(registers[PC]) << 8) + registers[PC + 1]
                // jumps back to itself
                addr -= 2
                registers[PC] = Byte(addr >> 8)
                registers[PC + 1] = Byte(addr & 0xFF)
                Wait(21)
                return
            case 0xA9:
                // CPD
                var bc = Bc
                var hl = Hl
                let a = registers[A]
                let b = mem[hl]
                hl -= 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                var f = registers[F] & 0x2A
                if a < b {
                    f |= Flags.S.rawValue
                }
                if a == b {
                    f |= Flags.Z.rawValue
                }
                if (a & 8) < (b & 8) {
                    f |= Flags.H.rawValue
                }
                if bc != 0 {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f | Flags.N.rawValue
#if DEBUG
                print("CPD")
#endif
                Wait(16)
                return
            case 0xB9:
                // CPDR
                var bc = Bc
                var hl = Hl
                let a = registers[A]
                let b = mem[hl]
                hl -= 1
                bc -= 1
                registers[B] = Byte(bc >> 8)
                registers[C] = Byte(bc & 0xFF)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(hl & 0xFF)
                if a == b || bc == 0
                {
                    var f = registers[F] & 0x2A
                    if a < b {
                        f |= Flags.S.rawValue
                    }
                    if a == b {
                        f |= Flags.Z.rawValue
                    }
                    if (a & 8) < (b & 8) {
                        f |= Flags.H.rawValue
                    }
                    if bc != 0 {
                        f |= Flags.PV.rawValue
                    }
                    registers[F] = f | Flags.N.rawValue
#if DEBUG
                    print("CPDR")
#endif
                    Wait(21)
                    return
                }
                var addr = (UShort(registers[PC]) << 8) + registers[PC + 1]
                // jumps back to itself
                addr -= 2
                registers[PC] = Byte(addr >> 8)
                registers[PC + 1] = Byte(addr & 0xFF)
                Wait(21)
                return
            case 0x44, 0x54, 0x64, 0x74, 0x4C, 0x5C, 0x6C, 0x7C:
                // NEG
                let a = registers[A]
                let dif = -Short(truncatingIfNeeded: a)
                registers[A] = Byte(truncatingIfNeeded: dif)
                var f = registers[F] & ~Flags.All.rawValue
                if (Byte(truncatingIfNeeded: dif) & 0x80) > 0 {
                    f |= Flags.S.rawValue
                }
                if dif == 0 {
                    f |= Flags.Z.rawValue
                }
                if (a & 0x0F) != 0 {
                    f |= Flags.H.rawValue
                }
                if a == 0x80 {
                    f |= Flags.PV.rawValue
                }
                f |= Flags.N.rawValue
                if dif != 0 {
                    f |= Flags.C.rawValue
                }
                registers[F] = f
#if DEBUG
                print("NEG")
#endif
                Wait(8)
                return
            case 0x46, 0x66:
                // IM 0
                IM = 0
#if DEBUG
                print("IM 0")
#endif
                Wait(8)
                return
            case 0x56, 0x76:
                // IM 1
                IM = 1
#if DEBUG
                print("IM 1")
#endif
                Wait(8)
                return
            case 0x5E, 0x7E:
                // IM 2
                IM = 2
#if DEBUG
                print("IM 2")
#endif
                Wait(8)
                return
            case 0x4A:
                AdcHl(Bc)
#if DEBUG
                print("ADC HL, BC")
#endif
                Wait(15)
                return
            case 0x5A:
                AdcHl(De)
#if DEBUG
                print("ADC HL, DE")
#endif
                Wait(15)
                return
            case 0x6A:
                AdcHl(Hl)
#if DEBUG
                print("ADC HL, HL")
#endif
                Wait(15)
                return
            case 0x7A:
                AdcHl(Sp)
#if DEBUG
                print("ADC HL, SP")
#endif
                Wait(15)
                return
            case 0x42:
                SbcHl(Bc)
#if DEBUG
                print("SBC HL, BC")
#endif
                Wait(15)
                return
            case 0x52:
                SbcHl(De)
#if DEBUG
                print("SBC HL, DE")
#endif
                Wait(15)
                return
            case 0x62:
                SbcHl(Hl)
#if DEBUG
                print("SBC HL, HL")
#endif
                Wait(15)
                return
            case 0x72:
                SbcHl(Sp)
#if DEBUG
                print("SBC HL, SP")
#endif
                Wait(15)
                return
            case 0x6F:
                var a = registers[A]
                let b = mem[Hl]
                mem[Hl] = (b << 4) | (a & 0x0F)
                a = (a & 0xF0) | (b >> 4)
                registers[A] = a
                var f = registers[F] & 0x29
                if (a & 0x80) > 0 {
                    f |= Flags.S.rawValue
                }
                if a == 0 {
                    f |= Flags.Z.rawValue
                }
                if Z80.Parity(a) {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print("RLD")
#endif
                Wait(18)
                return
            case 0x67:
                var a = registers[A]
                let b = mem[Hl]
                mem[Hl] = (b >> 4) | (a << 4)
                a = (a & 0xF0) | (b & 0x0F)
                registers[A] = a
                var f = registers[F] & 0x29
                if (a & 0x80) > 0 {
                    f |= Flags.S.rawValue
                }
                if a == 0 {
                    f |= Flags.Z.rawValue
                }
                if Z80.Parity(a) {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print("RRD")
#endif
                Wait(18)
                return
            case 0x45, 0x4D, 0x55, 0x5D, 0x65, 0x6D, 0x75, 0x7D:
                var addr = Sp
                registers[PC + 1] = mem[addr]
                addr = addr &+ 1
                registers[PC] = mem[addr]
                addr = addr &+ 1
                registers[SP] = Byte(addr >> 8)
                registers[SP + 1] = Byte(addr & 0xFF)
                IFF1 = IFF2
#if DEBUG
                if mc == 0x4D {
                    print("RETN")
                } else {
                    print("RETI")
                }
#endif
                Wait(10)
                return
            case 0x77, 0x7F:
#if DEBUG
                print("NOP")
#endif
                Wait(8)
                return
            case 0x40, 0x48, 0x50, 0x58, 0x60, 0x68, 0x78:
                let a = Byte(ports.rdPort(Bc))
                registers[r] = a
                var f = registers[F] & 0x29
                if (a & 0x80) > 0 {
                    f |= Flags.S.rawValue
                }
                if a == 0 {
                    f |= Flags.Z.rawValue
                }
                if Z80.Parity(a) {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print(String(format: "IN %@, (BC)", Z80.RegName(r)))
#endif
                Wait(8)
                return
            case 0xA2:
                let a = ports.rdPort(Bc)
                var hl = Hl
                mem[hl] = a
                hl += 1
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = registers[B] - 1
                registers[B] = b
                var f = registers[F] & ~(Flags.N.rawValue | Flags.Z.rawValue)
                if b == 0 {
                    f |= Flags.Z.rawValue
                }
                f |= Flags.N.rawValue
                registers[F] = f
#if DEBUG
                print("INI")
#endif
                Wait(16)
                return
            case 0xB2:
                let a = ports.rdPort(Bc)
                var hl = Hl
                mem[hl] = a
                hl += 1
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = Byte(registers[B] - 1)
                registers[B] = b
                if b != 0
                {
                    let addr = Pc - 2
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                    print("(INIR)")
#endif
                    Wait(21)
                }
                else
                {
                    registers[F] = (registers[F] | Flags.N.rawValue | Flags.Z.rawValue)
#if DEBUG
                    print("INIR")
#endif
                    Wait(16)
                }
                return
            case 0xAA:
                let a = ports.rdPort(Bc)
                var hl = Hl
                mem[hl] = a
                hl -= 1
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = Byte(registers[B] - 1)
                registers[B] = b
                var f = registers[F] & ~(Flags.N.rawValue | Flags.Z.rawValue)
                if b == 0 {
                    f |= Flags.Z.rawValue
                }
                f |= Flags.N.rawValue
                registers[F] = f
#if DEBUG
                print("IND")
#endif
                Wait(16)
                return
            case 0xBA:
                let a = ports.rdPort(Bc)
                var hl = Hl
                mem[hl] = a
                hl -= 1
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = Byte(registers[B] - 1)
                registers[B] = b
                if b != 0
                {
                    let addr = Pc - 2
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                    print("(INDR)")
#endif
                    Wait(21)
                }
                else
                {
                    registers[F] = (registers[F] | Flags.N.rawValue | Flags.Z.rawValue)
#if DEBUG
                    print("INDR")
#endif
                    Wait(16)
                }
                return
            case 0x41, 0x49, 0x51, 0x59, 0x61, 0x69, 0x79:
                let a = registers[r]
                ports.wrPort(Bc, a)
                var f = registers[F] & 0x29
                if (a & 0x80) > 0 {
                    f |= Flags.S.rawValue
                }
                if a == 0 {
                    f |= Flags.Z.rawValue
                }
                if Z80.Parity(a) {
                    f |= Flags.PV.rawValue
                }
                registers[F] = f
#if DEBUG
                print(String(format: "OUT (BC), %@", Z80.RegName(r)))
#endif
                Wait(8)
                return
            case 0xA3:
                var hl = Hl
                let a = mem[hl]
                hl += 1
                ports.wrPort(Bc, a)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = Byte(registers[B] - 1)
                registers[B] = b
                var f = registers[F] & ~(Flags.N.rawValue | Flags.Z.rawValue)
                if b == 0 {
                    f |= Flags.Z.rawValue
                }
                f |= Flags.N.rawValue
                registers[F] = f
#if DEBUG
                print("OUTI")
#endif
                Wait(16)
                return
            case 0xB3:
                var hl = Hl
                let a = mem[hl]
                hl += 1
                ports.wrPort(Bc, a)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = Byte(registers[B] - 1)
                registers[B] = b
                if b != 0
                {
                    let addr = Pc - 2
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                    print("(OUTIR)")
#endif
                    Wait(21)
                }
                else
                {
                    registers[F] = (registers[F] | Flags.N.rawValue | Flags.Z.rawValue)
#if DEBUG
                    print("OUTIR")
#endif
                    Wait(16)
                }
                return
            case 0xAB:
                var hl = Hl
                let a = mem[hl]
                hl -= 1
                ports.wrPort(Bc, a)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = Byte(registers[B] - 1)
                registers[B] = b
                var f = registers[F] & ~(Flags.N.rawValue | Flags.Z.rawValue)
                if b == 0 {
                    f |= Flags.Z.rawValue
                }
                f |= Flags.N.rawValue
                registers[F] = f
#if DEBUG
                print("OUTD")
#endif
                Wait(16)
                return
            case 0xBB:
                var hl = Hl
                let a = mem[hl]
                hl -= 1
                ports.wrPort(Bc, a)
                registers[H] = Byte(hl >> 8)
                registers[L] = Byte(truncatingIfNeeded: hl)
                let b = Byte(registers[B] - 1)
                registers[B] = b
                if b != 0
                {
                    let addr = Pc - 2
                    registers[PC] = Byte(addr >> 8)
                    registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                    print("(OUTDR)")
#endif
                    Wait(21)
                }
                else
                {
                    registers[F] = (registers[F] | Flags.N.rawValue | Flags.Z.rawValue)
#if DEBUG
                    print("OUTDR")
#endif
                    Wait(16)
                }
                return
            default:
                break
        }
#if DEBUG
        print(String(format: "Invalid Opcode ED %02X: %02X", mc, r))
#endif
        Halt = true
    }

    private mutating func ParseDD()
    {
        if Halt {
            return
        }
        let mc = Fetch()
        let hi = mc >> 6
        let lo = mc & 0x07
        let r = (mc >> 3) & 0x07
        switch mc
        {
            case 0xCB:
                ParseCB(0xDD)
                return
            case 0x21:
                // LD IX, nn
                registers[IX + 1] = Fetch()
                registers[IX] = Fetch()
#if DEBUG
                print(String(format: "LD IX, 0x%04X", Ix))
#endif
                Wait(14)
                return
            case 0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E, 0x7E:
                // LD r, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                registers[r] = mem[Ix + d]
#if DEBUG
                print(String(format: "LD %@, (IX+%d)", Z80.RegName(r), d))
#endif
                Wait(19)
                return
            case 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77:
                // LD (IX+d), r
                let d = SByte(truncatingIfNeeded: Fetch())
                mem[Ix + d] = registers[lo]
#if DEBUG
                print(String(format: "LD (IX+%d), %@", d, Z80.RegName(lo)))
#endif
                Wait(19)
                return
            case 0x36:
                // LD (IX+d), n
                let d = SByte(truncatingIfNeeded: Fetch())
                let n = Fetch()
                mem[Ix + d] = n
#if DEBUG
                print(String(format: "LD (IX+%d), %d", d, n))
#endif
                Wait(19)
                return
            case 0x2A:
                // LD IX, (nn)
                var addr = Fetch16()
                registers[IX + 1] = mem[addr]
                addr = addr &+ 1
                registers[IX] = mem[addr]
#if DEBUG
                print(String(format: "LD IX, (0x%04X)", addr))
#endif
                Wait(20)
                return
            case 0x22:
                // LD (nn), IX
                var addr = Fetch16()
                mem[addr] = registers[IX + 1]
                addr = addr &+ 1
                mem[addr] = registers[IX]
#if DEBUG
                print(String(format: "LD (0x%04X), IX", addr))
#endif
                Wait(20)
                return
            case 0xF9:
                // LD SP, IX
                registers[SP] = registers[IX]
                registers[SP + 1] = registers[IX + 1]
#if DEBUG
                print("LD SP, IX")
#endif
                Wait(10)
                return
            case 0xE5:
                // PUSH IX
                var addr = Sp
                addr = addr &- 1
                mem[addr] = registers[IX]
                addr = addr &- 1
                mem[addr] = registers[IX + 1]
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("PUSH IX")
#endif
                Wait(15)
                return
            case 0xE1:
                // POP IX
                var addr = Sp
                registers[IX + 1] = mem[addr]
                addr = addr &+ 1
                registers[IX] = mem[addr]
                addr = addr &+ 1
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("POP IX")
#endif
                Wait(14)
                return
            case 0xE3:
                // EX (SP), IX
                let hi = registers[IX]
                let lo = registers[IX + 1]
                var addr = Sp
                registers[IX + 1] = mem[addr]
                addr = addr &+ 1
                registers[IX] = mem[addr]
                mem[addr] = hi
                addr = addr &- 1
                mem[addr] = lo
#if DEBUG
                print("EX (SP), IX")
#endif
                Wait(24)
                return
            case 0x86:
                // ADD A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                Add(mem[Ix + d])
#if DEBUG
                print(String(format: "ADD A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0x8E:
                // ADC A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                // let a = registers[A]
                Adc(mem[Ix + d])
#if DEBUG
                print(String(format: "ADC A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0x96:
                // SUB A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Ix + d]
                Sub(b)
#if DEBUG
                print(String(format: "SUB A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0x9E:
                // SBC A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                Sbc(mem[Ix + d])
#if DEBUG
                print(String(format: "SBC A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0xA6:
                // AND A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Ix + d]
                And(b)
#if DEBUG
                print(String(format: "AND A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0xB6:
                // OR A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Ix + d]
                Or(b)
#if DEBUG
                print(String(format: "OR A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0xAE:
                // OR A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Ix + d]
                Xor(b)
#if DEBUG
                print(String(format: "XOR A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0xBE:
                // CP A, (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Ix + d]
                Cmp(b)
#if DEBUG
                print(String(format: "CP A, (IX+%d)", d))
#endif
                Wait(19)
                return
            case 0x34:
                // INC (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                mem[Ix + d] = Inc(mem[Ix + d])
#if DEBUG
                print(String(format: "INC (IX+%d)", d))
#endif
                Wait(7)
                return
            case 0x35:
                // DEC (IX+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                mem[Ix + d] = Dec(mem[Ix + d])
#if DEBUG
                print(String(format: "DEC (IX+%d)", d))
#endif
                Wait(7)
                return
            case 0x09:
                AddIx(Bc)
#if DEBUG
                print("ADD IX, BC")
#endif
                Wait(4)
                return
            case 0x19:
                AddIx(De)
#if DEBUG
                print("ADD IX, DE")
#endif
                Wait(4)
                return
            case 0x29:
                AddIx(Ix)
#if DEBUG
                print("ADD IX, IX")
#endif
                Wait(4)
                return
            case 0x39:
                AddIx(Sp)
#if DEBUG
                print("ADD IX, SP")
#endif
                Wait(4)
                return
            case 0x23:
                let val = Ix &+ 1
                registers[IX] = Byte(val >> 8)
                registers[IX + 1] = Byte(val & 0xFF)
#if DEBUG
                print("INC IX")
#endif
                Wait(4)
                return
            case 0x2B:
                let val = Ix &- 1
                registers[IX] = Byte(val >> 8)
                registers[IX + 1] = Byte(val & 0xFF)
#if DEBUG
                print("DEC IX")
#endif
                Wait(4)
                return
            case 0xE9:
                let addr = Ix
                registers[PC] = Byte(addr >> 8)
                registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                print("JP IX")
#endif
                Wait(8)
                return
            default:
                break
        }
#if DEBUG
        print(String(format: "Invalid Opcode DD %02X: %02X %02X %02X", mc, hi, lo, r))
#endif
        Halt = true
    }

    private mutating func ParseFD()
    {
        if Halt {
            return
        }
        let mc = Fetch()
        let hi = mc >> 6
        let lo = mc & 0x07
        let r = (mc >> 3) & 0x07
        switch mc
        {
            case 0xCB:
                ParseCB(0xFD)
                return
            case 0x21:
                // LD IY, nn
                registers[IY + 1] = Fetch()
                registers[IY] = Fetch()
#if DEBUG
                print(String(format: "LD IY, 0x%04X", Iy))
#endif
                Wait(14)
                return
            case 0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E, 0x7E:
                // LD r, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                registers[r] = mem[Iy + d]
#if DEBUG
                print(String(format: "LD %@, (IY+%d)", Z80.RegName(r), d))
#endif
                Wait(19)
                return
            case 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77:
                // LD (IY+d), r
                let d = SByte(truncatingIfNeeded: Fetch())
                mem[Iy + d] = registers[lo]
#if DEBUG
                print(String(format: "LD (IY+%d), %@", d, Z80.RegName(lo)))
#endif
                Wait(19)
                return
            case 0x36:
                // LD (IY+d), n
                let d = SByte(truncatingIfNeeded: Fetch())
                let n = Fetch()
                mem[Iy + d] = n
#if DEBUG
                print(String(format: "LD (IY+%d), %d", d, n))
#endif
                Wait(19)
                return
            case 0x2A:
                // LD IY, (nn)
                var addr = Fetch16()
                registers[IY + 1] = mem[addr]
                addr = addr &+ 1
                registers[IY] = mem[addr]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD IY, (0x%04X)", addr))
#endif
                Wait(20)
                return
            case 0x22:
                // LD (nn), IY
                var addr = Fetch16()
                mem[addr] = registers[IY + 1]
                addr = addr &+ 1
                mem[addr] = registers[IY]
#if DEBUG
                addr = addr &- 1
                print(String(format: "LD (0x%04X), IY", addr))
#endif
                Wait(20)
                return
            case 0xF9:
                // LD SP, IY
                registers[SP] = registers[IY]
                registers[SP + 1] = registers[IY + 1]
#if DEBUG
                print("LD SP, IY")
#endif
                Wait(10)
                return
            case 0xE5:
                // PUSH IY
                var addr = Sp
                addr = addr &- 1
                mem[addr] = registers[IY]
                addr = addr &- 1
                mem[addr] = registers[IY + 1]
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("PUSH IY")
#endif
                Wait(15)
                return
            case 0xE1:
                // POP IY
                var addr = Sp
                registers[IY + 1] = mem[addr]
                addr = addr &+ 1
                registers[IY] = mem[addr]
                addr = addr &+ 1
                registers[SP + 1] = Byte(addr & 0xFF)
                registers[SP] = Byte(addr >> 8)
#if DEBUG
                print("POP IY")
#endif
                Wait(14)
                return
            case 0xE3:
                // EX (SP), IY
                let hi = registers[IY]
                let lo = registers[IY + 1]
                var addr = Sp
                registers[IY + 1] = mem[addr]
                mem[addr] = lo
                addr = addr &+ 1
                registers[IY] = mem[addr]
                mem[addr] = hi
#if DEBUG
                print("EX (SP), IY")
#endif
                Wait(24)
                return
            case 0x86:
                // ADD A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                Add(mem[Iy + d])
#if DEBUG
                print(String(format: "ADD A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0x8E:
                // ADC A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                // let a = registers[A]
                Adc(mem[Iy + d])
#if DEBUG
                print(String(format: "ADC A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0x96:
                // SUB A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                Sub(mem[Iy + d])
#if DEBUG
                print(String(format: "SUB A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0x9E:
                // SBC A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                Sbc(mem[Iy + d])
#if DEBUG
                print(String(format: "SBC A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0xA6:
                // AND A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Iy + d]
                And(b)
#if DEBUG
                print(String(format: "AND A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0xB6:
                // OR A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Iy + d]
                Or(b)
#if DEBUG
                print(String(format: "OR A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0xAE:
                // XOR A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                let b = mem[Iy + d]
                Xor(b)
#if DEBUG
                print(String(format: "XOR A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0xBE:
                // CP A, (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                Cmp(mem[Iy + d])
#if DEBUG
                print(String(format: "CP A, (IY+%d)", d))
#endif
                Wait(19)
                return
            case 0x34:
                // INC (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                mem[Iy + d] = Inc(mem[Iy + d])
#if DEBUG
                print(String(format: "INC (IY+%d)", d))
#endif
                Wait(7)
                return
            case 0x35:
                // DEC (IY+d)
                let d = SByte(truncatingIfNeeded: Fetch())
                mem[Iy + d] = Dec(mem[Iy + d])
#if DEBUG
                print(String(format: "DEC (IY+%d)", d))
#endif
                Wait(7)
                return
            case 0x09:
                AddIy(Bc)
#if DEBUG
                print("ADD IY, BC")
#endif
                Wait(4)
                return
            case 0x19:
                AddIy(De)
#if DEBUG
                print("ADD IY, DE")
#endif
                Wait(4)
                return
            case 0x29:
                AddIy(Iy)
#if DEBUG
                print("ADD IY, IY")
#endif
                Wait(4)
                return
            case 0x39:
                AddIy(Sp)
#if DEBUG
                print("ADD IY, SP")
#endif
                Wait(4)
                return
            case 0x23:
                let val = Iy &+ 1
                registers[IY] = Byte(val >> 8)
                registers[IY + 1] = Byte(val & 0xFF)
#if DEBUG
                print("INC IY")
#endif
                Wait(4)
                return
            case 0x2B:
                let val = Iy &- 1
                registers[IY] = Byte(val >> 8)
                registers[IY + 1] = Byte(val & 0xFF)
#if DEBUG
                print("DEC IY")
#endif
                Wait(4)
                return
            case 0xE9:
                let addr = Iy
                registers[PC] = Byte(addr >> 8)
                registers[PC + 1] = Byte(addr & 0xFF)
#if DEBUG
                print("JP IY")
#endif
                Wait(8)
                return
            default:
                break
        }
#if DEBUG
        print(String(format: "Invalid Opcode FD %02X: %02X %02X %02X", mc, hi, lo, r))
#endif
        Halt = true
    }

    private mutating func Add(_ b: Byte)
    {
        let a = registers[A]
        let sum = UShort(a) + UShort(b)
        registers[A] = Byte(truncatingIfNeeded: sum)
        var f = registers[F] & ~Flags.All.rawValue
        if (sum & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if (sum & 0xFF) == 0 {
            f |= Flags.Z.rawValue
        }
        if (a & 0x0F) + (b & 0x0F) > 0x0F {
            f |= Flags.H.rawValue
        }
        if (a >= 0x80 && b >= 0x80 && SByte(truncatingIfNeeded: sum) > 0) || (a < 0x80 && b < 0x80 && SByte(truncatingIfNeeded: sum) < 0) {
            f |= Flags.PV.rawValue
        }
        if sum > 0xFF {
            f |= Flags.C.rawValue
        }
        registers[F] = f
    }

    private mutating func Adc(_ b: Byte)
    {
        let a = registers[A]
        let c = registers[F] & Flags.C.rawValue
        let sum = UShort(a) + UShort(b) + UShort(c)
        registers[A] = Byte(truncatingIfNeeded: sum)
        var f = registers[F] & ~Flags.All.rawValue
        if (sum & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if (sum & 0xFF) == 0 {
            f |= Flags.Z.rawValue
        }
        if (a & 0x0F) + (b & 0x0F) > 0x0F {
            f |= Flags.H.rawValue
        }
        if (a >= 0x80 && b >= 0x80 && SByte(truncatingIfNeeded: sum) > 0) || (a < 0x80 && b < 0x80 && SByte(truncatingIfNeeded: sum) < 0) {
            f |= Flags.PV.rawValue
        }
        f &= ~Flags.N.rawValue
        if sum > 0xFF {
            f |= Flags.C.rawValue
        }
        registers[F] = f
    }

    private mutating func Sub(_ b: Byte)
    {
        let a = registers[A]
        let dif = Short(a) - Short(b)
        registers[A] = Byte(truncatingIfNeeded: dif)
        var f = registers[F] & ~Flags.All.rawValue
        if (dif & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if (dif & 0xFF) == 0 {
            f |= Flags.Z.rawValue
        }
        if (a & 0x0F) < (b & 0x0F) {
            f |= Flags.H.rawValue
        }
        if (a >= 0x80 && b >= 0x80 && dif > 0) || (a < 0x80 && b < 0x80 && dif < 0) {
            f |= Flags.PV.rawValue
        }
        f |= Flags.N.rawValue
        if dif < 0 {
            f |= Flags.C.rawValue
        }
        registers[F] = f
    }

    private mutating func Sbc(_ b: Byte)
    {
        let a = registers[A]
        let c = registers[F] & Flags.C.rawValue
        let dif = Short(a) - Short(b) - Short(c)
        registers[A] = Byte(truncatingIfNeeded: dif)
        var f = registers[F] & ~Flags.All.rawValue
        if (dif & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if (dif & 0xFF) == 0 {
            f |= Flags.Z.rawValue
        }
        if (a & 0x0F) < (b & 0x0F) + c {
            f |= Flags.H.rawValue
        }
        if (a >= 0x80 && b >= 0x80 && dif > 0) || (a < 0x80 && b < 0x80 && dif < 0) {
            f |= Flags.PV.rawValue
        }
        f |= Flags.N.rawValue
        if dif > 0xFF {
            f |= Flags.C.rawValue
        }
        registers[F] = f
    }

    private mutating func And(_ b: Byte)
    {
        let a = registers[A]
        let res = a & b
        registers[A] = res
        var f = registers[F] & ~Flags.All.rawValue
        if (res & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if res == 0 {
            f |= Flags.Z.rawValue
        }
        f |= Flags.H.rawValue
        if Z80.Parity(res) {
            f |= Flags.PV.rawValue
        }
        registers[F] = f
    }

    private mutating func Or(_ b: Byte)
    {
        let a = registers[A]
        let res = a | b
        registers[A] = res
        var f = registers[F] & ~Flags.All.rawValue
        if (res & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if res == 0 {
            f |= Flags.Z.rawValue
        }
        if Z80.Parity(res) {
            f |= Flags.PV.rawValue
        }
         registers[F] = f
    }

    private mutating func Xor(_ b: Byte)
    {
        let a = registers[A]
        let res = a ^ b
        registers[A] = res
        var f = registers[F] & ~Flags.All.rawValue
        if (res & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
         if res == 0 {
            f |= Flags.Z.rawValue
        }
         if Z80.Parity(res) {
            f |= Flags.PV.rawValue
        }
         registers[F] = f
    }

    private mutating func Cmp(_ b: Byte)
    {
        let a = registers[A]
        let dif = a &- b
        var f = registers[F] & ~Flags.All.rawValue
        if (dif & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if dif == 0 {
            f |= Flags.Z.rawValue
        }
        if (a & 0x0F) < (b & 0x0F) {
            f |= Flags.H.rawValue
        }
        if (a > 0x80 && b > 0x80 && SByte(truncatingIfNeeded: dif) > 0) || (a < 0x80 && b < 0x80 && SByte(truncatingIfNeeded: dif) < 0) {
            f |= Flags.PV.rawValue
        }
        f |= Flags.N.rawValue
        if dif > 0xFF {
            f |= Flags.C.rawValue
        }
        registers[F] = f
    }

    private mutating func Inc(_ b: Byte) -> Byte
    {
        let sum = UShort(b) + UShort(1)
        var f = registers[F] & ~Flags.All.rawValue
        if (sum & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if sum == 0 {
            f |= Flags.Z.rawValue
        }
        if (b & 0x0F) == 0x0F {
            f |= Flags.H.rawValue
        }
        if (b < 0x80 && SByte(truncatingIfNeeded: sum) < 0) {
            f |= Flags.PV.rawValue
        }
        f |= Flags.N.rawValue
        if sum > 0xFF {
            f |= Flags.C.rawValue
        }
        registers[F] = f
        return Byte(truncatingIfNeeded: sum)
    }

    private mutating func Dec(_ b: Byte) -> Byte
    {
        let dif = Short(b) - Short(1)
        var f = registers[F] & ~Flags.All.rawValue
        if (dif & 0x80) > 0 {
            f |= Flags.S.rawValue
        }
        if dif == 0 {
            f |= Flags.Z.rawValue
        }
        if (b & 0x0F) == 0 {
            f |= Flags.H.rawValue
        }
        if b == 0x80 {
            f |= Flags.PV.rawValue
        }
        f |= Flags.N.rawValue
        registers[F] = f
        return Byte(truncatingIfNeeded: dif)
    }

    private static func Parity(_ val: Byte) -> Bool
    {
        Z80.Parity(UShort(val))
    }

    private static func Parity(_ val: UShort) -> Bool
    {
        var v = val
        var parity = true
        while v > 0
        {
            if (v & 1) == 1 {
                parity = !parity
            }
            v = (v >> 1)
        }
        return parity
    }

    private func JpCondition(is condition: Byte) -> Bool
    {
        var mask: Flags
        switch condition & 0xFE
        {
            case 0:
                mask = Flags.Z
                break
            case 2:
                mask = Flags.C
                break
            case 4:
                mask = Flags.PV
                break
            case 6:
                mask = Flags.S
                break
            default:
                return false
        }
        return ((registers[F] & mask.rawValue) > 0) == ((condition & 1) == 1)
    }

    private mutating func Fetch() -> Byte
    {
        var addr = Pc
        let ret = mem[addr]
#if DEBUG
        print(String(format: "  %04X %02X ", addr, ret))
#endif
        addr = addr &+ 1
        registers[PC] = Byte(addr >> 8)
        registers[PC + 1] = Byte(addr & 0xFF)
        return ret
    }

    private mutating func Fetch16() -> UShort
    {
        return UShort(Fetch()) + (UShort(Fetch()) << 8)
    }

    public mutating func reset()
    {
        for r in 0..<registers.count {
            registers[r] = 0
        }
        registers[A] = 0xFF
        registers[F] = 0xFF
        registers[SP] = 0xFF
        registers[SP + 1] = 0xFF
        //A CPU reset forces both the IFF1 and IFF2 to the reset state, which disables interrupts
        IFF1 = false
        IFF2 = false
        clock = Date().timeIntervalSinceReferenceDate
    }

    public func getState() -> [Byte] {
        let count = registers.count
        var state = Array<Byte>(repeating: 0, count: count + 2)
        for i in 0..<count {
            state[i] = registers[i]
        }
        state[count] = IFF1 ? 1 : 0
        state[count + 1] = IFF2 ? 1 : 0
        return state
    }

    public func dumpState() -> String {
        return " BC   DE   HL  SZ-H-PNC A\n"
        + String(format: "%02X%02X %02X%02X %02X%02X %d%d%d%d%d%d%d%d %02X\n", registers[B], registers[C], registers[D], registers[E], registers[H], registers[L],
            (registers[F] & 0x80) >> 7, (registers[F] & 0x40) >> 6, (registers[F] & 0x20) >> 5, (registers[F] & 0x10) >> 4,
            (registers[F] & 0x08) >> 3, (registers[F] & 0x04) >> 2, (registers[F] & 0x02) >> 1, registers[F] & 0x01, registers[A])
        + String(format: "%02X%02X %02X%02X %02X%02X %d%d%d%d%d%d%d%d %02X\n", registers[Bp], registers[Cp], registers[Dp], registers[Ep], registers[Hp], registers[Lp],
            (registers[Fp] & 0x80) >> 7, (registers[Fp] & 0x40) >> 6, (registers[Fp] & 0x20) >> 5, (registers[Fp] & 0x10) >> 4,
            (registers[Fp] & 0x08) >> 3, (registers[Fp] & 0x04) >> 2, (registers[Fp] & 0x02) >> 1, registers[Fp] & 0x01, registers[Ap])
        + "I  R   IX   IY   SP   PC\n"
        + String(format: "%02X %02X %02X%02X %02X%02X %02X%02X %02X%02X\n", registers[I], registers[R],
            registers[IX], registers[IX + 1], registers[IY], registers[IY + 1],
            registers[SP], registers[SP + 1], registers[PC], registers[PC + 1])
    }

    private mutating func Wait(_ tStates: Int)
    {
        registers[R] = registers[R] &+ Byte(truncatingIfNeeded: (tStates + 3) / 4)
        let tTime = Double(tStates) / Double(cfreq)
        let epoch = Date().timeIntervalSinceReferenceDate - clock
        let sleep = tTime - epoch
        if sleep > 0
        {
            Thread.sleep(forTimeInterval: sleep)
            clock = clock + tTime
        }
        else if (0 > sleep)
        {
#if DEBUG
            print(String(format: "Clock expected %.3f but was %.3f microseconds", tTime * 1_000_000, epoch * 1_000_000))
#endif
            clock = Date().timeIntervalSinceReferenceDate
        }
    }

    private mutating func SwapReg(_ reg: Byte, _ reg2: Byte)
    {
        let r = registers[reg]
        registers[reg] = registers[reg2]
        registers[reg2] = r
    }

    private enum Flags: Byte
    {
        case C = 0x01
        case N = 0x02
        case PV = 0x04
        case H = 0x10
        case Z = 0x40
        case S = 0x80
        case None = 0x00
        case All = 0xD7
    }

#if DEBUG
    private static func RegName(_ reg: Byte) -> String
    {
        switch reg
        {
            case 0:
                return "B"
            case 1:
                return "C"
            case 2:
                return "D"
            case 3:
                return "E"
            case 4:
                return "H"
            case 5:
                return "L"
            case 7:
                return "A"
            default:
                return ""
        }
    }

    private static func Reg16Name(_ reg: Byte) -> String
    {
        switch reg
        {
            case 0x00:
                return "BC"
            case 0x10:
                return "DE"
            case 0x20:
                return "HL"
            case 0x30:
                return "SP"
            default:
                return ""
        }
    }
#endif
}

extension Array {
    public subscript(index: Byte) -> Element {
        get {
            self[Int(index)]
        }
        set(newValue) {
            self[Int(index)] = newValue
        }
    }

    public subscript(index: UShort) -> Element {
        get {
            self[Int(index)]
        }
        set(newValue) {
            self[Int(index)] = newValue
        }
    }
}

public func +(lhs: UShort, rhs: Int) -> UShort {
    UShort(truncatingIfNeeded: Int(lhs) + rhs)
}

public func +(lhs: UShort, rhs: SByte) -> UShort {
    UShort(truncatingIfNeeded: Int(lhs) + Int(rhs))
}

public func +(lhs: UShort, rhs: Byte) -> UShort {
    UShort(truncatingIfNeeded: Int(lhs) + Int(rhs))
}

public func -(lhs: UShort, rhs: Int) -> UShort {
    UShort(truncatingIfNeeded: Int(lhs) - rhs)
}

public func -(lhs: UShort, rhs: Byte) -> UShort {
    UShort(truncatingIfNeeded: Int(lhs) - Int(rhs))
}
