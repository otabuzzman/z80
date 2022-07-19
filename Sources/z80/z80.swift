import Foundation

public struct Z80 {
    private let B = 0
    private let C = 1
    private let D = 2
    private let E = 3
    private let H = 4
    private let L = 5
    private let F = 6
    private let A = 7
    private let Bp = 8
    private let Cp = 9
    private let Dp = 10
    private let Ep = 11
    private let Hp = 12
    private let Lp = 13
    private let Fp = 14
    private let Ap = 15
    private let I = 16
    private let R = 17
    private let IX = 18
    private let IY = 20
    private let SP = 22
    private let PC = 24
    private(set) var mem: Memory
    private(set) var ports: IPorts
    private(set) var registers = Array<UInt8>(repeating: 0, count: 26)
    private var IFF1 = false
    private var IFF2 = false
    private var interruptMode: Int = 0

    private var Hl: UInt16 { UInt16(registers[L]) + (UInt16(registers[H]) << 8) }
    private var Sp: UInt16 { UInt16(registers[SP + 1]) + (UInt16(registers[SP]) << 8) }
    private var Ix: UInt16 { UInt16(registers[IX + 1]) + (UInt16(registers[IX]) << 8) }
    private var Iy: UInt16 { UInt16(registers[IY + 1]) + (UInt16(registers[IY]) << 8) }
    private var Bc: UInt16 { (UInt16(registers[B]) << 8) + UInt16(registers[C]) }
    private var De: UInt16 { (UInt16(registers[D]) << 8) + UInt16(registers[E]) }
    private var Pc: UInt16 { UInt16(registers[PC + 1]) + (UInt16(registers[PC]) << 8) }

    private(set) var Halt = false

    private var clock = Date.now

    init(_ memory: Memory, _ ports: IPorts) {
        self.mem = memory
        self.ports = ports

        reset()
    }

    public mutating func parse() {
        if ports.NMI {
            var stack = Sp
            stack -= 1
            mem[stack] = UInt8(Pc >> 8)
            stack -= 1
            mem[stack] = UInt8(Pc)
            registers[SP] = UInt8(stack >> 8)
            registers[SP + 1] = UInt8(stack)
            registers[PC] = 0x00
            registers[PC + 1] = 0x66
            IFF1 = IFF2
            IFF1 = false
#if DEBUG
            print("NMI")
#endif
            wait(17)
            Halt = false
            return
        }
        if IFF1 && ports.INT {
            IFF1 = false
            IFF2 = false
            switch interruptMode {
                case 0:
                    // This is not quite correct, as it only runs a RST xx
                    // Instead, it should also support any other instruction
                    let instruction = ports.data
                    var stack = Sp
                    stack -= 1
                    mem[stack] = UInt8(Pc >> 8)
                    stack -= 1
                    mem[stack] = UInt8(Pc)
                    registers[SP] = UInt8(stack >> 8)
                    registers[SP + 1] = UInt8(stack)
                    registers[PC] = 0x00
                    registers[PC + 1] = UInt8(instruction & 0x38)
                    wait(17)
#if DEBUG
                    print("INT 0")
#endif
                    Halt = false
                    return
                case 1:
                    var stack = Sp
                    stack -= 1
                    mem[stack] = UInt8(Pc >> 8)
                    stack -= 1
                    mem[stack] = UInt8(Pc)
                    registers[SP] = UInt8(stack >> 8)
                    registers[SP + 1] = UInt8(stack)
                    registers[PC] = 0x00
                    registers[PC + 1] = 0x38
#if DEBUG
                    print("INT 1")
#endif
                    wait(17)
                    Halt = false
                    return
                case 2:
                    let vector = ports.data
                    var stack = Sp
                    stack -= 1
                    mem[stack] = UInt8(Pc >> 8)
                    stack -= 1
                    mem[stack] = UInt8(Pc)
                    registers[SP] = UInt8(stack >> 8)
                    registers[SP + 1] = UInt8(stack)
                    var address = UInt16((registers[I] << 8) + vector)
                    registers[PC] = mem[address]
                    address += 1
                    registers[PC + 1] = mem[address]
#if DEBUG
                    print("INT 2")
#endif
                    wait(17)
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
        let mc = fetch();
        let hi = Int(mc >> 6)
        let lo = Int(mc & 0x07)
        let r = Int((mc >> 3) & 0x07)
        if hi == 1 {
            let useHL1 = r == 6
            let useHL2 = lo == 6
            if useHL2 && useHL1 {
#if(DEBUG)
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
            wait(useHL1 || useHL2 ? 7 : 4)
#if DEBUG
            print(String(format: "LD %s, %s\n", useHL1 ? "(HL)" : Z80.rName(r), useHL2 ? "(HL)" : Z80.rName(lo)))
#endif
            return
        }
        switch mc {
            case 0xCB:
                //parseCB()
                return
            case 0xDD:
                //parseDD()
                return
            case 0xED:
                //parseED()
                return
            case 0xFD:
                //parseFD()
                return
            case 0x00:
                // NOP
#if(DEBUG)
                print("NOP")
#endif
                wait(4)
                return
            case 0x01, 0x11, 0x21:
                // LD dd, nn
                registers[r + 1] = fetch()
                registers[r] = fetch()
#if DEBUG
                print(String(format: "LD %s%s, 0x%2X2X\n", Z80.rName(r), Z80.rName(r + 1), registers[r], registers[r + 1]))
#endif
                wait(10)
                return
            case 0x31:
                // LD SP, nn
                registers[SP + 1] = fetch()
                registers[SP] = fetch()
#if DEBUG
                print(String(format: "LD SP, 0x%2X%2X\n", registers[SP], registers[SP + 1]))
#endif
                wait(10)
                return
            case 0x06, 0x0e, 0x16, 0x1e, 0x26, 0x2e, 0x3e:
                // LD r,n
                let n = fetch()
                registers[r] = n
#if DEBUG
                print(String(format: "LD %s, 0x%2X\n", Z80.rName(r), n))
#endif
                wait(7)
                return
            case 0x36:
                // LD (HL), n
                let n = fetch()
                mem[Hl] = n
#if DEBUG
                print(String(format: "LD (HL), %d\n", n))
#endif
                wait(10)
                return
            case 0x0A:
                // LD A, (BC)
                registers[A] = mem[Bc]
#if DEBUG
                print("LD A, (BC)")
#endif
                wait(7)
                return
            case 0x1A:
                // LD A, (DE)
                registers[A] = mem[De]
#if DEBUG
                print("LD A, (DE)")
#endif
                wait(7)
                return
            case 0x3A:
                // LD A, (nn)
                let addr = fetch16()
                registers[A] = mem[addr]
#if DEBUG
                print(String(format: "LD A, (0x%4X)\n", addr))
#endif
                wait(13)
                return
            case 0x02:
                // LD (BC), A
                mem[Bc] = registers[A]
#if DEBUG
                print("LD (BC), A")
#endif
                wait(7)
                return
            case 0x12:
                // LD (DE), A
                mem[De] = registers[A]
#if DEBUG
                print("LD (DE), A")
#endif
                wait(7)
                return
            case 0x32:
                // LD (nn), A 
                let addr = fetch16()
                mem[addr] = registers[A]
#if DEBUG
                print(String(format: "LD (0x%4X), A\n", addr))
#endif
                wait(13)
                return
            case 0x2A:
                // LD HL, (nn) 
                var addr = fetch16()
                registers[L] = mem[addr]
                addr += 1
                registers[H] = mem[addr]
#if DEBUG
                addr -= 1
                print(String(format: "LD HL, (0x%4X)\n", addr))
#endif
                wait(16)
                return
            case 0x22:
                // LD (nn), HL
                var addr = fetch16()
                mem[addr] = registers[L]
                addr += 1
                mem[addr] = registers[H]
#if DEBUG
                addr -= 1
                print(String(format: "LD (0x%4X), HL\n", addr))
#endif
                wait(16)
                return
            case 0xF9:
                // LD SP, HL
                registers[SP + 1] = registers[L]
                registers[SP] = registers[H]
#if DEBUG
                print("LD SP, HL")
#endif
                wait(6)
                return
            case 0xC5:
                // PUSH BC
                var addr = Sp
                addr -= 1
                mem[addr] = registers[B]
                addr -= 1
                mem[addr] = registers[C]
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("PUSH BC")
#endif
                wait(11)
                return
            case 0xD5:
                // PUSH DE
                var addr = Sp
                addr -= 1
                mem[addr] = registers[D]
                addr -= 1
                mem[addr] = registers[E]
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("PUSH DE")
#endif
                wait(11)
                return
            case 0xE5:
                // PUSH HL
                var addr = Sp
                addr -= 1
                mem[addr] = registers[H]
                addr -= 1
                mem[addr] = registers[L]
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("PUSH HL")
#endif
                wait(11)
                return
            case 0xF5:
                // PUSH AF
                var addr = Sp
                addr -= 1
                mem[addr] = registers[A]
                addr -= 1
                mem[addr] = registers[F]
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("PUSH AF")
#endif
                wait(11)
                return
            case 0xC1:
                // POP BC
                var addr = Sp
                registers[C] = mem[addr]
                addr += 1
                registers[B] = mem[addr]
                addr += 1
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("POP BC")
#endif
                wait(10)
                return
            case 0xD1:
                // POP DE
                var addr = Sp
                registers[E] = mem[addr]
                addr += 1
                registers[D] = mem[addr]
                addr += 1
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("POP DE")
#endif
                wait(10)
                return
            case 0xE1:
                // POP HL
                var addr = Sp
                registers[L] = mem[addr]
                addr += 1
                registers[H] = mem[addr]
                addr += 1
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("POP HL")
#endif
                wait(10)
                return
            case 0xF1:
                // POP AF
                var addr = Sp
                registers[F] = mem[addr]
                addr += 1
                registers[A] = mem[addr]
                addr += 1
                registers[SP + 1] = UInt8(addr & 0xFF)
                registers[SP] = UInt8(addr >> 8)
#if DEBUG
                print("POP AF")
#endif
                wait(10)
                return
            case 0xEB:
                // EX DE, HL
                //swapReg8(D, H)
                //swapReg8(E, L)
#if DEBUG
                print("EX DE, HL")
#endif
                wait(4)
                return
            case 0x08:
                // EX AF, AF'
                //swapReg8(Ap, A)
                //swapReg8(Fp, F)
#if DEBUG
                print("EX AF, AF'")
#endif
                wait(4)
                return
            case 0xD9:
                // EXX
                //swapReg8(B, Bp)
                //swapReg8(C, Cp)
                //swapReg8(D, Dp)
                //swapReg8(E, Ep)
                //swapReg8(H, Hp)
                //swapReg8(L, Lp)
#if DEBUG
                print("EXX")
#endif
                wait(4)
                return
            case 0xE3:
                // EX (SP), HL
                var addr = Sp
                var tmp = registers[L]
                registers[L] = mem[addr]
                mem[addr] = tmp
                addr += 1
                tmp = registers[H]
                registers[H] = mem[addr]
                mem[addr] = tmp
#if DEBUG
                print("EX (SP), HL")
#endif
                wait(19)
                return
            case 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x87:
                // ADD A, r
                //add(registers[lo])
#if DEBUG
                print(String(format: "ADD A, %s\n", Z80.rName(lo)))
#endif
                wait(4)
                return
            case 0xC6:
                // ADD A, n
                let b = fetch()
                //add(b)
#if DEBUG
                print(String(format: "ADD A, 0x%2X\n", b))
#endif
                wait(4)
                wait(4)
                return
            case 0x86:
                // ADD A, (HL)
                //add(mem[Hl])
#if DEBUG
                print("ADD A, (HL)")
#endif
                wait(7)
                return
            case 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F:
                // ADC A, r
                //adc(registers[lo])
#if DEBUG
                print(String(format: "ADC A, %s\n", Z80.rName(lo)))
#endif
                wait(4)
                return
            case 0xCE:
                // ADC A, n
                let b = fetch()
                //adc(b)
#if DEBUG
                print(String(format: "ADC A, 0x%2X\n", b))
#endif
                wait(4)
                return
            case 0x8E:
                // ADC A, (HL)
                //adc(mem[Hl])
#if DEBUG
                print("ADC A, (HL)")
#endif
                wait(7)
                return
default: break ; } }/*
                case 0x90:
                case 0x91:
                case 0x92:
                case 0x93:
                case 0x94:
                case 0x95:
                case 0x97:
                        // SUB A, r
                        Sub(registers[lo]);
#if DEBUG
                        print(String("SUB A, {RName(lo)}");
#endif
                        wait(4);
                        return;
                case 0xD6:
                        // SUB A, n
                        var b = fetch();
                        Sub(b);
#if DEBUG
                        print(String("SUB A, 0x{b:X2}");
#endif
                        wait(4);
                        return;
                case 0x96:
                        // SUB A, (HL)
                        Sub(mem[Hl]);
#if DEBUG
                        print("SUB A, (HL)");
#endif
                        wait(7);
                        return;
                case 0x98:
                case 0x99:
                case 0x9A:
                case 0x9B:
                case 0x9C:
                case 0x9D:
                case 0x9F:
                        // SBC A, r
                        Sbc(registers[lo]);
#if DEBUG
                        print(String("SBC A, {RName(lo)}");
#endif
                        wait(4);
                        return;
                case 0xDE:
                        // SBC A, n
                        var b = fetch();
                        Sbc(b);
#if DEBUG
                        print(String("SBC A, 0x{b:X2}");
#endif
                        wait(4);
                        return;
                case 0x9E:
                        // SBC A, (HL)
                        Sbc(mem[Hl]);
#if DEBUG
                        print("SBC A, (HL)");
#endif
                        wait(7);
                        return;
                case 0xA0:
                case 0xA1:
                case 0xA2:
                case 0xA3:
                case 0xA4:
                case 0xA5:
                case 0xA7:
                        // AND A, r
                        And(registers[lo]);
#if DEBUG
                        print(String("AND A, {RName(lo)}");
#endif
                        wait(4);
                        return;
                case 0xE6:
                        // AND A, n
                        var b = fetch();

                        And(b);
#if DEBUG
                        print(String("AND A, 0x{b:X2}");
#endif
                        wait(4);
                        return;
                case 0xA6:
                        // AND A, (HL)
                        And(mem[Hl]);
#if DEBUG
                        print("AND A, (HL)");
#endif
                        wait(7);
                        return;
                case 0xB0:
                case 0xB1:
                case 0xB2:
                case 0xB3:
                case 0xB4:
                case 0xB5:
                case 0xB7:
                        // OR A, r
                        Or(registers[lo]);
#if DEBUG
                        print(String("OR A, {RName(lo)}");
#endif
                        wait(4);
                        return;
                case 0xF6:
                        // OR A, n
                        var b = fetch();
                        Or(b);
#if DEBUG
                        print(String("OR A, 0x{b:X2}");
#endif
                        wait(4);
                        return;
                case 0xB6:
                        // OR A, (HL)
                        Or(mem[Hl]);
#if DEBUG
                        print("OR A, (HL)");
#endif
                        wait(7);
                        return;
                case 0xA8:
                case 0xA9:
                case 0xAA:
                case 0xAB:
                case 0xAC:
                case 0xAD:
                case 0xAF:
                        // XOR A, r
                        Xor(registers[lo]);
#if DEBUG
                        print(String("XOR A, {RName(lo)}");
#endif
                        wait(4);
                        return;
                case 0xEE:
                        // XOR A, n
                        var b = fetch();
                        Xor(b);
#if DEBUG
                        print(String("XOR A, 0x{b:X2}");
#endif
                        wait(4);
                        return;
                case 0xAE:
                        // XOR A, (HL)
                        Xor(mem[Hl]);
#if DEBUG
                        print("XOR A, (HL)");
#endif
                        wait(7);
                        return;
                case 0xF3:
                        // DI
                        IFF1 = false;
                        IFF2 = false;
#if DEBUG
                        print("DI");
#endif
                        wait(4);
                        return;
                case 0xFB:
                        // EI
                        IFF1 = true;
                        IFF2 = true;
#if DEBUG
                        print("EI");
#endif
                        wait(4);
                        return;
                case 0xB8:
                case 0xB9:
                case 0xBA:
                case 0xBB:
                case 0xBC:
                case 0xBD:
                case 0xBF:
                        // CP A, r
                        Cmp(registers[lo]);
#if DEBUG
                        print(String("CP A, {RName(lo)}");
#endif
                        wait(4);
                        return;
                case 0xFE:
                        // CP A, n
                        var b = fetch();
                        Cmp(b);
#if DEBUG
                        print(String("CP A, 0x{b:X2}");
#endif
                        wait(4);
                        return;
                case 0xBE:
                        // CP A, (HL)
                        Cmp(mem[Hl]);
#if DEBUG
                        print("CP A, (HL)");
#endif
                        wait(7);
                        return;
                case 0x04:
                case 0x0C:
                case 0x14:
                case 0x1C:
                case 0x24:
                case 0x2C:
                case 0x3C:
                        // INC r
                        registers[r] = Inc(registers[r]);
#if DEBUG
                        print(String("INC {RName(r)}");
#endif
                        wait(4);
                        return;
                case 0x34:
                        // INC (HL)
                        mem[Hl] = Inc(mem[Hl]);
#if DEBUG
                        print("INC (HL)");
#endif
                        wait(7);
                        return;
                case 0x05:
                case 0x0D:
                case 0x15:
                case 0x1D:
                case 0x25:
                case 0x2D:
                case 0x3D:
                        // DEC r
                        registers[r] = Dec(registers[r]);
#if DEBUG
                        print(String("DEC {RName(r)}");
#endif
                        wait(7);
                        return;
                case 0x35:
                        // DEC (HL)
                        mem[Hl] = Dec(mem[Hl]);
#if DEBUG
                        print("DEC (HL)");
#endif
                        wait(7);
                        return;
                case 0x27:
                        // DAA
                        var a = registers[A];
                        var f = registers[F];
                        if ((a & 0x0F) > 0x09 || (f & (UInt8)Fl.H) > 0) {
                            add(0x06);
                            a = registers[A];
                        }
                        if ((a & 0xF0) > 0x90 || (f & (UInt8)Fl.C) > 0) {
                            add(0x60);
                        }
#if DEBUG
                        print("DAA");
#endif
                        wait(4);
                        return;
                case 0x2F:
                        // CPL
                        registers[A] ^= 0xFF;
                        registers[F] |= (UInt8)(Fl.H | Fl.N);
#if DEBUG
                        print("CPL");
#endif
                        wait(4);
                        return;
                case 0x3F:
                        // CCF
                        registers[F] &= (UInt8)~(Fl.N);
                        registers[F] ^= (UInt8)(Fl.C);
#if DEBUG
                        print("CCF");
#endif
                        wait(4);
                        return;
                case 0x37:
                        // SCF
                        registers[F] &= (UInt8)~(Fl.N);
                        registers[F] |= (UInt8)(Fl.C);
#if DEBUG
                        print("SCF");
#endif
                        wait(4);
                        return;
                case 0x09:
                        addHl(Bc);

#if DEBUG
                        print("ADD HL, BC");
#endif
                        wait(4);
                        return;
                case 0x19:
                        addHl(De);
#if DEBUG
                        print("ADD HL, DE");
#endif
                        wait(4);
                        return;
                case 0x29:
                        addHl(Hl);
#if DEBUG
                        print("ADD HL, HL");
#endif
                        wait(4);
                        return;
                case 0x39:
                        addHl(Sp);
#if DEBUG
                        print("ADD HL, SP");
#endif
                        wait(4);
                        return;
                case 0x03:
                        var val = Bc + 1;
                        registers[B] = (UInt8)(val >> 8);
                        registers[C] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("INC BC");
#endif
                        wait(4);
                        return;
                case 0x13:
                        var val = De + 1;
                        registers[D] = (UInt8)(val >> 8);
                        registers[E] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("INC DE");
#endif
                        wait(4);
                        return;
                case 0x23:
                        var val = Hl + 1;
                        registers[H] = (UInt8)(val >> 8);
                        registers[L] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("INC HL");
#endif
                        wait(4);
                        return;
                case 0x33:
                        var val = Sp + 1;
                        registers[SP] = (UInt8)(val >> 8);
                        registers[SP + 1] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("INC SP");
#endif
                        wait(4);
                        return;
                case 0x0B:
                        var val = Bc - 1;
                        registers[B] = (UInt8)(val >> 8);
                        registers[C] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("DEC BC");
#endif
                        wait(4);
                        return;
                case 0x1B:
                        var val = De - 1;
                        registers[D] = (UInt8)(val >> 8);
                        registers[E] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("DEC DE");
#endif
                        wait(4);
                        return;
                case 0x2B:
                        var val = Hl - 1;
                        registers[H] = (UInt8)(val >> 8);
                        registers[L] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("DEC HL");
#endif
                        wait(4);
                        return;
                case 0x3B:
                        var val = Sp - 1;
                        registers[SP] = (UInt8)(val >> 8);
                        registers[SP + 1] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("DEC SP");
#endif
                        wait(4);
                        return;
                case 0x07:
                        var a = registers[A];
                        var c = (UInt8)((a & 0x80) >> 7);
                        a <<= 1;
                        registers[A] = a;
                        registers[F] &= (UInt8)~(Fl.H | Fl.N | Fl.C);
                        registers[F] |= c;
#if DEBUG
                        print("RLCA");
#endif
                        wait(4);
                        return;
                case 0x17:
                        var a = registers[A];
                        var c = (UInt8)((a & 0x80) >> 7);
                        a <<= 1;
                        var f = registers[F];
                        a |= (UInt8)(f & (UInt8)Fl.C);
                        registers[A] = a;
                        f &= (UInt8)~(Fl.H | Fl.N | Fl.C);
                        f |= c;
                        registers[F] = f;
#if DEBUG
                        print("RLA");
#endif
                        wait(4);
                        return;
                case 0x0F:
                        var a = registers[A];
                        var c = (UInt8)(a & 0x01);
                        a >>= 1;
                        registers[A] = a;
                        registers[F] &= (UInt8)~(Fl.H | Fl.N | Fl.C);
                        registers[F] |= c;
#if DEBUG
                        print("RRCA");
#endif
                        wait(4);
                        return;
                case 0x1F:
                        var a = registers[A];
                        var c = (UInt8)(a & 0x01);
                        a >>= 1;
                        var f = registers[F];
                        a |= (UInt8)((f & (UInt8)Fl.C) << 7);
                        registers[A] = a;
                        f &= (UInt8)~(Fl.H | Fl.N | Fl.C);
                        f |= c;
                        registers[F] = f;
#if DEBUG
                        print("RRA");
#endif
                        wait(4);
                        return;
                case 0xC3:
                        var addr = fetch16();
                        registers[PC] = (UInt8)(addr >> 8);
                        registers[PC + 1] = (UInt8)(addr);
#if DEBUG
                        print(String("JP 0x{addr:X4}");
#endif
                        wait(10);
                        return;
                case 0xC2:
                case 0xCA:
                case 0xD2:
                case 0xDA:
                case 0xE2:
                case 0xEA:
                case 0xF2:
                case 0xFA:
                        var addr = fetch16();
                        if (JumpCondition(r)) {
                            registers[PC] = (UInt8)(addr >> 8);
                            registers[PC + 1] = (UInt8)(addr);
                        }
#if DEBUG
                        print(String("JP {JCName(r)}, 0x{addr:X4}");
#endif
                        wait(10);
                        return;

                case 0x18:
                        // order is important here
                        var d = (sbyte)fetch();
                        var addr = Pc + d;
                        registers[PC] = (UInt8)(addr >> 8);
                        registers[PC + 1] = (UInt8)(addr);
#if DEBUG
                        print(String("JR 0x{addr:X4}");
#endif
                        wait(12);
                        return;
                case 0x20:
                case 0x28:
                case 0x30:
                case 0x38:
                        // order is important here
                        var d = (sbyte)fetch();
                        var addr = Pc + d;
                        if (JumpCondition((UInt8)(r & 3))) {
                            registers[PC] = (UInt8)(addr >> 8);
                            registers[PC + 1] = (UInt8)(addr);
                            wait(12);
                        } else {
                            wait(7);
                        }
#if DEBUG
                        print(String("JR {JCName((UInt8)(r & 3))}, 0x{addr:X4}");
#endif
                        return;

                case 0xE9:
                        var addr = Hl;
                        registers[PC] = (UInt8)(addr >> 8);
                        registers[PC + 1] = (UInt8)(addr);
#if DEBUG
                        print("JP HL");
#endif
                        wait(4);
                        return;
                case 0x10:
                        // order is important here
                        var d = (sbyte)fetch();
                        var addr = Pc + d;
                        var b = registers[B];
                        registers[B] = --b;
                        if (b != 0) {
                            registers[PC] = (UInt8)(addr >> 8);
                            registers[PC + 1] = (UInt8)(addr);
                            wait(13);
                        } else {
                            wait(8);
                        }
#if DEBUG
                        print(String("DJNZ 0x{addr:X4}");
#endif
                        return;
                case 0xCD:
                        var addr = fetch16();
                        var stack = Sp;
                        mem[--stack] = (UInt8)(Pc >> 8);
                        mem[--stack] = (UInt8)(Pc);
                        registers[SP] = (UInt8)(stack >> 8);
                        registers[SP + 1] = (UInt8)(stack);
                        registers[PC] = (UInt8)(addr >> 8);
                        registers[PC + 1] = (UInt8)(addr);
#if DEBUG
                        print(String("CALL 0x{addr:X4}");
#endif
                        wait(17);
                        return;
                case 0xC4:
                case 0xCC:
                case 0xD4:
                case 0xDC:
                case 0xE4:
                case 0xEC:
                case 0xF4:
                case 0xFC:
                        var addr = fetch16();
                        if (JumpCondition(r)) {
                            var stack = Sp;
                            mem[--stack] = (UInt8)(Pc >> 8);
                            mem[--stack] = (UInt8)(Pc);
                            registers[SP] = (UInt8)(stack >> 8);
                            registers[SP + 1] = (UInt8)(stack);
                            registers[PC] = (UInt8)(addr >> 8);
                            registers[PC + 1] = (UInt8)(addr);
                            wait(17);
                        } else {
                            wait(10);
                        }
#if DEBUG
                        print(String("CALL {JCName(r)}, 0x{addr:X4}");
#endif
                        return;

                case 0xC9:
                        var stack = Sp;
                        registers[PC + 1] = mem[stack++];
                        registers[PC] = mem[stack++];
                        registers[SP] = (UInt8)(stack >> 8);
                        registers[SP + 1] = (UInt8)(stack);
#if DEBUG
                        print("RET");
#endif
                        wait(10);
                        return;
                case 0xC0:
                case 0xC8:
                case 0xD0:
                case 0xD8:
                case 0xE0:
                case 0xE8:
                case 0xF0:
                case 0xF8:
                        if (JumpCondition(r)) {
                            var stack = Sp;
                            registers[PC + 1] = mem[stack++];
                            registers[PC] = mem[stack++];
                            registers[SP] = (UInt8)(stack >> 8);
                            registers[SP + 1] = (UInt8)(stack);
                            wait(11);
                        } else {
                            wait(5);
                        }
#if DEBUG
                        print(String("RET {JCName(r)}");
#endif
                        return;

                case 0xC7:
                case 0xCF:
                case 0xD7:
                case 0xDF:
                case 0xE7:
                case 0xEF:
                case 0xF7:
                case 0xFF:
                        var stack = Sp;
                        mem[--stack] = (UInt8)(Pc >> 8);
                        mem[--stack] = (UInt8)(Pc);
                        registers[SP] = (UInt8)(stack >> 8);
                        registers[SP + 1] = (UInt8)(stack);
                        registers[PC] = 0;
                        registers[PC + 1] = (UInt8)(mc & 0x38);
#if DEBUG
                        print(String("RST 0x{mc & 0x38:X4}");
#endif
                        wait(17);
                        return;
                case 0xDB:
                        var port = fetch() + (registers[A] << 8);
                        registers[A] = ports.ReadPort((UInt16)port);
#if DEBUG
                        print(String("IN A, (0x{port:X2})");
#endif
                        wait(11);
                        return;
                case 0xD3:
                        var port = fetch() + (registers[A] << 8);
                        ports.WritePort((UInt16)port, registers[A]);
#if DEBUG
                        print(String("OUT (0x{port:X2}), A");
#endif
                        wait(11);
                        return;
            }

#if(DEBUG)
            print(String("{mc:X2}: {hi:X} {r:X} {lo:X}");
            //throw new InvalidOperationException("Invalid Opcode: "+mc.ToString("X2"));
#endif
            Halt = true;
        }

        private func jCName(_ condition: UInt8) -> String {
            switch (condition) {
                case 0:
                    return "NZ";
                case 1:
                    return "Z";
                case 2:
                    return "NC";
                case 3:
                    return "C";
                case 4:
                    return "PO";
                case 5:
                    return "PE";
                case 6:
                    return "P";
                case 7:
                    return "M";
            }
            return "";
        }

        private func parseCB(_ mode: UInt8 = 0) {
            sbyte d = 0;
            if (mode != 0) {
                d = (sbyte)fetch();
            }
            if (Halt) return;
            var mc = fetch();
            var hi = (UInt8)(mc >> 6);
            var lo = (UInt8)(mc & 0x07);
            var r = (UInt8)((mc >> 3) & 0x07);
            var useHL = lo == 6;
            var useIX = mode == 0xDD;
            var useIY = mode == 0XFD;
            var reg = useHL ? useIX ? mem[(UInt16)(Ix + d)] : useIY ? mem[(UInt16)(Iy + d)] : mem[Hl] : registers[lo];
#if DEBUG
            string debug_target;
            if (useHL) {
                if (useIX) {
                    debug_target = $"(IX{d:+0;-#})";
                } else {
                    debug_target = useIY ? $"(IY{d:+0;-#})" : "(HL)";
                }
            } else {
                debug_target = useIX ? $"(IX{d:+0;-#}), {RName(lo)}" : useIY ? $"(IY{d:+0;-#}), {RName(lo)}" : RName(lo);
            }
#endif
            switch (hi) {
                case 0:
                    UInt8 c;
                    if ((r & 1) == 1) {
                        c = (UInt8)(reg & 0x01);
                        reg >>= 1;
                    } else {
                        c = (UInt8)((reg & 0x80) >> 7);
                        reg <<= 1;
                    }
                    var f = registers[F];
                    switch (r) {
                        case 0:
                                reg |= c;
#if DEBUG
                                print(String("RLC {debug_target}");
#endif
                                break;
                            }
                        case 1:
                                reg |= (UInt8)(c << 7);
#if DEBUG
                                print(String("RRC {debug_target}");
#endif
                                break;
                            }
                        case 2:
                                reg |= (UInt8)(f & (UInt8)Fl.C);
#if DEBUG
                                print(String("RL {debug_target}");
#endif
                                break;
                            }
                        case 3:
                                reg |= (UInt8)((f & (UInt8)Fl.C) << 7);
#if DEBUG
                                print(String("RR {debug_target}");
#endif
                                break;
                            }
                        case 4:
#if DEBUG
                                print(String("SLA {debug_target}");
#endif
                                break;
                            }
                        case 5:
                                reg |= (UInt8)((reg & 0x40) << 1);
#if DEBUG
                                print(String("SRA {debug_target}");

#endif
                                break;
                            }
                        case 6:
                                reg |= 1;
#if DEBUG
                                print(String("SLL {debug_target}");
#endif
                                break;
                            }
                        case 7:
#if DEBUG
                                print(String("SRL {debug_target}");
#endif
                                break;
                            }
                    }
                    f &= (UInt8)~(Fl.H | Fl.N | Fl.C | Fl.PV | Fl.S | Fl.Z);
                    f |= (UInt8)(reg & (UInt8)Fl.S);
                    if (reg == 0) f |= (UInt8)Fl.Z;
                    if (Parity(reg)) f |= (UInt8)Fl.PV;
                    f |= c;
                    registers[F] = f;

                    break;
                case 1:
                        Bit(r, reg);
#if DEBUG
                        print(String("BIT {r}, {debug_target}");
#endif
                        wait(useHL ? 12 : 8);
                        return;
                case 2:
                    reg &= (UInt8)~(0x01 << r);
#if DEBUG
                    print(String("RES {r}, {debug_target}");
#endif
                    wait(useHL ? 12 : 8);
                    break;
                case 3:
                    reg |= (UInt8)(0x01 << r);
#if DEBUG
                    print(String("SET {r}, {debug_target}");
#endif
                    wait(useHL ? 12 : 8);
                    break;
            }
            if (useHL) {
                if (useIX) {
                    mem[(UInt16)(Ix + d)] = reg;
                    wait(23);
                } else if (useIY) {
                    mem[(UInt16)(Iy + d)] = reg;
                    wait(23);
                } else {
                    mem[Hl] = reg;
                    wait(15);
                }
            } else {
                if (useIX) {
                    mem[(UInt16)(Ix + d)] = reg;
                    wait(23);
                } else if (useIY) {
                    mem[(UInt16)(Iy + d)] = reg;
                    wait(23);
                }
                registers[lo] = reg;
                wait(8);
            }
        }

        private func bit(UInt8 bit, UInt8 value) {
            var f = (UInt8)(registers[F] & (UInt8)~(Fl.Z | Fl.H | Fl.N));
            if ((value & (0x01 << bit)) == 0) f |= (UInt8)Fl.Z;
            f |= (UInt8)Fl.H;
            registers[F] = f;
        }

        private func addHl(_ value: UInt16) {
            var sum = add(Hl, value);
            registers[H] = (UInt8)(sum >> 8);
            registers[L] = (UInt8)(sum & 0xFF);
        }

        private func addIx(_ value: UInt16) {
            var sum = add(Ix, value);
            registers[IX] = (UInt8)(sum >> 8);
            registers[IX + 1] = (UInt8)(sum & 0xFF);
        }

        private func addIy(_ value: UInt16) {
            var sum = add(Iy, value);
            registers[IY] = (UInt8)(sum >> 8);
            registers[IY + 1] = (UInt8)(sum & 0xFF);
        }

        private func add(_ value1: UInt16, _ value2: UInt16) {
            var sum = value1 + value2;
            var f = (UInt8)(registers[F] & (UInt8)~(Fl.H | Fl.N | Fl.C));
            if ((value1 & 0x0FFF) + (value2 & 0x0FFF) > 0x0FFF) {
                f |= (UInt8)Fl.H;
            if (sum > 0xFFFF) {
                f |= (UInt8)Fl.C;
            registers[F] = f;
            return (UInt16)sum;
        }

        private func adcHl(_ value: UInt16) {
            var sum = adc(Hl, value);
            registers[H] = (UInt8)(sum >> 8);
            registers[L] = (UInt8)(sum & 0xFF);
        }

        private func adc(_ value1: UInt16, _ value2: UInt16) {
            var sum = value1 + value2 + (registers[F] & (UInt8)Fl.C);
            var f = (UInt8)(registers[F] & (UInt8)~(Fl.S | Fl.Z | Fl.H | Fl.PV | Fl.N | Fl.C));
            if ((short)sum < 0) {
                f |= (UInt8)Fl.S;
            if (sum == 0) {
                f |= (UInt8)Fl.Z;
            if ((value1 & 0x0FFF) + (value2 & 0x0FFF) + (UInt8)Fl.C > 0x0FFF) {
                f |= (UInt8)Fl.H;
            if (sum > 0x7FFF) {
                f |= (UInt8)Fl.PV;
            if (sum > 0xFFFF) {
                f |= (UInt8)Fl.C;
            registers[F] = f;
            return (UInt16)sum;
        }

        private func sbcHl(_ value: UInt16) {
            var sum = Sbc(Hl, value);
            registers[H] = (UInt8)(sum >> 8);
            registers[L] = (UInt8)(sum & 0xFF);
        }


        private func sbc(_ value1: UInt16, _ value2: UInt16) {
            var diff = value1 - value2 - (registers[F] & (UInt8)Fl.C);
            var f = (UInt8)(registers[F] & (UInt8)~(Fl.S | Fl.Z | Fl.H | Fl.PV | Fl.N | Fl.C));
            if ((short)diff < 0) {
                f |= (UInt8)Fl.S;
            if (diff == 0) {
                f |= (UInt8)Fl.Z;
            if ((value1 & 0xFFF) < (value2 & 0xFFF) + (registers[F] & (UInt8)Fl.C)) {
                f |= (UInt8)Fl.H;
            if (diff > short.MaxValue || diff < short.MinValue) {
                f |= (UInt8)Fl.PV;
            if ((UInt16)diff > value1) {
                f |= (UInt8)Fl.C;
            registers[F] = f;
            return (UInt16)diff;
        }

        private func parseED() {
            if (Halt) return;
            var mc = fetch();
            var r = (UInt8)((mc >> 3) & 0x07);

            switch (mc) {
                case 0x47:
                        // LD I, A
                        registers[I] = registers[A];
#if DEBUG
                        print("LD I, A");
#endif
                        wait(9);
                        return;
                case 0x4F:
                        // LD R, A
                        registers[R] = registers[A];
#if DEBUG
                        print("LD R, A");
#endif
                        wait(9);
                        return;
                case 0x57:
                        // LD A, I

                        /*
                                     * Condition Bits Affected
                                     * S is set if the I Register is negative; otherwise, it is reset.
                                     * Z is set if the I Register is 0; otherwise, it is reset.
                                     * H is reset.
                                     * P/V contains contents of IFF2.
                                     * N is reset.
                                     * C is not affected.
                                     * If an interrupt occurs during execution of this instruction, the Parity flag contains a 0.
                                     */
                        var i = registers[I];
                        registers[A] = i;
                        var f = (UInt8)(registers[F] & (~(UInt8)(Fl.H | Fl.PV | Fl.N | Fl.S | Fl.Z | Fl.PV)));
                        if (i >= 0x80) {
                            f |= (UInt8)Fl.S;
                        } else if (i == 0x00) {
                            f |= (UInt8)Fl.Z;
                        }
                        if (IFF2) {
                            f |= (UInt8)Fl.PV;
                        }
                        registers[F] = f;
#if DEBUG
                        print("LD A, I");
#endif
                        wait(9);
                        return;
                case 0x5F:
                        // LD A, R

                        /*
                                     * Condition Bits Affected
                                     * S is set if, R-Register is negative; otherwise, it is reset.
                                     * Z is set if the R Register is 0; otherwise, it is reset.
                                     * H is reset.
                                     * P/V contains contents of IFF2.
                                     * N is reset.
                                     * C is not affected.
                                     * If an interrupt occurs during execution of this instruction, the parity flag contains a 0. 
                                     */
                        var reg = registers[R];
                        registers[A] = reg;
                        var f = (UInt8)(registers[F] & (~(UInt8)(Fl.H | Fl.PV | Fl.N | Fl.S | Fl.Z | Fl.PV)));
                        if (reg >= 0x80) {
                            f |= (UInt8)Fl.S;
                        } else if (reg == 0x00) {
                            f |= (UInt8)Fl.Z;
                        }
                        if (IFF2) {
                            f |= (UInt8)Fl.PV;
                        }
                        registers[F] = f;
#if DEBUG
                        print("LD A, R");
#endif
                        wait(9);
                        return;
                case 0x4B:
                        // LD BC, (nn)
                        var addr = fetch16();
                        registers[C] = mem[addr++];
                        registers[B] = mem[addr];
#if DEBUG
                        print(String("LD BC, (0x{--addr:X4})");
#endif
                        wait(20);
                        return;
                case 0x5B:
                        // LD DE, (nn)
                        var addr = fetch16();
                        registers[E] = mem[addr++];
                        registers[D] = mem[addr];
#if DEBUG
                        print(String("LD DE, (0x{--addr:X4})");
#endif
                        wait(20);
                        return;
                case 0x6B:
                        // LD HL, (nn)
                        var addr = fetch16();
                        registers[L] = mem[addr++];
                        registers[H] = mem[addr];
#if DEBUG
                        print(String("LD HL, (0x{--addr:X4})*");
#endif
                        wait(20);
                        return;
                case 0x7B:
                        // LD SP, (nn)
                        var addr = fetch16();
                        registers[SP + 1] = mem[addr++];
                        registers[SP] = mem[addr];
#if DEBUG
                        print(String("LD SP, (0x{--addr:X4})");
#endif
                        wait(20);
                        return;
                case 0x43:
                        // LD (nn), BC
                        var addr = fetch16();
                        mem[addr++] = registers[C];
                        mem[addr] = registers[B];
#if DEBUG
                        print(String("LD (0x{--addr:X4}), BC");
#endif
                        wait(20);
                        return;
                case 0x53:
                        // LD (nn), DE
                        var addr = fetch16();
                        mem[addr++] = registers[E];
                        mem[addr] = registers[D];
#if DEBUG
                        print(String("LD (0x{--addr:X4}), DE");
#endif
                        wait(20);
                        return;
                case 0x63:
                        // LD (nn), HL
                        var addr = fetch16();
                        mem[addr++] = registers[L];
                        mem[addr] = registers[H];
#if DEBUG
                        print(String("LD (0x{--addr:X4}), HL");
#endif
                        wait(20);
                        return;
                case 0x73:
                        // LD (nn), SP
                        var addr = fetch16();
                        mem[addr++] = registers[SP + 1];
                        mem[addr] = registers[SP];
#if DEBUG
                        print(String("LD (0x{--addr:X4}), SP");
#endif
                        wait(20);
                        return;
                case 0xA0:
                        // LDI
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de++;
                        hl++;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[D] = (UInt8)(de >> 8);
                        registers[E] = (UInt8)(de & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        var f = (UInt8)(registers[F] & 0xE9);
                        if (bc != 0) f = (UInt8)(f | 0x04);
                        registers[F] = f;
#if DEBUG
                        print("LDI");
#endif
                        wait(16);
                        return;
                case 0xB0:
                        // LDIR
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de++;
                        hl++;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[D] = (UInt8)(de >> 8);
                        registers[E] = (UInt8)(de & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        registers[F] = (UInt8)(registers[F] & 0xE9);
                        if (bc != 0) {
                            var pc = (UInt16)((registers[PC] << 8) + registers[PC + 1]);
                            // jumps back to itself
                            pc -= 2;
                            registers[PC] = (UInt8)(pc >> 8);
                            registers[PC + 1] = (UInt8)(pc & 0xFF);
                            wait(21);
                            return;
                        }
#if DEBUG
                        print("LDIR");
#endif
                        wait(16);
                        return;
                case 0xA8:
                        // LDD
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de--;
                        hl--;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[D] = (UInt8)(de >> 8);
                        registers[E] = (UInt8)(de & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        var f = (UInt8)(registers[F] & 0xE9);
                        if (bc != 0) f = (UInt8)(f | 0x04);
                        registers[F] = f;
#if DEBUG
                        print("LDD");
#endif
                        wait(16);
                        return;
                case 0xB8:
                        // LDDR
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de--;
                        hl--;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[D] = (UInt8)(de >> 8);
                        registers[E] = (UInt8)(de & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        registers[F] = (UInt8)(registers[F] & 0xE9);
                        if (bc != 0) {
                            var pc = (UInt16)((registers[PC] << 8) + registers[PC + 1]);
                            // jumps back to itself
                            pc -= 2;
                            registers[PC] = (UInt8)(pc >> 8);
                            registers[PC + 1] = (UInt8)(pc & 0xFF);
                            wait(21);
                            return;
                        }
#if DEBUG
                        print("LDDR");
#endif
                        wait(16);
                        return;
                    }

                case 0xA1:
                        // CPI
                        var bc = Bc;
                        var hl = Hl;

                        var a = registers[A];
                        var b = mem[hl];
                        hl++;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        var f = (UInt8)(registers[F] & 0x2A);
                        if (a < b) f = (UInt8)(f | 0x80);
                        if (a == b) f = (UInt8)(f | 0x40);
                        if ((a & 8) < (b & 8)) f = (UInt8)(f | 0x10);
                        if (bc != 0) f = (UInt8)(f | 0x04);
                        registers[F] = (UInt8)(f | 0x02);
#if DEBUG
                        print("CPI");
#endif
                        wait(16);
                        return;
                    }

                case 0xB1:
                        // CPIR
                        var bc = Bc;
                        var hl = Hl;

                        var a = registers[A];
                        var b = mem[hl];
                        hl++;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        if (a == b || bc == 0) {
                            var f = (UInt8)(registers[F] & 0x2A);
                            if (a < b) f = (UInt8)(f | 0x80);
                            if (a == b) f = (UInt8)(f | 0x40);
                            if ((a & 8) < (b & 8)) f = (UInt8)(f | 0x10);
                            if (bc != 0) f = (UInt8)(f | 0x04);
                            registers[F] = (UInt8)(f | 0x02);
#if DEBUG
                            print("CPIR");
#endif
                            wait(16);
                            return;
                        }

                        var pc = (UInt16)((registers[PC] << 8) + registers[PC + 1]);
                        // jumps back to itself
                        pc -= 2;
                        registers[PC] = (UInt8)(pc >> 8);
                        registers[PC + 1] = (UInt8)(pc & 0xFF);
                        wait(21);
                        return;
                    }

                case 0xA9:
                        // CPD
                        var bc = Bc;
                        var hl = Hl;

                        var a = registers[A];
                        var b = mem[hl];
                        hl--;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        var f = (UInt8)(registers[F] & 0x2A);
                        if (a < b) f = (UInt8)(f | 0x80);
                        if (a == b) f = (UInt8)(f | 0x40);
                        if ((a & 8) < (b & 8)) f = (UInt8)(f | 0x10);
                        if (bc != 0) f = (UInt8)(f | 0x04);
                        registers[F] = (UInt8)(f | 0x02);
#if DEBUG
                        print("CPD");
#endif
                        wait(16);
                        return;
                    }

                case 0xB9:
                        // CPDR
                        var bc = Bc;
                        var hl = Hl;

                        var a = registers[A];
                        var b = mem[hl];
                        hl--;
                        bc--;

                        registers[B] = (UInt8)(bc >> 8);
                        registers[C] = (UInt8)(bc & 0xFF);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)(hl & 0xFF);

                        if (a == b || bc == 0) {
                            var f = (UInt8)(registers[F] & 0x2A);
                            if (a < b) f = (UInt8)(f | 0x80);
                            if (a == b) f = (UInt8)(f | 0x40);
                            if ((a & 8) < (b & 8)) f = (UInt8)(f | 0x10);
                            if (bc != 0) f = (UInt8)(f | 0x04);
                            registers[F] = (UInt8)(f | 0x02);
#if DEBUG
                            print("CPDR");
#endif
                            wait(21);
                            return;
                        }

                        var pc = (UInt16)((registers[PC] << 8) + registers[PC + 1]);
                        // jumps back to itself
                        pc -= 2;
                        registers[PC] = (UInt8)(pc >> 8);
                        registers[PC + 1] = (UInt8)(pc & 0xFF);
                        wait(21);
                        return;
                case 0x44:
                case 0x54:
                case 0x64:
                case 0x74:
                case 0x4C:
                case 0x5C:
                case 0x6C:
                case 0x7C:
                        // NEG
                        var a = registers[A];
                        var diff = -a;
                        registers[A] = (UInt8)diff;

                        var f = (UInt8)(registers[F] & 0x28);
                        if ((diff & 0x80) > 0) f |= (UInt8)Fl.S;
                        if (diff == 0) f |= (UInt8)Fl.Z;
                        if ((a & 0xF) != 0) f |= (UInt8)Fl.H;
                        if (a == 0x80) f |= (UInt8)Fl.PV;
                        f |= (UInt8)Fl.N;
                        if (diff != 0) f |= (UInt8)Fl.C;
                        registers[F] = f;


#if DEBUG
                        print("NEG");
#endif
                        wait(8);
                        return;
                case 0x46:
                case 0x66:
                        // IM 0
                        interruptMode = 0;
#if DEBUG
                        print("IM 0");
#endif
                        wait(8);
                        return;
                case 0x56:
                case 0x76:
                        // IM 1
                        interruptMode = 1;
#if DEBUG
                        print("IM 1");
#endif
                        wait(8);
                        return;
                case 0x5E:
                case 0x7E:
                        // IM 2
                        interruptMode = 2;
#if DEBUG
                        print("IM 2");
#endif
                        wait(8);
                        return;
                case 0x4A:
                        adcHl(Bc);

#if DEBUG
                        print("ADC HL, BC");
#endif
                        wait(15);
                        return;
                case 0x5A:
                        adcHl(De);
#if DEBUG
                        print("ADC HL, DE");
#endif
                        wait(15);
                        return;
                case 0x6A:
                        adcHl(Hl);
#if DEBUG
                        print("ADC HL, HL");
#endif
                        wait(15);
                        return;
                case 0x7A:
                        adcHl(Sp);
#if DEBUG
                        print("ADC HL, SP");
#endif
                        wait(15);
                        return;
                case 0x42:
                        SbcHl(Bc);

#if DEBUG
                        print("SBC HL, BC");
#endif
                        wait(15);
                        return;
                case 0x52:
                        SbcHl(De);
#if DEBUG
                        print("SBC HL, DE");
#endif
                        wait(15);
                        return;
                case 0x62:
                        SbcHl(Hl);
#if DEBUG
                        print("SBC HL, HL");
#endif
                        wait(15);
                        return;
                case 0x72:
                        SbcHl(Sp);
#if DEBUG
                        print("SBC HL, SP");
#endif
                        wait(15);
                        return;
                    }

                case 0x6F:
                        var a = registers[A];
                        var b = mem[Hl];
                        mem[Hl] = (UInt8)((b << 4) | (a & 0x0F));
                        a = (UInt8)((a & 0xF0) | (b >> 4));
                        registers[A] = a;
                        var f = (UInt8)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) f |= (UInt8)Fl.S;
                        if (a == 0) f |= (UInt8)Fl.Z;
                        if (Parity(a)) f |= (UInt8)Fl.PV;
                        registers[F] = f;
#if DEBUG
                        print("RLD");
#endif
                        wait(18);
                        return;
                case 0x67:
                        var a = registers[A];
                        var b = mem[Hl];
                        mem[Hl] = (UInt8)((b >> 4) | (a << 4));
                        a = (UInt8)((a & 0xF0) | (b & 0x0F));
                        registers[A] = a;
                        var f = (UInt8)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) f |= (UInt8)Fl.S;
                        if (a == 0) f |= (UInt8)Fl.Z;
                        if (Parity(a)) f |= (UInt8)Fl.PV;
                        registers[F] = f;
#if DEBUG
                        print("RRD");
#endif
                        wait(18);
                        return;
                case 0x45:
                case 0x4D:
                case 0x55:
                case 0x5D:
                case 0x65:
                case 0x6D:
                case 0x75:
                case 0x7D:
                        var stack = Sp;
                        registers[PC + 1] = mem[stack++];
                        registers[PC] = mem[stack++];
                        registers[SP] = (UInt8)(stack >> 8);
                        registers[SP + 1] = (UInt8)(stack);
                        IFF1 = IFF2;
#if DEBUG
                        if (mc == 0x4D) {
                            print("RETN");
                        } else {
                            print("RETI");
                        }
#endif
                        wait(10);
                        return;
                    }

                case 0x77:
                case 0x7F:
#if DEBUG
                        print("NOP");
#endif
                        wait(8);
                        return;
                case 0x40:
                case 0x48:
                case 0x50:
                case 0x58:
                case 0x60:
                case 0x68:
                case 0x78:
                        var a = (UInt8)ports.ReadPort(Bc);
                        registers[r] = a;
                        var f = (UInt8)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) f |= (UInt8)Fl.S;
                        if (a == 0) f |= (UInt8)Fl.Z;
                        if (Parity(a)) f |= (UInt8)Fl.PV;
                        registers[F] = f;
#if DEBUG
                        print(String("IN {RName(r)}, (BC)");
#endif
                        wait(8);
                        return;
                case 0xA2:
                        var a = (UInt8)ports.ReadPort(Bc);
                        var hl = Hl;
                        mem[hl++] = a;
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        var f = (UInt8)(registers[F] & (UInt8)~(Fl.N | Fl.Z));
                        if (b == 0) f |= (UInt8)Fl.Z;
                        f |= (UInt8)Fl.N;
                        registers[F] = f;

#if DEBUG
                        print("INI");
#endif
                        wait(16);
                        return;
                case 0xB2:
                        var a = (UInt8)ports.ReadPort(Bc);
                        var hl = Hl;
                        mem[hl++] = a;
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0) {
                            var pc = Pc - 2;
                            registers[PC] = (UInt8)(pc >> 8);
                            registers[PC + 1] = (UInt8)pc;
#if DEBUG
                            print("(INIR)");
#endif
                            wait(21);
                        } else {
                            registers[F] = (UInt8)(registers[F] | (UInt8)(Fl.N | Fl.Z));
#if DEBUG
                            print("INIR");
#endif
                            wait(16);
                        }
                        return;
                case 0xAA:
                        var a = (UInt8)ports.ReadPort(Bc);
                        var hl = Hl;
                        mem[hl--] = a;
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        var f = (UInt8)(registers[F] & (UInt8)~(Fl.N | Fl.Z));
                        if (b == 0) f |= (UInt8)Fl.Z;
                        f |= (UInt8)Fl.N;
                        registers[F] = f;
#if DEBUG
                        print("IND");
#endif
                        wait(16);
                        return;
                case 0xBA:
                        var a = (UInt8)ports.ReadPort(Bc);
                        var hl = Hl;
                        mem[hl--] = a;
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0) {
                            var pc = Pc - 2;
                            registers[PC] = (UInt8)(pc >> 8);
                            registers[PC + 1] = (UInt8)pc;
#if DEBUG
                            print("(INDR)");
#endif
                            wait(21);
                        } else {
                            registers[F] = (UInt8)(registers[F] | (UInt8)(Fl.N | Fl.Z));
#if DEBUG
                            print("INDR");
#endif
                            wait(16);
                        }
                        return;
                case 0x41:
                case 0x49:
                case 0x51:
                case 0x59:
                case 0x61:
                case 0x69:
                case 0x79:
                        var a = registers[r];
                        ports.WritePort(Bc, a);
                        var f = (UInt8)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) f |= (UInt8)Fl.S;
                        if (a == 0) f |= (UInt8)Fl.Z;
                        if (Parity(a)) f |= (UInt8)Fl.PV;
                        registers[F] = f;
#if DEBUG
                        print(String("OUT (BC), {RName(r)}");
#endif
                        wait(8);
                        return;
                case 0xA3:
                        var hl = Hl;
                        var a = mem[hl++];
                        ports.WritePort(Bc, a);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        var f = (UInt8)(registers[F] & (UInt8)~(Fl.N | Fl.Z));
                        if (b == 0) f |= (UInt8)Fl.Z;
                        f |= (UInt8)Fl.N;
                        registers[F] = f;

#if DEBUG
                        print("OUTI");
#endif
                        wait(16);
                        return;
                case 0xB3:
                        var hl = Hl;
                        var a = mem[hl++];
                        ports.WritePort(Bc, a);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0) {
                            var pc = Pc - 2;
                            registers[PC] = (UInt8)(pc >> 8);
                            registers[PC + 1] = (UInt8)pc;
#if DEBUG
                            print("(OUTIR)");
#endif
                            wait(21);
                        } else {
                            registers[F] = (UInt8)(registers[F] | (UInt8)(Fl.N | Fl.Z));
#if DEBUG
                            print("OUTIR");
#endif
                            wait(16);
                        }
                        return;
                case 0xAB:
                        var hl = Hl;
                        var a = mem[hl--];
                        ports.WritePort(Bc, a);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        var f = (UInt8)(registers[F] & (UInt8)~(Fl.N | Fl.Z));
                        if (b == 0) f |= (UInt8)Fl.Z;
                        f |= (UInt8)Fl.N;
                        registers[F] = f;
#if DEBUG
                        print("OUTD");
#endif
                        wait(16);
                        return;
                case 0xBB:
                        var hl = Hl;
                        var a = mem[hl--];
                        ports.WritePort(Bc, a);
                        registers[H] = (UInt8)(hl >> 8);
                        registers[L] = (UInt8)hl;
                        var b = (UInt8)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0) {
                            var pc = Pc - 2;
                            registers[PC] = (UInt8)(pc >> 8);
                            registers[PC + 1] = (UInt8)pc;
#if DEBUG
                            print("(OUTDR)");
#endif
                            wait(21);
                        } else {
                            registers[F] = (UInt8)(registers[F] | (UInt8)(Fl.N | Fl.Z));
#if DEBUG
                            print("OUTDR");
#endif
                            wait(16);
                        }
                        return;
                    }
            }
#if DEBUG
            print(String("ED {mc:X2}: {r:X2}");
#endif
            Halt = true;
        }

        private func parseDD() {
            if (Halt) return;
            var mc = fetch();
            var hi = (UInt8)(mc >> 6);
            var lo = (UInt8)(mc & 0x07);
            var mid = (UInt8)((mc >> 3) & 0x07);

            switch (mc) {
                case 0xCB:
                        ParseCB(0xDD);
                        return;
                case 0x21:
                        // LD IX, nn
                        registers[IX + 1] = fetch();
                        registers[IX] = fetch();
#if DEBUG
                        print(String("LD IX, 0x{Ix:X4}");
#endif
                        wait(14);
                        return;
                case 0x46:
                case 0x4e:
                case 0x56:
                case 0x5e:
                case 0x66:
                case 0x6e:
                case 0x7e:
                        // LD r, (IX+d)
                        var d = (sbyte)fetch();
                        registers[mid] = mem[(UInt16)(Ix + d)];
#if DEBUG
                        print(String("LD {RName(mid)}, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x70:
                case 0x71:
                case 0x72:
                case 0x73:
                case 0x74:
                case 0x75:
                case 0x77:
                        // LD (IX+d), r
                        var d = (sbyte)fetch();
                        mem[(UInt16)(Ix + d)] = registers[lo];
#if DEBUG
                        print(String("LD (IX{d:+0;-#}), {RName(lo)}");
#endif
                        wait(19);
                        return;
                case 0x36:
                        // LD (IX+d), n
                        var d = (sbyte)fetch();
                        var n = fetch();
                        mem[(UInt16)(Ix + d)] = n;
#if DEBUG
                        print(String("LD (IX{d:+0;-#}), {n}");
#endif
                        wait(19);
                        return;
                case 0x2A:
                        // LD IX, (nn)
                        var addr = fetch16();
                        registers[IX + 1] = mem[addr++];
                        registers[IX] = mem[addr];
#if DEBUG
                        print(String("LD IX, (0x{addr:X4})*");
#endif
                        wait(20);
                        return;
                case 0x22:
                        // LD (nn), IX
                        var addr = fetch16();
                        mem[addr++] = registers[IX + 1];
                        mem[addr] = registers[IX];
#if DEBUG
                        print(String("LD (0x{addr:X4}), IX");
#endif
                        wait(20);
                        return;
                    }

                case 0xF9:
                        // LD SP, IX
                        registers[SP] = registers[IX];
                        registers[SP + 1] = registers[IX + 1];
#if DEBUG
                        print("LD SP, IX");
#endif
                        wait(10);
                        return;
                case 0xE5:
                        // PUSH IX
                        var addr = Sp;
                        addr--;
                        mem[addr] = registers[IX];
                        addr--;
                        mem[addr] = registers[IX + 1];
                        registers[SP + 1] = (UInt8)(addr & 0xFF);
                        registers[SP] = (UInt8)(addr >> 8);
#if DEBUG
                        print("PUSH IX");
#endif
                        wait(15);
                        return;
                case 0xE1:
                        // POP IX
                        var addr = Sp;
                        registers[IX + 1] = mem[addr++];
                        registers[IX] = mem[addr++];
                        registers[SP + 1] = (UInt8)(addr & 0xFF);
                        registers[SP] = (UInt8)(addr >> 8);
#if DEBUG
                        print("POP IX");
#endif
                        wait(14);
                        return;
                case 0xE3:
                        // EX (SP), IX
                        var h = registers[IX];
                        var l = registers[IX + 1];
                        var addr = Sp;
                        registers[IX + 1] = mem[addr++];
                        registers[IX] = mem[addr];
                        mem[addr--] = h;
                        mem[addr] = l;

#if DEBUG
                        print("EX (SP), IX");
#endif
                        wait(24);
                        return;
                    }

                case 0x86:
                        // ADD A, (IX+d)
                        var d = (sbyte)fetch();

                        add(mem[(UInt16)(Ix + d)]);
#if DEBUG
                        print(String("ADD A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x8E:
                        // ADC A, (IX+d)
                        var d = (sbyte)fetch();
                        var a = registers[A];
                        adc(mem[(UInt16)(Ix + d)]);
#if DEBUG
                        print(String("ADC A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x96:
                        // SUB A, (IX+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Ix + d)];

                        Sub(b);
#if DEBUG
                        print(String("SUB A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x9E:
                        // SBC A, (IX+d)
                        var d = (sbyte)fetch();

                        Sbc(mem[(UInt16)(Ix + d)]);
#if DEBUG
                        print(String("SBC A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xA6:
                        // AND A, (IX+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Ix + d)];

                        And(b);
#if DEBUG
                        print(String("AND A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xB6:
                        // OR A, (IX+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Ix + d)];

                        Or(b);
#if DEBUG
                        print(String("OR A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xAE:
                        // OR A, (IX+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Ix + d)];

                        Xor(b);
#if DEBUG
                        print(String("XOR A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xBE:
                        // CP A, (IX+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Ix + d)];

                        Cmp(b);
#if DEBUG
                        print(String("CP A, (IX{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x34:
                        // INC (IX+d)
                        var d = (sbyte)fetch();
                        mem[(UInt16)(Ix + d)] = Inc(mem[(UInt16)(Ix + d)]);
#if DEBUG
                        print(String("INC (IX{d:+0;-#})");
#endif
                        wait(7);
                        return;
                case 0x35:
                        // DEC (IX+d)
                        var d = (sbyte)fetch();
                        mem[(UInt16)(Ix + d)] = Dec(mem[(UInt16)(Ix + d)]);
#if DEBUG
                        print(String("DEC (IX{d:+0;-#})");
#endif
                        wait(7);
                        return;
                case 0x09:
                        addIx(Bc);
#if DEBUG
                        print("ADD IX, BC");
#endif
                        wait(4);
                        return;
                case 0x19:
                        addIx(De);
#if DEBUG
                        print("ADD IX, DE");
#endif
                        wait(4);
                        return;
                case 0x29:
                        addIx(Ix);
#if DEBUG
                        print("ADD IX, IX");
#endif
                        wait(4);
                        return;
                case 0x39:
                        addIx(Sp);
#if DEBUG
                        print("ADD IX, SP");
#endif
                        wait(4);
                        return;
                case 0x23:
                        var val = Ix + 1;
                        registers[IX] = (UInt8)(val >> 8);
                        registers[IX + 1] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("INC IX");
#endif
                        wait(4);
                        return;
                case 0x2B:
                        var val = Ix - 1;
                        registers[IX] = (UInt8)(val >> 8);
                        registers[IX + 1] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("DEC IX");
#endif
                        wait(4);
                        return;
                case 0xE9:
                        var addr = Ix;
                        registers[PC] = (UInt8)(addr >> 8);
                        registers[PC + 1] = (UInt8)(addr);
#if DEBUG
                        print("JP IX");
#endif
                        wait(8);
                        return;
                    }

            }
#if DEBUG
            print(String("DD {mc:X2}: {hi:X} {mid:X} {lo:X}");
#endif
            Halt = true;
        }

        private func parseFD() {
            if (Halt) return;
            var mc = fetch();
            var hi = (UInt8)(mc >> 6);
            var lo = (UInt8)(mc & 0x07);
            var r = (UInt8)((mc >> 3) & 0x07);

            switch (mc) {
                case 0xCB:
                        ParseCB(0xFD);
                        return;
                case 0x21:
                        // LD IY, nn
                        registers[IY + 1] = fetch();
                        registers[IY] = fetch();
#if DEBUG
                        print(String("LD IY, 0x{Iy:X4}");
#endif
                        wait(14);
                        return;
                    }

                case 0x46:
                case 0x4e:
                case 0x56:
                case 0x5e:
                case 0x66:
                case 0x6e:
                case 0x7e:
                        // LD r, (IY+d)
                        var d = (sbyte)fetch();
                        registers[r] = mem[(UInt16)(Iy + d)];
#if DEBUG
                        print(String("LD {RName(r)}, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x70:
                case 0x71:
                case 0x72:
                case 0x73:
                case 0x74:
                case 0x75:
                case 0x77:
                        // LD (IY+d), r
                        var d = (sbyte)fetch();
                        mem[(UInt16)(Iy + d)] = registers[lo];
#if DEBUG
                        print(String("LD (IY{d:+0;-#}), {RName(lo)}");
#endif
                        wait(19);
                        return;
                case 0x36:
                        // LD (IY+d), n
                        var d = (sbyte)fetch();
                        var n = fetch();
                        mem[(UInt16)(Iy + d)] = n;
#if DEBUG
                        print(String("LD (IY{d:+0;-#}), {n}");
#endif
                        wait(19);
                        return;
                case 0x2A:
                        // LD IY, (nn)
                        var addr = fetch16();
                        registers[IY + 1] = mem[addr++];
                        registers[IY] = mem[addr];
#if DEBUG
                        print(String("LD IY, (0x{--addr:X4})*");
#endif
                        wait(20);
                        return;
                    }

                case 0x22:
                        // LD (nn), IY
                        var addr = fetch16();
                        mem[addr++] = registers[IY + 1];
                        mem[addr] = registers[IY];
#if DEBUG
                        print(String("LD (0x{--addr:X4}), IY");
#endif
                        wait(20);
                        return;
                case 0xF9:
                        // LD SP, IY
                        registers[SP] = registers[IY];
                        registers[SP + 1] = registers[IY + 1];
#if DEBUG
                        print("LD SP, IY");
#endif
                        wait(10);
                        return;
                case 0xE5:
                        // PUSH IY
                        var addr = Sp;
                        mem[--addr] = registers[IY];
                        mem[--addr] = registers[IY + 1];
                        registers[SP + 1] = (UInt8)(addr & 0xFF);
                        registers[SP] = (UInt8)(addr >> 8);
#if DEBUG
                        print("PUSH IY");
#endif
                        wait(15);
                        return;
                case 0xE1:
                        // POP IY
                        var addr = Sp;
                        registers[IY + 1] = mem[addr++];
                        registers[IY] = mem[addr++];
                        registers[SP + 1] = (UInt8)(addr & 0xFF);
                        registers[SP] = (UInt8)(addr >> 8);
#if DEBUG
                        print("POP IY");
#endif
                        wait(14);
                        return;
                case 0xE3:
                        // EX (SP), IY
                        var h = registers[IY];
                        var l = registers[IY + 1];
                        var addr = Sp;
                        registers[IY + 1] = mem[addr];
                        mem[addr++] = l;
                        registers[IY] = mem[addr];
                        mem[addr] = h;

#if DEBUG
                        print("EX (SP), IY");
#endif
                        wait(24);
                        return;
                case 0x86:
                        // ADD A, (IY+d)
                        var d = (sbyte)fetch();

                        add(mem[(UInt16)(Iy + d)]);
#if DEBUG
                        print(String("ADD A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x8E:
                        // ADC A, (IY+d)
                        var d = (sbyte)fetch();
                        var a = registers[A];
                        adc(mem[(UInt16)(Iy + d)]);

#if DEBUG
                        print(String("ADC A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x96:
                        // SUB A, (IY+d)
                        var d = (sbyte)fetch();

                        Sub(mem[(UInt16)(Iy + d)]);
#if DEBUG
                        print(String("SUB A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x9E:
                        // SBC A, (IY+d)
                        var d = (sbyte)fetch();

                        Sbc(mem[(UInt16)(Iy + d)]);
#if DEBUG
                        print(String("SBC A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xA6:
                        // AND A, (IY+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Iy + d)];

                        And(b);
#if DEBUG
                        print(String("AND A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xB6:
                        // OR A, (IY+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Iy + d)];

                        Or(b);
#if DEBUG
                        print(String("OR A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xAE:
                        // XOR A, (IY+d)
                        var d = (sbyte)fetch();
                        var b = mem[(UInt16)(Iy + d)];

                        Xor(b);
#if DEBUG
                        print(String("XOR A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0xBE:
                        // CP A, (IY+d)
                        var d = (sbyte)fetch();

                        Cmp(mem[(UInt16)(Iy + d)]);
#if DEBUG
                        print(String("CP A, (IY{d:+0;-#})");
#endif
                        wait(19);
                        return;
                case 0x34:
                        // INC (IY+d)
                        var d = (sbyte)fetch();
                        mem[(UInt16)(Iy + d)] = Inc(mem[(UInt16)(Iy + d)]);
#if DEBUG
                        print(String("INC (IY{d:+0;-#})");
#endif
                        wait(7);
                        return;
                case 0x35:
                        // DEC (IY+d)
                        var d = (sbyte)fetch();
                        mem[(UInt16)(Iy + d)] = Dec(mem[(UInt16)(Iy + d)]);
#if DEBUG
                        print(String("DEC (IY{d:+0;-#})");
#endif
                        wait(7);
                        return;
                case 0x09:
                        addIy(Bc);
#if DEBUG
                        print("ADD IY, BC");
#endif
                        wait(4);
                        return;
                case 0x19:
                        addIy(De);
#if DEBUG
                        print("ADD IY, DE");
#endif
                        wait(4);
                        return;
                case 0x29:
                        addIy(Iy);
#if DEBUG
                        print("ADD IY, IY");
#endif
                        wait(4);
                        return;
                case 0x39:
                        addIy(Sp);
#if DEBUG
                        print("ADD IY, SP");
#endif
                        wait(4);
                        return;
                case 0x23:
                        var val = Iy + 1;
                        registers[IY] = (UInt8)(val >> 8);
                        registers[IY + 1] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("INC IY");
#endif
                        wait(4);
                        return;
                case 0x2B:
                        var val = Iy - 1;
                        registers[IY] = (UInt8)(val >> 8);
                        registers[IY + 1] = (UInt8)(val & 0xFF);
#if DEBUG
                        print("DEC IY");
#endif
                        wait(4);
                        return;
                case 0xE9:
                        var addr = Iy;
                        registers[PC] = (UInt8)(addr >> 8);
                        registers[PC + 1] = (UInt8)(addr);
#if DEBUG
                        print("JP IY");
#endif
                        wait(8);
                        return;
                    }

            }
#if DEBUG
            print(String("FD {mc:X2}: {hi:X2} {lo:X2} {r:X2}");
#endif
            Halt = true;
        }

        private func add(_ b: UInt8) {
            var a = registers[A];
            var sum = a + b;
            registers[A] = (UInt8)sum;
            var f = (UInt8)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f |= (UInt8)Fl.S;
            if ((UInt8)sum == 0) {
                f |= (UInt8)Fl.Z;
            if ((a & 0xF + b & 0xF) > 0xF) {
                f |= (UInt8)Fl.H;
            if ((a >= 0x80 && b >= 0x80 && (sbyte)sum > 0) || (a < 0x80 && b < 0x80 && (sbyte)sum < 0)) {
                f |= (UInt8)Fl.PV;
            if (sum > 0xFF) {
                f |= (UInt8)Fl.C;
            registers[F] = f;
        }

        private func adc(_ b: UInt8) {
            var a = registers[A];
            var c = (UInt8)(registers[F] & (UInt8)Fl.C);
            var sum = a + b + c;
            registers[A] = (UInt8)sum;
            var f = (UInt8)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f |= (UInt8)Fl.S;
            if ((UInt8)sum == 0) {
                f |= (UInt8)Fl.Z;
            if ((a & 0xF + b & 0xF) > 0xF) {
                f |= (UInt8)Fl.H;
            if ((a >= 0x80 && b >= 0x80 && (sbyte)sum > 0) || (a < 0x80 && b < 0x80 && (sbyte)sum < 0)) {
                f |= (UInt8)Fl.PV;
            f = (UInt8)(f & ~(UInt8)Fl.N);
            if (sum > 0xFF) f |= (UInt8)Fl.C;
            registers[F] = f;
        }

        private func sub(_ b: UInt8) {
            var a = registers[A];
            var diff = a - b;
            registers[A] = (UInt8)diff;
            var f = (UInt8)(registers[F] & 0x28);
            if ((diff & 0x80) > 0) {
                f |= (UInt8)Fl.S;
            if (diff == 0) {
                f |= (UInt8)Fl.Z;
            if ((a & 0xF) < (b & 0xF)) {
                f |= (UInt8)Fl.H;
            if ((a >= 0x80 && b >= 0x80 && (sbyte)diff > 0) || (a < 0x80 && b < 0x80 && (sbyte)diff < 0)) {
                f |= (UInt8)Fl.PV;
            f |= (UInt8)Fl.N;
            if (diff < 0) {
                f |= (UInt8)Fl.C;
            registers[F] = f;
        }

        private func sbc(_ b: UInt8) {
            var a = registers[A];
            var c = (UInt8)(registers[F] & 0x01);
            var diff = a - b - c;
            registers[A] = (UInt8)diff;
            var f = (UInt8)(registers[F] & 0x28);
            if ((diff & 0x80) > 0) f |= (UInt8)Fl.S;
            if (diff == 0) f |= (UInt8)Fl.Z;
            if ((a & 0xF) < (b & 0xF) + c) f |= (UInt8)Fl.H;
            if ((a >= 0x80 && b >= 0x80 && (sbyte)diff > 0) || (a < 0x80 && b < 0x80 && (sbyte)diff < 0)) {
                f |= (UInt8)Fl.PV;
            f |= (UInt8)Fl.N;
            if (diff > 0xFF) f |= (UInt8)Fl.C;
            registers[F] = f;
        }

        private func and(_ b: UInt8) {
            var a = registers[A];
            var res = (UInt8)(a & b);
            registers[A] = res;
            var f = (UInt8)(registers[F] & 0x28);
            if ((res & 0x80) > 0) f |= (UInt8)Fl.S;
            if (res == 0) f |= (UInt8)Fl.Z;
            f |= (UInt8)Fl.H;
            if (Parity(res)) f |= (UInt8)Fl.PV;
            registers[F] = f;
        }

        private func or(_ b: UInt8) {
            var a = registers[A];
            var res = (UInt8)(a | b);
            registers[A] = res;
            var f = (UInt8)(registers[F] & 0x28);
            if ((res & 0x80) > 0) {
                f |= (UInt8)Fl.S;
            if (res == 0) {
                f |= (UInt8)Fl.Z;
            if (Parity(res)) {
                f |= (UInt8)Fl.PV;
            registers[F] = f;
        }

        private func xor(_ b: UInt8) {
            var a = registers[A];
            var res = (UInt8)(a ^ b);
            registers[A] = res;
            var f = (UInt8)(registers[F] & 0x28);
            if ((res & 0x80) > 0) {
                f |= (UInt8)Fl.S;
            if (res == 0) {
                f |= (UInt8)Fl.Z;
            if (Parity(res)) {
                f |= (UInt8)Fl.PV;
            registers[F] = f;
        }

        private func cmp(_ b: UInt8) {
            var a = registers[A];
            var diff = a - b;
            var f = (UInt8)(registers[F] & 0x28);
            if ((diff & 0x80) > 0) {
                f = (UInt8)(f | 0x80);
            if (diff == 0) {
                f = (UInt8)(f | 0x40);
            if ((a & 0xF) < (b & 0xF)) {
                f = (UInt8)(f | 0x10);
            if ((a > 0x80 && b > 0x80 && (sbyte)diff > 0) || (a < 0x80 && b < 0x80 && (sbyte)diff < 0)) {
                f = (UInt8)(f | 0x04);
            f = (UInt8)(f | 0x02);
            if (diff > 0xFF) {
                f = (UInt8)(f | 0x01);
            registers[F] = f;
        }

        private func inc(_ b: UInt8) {
            var sum = b + 1;
            var f = (UInt8)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f = (UInt8)(f | 0x80);
            if (sum == 0) {
                f = (UInt8)(f | 0x40);
            if ((b & 0xF) == 0xF) {
                f = (UInt8)(f | 0x10);
            if ((b < 0x80 && (sbyte)sum < 0)) {
                f = (UInt8)(f | 0x04);
            f = (UInt8)(f | 0x02);
            if (sum > 0xFF) f = (UInt8)(f | 0x01);
            registers[F] = f;

            return (UInt8)sum;
        }

        private func dec(_ b: UInt8) {
            var sum = b - 1;
            var f = (UInt8)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f = (UInt8)(f | 0x80);
            if (sum == 0) {
                f = (UInt8)(f | 0x40);
            if ((b & 0x0F) == 0) {
                f = (UInt8)(f | 0x10);
            if (b == 0x80) {
                f = (UInt8)(f | 0x04);
            f = (UInt8)(f | 0x02);
            registers[F] = f;

            return (UInt8)sum;
        }

        private static func parity(_ value: UInt16) -> Bool {
            var parity = true;
            while (value > 0)
                if ((value & 1) == 1) parity = !parity;
                value = (UInt8)(value >> 1);
            }
            return parity;
        }

        private func jumpCondition(_ condition: UInt8) -> Bool {
            Fl mask;
            switch (condition & 0xFE) {
                case 0:
                    mask = Fl.Z;
                    break;
                case 2:
                    mask = Fl.C;
                    break;
                case 4:
                    mask = Fl.PV;
                    break;
                case 6:
                    mask = Fl.S;
                    break;
                default:
                    return false;
            }
            return ((registers[F] & (UInt8)mask) > 0) == ((condition & 1) == 1);

        }
*/
    private mutating func fetch() -> UInt8 {
        var pc = Pc
        let value = mem[pc]
#if DEBUG
        print(String(format: "%4X %2X\n", pc, value))
#endif
        pc += 1
        registers[PC] = UInt8(pc >> 8)
        registers[PC + 1] = UInt8(pc & 0xFF)
        return value
    }

    private mutating func fetch16() -> UInt16 {
        return UInt16(fetch()) + (UInt16(fetch()) << 8)
    }

    public mutating func reset() {
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

        clock = Date.now
    }
/*
        public func getState() -> [UInt8] {
            var length = registers.Length;
            var ret = new UInt8[length + 2];
            Array.Copy(registers, ret, length);
            ret[length] = (UInt8)(IFF1 ? 1 : 0);
            ret[length + 1] = (UInt8)(IFF2 ? 1 : 0);
            return ret;
        }

        public func dumpState() -> String {
            var ret = " BC   DE   HL  SZ-H-PNC A" + Environment.NewLine;
            ret +=
                $"{registers[B]:X2}{registers[C]:X2} {registers[D]:X2}{registers[E]:X2} {registers[H]:X2}{registers[L]:X2} {(registers[F] & 0x80) >> 7}{(registers[F] & 0x40) >> 6}{(registers[F] & 0x20) >> 5}{(registers[F] & 0x10) >> 4}{(registers[F] & 0x08) >> 3}{(registers[F] & 0x04) >> 2}{(registers[F] & 0x02) >> 1}{(registers[F] & 0x01)} {registers[A]:X2}";
            ret +=
                $"\n{registers[Bp]:X2}{registers[Cp]:X2} {registers[Dp]:X2}{registers[Ep]:X2} {registers[Hp]:X2}{registers[Lp]:X2} {(registers[Fp] & 0x80) >> 7}{(registers[Fp] & 0x40) >> 6}{(registers[Fp] & 0x20) >> 5}{(registers[Fp] & 0x10) >> 4}{(registers[Fp] & 0x08) >> 3}{(registers[Fp] & 0x04) >> 2}{(registers[Fp] & 0x02) >> 1}{registers[Fp] & 0x01} {registers[Ap]:X2}";
            ret += Environment.NewLine + Environment.NewLine + "I  R   IX   IY   SP   PC" + Environment.NewLine;
            ret +=
                $"{registers[I]:X2} {registers[R]:X2} {registers[IX]:X2}{registers[IX + 1]:X2} {registers[IY]:X2}{registers[IY + 1]:X2} {registers[SP]:X2}{registers[SP + 1]:X2} {registers[PC]:X2}{registers[PC + 1]:X2} ";

            ret += Environment.NewLine;
            return ret;
        }
*/
    private mutating func wait(_ t: Int) {
        registers[R] += UInt8((t + 3) / 4)
        let realTicksPerTick = 250 // 4MHz
        let ticks = t * realTicksPerTick
        let elapsed = Date.now - clock
        let sleep = Double(ticks) / 1_000_000_000 - elapsed
        if sleep > 0 {
            Thread.sleep(forTimeInterval: sleep)
            clock = clock + sleep
        } else {
#if DEBUG
            print(String(format: "Clock expected %.2g but was %.2g\n", t, Double(elapsed) / Double(realTicksPerTick)))
#endif
            clock = Date.now
        }
    }
/*
        private func swapReg8(_ register1: UInt8, _ register2, UInt8) {
            var t = registers[r1];
            registers[r1] = registers[r2];
            registers[r2] = t;
        }

        [Flags]
        private enum Fl : UInt8
            C = 0x01,
            N = 0x02,
            PV = 0x04,
            H = 0x10,
            Z = 0x40,
            S = 0x80,

            None = 0x00,
            All = 0xD7
        }
*/

#if DEBUG
    private static func rName(_ n: Int) -> String {
        switch n {
            case 0:
                return "B";
            case 1:
                return "C";
            case 2:
                return "D";
            case 3:
                return "E";
            case 4:
                return "H";
            case 5:
                return "L";
            case 7:
                return "A";
            default:
                return "";
        }
    }

    private static func r16Name(_ n: Int) -> String {
        switch n {
            case 0x00:
                return "BC";
            case 0x10:
                return "DE";
            case 0x20:
                return "HL";
            case 0x30:
                return "SP";
            default:
                break;
        }
        return "";
    }
#endif
}

extension Date {
    static var now: Double {
         Date().timeIntervalSince1970 + 62_135_596_800
    }
}
