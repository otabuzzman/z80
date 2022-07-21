import Foundation

    public struct Z80
    {
        private let B: byte = 0
        private let C: byte = 1
        private let D: byte = 2
        private let E: byte = 3
        private let H: byte = 4
        private let L: byte = 5
        private let F: byte = 6
        private let A: byte = 7
        private let Bp: byte = 8
        private let Cp: byte = 9
        private let Dp: byte = 10
        private let Ep: byte = 11
        private let Hp: byte = 12
        private let Lp: byte = 13
        private let Fp: byte = 14
        private let Ap: byte = 15
        private let I: byte = 16
        private let R: byte = 17
        private let IX: byte = 18
        private let IY: byte = 20
        private let SP: byte = 22
        private let PC: byte = 24
        private(set) var mem: Memory
        private(set) var registers = Array<byte>(repeating: 0, count: 26)
        private var _clock = Date()
        private var IFF1 = false
        private var IFF2 = false
        private var interruptMode: int = 0

        private(set) var ports: IPorts

        init(_ memory: Memory, _ ports: IPorts)
        {
            // if (memory == null) throw new ArgumentNullException(nameof(memory));
            // if (ports == null) throw new ArgumentNullException(nameof(ports));
            mem = memory
            self.ports = ports
            Reset()
        }

        private var Hl: ushort { (ushort)(registers[L] + (registers[H] << 8)) }
        private var Sp: ushort { (ushort)(registers[SP + 1] + (registers[SP] << 8)) }
        private var Ix: ushort { (ushort)(registers[IX + 1] + (registers[IX] << 8)) }
        private var Iy: ushort { (ushort)(registers[IY + 1] + (registers[IY] << 8)) }
        private var Bc: ushort { (ushort)((registers[B] << 8) + registers[C]) }
        private var De: ushort { (ushort)((registers[D] << 8) + registers[E]) }
        private var Pc: ushort { (ushort)(registers[PC + 1] + (registers[PC] << 8)) }
        private(set) var Halt = false

        public mutating func Parse()
        {
            if (ports.NMI)
            {
                var stack = Sp;
				stack -= 1
                mem[stack] = (byte)(Pc >> 8);
				stack -= 1
                mem[stack] = (byte)(Pc);
                registers[SP] = (byte)(stack >> 8);
                registers[SP + 1] = (byte)(stack);
                registers[PC] = 0x00;
                registers[PC + 1] = 0x66;
                IFF1 = IFF2;
                IFF1 = false;
#if DEBUG
                print("NMI");
#endif
                Wait(17);
                Halt = false;
                return;
            }

            if (IFF1 && ports.MI)
            {
                IFF1 = false;
                IFF2 = false;
                switch (interruptMode)
                {
                    case 0:
                            // This is not quite correct, as it only runs a RST xx
                            // Instead, it should also support any other instruction
                            let instruction = ports.Data;
                            var stack = Sp;
            				stack -= 1
                            mem[stack] = (byte)(Pc >> 8);
            				stack -= 1
                            mem[stack] = (byte)(Pc);
                            registers[SP] = (byte)(stack >> 8);
                            registers[SP + 1] = (byte)(stack);
                            registers[PC] = 0x00;
                            registers[PC + 1] = (byte)(instruction & 0x38);
                            Wait(17);

#if DEBUG
                            print("MI 0");
#endif
                            Halt = false;
                            return;
                    case 1:
                            var stack = Sp;
            				stack -= 1
                            mem[stack] = (byte)(Pc >> 8);
            				stack -= 1
                            mem[stack] = (byte)(Pc);
                            registers[SP] = (byte)(stack >> 8);
                            registers[SP + 1] = (byte)(stack);
                            registers[PC] = 0x00;
                            registers[PC + 1] = 0x38;
#if DEBUG
                            print("MI 1");
#endif
                            Wait(17);
                            Halt = false;
                            return;
                    case 2:
                            let vector = ports.Data;
                            var stack = Sp;
            				stack -= 1
                            mem[stack] = (byte)(Pc >> 8);
            				stack -= 1
                            mem[stack] = (byte)(Pc);
                            registers[SP] = (byte)(stack >> 8);
                            registers[SP + 1] = (byte)(stack);
                            var address = (ushort)((registers[I] << 8) + vector);
                            registers[PC] = mem[address];
							address += 1
                            registers[PC + 1] = mem[address];
#if DEBUG
                            print("MI 2");
#endif
                            Wait(17);
                            Halt = false;
                            return;
					default:
							break
                }
                return;
            }
            if (Halt) {
				return;
			}
            let mc = Fetch();
            let hi = (byte)(mc >> 6);
            let lo = (byte)(mc & 0x07);
            let r = (byte)((mc >> 3) & 0x07);
            if (hi == 1)
            {
                let useHL1 = r == 6;
                let useHL2 = lo == 6;
                if (useHL2 && useHL1)
                {
#if DEBUG
                    print("HALT");
#endif
                    Halt = true;
                    return;
                }
                let reg = useHL2 ? mem[Hl] : registers[lo];

                if (useHL1) {
                    mem[Hl] = reg;
                } else {
                    registers[r] = reg;
				}
                Wait(useHL1 || useHL2 ? 7 : 4);
#if DEBUG
                print(String(format: "LD %s %s\n", useHL1 ? "(HL)" : Z80.RName(r), useHL2 ? "(HL)" : Z80.RName(lo)));
#endif
                return;
            }
            switch (mc)
            {
                case 0xCB:
                    ParseCB();
                    return;
                case 0xDD:
                    ParseDD();
                    return;
                case 0xED:
                    ParseED();
                    return;
                case 0xFD:
                    ParseFD();
                    return;
                case 0x00:
                    // NOP
#if DEBUG
                    print("NOP");
#endif
                    Wait(4);
                    return;
                case 0x01, 0x11, 0x21:

                        // LD dd, nn
                        registers[r + 1] = Fetch();
                        registers[r] = Fetch();
#if DEBUG
                        print(String(format: "LD %s%s, 0x%2X%2X\n", Z80.RName(r), Z80.RName((byte)(r + 1)), registers[r], registers[r + 1]));
#endif
                        Wait(10);
                        return;

                case 0x31:

                        // LD SP, nn
                        registers[SP + 1] = Fetch();
                        registers[SP] = Fetch();
#if DEBUG
                        print(String(format: "LD SP, 0x%2X%2X\n", registers[SP], registers[SP + 1]));
#endif
                        Wait(10);
                        return;

                case 0x06, 0x0e, 0x16, 0x1e, 0x26, 0x2e, 0x3e:

                        // LD r, n
                        let n = Fetch();
                        registers[r] = n;
#if DEBUG
                        print(String(format: "LD %s, 0x%2X\n", Z80.RName(r), n));
#endif
                        Wait(7);
                        return;

                case 0x36:

                        // LD (HL), n
                        let n = Fetch();
                        mem[Hl] = n;
#if DEBUG
                        print(String(format: "LD (HL), 0x%2X\n", n));
#endif
                        Wait(10);
                        return;

                case 0x0A:

                        // LD A, (BC)
                        registers[A] = mem[Bc];
#if DEBUG
                        print("LD A, (BC)");
#endif
                        Wait(7);
                        return;

                case 0x1A:

                        // LD A, (DE)
                        registers[A] = mem[De];
#if DEBUG
                        print("LD A, (DE)");
#endif
                        Wait(7);
                        return;

                case 0x3A:

                        // LD A, (nn)
                        let addr = Fetch16();
                        registers[A] = mem[addr];
#if DEBUG
                        print(String(format: "LD A, (0x54X)\n", addr));
#endif
                        Wait(13);
                        return;

                case 0x02:

                        // LD (BC), A
                        mem[Bc] = registers[A];
#if DEBUG
                        print("LD (BC), A");
#endif
                        Wait(7);
                        return;

                case 0x12:

                        // LD (DE), A
                        mem[De] = registers[A];
#if DEBUG
                        print("LD (DE), A");
#endif
                        Wait(7);
                        return;

                case 0x32:

                        // LD (nn), A 
                        let addr = Fetch16();
                        mem[addr] = registers[A];
#if DEBUG
                        print(String(format: "LD (0x%4X), A\n", addr));
#endif
                        Wait(13);
                        return;

                case 0x2A:

                        // LD HL, (nn) 
                        var addr = Fetch16();
                        registers[L] = mem[addr];
						addr += 1
                        registers[H] = mem[addr];
#if DEBUG
                        addr -= 1
						print(String(format: "LD HL, (0x%4X)\n", addr));
#endif
                        Wait(16);
                        return;

                case 0x22:

                        // LD (nn), HL
                        var addr = Fetch16();
                        mem[addr] = registers[L];
						addr += 1
                        mem[addr] = registers[H];
#if DEBUG
                        addr -= 1
						print(String(format: "LD (0x%4X), HL\n", addr));
#endif
                        Wait(16);
                        return;

                case 0xF9:

                        // LD SP, HL
                        registers[SP + 1] = registers[L];
                        registers[SP] = registers[H];
#if DEBUG
                        print("LD SP, HL");
#endif
                        Wait(6);
                        return;


                case 0xC5:

                        // PUSH BC
                        var addr = Sp;
						addr -= 1
                        mem[addr] = registers[B];
						addr -= 1
                        mem[addr] = registers[C];
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("PUSH BC");
#endif
                        Wait(11);
                        return;

                case 0xD5:

                        // PUSH DE
                        var addr = Sp;
						addr -= 1
                        mem[addr] = registers[D];
						addr -= 1
                        mem[addr] = registers[E];
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("PUSH DE");
#endif
                        Wait(11);
                        return;

                case 0xE5:

                        // PUSH HL
                        var addr = Sp;
						addr -= 1
                        mem[addr] = registers[H];
						addr -= 1
                        mem[addr] = registers[L];
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("PUSH HL");
#endif
                        Wait(11);
                        return;

                case 0xF5:

                        // PUSH AF
                        var addr = Sp;
						addr -= 1
                        mem[addr] = registers[A];
						addr -= 1
                        mem[addr] = registers[F];
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("PUSH AF");
#endif
                        Wait(11);
                        return;

                case 0xC1:

                        // POP BC
                        var addr = Sp;
                        registers[C] = mem[addr];
						addr += 1
                        registers[B] = mem[addr];
						addr += 1
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("POP BC");
#endif
                        Wait(10);
                        return;

                case 0xD1:

                        // POP DE
                        var addr = Sp;
                        registers[E] = mem[addr];
						addr += 1
                        registers[D] = mem[addr];
						addr += 1
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("POP DE");
#endif
                        Wait(10);
                        return;

                case 0xE1:

                        // POP HL
                        var addr = Sp;
                        registers[L] = mem[addr];
						addr += 1
                        registers[H] = mem[addr];
						addr += 1
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("POP HL");
#endif
                        Wait(10);
                        return;

                case 0xF1:

                        // POP AF
                        var addr = Sp;
                        registers[F] = mem[addr];
						addr += 1
                        registers[A] = mem[addr];
						addr += 1
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("POP AF");
#endif
                        Wait(10);
                        return;

                case 0xEB:

                        // EX DE, HL
                        SwapReg8(D, H);
                        SwapReg8(E, L);
#if DEBUG
                        print("EX DE, HL");
#endif
                        Wait(4);
                        return;

                case 0x08:

                        // EX AF, AF'
                        SwapReg8(Ap, A);
                        SwapReg8(Fp, F);
#if DEBUG
                        print("EX AF, AF'");
#endif
                        Wait(4);
                        return;

                case 0xD9:

                        // EXX
                        SwapReg8(B, Bp);
                        SwapReg8(C, Cp);
                        SwapReg8(D, Dp);
                        SwapReg8(E, Ep);
                        SwapReg8(H, Hp);
                        SwapReg8(L, Lp);
#if DEBUG
                        print("EXX");
#endif
                        Wait(4);
                        return;

                case 0xE3:

                        // EX (SP), HL
                        var addr = Sp;

                        var tmp = registers[L];
                        registers[L] = mem[addr];
                        mem[addr] = tmp;
						addr += 1

                        tmp = registers[H];
                        registers[H] = mem[addr];
                        mem[addr] = tmp;

#if DEBUG
                        print("EX (SP), HL");
#endif
                        Wait(19);
                        return;

                case 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x87:

                        // ADD A, r
                        Add(registers[lo]);
#if DEBUG
                        print(String(format: "ADD A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xC6:

                        // ADD A, n
                        let b = Fetch();
                        Add(b);
#if DEBUG
                        print(String(format: "ADD A, 0x%2X\n", b));
#endif
                        Wait(4);
                        Wait(4);
                        return;

                case 0x86:

                        // ADD A, (HL)
                        Add(mem[Hl]);
#if DEBUG
                        print("ADD A, (HL)");
#endif
                        Wait(7);
                        return;

                case 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F:

                        // ADC A, r
                        Adc(registers[lo]);
#if DEBUG
                        print(String(format: "ADC A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xCE:

                        // ADC A, n
                        let b = Fetch();
                        Adc(b);
#if DEBUG
                        print(String(format: "ADC A, 0x%2X\n", b));
#endif
                        Wait(4);
                        return;

                case 0x8E:

                        // ADC A, (HL)
                        Adc(mem[Hl]);
#if DEBUG
                        print("ADC A, (HL)");
#endif
                        Wait(7);
                        return;

                case 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x97:

                        // SUB A, r
                        Sub(registers[lo]);
#if DEBUG
                        print(String(format: "SUB A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xD6:

                        // SUB A, n
                        let b = Fetch();
                        Sub(b);
#if DEBUG
                        print(String(format: "SUB A, 0x%2X\n", b));
#endif
                        Wait(4);
                        return;

                case 0x96:

                        // SUB A, (HL)
                        Sub(mem[Hl]);
#if DEBUG
                        print("SUB A, (HL)");
#endif
                        Wait(7);
                        return;

                case 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9F:

                        // SBC A, r
                        Sbc(registers[lo]);
#if DEBUG
                        print(String(format: "SBC A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xDE:

                        // SBC A, n
                        let b = Fetch();
                        Sbc(b);
#if DEBUG
                        print(String(format: "SBC A, 0x%2X\n", b));
#endif
                        Wait(4);
                        return;

                case 0x9E:

                        // SBC A, (HL)
                        Sbc(mem[Hl]);
#if DEBUG
                        print("SBC A, (HL)");
#endif
                        Wait(7);
                        return;


                case 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA7:

                        // AND A, r
                        And(registers[lo]);
#if DEBUG
                        print(String(format: "AND A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xE6:

                        // AND A, n
                        let b = Fetch();

                        And(b);
#if DEBUG
                        print(String(format: "AND A, 0x%2X\n", b));
#endif
                        Wait(4);
                        return;

                case 0xA6:

                        // AND A, (HL)
                        And(mem[Hl]);
#if DEBUG
                        print("AND A, (HL)");
#endif
                        Wait(7);
                        return;

                case 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB7:

                        // OR A, r
                        Or(registers[lo]);
#if DEBUG
                        print(String(format: "OR A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xF6:

                        // OR A, n
                        let b = Fetch();
                        Or(b);
#if DEBUG
                        print(String(format: "OR A, 0x%2X\n", b));
#endif
                        Wait(4);
                        return;

                case 0xB6:

                        // OR A, (HL)
                        Or(mem[Hl]);
#if DEBUG
                        print("OR A, (HL)");
#endif
                        Wait(7);
                        return;

                case 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF:

                        // XOR A, r
                        Xor(registers[lo]);
#if DEBUG
                        print(String(format: "XOR A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xEE:

                        // XOR A, n
                        let b = Fetch();
                        Xor(b);
#if DEBUG
                        print(String(format: "XOR A, 0x%2X\n", b));
#endif
                        Wait(4);
                        return;

                case 0xAE:

                        // XOR A, (HL)
                        Xor(mem[Hl]);
#if DEBUG
                        print("XOR A, (HL)");
#endif
                        Wait(7);
                        return;


                case 0xF3:

                        // DI
                        IFF1 = false;
                        IFF2 = false;
#if DEBUG
                        print("DI");
#endif
                        Wait(4);
                        return;

                case 0xFB:

                        // EI
                        IFF1 = true;
                        IFF2 = true;
#if DEBUG
                        print("EI");
#endif
                        Wait(4);
                        return;

                case 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBF:

                        // CP A, r
                        Cmp(registers[lo]);
#if DEBUG
                        print(String(format: "CP A, %s\n", Z80.RName(lo)));
#endif
                        Wait(4);
                        return;

                case 0xFE:

                        // CP A, n
                        let b = Fetch();
                        Cmp(b);
#if DEBUG
                        print(String(format: "CP A, 0x%2X\n", b));
#endif
                        Wait(4);
                        return;

                case 0xBE:

                        // CP A, (HL)
                        Cmp(mem[Hl]);
#if DEBUG
                        print("CP A, (HL)");
#endif
                        Wait(7);
                        return;

                case 0x04, 0x0C, 0x14, 0x1C, 0x24, 0x2C, 0x3C:

                        // INC r
                        registers[r] = Inc(registers[r]);
#if DEBUG
                        print(String(format: "INC %s\n", Z80.RName(r)));
#endif
                        Wait(4);
                        return;

                case 0x34:

                        // INC (HL)
                        mem[Hl] = Inc(mem[Hl]);
#if DEBUG
                        print("INC (HL)");
#endif
                        Wait(7);
                        return;


                case 0x05, 0x0D, 0x15, 0x1D, 0x25, 0x2D, 0x3D:

                        // DEC r
                        registers[r] = Dec(registers[r]);
#if DEBUG
                        print(String(format: "DEC %s\n", Z80.RName(r)));
#endif
                        Wait(7);
                        return;

                case 0x35:

                        // DEC (HL)
                        mem[Hl] = Dec(mem[Hl]);
#if DEBUG
                        print("DEC (HL)");
#endif
                        Wait(7);
                        return;

                case 0x27:

                        // DAA
                        var a = registers[A];
                        let f = registers[F];
                        if ((a & 0x0F) > 0x09 || (f & (byte)(Fl.H.rawValue)) > 0)
                        {
                            Add(0x06);
                            a = registers[A];
                        }
                        if ((a & 0xF0) > 0x90 || (f & (byte)(Fl.C.rawValue)) > 0)
                        {
                            Add(0x60);
                        }
#if DEBUG
                        print("DAA");
#endif
                        Wait(4);
                        return;

                case 0x2F:

                        // CPL
                        registers[A] ^= 0xFF;
                        registers[F] |= (byte)(Fl.H.rawValue | Fl.N.rawValue);
#if DEBUG
                        print("CPL");
#endif
                        Wait(4);
                        return;

                case 0x3F:

                        // CCF
                        registers[F] &= (byte)(~Fl.N.rawValue);
                        registers[F] ^= (byte)(Fl.C.rawValue);
#if DEBUG
                        print("CCF");
#endif
                        Wait(4);
                        return;

                case 0x37:

                        // SCF
                        registers[F] &= (byte)(~Fl.N.rawValue);
                        registers[F] |= (byte)(Fl.C.rawValue);
#if DEBUG
                        print("SCF");
#endif
                        Wait(4);
                        return;

                case 0x09:

                        AddHl(Bc);

#if DEBUG
                        print("ADD HL, BC");
#endif
                        Wait(4);
                        return;

                case 0x19:

                        AddHl(De);
#if DEBUG
                        print("ADD HL, DE");
#endif
                        Wait(4);
                        return;

                case 0x29:

                        AddHl(Hl);
#if DEBUG
                        print("ADD HL, HL");
#endif
                        Wait(4);
                        return;

                case 0x39:

                        AddHl(Sp);
#if DEBUG
                        print("ADD HL, SP");
#endif
                        Wait(4);
                        return;

                case 0x03:

                        let val = Bc + 1;
                        registers[B] = (byte)(val >> 8);
                        registers[C] = (byte)(val & 0xFF);
#if DEBUG
                        print("INC BC");
#endif
                        Wait(4);
                        return;

                case 0x13:

                        let val = De + 1;
                        registers[D] = (byte)(val >> 8);
                        registers[E] = (byte)(val & 0xFF);
#if DEBUG
                        print("INC DE");
#endif
                        Wait(4);
                        return;

                case 0x23:

                        let val = Hl + 1;
                        registers[H] = (byte)(val >> 8);
                        registers[L] = (byte)(val & 0xFF);
#if DEBUG
                        print("INC HL");
#endif
                        Wait(4);
                        return;

                case 0x33:

                        let val = Sp + 1;
                        registers[SP] = (byte)(val >> 8);
                        registers[SP + 1] = (byte)(val & 0xFF);
#if DEBUG
                        print("INC SP");
#endif
                        Wait(4);
                        return;

                case 0x0B:

                        let val = Bc - 1;
                        registers[B] = (byte)(val >> 8);
                        registers[C] = (byte)(val & 0xFF);
#if DEBUG
                        print("DEC BC");
#endif
                        Wait(4);
                        return;

                case 0x1B:

                        let val = De - 1;
                        registers[D] = (byte)(val >> 8);
                        registers[E] = (byte)(val & 0xFF);
#if DEBUG
                        print("DEC DE");
#endif
                        Wait(4);
                        return;

                case 0x2B:

                        let val = Hl - 1;
                        registers[H] = (byte)(val >> 8);
                        registers[L] = (byte)(val & 0xFF);
#if DEBUG
                        print("DEC HL");
#endif
                        Wait(4);
                        return;

                case 0x3B:

                        let val = Sp - 1;
                        registers[SP] = (byte)(val >> 8);
                        registers[SP + 1] = (byte)(val & 0xFF);
#if DEBUG
                        print("DEC SP");
#endif
                        Wait(4);
                        return;

                case 0x07:

                        var a = registers[A];
                        let c = (byte)((a & 0x80) >> 7);
                        a <<= 1;
                        registers[A] = a;
                        registers[F] &= (byte)(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue));
                        registers[F] |= c;
#if DEBUG
                        print("RLCA");
#endif
                        Wait(4);
                        return;

                case 0x17:

                        var a = registers[A];
                        let c = (byte)((a & 0x80) >> 7);
                        a <<= 1;
                        var f = registers[F];
                        a |= (byte)(f & (byte)(Fl.C.rawValue));
                        registers[A] = a;
                        f &= (byte)(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue));
                        f |= c;
                        registers[F] = f;
#if DEBUG
                        print("RLA");
#endif
                        Wait(4);
                        return;

                case 0x0F:

                        var a = registers[A];
                        let c = (byte)(a & 0x01);
                        a >>= 1;
                        registers[A] = a;
                        registers[F] &= (byte)(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue));
                        registers[F] |= c;
#if DEBUG
                        print("RRCA");
#endif
                        Wait(4);
                        return;

                case 0x1F:

                        var a = registers[A];
                        let c = (byte)(a & 0x01);
                        a >>= 1;
                        var f = registers[F];
                        a |= (byte)((f & (byte)(Fl.C.rawValue)) << 7);
                        registers[A] = a;
                        f &= (byte)(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue));
                        f |= c;
                        registers[F] = f;
#if DEBUG
                        print("RRA");
#endif
                        Wait(4);
                        return;

                case 0xC3:

                        let addr = Fetch16();
                        registers[PC] = (byte)(addr >> 8);
                        registers[PC + 1] = (byte)(addr);
#if DEBUG
                        print(String(format: "JP 0x%4X\n", addr));
#endif
                        Wait(10);
                        return;

                case 0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA:

                        let addr = Fetch16();
                        if (JumpCondition(r))
                        {
                            registers[PC] = (byte)(addr >> 8);
                            registers[PC + 1] = (byte)(addr);
                        }
#if DEBUG
                        print(String(format: "JP %s, 0x%4X\n", Z80.JCName(r), addr));
#endif
                        Wait(10);
                        return;


                case 0x18:

                        // order is important here
                        let d = (sbyte)(Fetch());
                        let addr = Pc + d;
                        registers[PC] = (byte)(addr >> 8);
                        registers[PC + 1] = (byte)(addr);
#if DEBUG
                        print(String(format: "JR 0x%4X\n", addr));
#endif
                        Wait(12);
                        return;

                case 0x20, 0x28, 0x30, 0x38:

                        // order is important here
                        let d = (sbyte)(Fetch());
                        let addr = Pc + d;
                        if (JumpCondition((byte)(r & 3)))
                        {
                            registers[PC] = (byte)(addr >> 8);
                            registers[PC + 1] = (byte)(addr);
                            Wait(12);
                        }
                        else
                        {
                            Wait(7);
                        }
#if DEBUG
                        print(String(format: "JR %s, 0x%4X\n", Z80.JCName((byte)(r & 3)), addr));
#endif
                        return;


                case 0xE9:

                        let addr = Hl;
                        registers[PC] = (byte)(addr >> 8);
                        registers[PC + 1] = (byte)(addr);
#if DEBUG
                        print("JP HL");
#endif
                        Wait(4);
                        return;

                case 0x10:

                        // order is important here
                        let d = (sbyte)(Fetch());
                        let addr = Pc + d;
                        var b = registers[B];
						b -= 1
                        registers[B] = b;
                        if (b != 0)
                        {
                            registers[PC] = (byte)(addr >> 8);
                            registers[PC + 1] = (byte)(addr);
                            Wait(13);
                        }
                        else
                        {
                            Wait(8);
                        }
#if DEBUG
                        print(String(format: "DJNZ 0x%4X\n", addr));
#endif
                        return;

                case 0xCD:

                        let addr = Fetch16();
                        var stack = Sp;
						stack -= 1
                        mem[stack] = (byte)(Pc >> 8);
						stack -= 1
                        mem[stack] = (byte)(Pc);
                        registers[SP] = (byte)(stack >> 8);
                        registers[SP + 1] = (byte)(stack);
                        registers[PC] = (byte)(addr >> 8);
                        registers[PC + 1] = (byte)(addr);
#if DEBUG
                        print(String(format: "CALL 0x%4X\n", addr));
#endif
                        Wait(17);
                        return;

                case 0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC:

                        let addr = Fetch16();
                        if (JumpCondition(r))
                        {
                            var stack = Sp;
    						stack -= 1
                            mem[stack] = (byte)(Pc >> 8);
    						stack -= 1
                            mem[stack] = (byte)(Pc);
                            registers[SP] = (byte)(stack >> 8);
                            registers[SP + 1] = (byte)(stack);
                            registers[PC] = (byte)(addr >> 8);
                            registers[PC + 1] = (byte)(addr);
                            Wait(17);
                        }
                        else
                        {
                            Wait(10);
                        }
#if DEBUG
                        print(String(format: "CALL %s, 0x%4X\n", Z80.JCName(r), addr));
#endif
                        return;


                case 0xC9:

                        var stack = Sp;
                        registers[PC + 1] = mem[stack];
						stack += 1
                        registers[PC] = mem[stack];
						stack += 1
                        registers[SP] = (byte)(stack >> 8);
                        registers[SP + 1] = (byte)(stack);
#if DEBUG
                        print("RET");
#endif
                        Wait(10);
                        return;

                case 0xC0, 0xC8, 0xD0, 0xD8, 0xE0, 0xE8, 0xF0, 0xF8:

                        if (JumpCondition(r))
                        {
                            var stack = Sp;
                            registers[PC + 1] = mem[stack];
    						stack += 1
                            registers[PC] = mem[stack];
    						stack += 1
                            registers[SP] = (byte)(stack >> 8);
                            registers[SP + 1] = (byte)(stack);
                            Wait(11);
                        }
                        else
                        {
                            Wait(5);
                        }
#if DEBUG
                        print(String(format: "RET %s\n", Z80.JCName(r)));
#endif
                        return;


                case 0xC7, 0xCF, 0xD7, 0xDF, 0xE7, 0xEF, 0xF7, 0xFF:

                        var stack = Sp;
						stack -= 1
                        mem[stack] = (byte)(Pc >> 8);
						stack -= 1
                        mem[stack] = (byte)(Pc);
                        registers[SP] = (byte)(stack >> 8);
                        registers[SP + 1] = (byte)(stack);
                        registers[PC] = 0;
                        registers[PC + 1] = (byte)(mc & 0x38);
#if DEBUG
                        print(String(format: "RST 0x%4X\n", mc & 0x38));
#endif
                        Wait(17);
                        return;

                case 0xDB:

                        let port = Fetch() + (registers[A] << 8);
                        registers[A] = ports.ReadPort((ushort)(port));
#if DEBUG
                        print(String(format: "IN A, (0x%2X)\n", port));
#endif
                        Wait(11);
                        return;

                case 0xD3:

                        let port = Fetch() + (registers[A] << 8);
                        ports.WritePort((ushort)(port), registers[A]);
#if DEBUG
                        print(String(format: "OUT (0x%2X), A\n", port));
#endif
                        Wait(11);
                        return;
				default:
						break

            }

#if DEBUG
            print(String(format: "%2X: %2X %2X %2X\n", mc, hi, lo, r));
            //throw new InvalidOperationException("Invalid Opcode: "+mc.ToString("X2"));
#endif
            Halt = true;
        }

        private static func JCName(_ condition: byte) -> string
        {
            switch (condition)
            {
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
				default:
					break
            }
            return "";
        }

        private mutating func ParseCB(_ mode: byte = 0)
        {
            var d: sbyte = 0;
            if (mode != 0)
            {
                d = (sbyte)(Fetch());
            }
            if (Halt) {
				return;
			}
            let mc = Fetch();
            let hi = (byte)(mc >> 6);
            let lo = (byte)(mc & 0x07);
            let r = (byte)((mc >> 3) & 0x07);
            let useHL = lo == 6;
            let useIX = mode == 0xDD;
            let useIY = mode == 0xFD;
            var reg = useHL ? useIX ? mem[(ushort)(Ix + d)] : useIY ? mem[(ushort)(Iy + d)] : mem[Hl] : registers[lo];
#if DEBUG
            var debug_target: string;
            if (useHL) {
                if (useIX) {
					debug_target = "(IX{d:+0;-#})";
                } else {
					debug_target = useIY ? "(IY{d:+0;-#})" : "(HL)";
				}
            } else {
                debug_target = useIX ? "(IX{d:+0;-#}), {RName(lo)}" : useIY ? "(IY{d:+0;-#}), {RName(lo)}" : Z80.RName(lo);
			}
#endif
            switch (hi)
            {
                case 0:
                    var c: byte;
                    if ((r & 1) == 1)
                    {
                        c = (byte)(reg & 0x01);
                        reg >>= 1;
                    }
                    else
                    {
                        c = (byte)((reg & 0x80) >> 7);
                        reg <<= 1;
                    }
                    var f = registers[F];
                    switch (r)
                    {
                        case 0:

                                reg |= c;
#if DEBUG
                                print(String(format: "RLC {debug_target}\n"));
#endif
                                break;

                        case 1:

                                reg |= (byte)(c << 7);
#if DEBUG
                                print(String(format: "RRC {debug_target}\n"));
#endif
                                break;

                        case 2:

                                reg |= (byte)(f & (byte)(Fl.C.rawValue));
#if DEBUG
                                print(String(format: "RL {debug_target}\n"));
#endif
                                break;

                        case 3:

                                reg |= (byte)((f & (byte)(Fl.C.rawValue)) << 7);
#if DEBUG
                                print(String(format: "RR {debug_target}\n"));
#endif
                                break;

                        case 4:

#if DEBUG
                                print(String(format: "SLA {debug_target}\n"));
#endif
                                break;

                        case 5:

                                reg |= (byte)((reg & 0x40) << 1);
#if DEBUG
                                print(String(format: "SRA {debug_target}\n"));

#endif
                                break;

                        case 6:

                                reg |= 1;
#if DEBUG
                                print(String(format: "SLL {debug_target}\n"));
#endif
                                break;

                        case 7:

#if DEBUG
                                print(String(format: "SRL {debug_target}\n"));
#endif
                                break;

						default:
							break
                    }
                    f &= (byte)(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue | Fl.PV.rawValue | Fl.S.rawValue | Fl.Z.rawValue));
                    f |= (byte)(reg & (byte)(Fl.S.rawValue));
                    if (reg == 0) {
						f |= (byte)(Fl.Z.rawValue);
					}
                    if (Z80.Parity(reg)) {
						f |= (byte)(Fl.PV.rawValue);
					}
                    f |= c;
                    registers[F] = f;

                    break;
                case 1:

                        Bit(r, reg);
#if DEBUG
                        print(String(format: "BIT %d, {debug_target}\n", r));
#endif
                        Wait(useHL ? 12 : 8);
                        return;

                case 2:
                    reg &= (byte)(~(0x01 << r));
#if DEBUG
                    print(String(format: "RES %d, {debug_target}\n", r));
#endif
                    Wait(useHL ? 12 : 8);
                    break;
                case 3:
                    reg |= (byte)(0x01 << r);
#if DEBUG
                    print(String(format: "SET %d, {debug_target}\n", r));
#endif
                    Wait(useHL ? 12 : 8);
                    break;
				default:
					break
            }
            if (useHL)
            {
                if (useIX)
                {
                    mem[(ushort)(Ix + d)] = reg;
                    Wait(23);
                }
                else if (useIY)
                {
                    mem[(ushort)(Iy + d)] = reg;
                    Wait(23);
                }
                else
                {
                    mem[Hl] = reg;
                    Wait(15);
                }
            }
            else
            {
                if (useIX)
                {
                    mem[(ushort)(Ix + d)] = reg;
                    Wait(23);
                }
                else if (useIY)
                {
                    mem[(ushort)(Iy + d)] = reg;
                    Wait(23);
                }
                registers[lo] = reg;
                Wait(8);
            }
        }

        private mutating func Bit(_ bit: byte, _ value: byte)
        {
            var f = (byte)(registers[F] & (byte)(~(Fl.Z.rawValue | Fl.H.rawValue | Fl.N.rawValue)));
            if ((value & (0x01 << bit)) == 0) {
				f |= (byte)(Fl.Z.rawValue);
			}
            f |= (byte)(Fl.H.rawValue);
            registers[F] = f;
        }

        private mutating func AddHl(_ value: ushort)
        {
            let sum = Add(Hl, value);
            registers[H] = (byte)(sum >> 8);
            registers[L] = (byte)(sum & 0xFF);
        }

        private mutating func AddIx(_ value: ushort)
        {
            let sum = Add(Ix, value);
            registers[IX] = (byte)(sum >> 8);
            registers[IX + 1] = (byte)(sum & 0xFF);
        }

        private mutating func AddIy(_ value: ushort)
        {
            let sum = Add(Iy, value);
            registers[IY] = (byte)(sum >> 8);
            registers[IY + 1] = (byte)(sum & 0xFF);
        }

        private mutating func Add(_ value1: ushort, _ value2: ushort) -> ushort
        {
            let sum = value1 + value2;
            var f = (byte)(registers[F] & (byte)(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue)));
            if ((value1 & 0x0FFF) + (value2 & 0x0FFF) > 0x0FFF) {
                f |= (byte)(Fl.H.rawValue);
			}
            if (sum > 0xFFFF) {
                f |= (byte)(Fl.C.rawValue);
			}
            registers[F] = f;
            return (ushort)(sum);
        }

        private mutating func AdcHl(_ value: ushort)
        {
            let sum = Adc(Hl, value);
            registers[H] = (byte)(sum >> 8);
            registers[L] = (byte)(sum & 0xFF);
        }

        private mutating func Adc(_ value1: ushort, _ value2: ushort) -> ushort
        {
            let sum = value1 + value2 + (registers[F] & (byte)(Fl.C.rawValue));
            var f = (byte)(registers[F] & (byte)(~(Fl.S.rawValue | Fl.Z.rawValue | Fl.H.rawValue | Fl.PV.rawValue | Fl.N.rawValue | Fl.C.rawValue)));
            if ((short)(sum) < 0) {
                f |= (byte)(Fl.S.rawValue);
			}
            if (sum == 0) {
                f |= (byte)(Fl.Z.rawValue);
			}
            if ((value1 & 0x0FFF) + (value2 & 0x0FFF) + (byte)(Fl.C.rawValue) > 0x0FFF) {
                f |= (byte)(Fl.H.rawValue);
			}
            if (sum > 0x7FFF) {
                f |= (byte)(Fl.PV.rawValue);
			}
            if (sum > 0xFFFF) {
                f |= (byte)(Fl.C.rawValue);
			}
            registers[F] = f;
            return (ushort)(sum);
        }

        private mutating func SbcHl(_ value: ushort)
        {
            let sum = Sbc(Hl, value);
            registers[H] = (byte)(sum >> 8);
            registers[L] = (byte)(sum & 0xFF);
        }


        private mutating func Sbc(_ value1: ushort, _ value2: ushort) -> ushort
        {
            let diff = value1 - value2 - (registers[F] & (byte)(Fl.C.rawValue));
            var f = (byte)(registers[F] & (byte)(~(Fl.S.rawValue | Fl.Z.rawValue | Fl.H.rawValue | Fl.PV.rawValue | Fl.N.rawValue | Fl.C.rawValue)));
            if ((short)(diff) < 0) {
                f |= (byte)(Fl.S.rawValue);
			}
            if (diff == 0) {
                f |= (byte)(Fl.Z.rawValue);
			}
            if ((value1 & 0xFFF) < (value2 & 0xFFF) + (registers[F] & (byte)(Fl.C.rawValue))) {
                f |= (byte)(Fl.H.rawValue);
			}
            if (diff > short.MaxValue || diff < short.MinValue) {
                f |= (byte)(Fl.PV.rawValue);
			}
            if ((ushort)(diff) > value1) {
                f |= (byte)(Fl.C.rawValue);
			}
            registers[F] = f;
            return (ushort)(diff);
        }

        private mutating func ParseED()
        {
            if (Halt) {
				return;
			}
            let mc = Fetch();
            let r = (byte)((mc >> 3) & 0x07);

            switch (mc)
            {
                case 0x47:

                        // LD I, A
                        registers[I] = registers[A];
#if DEBUG
                        print("LD I, A");
#endif
                        Wait(9);
                        return;

                case 0x4F:

                        // LD R, A
                        registers[R] = registers[A];
#if DEBUG
                        print("LD R, A");
#endif
                        Wait(9);
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
                        let i = registers[I];
                        registers[A] = i;
                        var f = (byte)(registers[F] & (~(byte)(Fl.H.rawValue | Fl.PV.rawValue | Fl.N.rawValue | Fl.S.rawValue | Fl.Z.rawValue | Fl.PV.rawValue)));
                        if (i >= 0x80)
                        {
                            f |= (byte)(Fl.S.rawValue);
                        }
                        else if (i == 0x00)
                        {
                            f |= (byte)(Fl.Z.rawValue);
                        }
                        if (IFF2)
                        {
                            f |= (byte)(Fl.PV.rawValue);
                        }
                        registers[F] = f;
#if DEBUG
                        print("LD A, I");
#endif
                        Wait(9);
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
                        let reg = registers[R];
                        registers[A] = reg;
                        var f = (byte)(registers[F] & (~(byte)(Fl.H.rawValue | Fl.PV.rawValue | Fl.N.rawValue | Fl.S.rawValue | Fl.Z.rawValue | Fl.PV.rawValue)));
                        if (reg >= 0x80)
                        {
                            f |= (byte)(Fl.S.rawValue);
                        }
                        else if (reg == 0x00)
                        {
                            f |= (byte)(Fl.Z.rawValue);
                        }
                        if (IFF2)
                        {
                            f |= (byte)(Fl.PV.rawValue);
                        }
                        registers[F] = f;
#if DEBUG
                        print("LD A, R");
#endif
                        Wait(9);
                        return;

                case 0x4B:

                        // LD BC, (nn)
                        var addr = Fetch16();
                        registers[C] = mem[addr];
						addr += 1
                        registers[B] = mem[addr];
#if DEBUG
                        addr -= 1
						print(String(format: "LD BC, (0x%4X)\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x5B:

                        // LD DE, (nn)
                        var addr = Fetch16();
                        registers[E] = mem[addr];
						addr += 1
                        registers[D] = mem[addr];
#if DEBUG
                        addr -= 1
						print(String(format: "LD DE, (0x%4X)\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x6B:

                        // LD HL, (nn)
                        var addr = Fetch16();
                        registers[L] = mem[addr];
						addr += 1
                        registers[H] = mem[addr];
#if DEBUG
                        addr -= 1
						print(String(format: "LD HL, (0x%4X)\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x7B:

                        // LD SP, (nn)
                        var addr = Fetch16();
                        registers[SP + 1] = mem[addr];
						addr += 1
                        registers[SP] = mem[addr];
#if DEBUG
                        addr -= 1
						print(String(format: "LD SP, (0x%4X)\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x43:

                        // LD (nn), BC
                        var addr = Fetch16();
                        mem[addr] = registers[C];
						addr += 1
                        mem[addr] = registers[B];
#if DEBUG
                        addr -= 1
						print(String(format: "LD (0x%4X), BC\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x53:

                        // LD (nn), DE
                        var addr = Fetch16();
                        mem[addr] = registers[E];
						addr += 1
                        mem[addr] = registers[D];
#if DEBUG
                        addr -= 1
						print(String(format: "LD (0x%4X), DE\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x63:

                        // LD (nn), HL
                        var addr = Fetch16();
                        mem[addr] = registers[L];
						addr += 1
                        mem[addr] = registers[H];
#if DEBUG
                        addr -= 1
						print(String(format: "LD (0x%4X), HL\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x73:

                        // LD (nn), SP
                        var addr = Fetch16();
                        mem[addr] = registers[SP + 1];
						addr += 1
                        mem[addr] = registers[SP];
#if DEBUG
                        addr -= 1
						print(String(format: "LD (0x%4X), SP\n", addr));
#endif
                        Wait(20);
                        return;

                case 0xA0:

                        // LDI
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de += 1
                        hl += 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[D] = (byte)(de >> 8);
                        registers[E] = (byte)(de & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        var f = (byte)(registers[F] & 0xE9);
                        if (bc != 0) {
							f = (byte)(f | 0x04);
                        }
						registers[F] = f;
#if DEBUG
                        print("LDI");
#endif
                        Wait(16);
                        return;

                case 0xB0:

                        // LDIR
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de += 1
                        hl += 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[D] = (byte)(de >> 8);
                        registers[E] = (byte)(de & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        registers[F] = (byte)(registers[F] & 0xE9);
                        if (bc != 0)
                        {
                            var pc = (ushort)((registers[PC] << 8) + registers[PC + 1]);
                            // jumps back to itself
                            pc -= 2;
                            registers[PC] = (byte)(pc >> 8);
                            registers[PC + 1] = (byte)(pc & 0xFF);
                            Wait(21);
                            return;
                        }
#if DEBUG
                        print("LDIR");
#endif
                        Wait(16);
                        return;

                case 0xA8:

                        // LDD
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de -= 1
                        hl -= 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[D] = (byte)(de >> 8);
                        registers[E] = (byte)(de & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        var f = (byte)(registers[F] & 0xE9);
                        if (bc != 0) {
							f = (byte)(f | 0x04);
                        }
						registers[F] = f;
#if DEBUG
                        print("LDD");
#endif
                        Wait(16);
                        return;

                case 0xB8:

                        // LDDR
                        var bc = Bc;
                        var de = De;
                        var hl = Hl;

                        mem[de] = mem[hl];
                        de -= 1
                        hl -= 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[D] = (byte)(de >> 8);
                        registers[E] = (byte)(de & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        registers[F] = (byte)(registers[F] & 0xE9);
                        if (bc != 0)
                        {
                            var pc = (ushort)((registers[PC] << 8) + registers[PC + 1]);
                            // jumps back to itself
                            pc -= 2;
                            registers[PC] = (byte)(pc >> 8);
                            registers[PC + 1] = (byte)(pc & 0xFF);
                            Wait(21);
                            return;
                        }
#if DEBUG
                        print("LDDR");
#endif
                        Wait(16);
                        return;


                case 0xA1:

                        // CPI
                        var bc = Bc;
                        var hl = Hl;

                        let a = registers[A];
                        let b = mem[hl];
                        hl += 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        var f = (byte)(registers[F] & 0x2A);
                        if (a < b) {
							f = (byte)(f | 0x80);
                        }
						if (a == b) {
							f = (byte)(f | 0x40);
                        }
						if ((a & 8) < (b & 8)) {
							f = (byte)(f | 0x10);
                        }
						if (bc != 0) {
							f = (byte)(f | 0x04);
                        }
						registers[F] = (byte)(f | 0x02);
#if DEBUG
                        print("CPI");
#endif
                        Wait(16);
                        return;


                case 0xB1:

                        // CPIR
                        var bc = Bc;
                        var hl = Hl;

                        let a = registers[A];
                        let b = mem[hl];
                        hl += 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        if (a == b || bc == 0)
                        {
                            var f = (byte)(registers[F] & 0x2A);
                            if (a < b) {
								f = (byte)(f | 0x80);
                            }
							if (a == b) {
								f = (byte)(f | 0x40);
                            }
							if ((a & 8) < (b & 8)) {
								f = (byte)(f | 0x10);
                            }
							if (bc != 0) {
								f = (byte)(f | 0x04);
                            }
							registers[F] = (byte)(f | 0x02);
#if DEBUG
                            print("CPIR");
#endif
                            Wait(16);
                            return;
                        }

                        var pc = (ushort)((registers[PC] << 8) + registers[PC + 1]);
                        // jumps back to itself
                        pc -= 2;
                        registers[PC] = (byte)(pc >> 8);
                        registers[PC + 1] = (byte)(pc & 0xFF);
                        Wait(21);
                        return;


                case 0xA9:

                        // CPD
                        var bc = Bc;
                        var hl = Hl;

                        let a = registers[A];
                        let b = mem[hl];
                        hl -= 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        var f = (byte)(registers[F] & 0x2A);
                        if (a < b) {
							f = (byte)(f | 0x80);
                        }
						if (a == b) {
							f = (byte)(f | 0x40);
                        }
						if ((a & 8) < (b & 8)) {
							f = (byte)(f | 0x10);
                        }
						if (bc != 0) {
							f = (byte)(f | 0x04);
                        }
						registers[F] = (byte)(f | 0x02);
#if DEBUG
                        print("CPD");
#endif
                        Wait(16);
                        return;


                case 0xB9:

                        // CPDR
                        var bc = Bc;
                        var hl = Hl;

                        let a = registers[A];
                        let b = mem[hl];
                        hl -= 1
                        bc -= 1

                        registers[B] = (byte)(bc >> 8);
                        registers[C] = (byte)(bc & 0xFF);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl & 0xFF);

                        if (a == b || bc == 0)
                        {
                            var f = (byte)(registers[F] & 0x2A);
                            if (a < b) {
								f = (byte)(f | 0x80);
							}
							if (a == b) {
								f = (byte)(f | 0x40);
                            }
							if ((a & 8) < (b & 8)) {
								f = (byte)(f | 0x10);
                            }
							if (bc != 0) {
								f = (byte)(f | 0x04);
                            }
							registers[F] = (byte)(f | 0x02);
#if DEBUG
                            print("CPDR");
#endif
                            Wait(21);
                            return;
                        }

                        var pc = (ushort)((registers[PC] << 8) + registers[PC + 1]);
                        // jumps back to itself
                        pc -= 2;
                        registers[PC] = (byte)(pc >> 8);
                        registers[PC + 1] = (byte)(pc & 0xFF);
                        Wait(21);
                        return;

                case 0x44, 0x54, 0x64, 0x74, 0x4C, 0x5C, 0x6C, 0x7C:

                        // NEG
                        let a = registers[A];
                        let diff = -(sbyte)(a);
                        registers[A] = (byte)(diff);

                        var f = (byte)(registers[F] & 0x28);
                        if (((byte)(diff) & 0x80) > 0) {
							f |= (byte)(Fl.S.rawValue);
                        }
						if (diff == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						if ((a & 0xF) != 0) {
							f |= (byte)(Fl.H.rawValue);
                        }
						if (a == 0x80) {
							f |= (byte)(Fl.PV.rawValue);
                        }
						f |= (byte)(Fl.N.rawValue);
                        if (diff != 0) {
							f |= (byte)(Fl.C.rawValue);
                        }
						registers[F] = f;


#if DEBUG
                        print("NEG");
#endif
                        Wait(8);
                        return;

                case 0x46, 0x66:

                        // IM 0
                        interruptMode = 0;
#if DEBUG
                        print("IM 0");
#endif
                        Wait(8);
                        return;

                case 0x56, 0x76:

                        // IM 1
                        interruptMode = 1;
#if DEBUG
                        print("IM 1");
#endif
                        Wait(8);
                        return;

                case 0x5E, 0x7E:

                        // IM 2
                        interruptMode = 2;
#if DEBUG
                        print("IM 2");
#endif
                        Wait(8);
                        return;

                case 0x4A:

                        AdcHl(Bc);

#if DEBUG
                        print("ADC HL, BC");
#endif
                        Wait(15);
                        return;

                case 0x5A:

                        AdcHl(De);
#if DEBUG
                        print("ADC HL, DE");
#endif
                        Wait(15);
                        return;

                case 0x6A:

                        AdcHl(Hl);
#if DEBUG
                        print("ADC HL, HL");
#endif
                        Wait(15);
                        return;

                case 0x7A:

                        AdcHl(Sp);
#if DEBUG
                        print("ADC HL, SP");
#endif
                        Wait(15);
                        return;

                case 0x42:

                        SbcHl(Bc);

#if DEBUG
                        print("SBC HL, BC");
#endif
                        Wait(15);
                        return;

                case 0x52:

                        SbcHl(De);
#if DEBUG
                        print("SBC HL, DE");
#endif
                        Wait(15);
                        return;

                case 0x62:

                        SbcHl(Hl);
#if DEBUG
                        print("SBC HL, HL");
#endif
                        Wait(15);
                        return;

                case 0x72:

                        SbcHl(Sp);
#if DEBUG
                        print("SBC HL, SP");
#endif
                        Wait(15);
                        return;


                case 0x6F:

                        var a = registers[A];
                        let b = mem[Hl];
                        mem[Hl] = (byte)((b << 4) | (a & 0x0F));
                        a = (byte)((a & 0xF0) | (b >> 4));
                        registers[A] = a;
                        var f = (byte)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) {
							f |= (byte)(Fl.S.rawValue);
                        }
						if (a == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						if (Z80.Parity(a)) {
							f |= (byte)(Fl.PV.rawValue);
                        }
						registers[F] = f;
#if DEBUG
                        print("RLD");
#endif
                        Wait(18);
                        return;

                case 0x67:

                        var a = registers[A];
                        let b = mem[Hl];
                        mem[Hl] = (byte)((b >> 4) | (a << 4));
                        a = (byte)((a & 0xF0) | (b & 0x0F));
                        registers[A] = a;
                        var f = (byte)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) {
							f |= (byte)(Fl.S.rawValue);
                        }
						if (a == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						if (Z80.Parity(a)) {
							f |= (byte)(Fl.PV.rawValue);
                        }
						registers[F] = f;
#if DEBUG
                        print("RRD");
#endif
                        Wait(18);
                        return;

                case 0x45, 0x4D, 0x55, 0x5D, 0x65, 0x6D, 0x75, 0x7D:

                        var stack = Sp;
                        registers[PC + 1] = mem[stack];
						stack += 1
                        registers[PC] = mem[stack];
						stack += 1
                        registers[SP] = (byte)(stack >> 8);
                        registers[SP + 1] = (byte)(stack);
                        IFF1 = IFF2;
#if DEBUG
                        if (mc == 0x4D) {
                            print("RETN");
                        } else {
                            print("RETI");
						}
#endif
                        Wait(10);
                        return;


                case 0x77, 0x7F:

#if DEBUG
                        print("NOP");
#endif
                        Wait(8);
                        return;

                case 0x40, 0x48, 0x50, 0x58, 0x60, 0x68, 0x78:

                        let a = (byte)(ports.ReadPort(Bc));
                        registers[r] = a;
                        var f = (byte)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) {
							f |= (byte)(Fl.S.rawValue);
                        }
						if (a == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						if (Z80.Parity(a)) {
							f |= (byte)(Fl.PV.rawValue);
                        }
						registers[F] = f;
#if DEBUG
                        print(String(format: "IN %s, (BC)\n", Z80.RName(r)));
#endif
                        Wait(8);
                        return;

                case 0xA2:

                        let a = (byte)(ports.ReadPort(Bc));
                        var hl = Hl;
                        mem[hl] = a;
						hl += 1
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        var f = (byte)(registers[F] & (byte)(~(Fl.N.rawValue | Fl.Z.rawValue)));
                        if (b == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						f |= (byte)(Fl.N.rawValue);
                        registers[F] = f;

#if DEBUG
                        print("INI");
#endif
                        Wait(16);
                        return;

                case 0xB2:

                        let a = (byte)(ports.ReadPort(Bc));
                        var hl = Hl;
                        mem[hl] = a;
						hl += 1
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0)
                        {
                            let pc = Pc - 2;
                            registers[PC] = (byte)(pc >> 8);
                            registers[PC + 1] = (byte)(pc);
#if DEBUG
                            print("(INIR)");
#endif
                            Wait(21);
                        }
                        else
                        {
                            registers[F] = (byte)(registers[F] | (byte)(Fl.N.rawValue | Fl.Z.rawValue));
#if DEBUG
                            print("INIR");
#endif
                            Wait(16);
                        }
                        return;

                case 0xAA:

                        let a = (byte)(ports.ReadPort(Bc));
                        var hl = Hl;
                        mem[hl] = a;
						hl -= 1
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        var f = (byte)(registers[F] & (byte)(~(Fl.N.rawValue | Fl.Z.rawValue)));
                        if (b == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						f |= (byte)(Fl.N.rawValue);
                        registers[F] = f;
#if DEBUG
                        print("IND");
#endif
                        Wait(16);
                        return;

                case 0xBA:

                        let a = (byte)(ports.ReadPort(Bc));
                        var hl = Hl;
                        mem[hl] = a;
						hl -= 1
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0)
                        {
                            let pc = Pc - 2;
                            registers[PC] = (byte)(pc >> 8);
                            registers[PC + 1] = (byte)(pc);
#if DEBUG
                            print("(INDR)");
#endif
                            Wait(21);
                        }
                        else
                        {
                            registers[F] = (byte)(registers[F] | (byte)(Fl.N.rawValue | Fl.Z.rawValue));
#if DEBUG
                            print("INDR");
#endif
                            Wait(16);
                        }
                        return;

                case 0x41, 0x49, 0x51, 0x59, 0x61, 0x69, 0x79:

                        let a = registers[r];
                        ports.WritePort(Bc, a);
                        var f = (byte)(registers[F] & 0x29);
                        if ((a & 0x80) > 0) {
							f |= (byte)(Fl.S.rawValue);
                        }
						if (a == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						if (Z80.Parity(a)) {
							f |= (byte)(Fl.PV.rawValue);
                        }
						registers[F] = f;
#if DEBUG
                        print(String(format: "OUT (BC), %s\n", Z80.RName(r)));
#endif
                        Wait(8);
                        return;

                case 0xA3:

                        var hl = Hl;
                        let a = mem[hl];
						hl += 1
                        ports.WritePort(Bc, a);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        var f = (byte)(registers[F] & (byte)(~(Fl.N.rawValue | Fl.Z.rawValue)));
                        if (b == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						f |= (byte)(Fl.N.rawValue);
                        registers[F] = f;

#if DEBUG
                        print("OUTI");
#endif
                        Wait(16);
                        return;

                case 0xB3:

                        var hl = Hl;
                        let a = mem[hl];
						hl += 1
                        ports.WritePort(Bc, a);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0)
                        {
                            let pc = Pc - 2;
                            registers[PC] = (byte)(pc >> 8);
                            registers[PC + 1] = (byte)(pc);
#if DEBUG
                            print("(OUTIR)");
#endif
                            Wait(21);
                        }
                        else
                        {
                            registers[F] = (byte)(registers[F] | (byte)(Fl.N.rawValue | Fl.Z.rawValue));
#if DEBUG
                            print("OUTIR");
#endif
                            Wait(16);
                        }
                        return;

                case 0xAB:

                        var hl = Hl;
                        let a = mem[hl];
						hl -= 1
                        ports.WritePort(Bc, a);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        var f = (byte)(registers[F] & (byte)(~(Fl.N.rawValue | Fl.Z.rawValue)));
                        if (b == 0) {
							f |= (byte)(Fl.Z.rawValue);
                        }
						f |= (byte)(Fl.N.rawValue);
                        registers[F] = f;
#if DEBUG
                        print("OUTD");
#endif
                        Wait(16);
                        return;

                case 0xBB:

                        var hl = Hl;
                        let a = mem[hl];
						hl -= 1
                        ports.WritePort(Bc, a);
                        registers[H] = (byte)(hl >> 8);
                        registers[L] = (byte)(hl);
                        let b = (byte)(registers[B] - 1);
                        registers[B] = b;
                        if (b != 0)
                        {
                            let pc = Pc - 2;
                            registers[PC] = (byte)(pc >> 8);
                            registers[PC + 1] = (byte)(pc);
#if DEBUG
                            print("(OUTDR)");
#endif
                            Wait(21);
                        }
                        else
                        {
                            registers[F] = (byte)(registers[F] | (byte)(Fl.N.rawValue | Fl.Z.rawValue));
#if DEBUG
                            print("OUTDR");
#endif
                            Wait(16);
                        }
                        return;
				default:
						break

            }
#if DEBUG
            print(String(format: "ED %2X: %2X\n", mc, r));
#endif
            Halt = true;
        }

        private mutating func ParseDD()
        {
            if (Halt) {
				return;
			}
            let mc = Fetch();
            let hi = (byte)(mc >> 6);
            let lo = (byte)(mc & 0x07);
            let mid = (byte)((mc >> 3) & 0x07);

            switch (mc)
            {
                case 0xCB:

                        ParseCB(0xDD);
                        return;

                case 0x21:

                        // LD IX, nn
                        registers[IX + 1] = Fetch();
                        registers[IX] = Fetch();
#if DEBUG
                        print(String(format: "LD IX, 0x%4X\n", Ix));
#endif
                        Wait(14);
                        return;

                case 0x46, 0x4e, 0x56, 0x5e, 0x66, 0x6e, 0x7e:

                        // LD r, (IX+d)
                        let d = (sbyte)(Fetch());
                        registers[mid] = mem[(ushort)(Ix + d)];
#if DEBUG
                        print(String(format: "LD %s, (IX+%d)\n", Z80.RName(mid), d));
#endif
                        Wait(19);
                        return;

                case 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77:

                        // LD (IX+d), r
                        let d = (sbyte)(Fetch());
                        mem[(ushort)(Ix + d)] = registers[lo];
#if DEBUG
                        print(String(format: "LD (IX+%d), %s\n", d, Z80.RName(lo)));
#endif
                        Wait(19);
                        return;

                case 0x36:

                        // LD (IX+d), n
                        let d = (sbyte)(Fetch());
                        let n = Fetch();
                        mem[(ushort)(Ix + d)] = n;
#if DEBUG
                        print(String(format: "LD (IX+%d), %d\n", d, n));
#endif
                        Wait(19);
                        return;

                case 0x2A:

                        // LD IX, (nn)
                        var addr = Fetch16();
                        registers[IX + 1] = mem[addr];
						addr += 1
                        registers[IX] = mem[addr];
#if DEBUG
                        print(String(format: "LD IX, (0x%4X)\n", addr));
#endif
                        Wait(20);
                        return;

                case 0x22:

                        // LD (nn), IX
                        var addr = Fetch16();
                        mem[addr] = registers[IX + 1];
						addr += 1
                        mem[addr] = registers[IX];
#if DEBUG
                        print(String(format: "LD (0x%4X), IX\n", addr));
#endif
                        Wait(20);
                        return;


                case 0xF9:

                        // LD SP, IX
                        registers[SP] = registers[IX];
                        registers[SP + 1] = registers[IX + 1];
#if DEBUG
                        print("LD SP, IX");
#endif
                        Wait(10);
                        return;

                case 0xE5:

                        // PUSH IX
                        var addr = Sp;
                        addr -= 1
                        mem[addr] = registers[IX];
                        addr -= 1
                        mem[addr] = registers[IX + 1];
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("PUSH IX");
#endif
                        Wait(15);
                        return;

                case 0xE1:

                        // POP IX
                        var addr = Sp;
                        registers[IX + 1] = mem[addr];
						addr += 1
                        registers[IX] = mem[addr];
						addr += 1
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("POP IX");
#endif
                        Wait(14);
                        return;

                case 0xE3:

                        // EX (SP), IX
                        let h = registers[IX];
                        let l = registers[IX + 1];
                        var addr = Sp;
                        registers[IX + 1] = mem[addr];
						addr += 1
                        registers[IX] = mem[addr];
                        mem[addr] = h;
						addr -= 1
                        mem[addr] = l;

#if DEBUG
                        print("EX (SP), IX");
#endif
                        Wait(24);
                        return;


                case 0x86:

                        // ADD A, (IX+d)
                        let d = (sbyte)(Fetch());

                        Add(mem[(ushort)(Ix + d)]);
#if DEBUG
                        print(String(format: "ADD A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x8E:

                        // ADC A, (IX+d)
                        let d = (sbyte)(Fetch());
                        // let a = registers[A];
                        Adc(mem[(ushort)(Ix + d)]);
#if DEBUG
                        print(String(format: "ADC A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x96:

                        // SUB A, (IX+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Ix + d)];

                        Sub(b);
#if DEBUG
                        print(String(format: "SUB A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x9E:

                        // SBC A, (IX+d)
                        let d = (sbyte)(Fetch());

                        Sbc(mem[(ushort)(Ix + d)]);
#if DEBUG
                        print(String(format: "SBC A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xA6:

                        // AND A, (IX+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Ix + d)];

                        And(b);
#if DEBUG
                        print(String(format: "AND A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xB6:

                        // OR A, (IX+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Ix + d)];

                        Or(b);
#if DEBUG
                        print(String(format: "OR A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xAE:

                        // OR A, (IX+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Ix + d)];

                        Xor(b);
#if DEBUG
                        print(String(format: "XOR A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xBE:

                        // CP A, (IX+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Ix + d)];

                        Cmp(b);
#if DEBUG
                        print(String(format: "CP A, (IX+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x34:

                        // INC (IX+d)
                        let d = (sbyte)(Fetch());
                        mem[(ushort)(Ix + d)] = Inc(mem[(ushort)(Ix + d)]);
#if DEBUG
                        print(String(format: "INC (IX+%d)\n", d));
#endif
                        Wait(7);
                        return;

                case 0x35:

                        // DEC (IX+d)
                        let d = (sbyte)(Fetch());
                        mem[(ushort)(Ix + d)] = Dec(mem[(ushort)(Ix + d)]);
#if DEBUG
                        print(String(format: "DEC (IX+%d)\n", d));
#endif
                        Wait(7);
                        return;

                case 0x09:

                        AddIx(Bc);
#if DEBUG
                        print("ADD IX, BC");
#endif
                        Wait(4);
                        return;

                case 0x19:

                        AddIx(De);
#if DEBUG
                        print("ADD IX, DE");
#endif
                        Wait(4);
                        return;

                case 0x29:

                        AddIx(Ix);
#if DEBUG
                        print("ADD IX, IX");
#endif
                        Wait(4);
                        return;

                case 0x39:

                        AddIx(Sp);
#if DEBUG
                        print("ADD IX, SP");
#endif
                        Wait(4);
                        return;

                case 0x23:

                        let val = Ix + 1;
                        registers[IX] = (byte)(val >> 8);
                        registers[IX + 1] = (byte)(val & 0xFF);
#if DEBUG
                        print("INC IX");
#endif
                        Wait(4);
                        return;

                case 0x2B:

                        let val = Ix - 1;
                        registers[IX] = (byte)(val >> 8);
                        registers[IX + 1] = (byte)(val & 0xFF);
#if DEBUG
                        print("DEC IX");
#endif
                        Wait(4);
                        return;

                case 0xE9:

                        let addr = Ix;
                        registers[PC] = (byte)(addr >> 8);
                        registers[PC + 1] = (byte)(addr);
#if DEBUG
                        print("JP IX");
#endif
                        Wait(8);
                        return;
				default:
						break


            }
#if DEBUG
            print(String(format: "DD %2X: %2X %2X %2X\n", mc, hi, lo, mid));
#endif
            Halt = true;
        }

        private mutating func ParseFD()
        {
            if (Halt) {
				return;
			}
            let mc = Fetch();
            let hi = (byte)(mc >> 6);
            let lo = (byte)(mc & 0x07);
            let r = (byte)((mc >> 3) & 0x07);

            switch (mc)
            {
                case 0xCB:

                        ParseCB(0xFD);
                        return;

                case 0x21:

                        // LD IY, nn
                        registers[IY + 1] = Fetch();
                        registers[IY] = Fetch();
#if DEBUG
                        print(String(format: "LD IY, 0x%4X\n", Iy));
#endif
                        Wait(14);
                        return;


                case 0x46, 0x4e, 0x56, 0x5e, 0x66, 0x6e, 0x7e:

                        // LD r, (IY+d)
                        let d = (sbyte)(Fetch());
                        registers[r] = mem[(ushort)(Iy + d)];
#if DEBUG
                        print(String(format: "LD %s, (IY+%d)\n", Z80.RName(r), d));
#endif
                        Wait(19);
                        return;

                case 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77:

                        // LD (IY+d), r
                        let d = (sbyte)(Fetch());
                        mem[(ushort)(Iy + d)] = registers[lo];
#if DEBUG
                        print(String(format: "LD (IY+%d), %s\n", d, Z80.RName(lo)));
#endif
                        Wait(19);
                        return;

                case 0x36:

                        // LD (IY+d), n
                        let d = (sbyte)(Fetch());
                        let n = Fetch();
                        mem[(ushort)(Iy + d)] = n;
#if DEBUG
                        print(String(format: "LD (IY+%d), %d\n", d, n));
#endif
                        Wait(19);
                        return;

                case 0x2A:

                        // LD IY, (nn)
                        var addr = Fetch16();
                        registers[IY + 1] = mem[addr];
						addr += 1
                        registers[IY] = mem[addr];
#if DEBUG
                        addr -= 1
						print(String(format: "LD IY, (0x%4X)\n", addr));
#endif
                        Wait(20);
                        return;


                case 0x22:

                        // LD (nn), IY
                        var addr = Fetch16();
                        mem[addr] = registers[IY + 1];
						addr += 1
                        mem[addr] = registers[IY];
#if DEBUG
                        addr -= 1
						print(String(format: "LD (0x%4X), IY", addr));
#endif
                        Wait(20);
                        return;

                case 0xF9:

                        // LD SP, IY
                        registers[SP] = registers[IY];
                        registers[SP + 1] = registers[IY + 1];
#if DEBUG
                        print("LD SP, IY");
#endif
                        Wait(10);
                        return;

                case 0xE5:

                        // PUSH IY
                        var addr = Sp;
						addr -= 1
                        mem[addr] = registers[IY];
						addr -= 1
                        mem[addr] = registers[IY + 1];
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("PUSH IY");
#endif
                        Wait(15);
                        return;

                case 0xE1:

                        // POP IY
                        var addr = Sp;
                        registers[IY + 1] = mem[addr];
						addr += 1
                        registers[IY] = mem[addr];
						addr += 1
                        registers[SP + 1] = (byte)(addr & 0xFF);
                        registers[SP] = (byte)(addr >> 8);
#if DEBUG
                        print("POP IY");
#endif
                        Wait(14);
                        return;

                case 0xE3:

                        // EX (SP), IY
                        let h = registers[IY];
                        let l = registers[IY + 1];
                        var addr = Sp;
                        registers[IY + 1] = mem[addr];
                        mem[addr] = l;
						addr += 1
                        registers[IY] = mem[addr];
                        mem[addr] = h;

#if DEBUG
                        print("EX (SP), IY");
#endif
                        Wait(24);
                        return;

                case 0x86:

                        // ADD A, (IY+d)
                        let d = (sbyte)(Fetch());

                        Add(mem[(ushort)(Iy + d)]);
#if DEBUG
                        print(String(format: "ADD A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x8E:

                        // ADC A, (IY+d)
                        let d = (sbyte)(Fetch());
                        // let a = registers[A];
                        Adc(mem[(ushort)(Iy + d)]);

#if DEBUG
                        print(String(format: "ADC A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x96:

                        // SUB A, (IY+d)
                        let d = (sbyte)(Fetch());

                        Sub(mem[(ushort)(Iy + d)]);
#if DEBUG
                        print(String(format: "SUB A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x9E:

                        // SBC A, (IY+d)
                        let d = (sbyte)(Fetch());

                        Sbc(mem[(ushort)(Iy + d)]);
#if DEBUG
                        print(String(format: "SBC A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xA6:

                        // AND A, (IY+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Iy + d)];

                        And(b);
#if DEBUG
                        print(String(format: "AND A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xB6:

                        // OR A, (IY+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Iy + d)];

                        Or(b);
#if DEBUG
                        print(String(format: "OR A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xAE:

                        // XOR A, (IY+d)
                        let d = (sbyte)(Fetch());
                        let b = mem[(ushort)(Iy + d)];

                        Xor(b);
#if DEBUG
                        print(String(format: "XOR A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0xBE:

                        // CP A, (IY+d)
                        let d = (sbyte)(Fetch());

                        Cmp(mem[(ushort)(Iy + d)]);
#if DEBUG
                        print(String(format: "CP A, (IY+%d)\n", d));
#endif
                        Wait(19);
                        return;

                case 0x34:

                        // INC (IY+d)
                        let d = (sbyte)(Fetch());
                        mem[(ushort)(Iy + d)] = Inc(mem[(ushort)(Iy + d)]);
#if DEBUG
                        print(String(format: "INC (IY+%d)\n", d));
#endif
                        Wait(7);
                        return;

                case 0x35:

                        // DEC (IY+d)
                        let d = (sbyte)(Fetch());
                        mem[(ushort)(Iy + d)] = Dec(mem[(ushort)(Iy + d)]);
#if DEBUG
                        print(String(format: "DEC (IY+%d)\n", d));
#endif
                        Wait(7);
                        return;

                case 0x09:

                        AddIy(Bc);
#if DEBUG
                        print("ADD IY, BC");
#endif
                        Wait(4);
                        return;

                case 0x19:

                        AddIy(De);
#if DEBUG
                        print("ADD IY, DE");
#endif
                        Wait(4);
                        return;

                case 0x29:

                        AddIy(Iy);
#if DEBUG
                        print("ADD IY, IY");
#endif
                        Wait(4);
                        return;

                case 0x39:

                        AddIy(Sp);
#if DEBUG
                        print("ADD IY, SP");
#endif
                        Wait(4);
                        return;

                case 0x23:

                        let val = Iy + 1;
                        registers[IY] = (byte)(val >> 8);
                        registers[IY + 1] = (byte)(val & 0xFF);
#if DEBUG
                        print("INC IY");
#endif
                        Wait(4);
                        return;

                case 0x2B:

                        let val = Iy - 1;
                        registers[IY] = (byte)(val >> 8);
                        registers[IY + 1] = (byte)(val & 0xFF);
#if DEBUG
                        print("DEC IY");
#endif
                        Wait(4);
                        return;

                case 0xE9:

                        let addr = Iy;
                        registers[PC] = (byte)(addr >> 8);
                        registers[PC + 1] = (byte)(addr);
#if DEBUG
                        print("JP IY");
#endif
                        Wait(8);
                        return;
				default:
						break


            }
#if DEBUG
            print(String(format: "FD %2X: %2X %2X %2X\n", mc, hi, lo, r));
#endif
            Halt = true;
        }

        private mutating func Add(_ b: byte)
        {
            let a = registers[A];
            let sum = a + b;
            registers[A] = (byte)(sum);
            var f = (byte)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f |= (byte)(Fl.S.rawValue);
			}
            if ((byte)(sum) == 0) {
                f |= (byte)(Fl.Z.rawValue);
			}
            if ((a & 0xF + b & 0xF) > 0xF) {
                f |= (byte)(Fl.H.rawValue);
			}
            if ((a >= 0x80 && b >= 0x80 && (sbyte)(sum) > 0) || (a < 0x80 && b < 0x80 && (sbyte)(sum) < 0)) {
                f |= (byte)(Fl.PV.rawValue);
			}
            if (sum > 0xFF) {
                f |= (byte)(Fl.C.rawValue);
			}
            registers[F] = f;
        }

        private mutating func Adc(_ b: byte)
        {
            let a = registers[A];
            let c = (byte)(registers[F] & (byte)(Fl.C.rawValue));
            let sum = a + b + c;
            registers[A] = (byte)(sum);
            var f = (byte)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f |= (byte)(Fl.S.rawValue);
			}
            if ((byte)(sum) == 0) {
                f |= (byte)(Fl.Z.rawValue);
			}
            if ((a & 0xF + b & 0xF) > 0xF) {
                f |= (byte)(Fl.H.rawValue);
			}
            if ((a >= 0x80 && b >= 0x80 && (sbyte)(sum) > 0) || (a < 0x80 && b < 0x80 && (sbyte)(sum) < 0)) {
                f |= (byte)(Fl.PV.rawValue);
			}
            f = (byte)(f & ~(byte)(Fl.N.rawValue));
            if (sum > 0xFF) {
				f |= (byte)(Fl.C.rawValue);
			}
            registers[F] = f;
        }

        private mutating func Sub(_ b: byte)
        {
            let a = registers[A];
            let diff = a - b;
            registers[A] = (byte)(diff);
            var f = (byte)(registers[F] & 0x28);
            if ((diff & 0x80) > 0) {
                f |= (byte)(Fl.S.rawValue);
			}
            if (diff == 0) {
                f |= (byte)(Fl.Z.rawValue);
			}
            if ((a & 0xF) < (b & 0xF)) {
                f |= (byte)(Fl.H.rawValue);
			}
            if ((a >= 0x80 && b >= 0x80 && (sbyte)(diff) > 0) || (a < 0x80 && b < 0x80 && (sbyte)(diff) < 0)) {
                f |= (byte)(Fl.PV.rawValue);
			}
            f |= (byte)(Fl.N.rawValue);
            if ((sbyte)(diff) < 0) {
                f |= (byte)(Fl.C.rawValue);
			}
            registers[F] = f;
        }

        private mutating func Sbc(_ b: byte)
        {
            let a = registers[A];
            let c = (byte)(registers[F] & 0x01);
            let diff = a - b - c;
            registers[A] = (byte)(diff);
            var f = (byte)(registers[F] & 0x28);
            if ((diff & 0x80) > 0) {
				f |= (byte)(Fl.S.rawValue);
			}
            if (diff == 0) {
				f |= (byte)(Fl.Z.rawValue);
			}
            if ((a & 0xF) < (b & 0xF) + c) {
				f |= (byte)(Fl.H.rawValue);
			}
            if ((a >= 0x80 && b >= 0x80 && (sbyte)(diff) > 0) || (a < 0x80 && b < 0x80 && (sbyte)(diff) < 0)) {
                f |= (byte)(Fl.PV.rawValue);
			}
            f |= (byte)(Fl.N.rawValue);
            if (diff > 0xFF) {
				f |= (byte)(Fl.C.rawValue);
			}
            registers[F] = f;
        }

        private mutating func And(_ b: byte)
        {
            let a = registers[A];
            let res = (byte)(a & b);
            registers[A] = res;
            var f = (byte)(registers[F] & 0x28);
            if ((res & 0x80) > 0) {
				f |= (byte)(Fl.S.rawValue);
			}
            if (res == 0) {
				f |= (byte)(Fl.Z.rawValue);
			}
            f |= (byte)(Fl.H.rawValue);
            if (Z80.Parity(res)) {
				f |= (byte)(Fl.PV.rawValue);
			}
            registers[F] = f;
        }

        private mutating func Or(_ b: byte)
        {
            let a = registers[A];
            let res = (byte)(a | b);
            registers[A] = res;
            var f = (byte)(registers[F] & 0x28);
            if ((res & 0x80) > 0) {
                f |= (byte)(Fl.S.rawValue);
			}
            if (res == 0) {
                f |= (byte)(Fl.Z.rawValue);
			}
            if (Z80.Parity(res)) {
                f |= (byte)(Fl.PV.rawValue);
			}
             registers[F] = f;
        }

        private mutating func Xor(_ b: byte)
        {
            let a = registers[A];
            let res = (byte)(a ^ b);
            registers[A] = res;
            var f = (byte)(registers[F] & 0x28);
            if ((res & 0x80) > 0) {
                f |= (byte)(Fl.S.rawValue);
			}
             if (res == 0) {
                f |= (byte)(Fl.Z.rawValue);
			}
             if (Z80.Parity(res)) {
                f |= (byte)(Fl.PV.rawValue);
			}
             registers[F] = f;
        }

        private mutating func Cmp(_ b: byte)
        {
            let a = registers[A];
            let diff = a - b;
            var f = (byte)(registers[F] & 0x28);
            if ((diff & 0x80) > 0) {
                f = (byte)(f | 0x80);
			}
            if (diff == 0) {
                f = (byte)(f | 0x40);
			}
            if ((a & 0xF) < (b & 0xF)) {
                f = (byte)(f | 0x10);
			}
            if ((a > 0x80 && b > 0x80 && (sbyte)(diff) > 0) || (a < 0x80 && b < 0x80 && (sbyte)(diff) < 0)) {
                f = (byte)(f | 0x04);
			}
            f = (byte)(f | 0x02);
            if (diff > 0xFF) {
                f = (byte)(f | 0x01);
			}
            registers[F] = f;
        }

        private mutating func Inc(_ b: byte) -> byte
        {
            let sum = b + 1;
            var f = (byte)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f = (byte)(f | 0x80);
			}
            if (sum == 0) {
                f = (byte)(f | 0x40);
			}
            if ((b & 0xF) == 0xF) {
                f = (byte)(f | 0x10);
			}
            if ((b < 0x80 && (sbyte)(sum) < 0)) {
                f = (byte)(f | 0x04);
			}
            f = (byte)(f | 0x02);
            if (sum > 0xFF) {
				f = (byte)(f | 0x01);
			}
            registers[F] = f;

            return (byte)(sum);
        }

        private mutating func Dec(_ b: byte) -> byte
        {
            let sum = b - 1;
            var f = (byte)(registers[F] & 0x28);
            if ((sum & 0x80) > 0) {
                f = (byte)(f | 0x80);
			}
            if (sum == 0) {
                f = (byte)(f | 0x40);
			}
            if ((b & 0x0F) == 0) {
                f = (byte)(f | 0x10);
			}
            if (b == 0x80) {
                f = (byte)(f | 0x04);
			}
            f = (byte)(f | 0x02);
            registers[F] = f;

            return (byte)(sum);
        }

        private static func Parity(_ value: byte) -> bool
        {
			Z80.Parity((ushort)(value))
		}

        private static func Parity(_ value: ushort) -> bool
        {
			var v = value
            var parity = true;
            while (v > 0)
            {
                if ((v & 1) == 1) {
					parity = !parity;
				}
                v = (v >> 1);
            }
            return parity;
        }

        private func JumpCondition(_ condition: byte) -> bool
        {
            var mask: Fl;
            switch (condition & 0xFE)
            {
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
            return ((registers[F] & (byte)(mask.rawValue)) > 0) == ((condition & 1) == 1);

        }

        /// <summary>
        ///     Fetches from [PC] and increments PC
        /// </summary>
        /// <returns></returns>
        private mutating func Fetch() -> byte
        {
            var pc = Pc;
            let ret = mem[pc];
#if DEBUG
            print(String(format: "%4X %2X ", pc, ret));
#endif
            pc += 1;
            registers[PC] = (byte)(pc >> 8);
            registers[PC + 1] = (byte)(pc & 0xFF);
            return ret;
        }

        private mutating func Fetch16() -> ushort
        {
            return (ushort)(Fetch() + (Fetch() << 8));
        }

        public mutating func Reset()
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

            _clock = Date()
        }

    public func GetState() -> [UInt8] {
        let count = registers.count
        var state = Array<UInt8>(repeating: 0, count: count + 2)
        for i in 0..<count {
            state[i] = registers[i]
        }
        state[count] = IFF1 ? 1 : 0
        state[count + 1] = IFF2 ? 1 : 0
        return state
    }

    public func DumpState() -> String {
        return " BC   DE   HL  SZ-H-PNC A\n"
        + String(format: "%4X %4X %4X %d%d%d%d%d%d%d%d %2X\n", registers[B], registers[C], registers[D], registers[E], registers[H], registers[L],
            (registers[F] & 0x80) >> 7, (registers[F] & 0x40) >> 6, (registers[F] & 0x20) >> 5, (registers[F] & 0x10) >> 4,
            (registers[F] & 0x08) >> 3, (registers[F] & 0x04) >> 2, (registers[F] & 0x02) >> 1, registers[F] & 0x01, registers[A])
        + String(format: "%4X %4X %4X %d%d%d%d%d%d%d%d %2X\n", registers[Bp], registers[Cp], registers[Dp], registers[Ep], registers[Hp], registers[Lp],
            (registers[Fp] & 0x80) >> 7, (registers[Fp] & 0x40) >> 6, (registers[Fp] & 0x20) >> 5, (registers[Fp] & 0x10) >> 4,
            (registers[Fp] & 0x08) >> 3, (registers[Fp] & 0x04) >> 2, (registers[Fp] & 0x02) >> 1, registers[Fp] & 0x01, registers[Ap])
        + "I  R   IX   IY   SP   PC\n"
        + String(format: "%2X %2X %2X%2X %2X%2X %2X%2X %2X%2X\n", registers[I], registers[R],
            registers[IX], registers[IX + 1], registers[IY], registers[IY + 1],
            registers[SP], registers[SP + 1], registers[PC], registers[PC + 1])
        }

        private mutating func Wait(_ t: int)
        {
            registers[R] += (byte)((t + 3) / 4);
            let realTicksPerTick = 250; // 4MHz
            let ticks = TimeInterval(t * realTicksPerTick / 1_000_000_000);
            let elapsed = (Date() - _clock.timeIntervalSinceReferenceDate).timeIntervalSinceReferenceDate;
            let sleep = ticks - elapsed;
            if (sleep > 0)
            {
                Thread.sleep(forTimeInterval: sleep);
                _clock = _clock + ticks;
            }
            else
            {
#if DEBUG
                print(String(format: "Clock expected %.2g but was %.2g\n", ticks / Double(realTicksPerTick), elapsed / Double(realTicksPerTick)));
#endif
                _clock = Date();
            }
        }

        private mutating func SwapReg8(_ r1: byte, _ r2: byte)
        {
            let t = registers[r1];
            registers[r1] = registers[r2];
            registers[r2] = t;
        }

        //[Flags]
        private enum Fl: byte
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
/*
#if DEBUG
        private static bool debug_atStart = true;

        private static void LogMemRead(ushort addr, byte val)
        {
            if (debug_atStart)
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.Write($"{addr:X4} ");
                debug_atStart = false;
            }
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.Write($"{val:X2} ");
            Console.ForegroundColor = ConsoleColor.White;
        }

        private static void print(string text)
        {
            Console.CursorLeft = 20;
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine(text);
            Console.ForegroundColor = ConsoleColor.White;
            debug_atStart = true;
        }
*/
        private static func RName(_ n: byte) -> string
        {
            switch (n)
            {
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
/*
        private static string R16Name(byte n)
        {
            switch (n)
            {
                case 0x00:
                    return "BC";
                case 0x10:
                    return "DE";
                case 0x20:
                    return "HL";
                case 0x30:
                    return "SP";
            }
            return "";
        }
#endif
	*/
    }
