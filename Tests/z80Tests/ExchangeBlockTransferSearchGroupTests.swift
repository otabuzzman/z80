import XCTest
@testable import z80

final class ExchangeBlockTransferSearchGroupTests: XCTestCase {
    var mem: Memory!
    var asm: Z80Asm!
    var z80: TestSystem!

    override func setUp() {
        super.setUp()

        let ram = Array<byte>(repeating: 0, count: 0x10000)
        mem = Memory(ram, 0)
        z80 = TestSystem(mem)
        asm = Z80Asm(mem)

        z80.Reset()
        asm.Reset()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_EX_DE_HL()
    {
        asm.LoadReg16Val(1, 0x1122)
        asm.LoadReg16Val(2, 0x1942)
        asm.ExDeHl()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1122, z80.HL)
        XCTAssertEqual(0x1942, z80.DE)
    }

    func test_EX_AF_AFp()
    {
        asm.LoadReg16Val(0, 0x1942)
        asm.PushReg16(0)
        asm.PopReg16(3)
        asm.ExAfAfp()
        asm.LoadReg16Val(0, 0x1122)
        asm.PushReg16(0)
        asm.PopReg16(3)
        asm.ExAfAfp()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x4219, z80.AF)
        XCTAssertEqual(0x2211, z80.AFp)
    }

    func test_EXX()
    {
        asm.LoadReg16Val(0, 0x1942)
        asm.LoadReg16Val(1, 0x2041)
        asm.LoadReg16Val(2, 0x2140)
        asm.Exx()
        asm.LoadReg16Val(0, 0x1122)
        asm.LoadReg16Val(1, 0x1223)
        asm.LoadReg16Val(2, 0x1324)
        asm.Exx()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1942, z80.BC)
        XCTAssertEqual(0x2041, z80.DE)
        XCTAssertEqual(0x2140, z80.HL)
        XCTAssertEqual(0x1122, z80.BCp)
        XCTAssertEqual(0x1223, z80.DEp)
        XCTAssertEqual(0x1324, z80.HLp)
    }

    func test_EX_at_SP_HL()
    {
        asm.LoadReg16Val(2, 0x1942)
        asm.LoadReg16Val(3, 0x0040)
        asm.LoadRegVal(7, 0x22)
        asm.LoadAddrA(0x0040)
        asm.LoadRegVal(7, 0x11)
        asm.LoadAddrA(0x0041)
        asm.ExAddrSpHl()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1122, z80.HL)
        XCTAssertEqual(0x42, mem[0x40])
        XCTAssertEqual(0x19, mem[0x41])
    }

    func test_EX_at_SP_IX()
    {
        asm.LoadIxVal(0x1942)
        asm.LoadReg16Val(3, 0x0040)
        asm.LoadRegVal(7, 0x22)
        asm.LoadAddrA(0x0040)
        asm.LoadRegVal(7, 0x11)
        asm.LoadAddrA(0x0041)
        asm.ExAddrSpIx()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1122, z80.IX)
        XCTAssertEqual(0x42, mem[0x40])
        XCTAssertEqual(0x19, mem[0x41])
    }

    func test_EX_at_SP_IY()
    {
        asm.LoadIyVal(0x1942)
        asm.LoadReg16Val(3, 0x0040)
        asm.LoadRegVal(7, 0x22)
        asm.LoadAddrA(0x0040)
        asm.LoadRegVal(7, 0x11)
        asm.LoadAddrA(0x0041)
        asm.ExAddrSpIy()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1122, z80.IY)
        XCTAssertEqual(0x42, mem[0x40])
        XCTAssertEqual(0x19, mem[0x41])
    }

    func test_LDI()
    {
        [
            byte(7),
            byte(1),
        ].forEach { bc in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x3333)
            asm.LoadReg16Val(0, 0xFFFF)
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(0, ushort(bc))
            asm.LoadReg16Val(1, 0x2222)
            asm.LoadReg16Val(2, 0x1111)
            asm.LoadRegVal(7, 0x88)
            asm.LoadAddrA(0x1111)
            asm.LoadRegVal(7, 0x66)
            asm.LoadAddrA(0x2222)
            asm.Ldi()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(ushort(bc - 1), z80.BC)
            XCTAssertEqual(0x2223, z80.DE)
            XCTAssertEqual(0x1112, z80.HL)
            XCTAssertEqual(0x88, mem[0x1111])
            XCTAssertEqual(0x88, mem[0x2222])
            XCTAssertFalse(z80.FlagH)
            XCTAssertFalse(z80.FlagN)
            XCTAssertEqual(bc != 1, z80.FlagP, "Flag P contained the wrong value")
        }
    }

    func test_LDIR()
    {
        mem[0x1111] = 0x88
        mem[0x1112] = 0x36
        mem[0x1113] = 0xA5
        mem[0x1114] = 0x42
        mem[0x2222] = 0x66
        mem[0x2223] = 0x59
        mem[0x2224] = 0xC5
        mem[0x2225] = 0x24

        asm.LoadReg16Val(3, 0x3333)
        asm.LoadReg16Val(0, 0xFFFF)
        asm.PushReg16(0)
        asm.PopReg16(3)
        asm.LoadReg16Val(0, 0x0003)
        asm.LoadReg16Val(1, 0x2222)
        asm.LoadReg16Val(2, 0x1111)
        asm.Ldir()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x0000, z80.BC)
        XCTAssertEqual(0x2225, z80.DE)
        XCTAssertEqual(0x1114, z80.HL)
        XCTAssertEqual(0x88, mem[0x1111])
        XCTAssertEqual(0x36, mem[0x1112])
        XCTAssertEqual(0xA5, mem[0x1113])
        XCTAssertEqual(0x42, mem[0x1114])
        XCTAssertEqual(0x88, mem[0x2222])
        XCTAssertEqual(0x36, mem[0x2223])
        XCTAssertEqual(0xA5, mem[0x2224])
        XCTAssertEqual(0x24, mem[0x2225])
        XCTAssertFalse(z80.FlagH)
        XCTAssertFalse(z80.FlagN)
        XCTAssertFalse(z80.FlagP)
    }

    func test_LDD()
    {
        [
            byte(7),
            byte(1),
        ].forEach { bc in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x3333)
            asm.LoadReg16Val(0, 0xFFFF)
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(0, ushort(bc))
            asm.LoadReg16Val(1, 0x2222)
            asm.LoadReg16Val(2, 0x1111)
            asm.LoadRegVal(7, 0x88)
            asm.LoadAddrA(0x1111)
            asm.LoadRegVal(7, 0x66)
            asm.LoadAddrA(0x2222)
            asm.Ldd()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(ushort(bc - 1), z80.BC)
            XCTAssertEqual(0x2221, z80.DE)
            XCTAssertEqual(0x1110, z80.HL)
            XCTAssertEqual(0x88, mem[0x1111])
            XCTAssertEqual(0x88, mem[0x2222])
            XCTAssertFalse(z80.FlagH)
            XCTAssertFalse(z80.FlagN)
            XCTAssertEqual(bc != 1, z80.FlagP, "Flag P contained the wrong value")
        }
    }

    func test_LDDR()
    {
        mem[0x1111] = 0x42
        mem[0x1112] = 0x88
        mem[0x1113] = 0x36
        mem[0x1114] = 0xA5
        mem[0x2222] = 0x24
        mem[0x2223] = 0x66
        mem[0x2224] = 0x59
        mem[0x2225] = 0xC5

        asm.LoadReg16Val(3, 0x3333)
        asm.LoadReg16Val(0, 0xFFFF)
        asm.PushReg16(0)
        asm.PopReg16(3)
        asm.LoadReg16Val(0, 0x0003)
        asm.LoadReg16Val(1, 0x2225)
        asm.LoadReg16Val(2, 0x1114)
        asm.Lddr()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x0000, z80.BC)
        XCTAssertEqual(0x2222, z80.DE)
        XCTAssertEqual(0x1111, z80.HL)
        XCTAssertEqual(0x88, mem[0x1112])
        XCTAssertEqual(0x36, mem[0x1113])
        XCTAssertEqual(0xA5, mem[0x1114])
        XCTAssertEqual(0x42, mem[0x1111])
        XCTAssertEqual(0x88, mem[0x2223])
        XCTAssertEqual(0x36, mem[0x2224])
        XCTAssertEqual(0xA5, mem[0x2225])
        XCTAssertEqual(0x24, mem[0x2222])
        XCTAssertFalse(z80.FlagH)
        XCTAssertFalse(z80.FlagN)
        XCTAssertFalse(z80.FlagP)
    }

    func test_CPI()
    {
        [
            (bc: byte(7), a: byte(0x3F)),
            (bc: byte(1), a: byte(0x3F)),
            (bc: byte(7), a: byte(0x42)),
            (bc: byte(1), a: byte(0x42)),
            (bc: byte(7), a: byte(0x21)),
            (bc: byte(1), a: byte(0x21)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x3333)
            asm.LoadReg16Val(0, 0xFFFF)
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(0, ushort(testCase.bc))
            asm.LoadReg16Val(2, 0x1111)
            asm.LoadRegVal(7, 0x3F)
            asm.LoadAddrA(0x1111)
            asm.LoadRegVal(7, testCase.a)
            asm.Cpi()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(ushort(testCase.bc - 1), z80.BC)
            XCTAssertEqual(0x1112, z80.HL)
            XCTAssertEqual(testCase.a, z80.A)
            XCTAssertEqual(0x3F, mem[0x1111])

            XCTAssertEqual(testCase.a < 0x3f, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.a == 0x3F, z80.FlagZ, "Flag Z contained the wrong value")
            // (hl) has bit 3 set, if a doesn't a borrow occurs from bit 4 (half carry flag)
            XCTAssertEqual((testCase.a & 8) == 0, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(testCase.bc != 1, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertTrue(z80.FlagN)
        }
    }

    func test_CPIR()
    {
        [
            (bc: byte(7), a: byte(0xF3), bc_res: byte(4)),
            (bc: byte(1), a: byte(0xF3), bc_res: byte(0)),
            (bc: byte(7), a: byte(0x42), bc_res: byte(0)),
            (bc: byte(1), a: byte(0x42), bc_res: byte(0)),
            (bc: byte(7), a: byte(0x21), bc_res: byte(0)),
            (bc: byte(1), a: byte(0x21), bc_res: byte(0)),
        ].forEach { testCase in
            tearDown()
            setUp()

            mem[0x1111] = 0x52
            mem[0x1112] = 0x00
            mem[0x1113] = 0xF3

            asm.LoadReg16Val(3, 0x3333)
            asm.LoadReg16Val(0, 0xFFFF)
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(0, ushort(testCase.bc))
            asm.LoadReg16Val(2, 0x1111)
            asm.LoadRegVal(7, testCase.a)
            asm.Cpir()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(ushort(testCase.bc_res), z80.BC)
            XCTAssertEqual(0x1111 + ushort(testCase.bc) - ushort(testCase.bc_res), z80.HL)
            XCTAssertEqual(testCase.a, z80.A)

            let last = mem[z80.HL - ushort(1)]
            XCTAssertEqual(testCase.a < last, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.a == last, z80.FlagZ, "Flag Z contained the wrong value")
            // (hl) has bit 3 set, if a doesn't a borrow occurs from bit 4 (half carry flag)
            XCTAssertEqual((testCase.a & 8) < (last & 8), z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(z80.BC != 0, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertTrue(z80.FlagN)
        }
    }

    func test_CPD()
    {
        [
            (bc: byte(7), a: byte(0x3F)),
            (bc: byte(1), a: byte(0x3F)),
            (bc: byte(7), a: byte(0x42)),
            (bc: byte(1), a: byte(0x42)),
            (bc: byte(7), a: byte(0x21)),
            (bc: byte(1), a: byte(0x21)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x3333)
            asm.LoadReg16Val(0, 0xFFFF)
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(0, ushort(testCase.bc))
            asm.LoadReg16Val(2, 0x1111)
            asm.LoadRegVal(7, 0x3F)
            asm.LoadAddrA(0x1111)
            asm.LoadRegVal(7, testCase.a)
            asm.Cpd()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(ushort(testCase.bc - 1), z80.BC)
            XCTAssertEqual(0x1110, z80.HL)
            XCTAssertEqual(testCase.a, z80.A)
            XCTAssertEqual(0x3F, mem[0x1111])

            XCTAssertEqual(testCase.a < 0x3f, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.a == 0x3F, z80.FlagZ, "Flag Z contained the wrong value")
            // (hl) has bit 3 set, if a doesn't a borrow occurs from bit 4 (half carry flag)
            XCTAssertEqual((testCase.a & 8) == 0, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(testCase.bc != 1, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertTrue(z80.FlagN)
        }
    }

    func test_CPDR()
    {
        [
            (bc: byte(7), a: byte(0xF3), bc_res: byte(4)),
            (bc: byte(1), a: byte(0xF3), bc_res: byte(0)),
            (bc: byte(7), a: byte(0x42), bc_res: byte(0)),
            (bc: byte(1), a: byte(0x42), bc_res: byte(0)),
            (bc: byte(7), a: byte(0x21), bc_res: byte(0)),
            (bc: byte(1), a: byte(0x21), bc_res: byte(0)),
        ].forEach { testCase in
            tearDown()
            setUp()

            mem[0x1116] = 0xF3
            mem[0x1117] = 0x00
            mem[0x1118] = 0x52

            asm.LoadReg16Val(3, 0x3333)
            asm.LoadReg16Val(0, 0xFFFF)
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(0, ushort(testCase.bc))
            asm.LoadReg16Val(2, 0x1118)
            asm.LoadRegVal(7, testCase.a)
            asm.Cpdr()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(ushort(testCase.bc_res), z80.BC)
            XCTAssertEqual(0x1118 - ushort(testCase.bc) + ushort(testCase.bc_res), z80.HL)
            XCTAssertEqual(testCase.a, z80.A)

            let last = mem[z80.HL + ushort(1)]
            XCTAssertEqual(testCase.a < last, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.a == last, z80.FlagZ, "Flag Z contained the wrong value")
            // (hl) has bit 3 set, if a doesn't a borrow occurs from bit 4 (half carry flag)
            XCTAssertEqual((testCase.a & 8) < (last & 8), z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(z80.BC != 0, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertTrue(z80.FlagN)
        }
    }
}
