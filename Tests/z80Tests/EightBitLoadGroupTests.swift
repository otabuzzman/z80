import XCTest
@testable import z80

final class EightBitLoadGroupTests: XCTestCase {
    var mem: Memory!
    var asm: Z80Asm!
    var z80: TestSystem!

    override func setUp() {
        super.setUp()

        let ram = Array<Byte>(repeating: 0, count: 0x10000)
        mem = Memory(ram, 0)
        z80 = TestSystem(mem)
        asm = Z80Asm(mem)

        z80.Reset()
        asm.Reset()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_LD_r_n()
    {
        [
            Byte(0),
            Byte(1),
            Byte(2),
            Byte(3),
            Byte(4),
            Byte(5),
            Byte(7),
        ].forEach { reg in
            tearDown()
            setUp()

            asm.LoadRegVal(reg, 42)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(42, z80.Reg8(reg))
        }
    }

    func test_LD_r1_r2()
    {
        [
            (reg: Byte(0), reg2: Byte(0)),
            (reg: Byte(1), reg2: Byte(0)),
            (reg: Byte(2), reg2: Byte(0)),
            (reg: Byte(3), reg2: Byte(0)),
            (reg: Byte(4), reg2: Byte(0)),
            (reg: Byte(5), reg2: Byte(0)),
            (reg: Byte(7), reg2: Byte(0)),
            (reg: Byte(0), reg2: Byte(1)),
            (reg: Byte(1), reg2: Byte(1)),
            (reg: Byte(2), reg2: Byte(1)),
            (reg: Byte(3), reg2: Byte(1)),
            (reg: Byte(4), reg2: Byte(1)),
            (reg: Byte(5), reg2: Byte(1)),
            (reg: Byte(7), reg2: Byte(1)),
            (reg: Byte(0), reg2: Byte(2)),
            (reg: Byte(1), reg2: Byte(2)),
            (reg: Byte(2), reg2: Byte(2)),
            (reg: Byte(3), reg2: Byte(2)),
            (reg: Byte(4), reg2: Byte(2)),
            (reg: Byte(5), reg2: Byte(2)),
            (reg: Byte(7), reg2: Byte(2)),
            (reg: Byte(0), reg2: Byte(3)),
            (reg: Byte(1), reg2: Byte(3)),
            (reg: Byte(2), reg2: Byte(3)),
            (reg: Byte(3), reg2: Byte(3)),
            (reg: Byte(4), reg2: Byte(3)),
            (reg: Byte(5), reg2: Byte(3)),
            (reg: Byte(7), reg2: Byte(3)),
            (reg: Byte(0), reg2: Byte(4)),
            (reg: Byte(1), reg2: Byte(4)),
            (reg: Byte(2), reg2: Byte(4)),
            (reg: Byte(3), reg2: Byte(4)),
            (reg: Byte(4), reg2: Byte(4)),
            (reg: Byte(5), reg2: Byte(4)),
            (reg: Byte(7), reg2: Byte(4)),
            (reg: Byte(0), reg2: Byte(5)),
            (reg: Byte(1), reg2: Byte(5)),
            (reg: Byte(2), reg2: Byte(5)),
            (reg: Byte(3), reg2: Byte(5)),
            (reg: Byte(4), reg2: Byte(5)),
            (reg: Byte(5), reg2: Byte(5)),
            (reg: Byte(7), reg2: Byte(5)),
            (reg: Byte(0), reg2: Byte(7)),
            (reg: Byte(1), reg2: Byte(7)),
            (reg: Byte(2), reg2: Byte(7)),
            (reg: Byte(3), reg2: Byte(7)),
            (reg: Byte(4), reg2: Byte(7)),
            (reg: Byte(5), reg2: Byte(7)),
            (reg: Byte(7), reg2: Byte(7)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.reg, 33)
            asm.LoadRegReg(testCase.reg2, testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(33, z80.Reg8(testCase.reg))
            XCTAssertEqual(33, z80.Reg8(testCase.reg2))
        }
    }

    func test_LD_r_HL()
    {
        [
            Byte(0),
            Byte(1),
            Byte(2),
            Byte(3),
            Byte(4),
            Byte(5),
            Byte(7),
        ].forEach { reg in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 5)
            asm.LoadRegAtHl(reg)
            asm.Halt()
            asm.Data(123)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(1), z80.PC)
            XCTAssertEqual(123, z80.Reg8(reg))
        }
    }

    func test_LD_r_at_IX()
    {
        [
            (reg: Byte(0), d: SByte(0)),
            (reg: Byte(1), d: SByte(0)),
            (reg: Byte(2), d: SByte(0)),
            (reg: Byte(3), d: SByte(0)),
            (reg: Byte(4), d: SByte(0)),
            (reg: Byte(5), d: SByte(0)),
            (reg: Byte(7), d: SByte(0)),
            (reg: Byte(0), d: SByte(1)),
            (reg: Byte(1), d: SByte(1)),
            (reg: Byte(2), d: SByte(1)),
            (reg: Byte(3), d: SByte(1)),
            (reg: Byte(4), d: SByte(1)),
            (reg: Byte(5), d: SByte(1)),
            (reg: Byte(7), d: SByte(1)),
            (reg: Byte(0), d: SByte(2)),
            (reg: Byte(1), d: SByte(2)),
            (reg: Byte(2), d: SByte(2)),
            (reg: Byte(3), d: SByte(2)),
            (reg: Byte(4), d: SByte(2)),
            (reg: Byte(5), d: SByte(2)),
            (reg: Byte(7), d: SByte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIxVal(8)
            asm.LoadRegAddrIx(testCase.reg, testCase.d)
            asm.Halt()
            asm.Data(123)
            asm.Data(42)
            asm.Data(66)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(3), z80.PC)
            XCTAssertEqual(mem[z80.PC + testCase.d], z80.Reg8(testCase.reg))
        }
    }

    func test_LD_r_at_IY()
    {
        [
            (reg: Byte(0), d: SByte(0)),
            (reg: Byte(1), d: SByte(0)),
            (reg: Byte(2), d: SByte(0)),
            (reg: Byte(3), d: SByte(0)),
            (reg: Byte(4), d: SByte(0)),
            (reg: Byte(5), d: SByte(0)),
            (reg: Byte(7), d: SByte(0)),
            (reg: Byte(0), d: SByte(1)),
            (reg: Byte(1), d: SByte(1)),
            (reg: Byte(2), d: SByte(1)),
            (reg: Byte(3), d: SByte(1)),
            (reg: Byte(4), d: SByte(1)),
            (reg: Byte(5), d: SByte(1)),
            (reg: Byte(7), d: SByte(1)),
            (reg: Byte(0), d: SByte(2)),
            (reg: Byte(1), d: SByte(2)),
            (reg: Byte(2), d: SByte(2)),
            (reg: Byte(3), d: SByte(2)),
            (reg: Byte(4), d: SByte(2)),
            (reg: Byte(5), d: SByte(2)),
            (reg: Byte(7), d: SByte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIyVal(8)
            asm.LoadRegAddrIy(testCase.reg, testCase.d)
            asm.Halt()
            asm.Data(123)
            asm.Data(42)
            asm.Data(66)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(3), z80.PC)
            XCTAssertEqual(mem[z80.PC + testCase.d], z80.Reg8(testCase.reg))
        }
    }

    func test_LD_at_HL_r()
    {
        [
            Byte(0),
            Byte(1),
            Byte(2),
            Byte(3),
            Byte(7),
        ].forEach { reg in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 8)
            asm.LoadRegVal(reg, 66)
            asm.LoadAtHlReg(reg)
            asm.Nop()
            asm.Halt()
            asm.Data(123)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(1), z80.PC)
            XCTAssertEqual(66, mem[8])
        }
    }

    func test_LD_at_IX_r()
    {
        [
            (reg: Byte(0), d: SByte(-2)),
            (reg: Byte(1), d: SByte(-2)),
            (reg: Byte(2), d: SByte(-2)),
            (reg: Byte(3), d: SByte(-2)),
            (reg: Byte(4), d: SByte(-2)),
            (reg: Byte(5), d: SByte(-2)),
            (reg: Byte(7), d: SByte(-2)),
            (reg: Byte(0), d: SByte(-1)),
            (reg: Byte(1), d: SByte(-1)),
            (reg: Byte(2), d: SByte(-1)),
            (reg: Byte(3), d: SByte(-1)),
            (reg: Byte(4), d: SByte(-1)),
            (reg: Byte(5), d: SByte(-1)),
            (reg: Byte(7), d: SByte(-1)),
            (reg: Byte(0), d: SByte(0)),
            (reg: Byte(1), d: SByte(0)),
            (reg: Byte(2), d: SByte(0)),
            (reg: Byte(3), d: SByte(0)),
            (reg: Byte(4), d: SByte(0)),
            (reg: Byte(5), d: SByte(0)),
            (reg: Byte(7), d: SByte(0)),
            (reg: Byte(0), d: SByte(1)),
            (reg: Byte(1), d: SByte(1)),
            (reg: Byte(2), d: SByte(1)),
            (reg: Byte(3), d: SByte(1)),
            (reg: Byte(4), d: SByte(1)),
            (reg: Byte(5), d: SByte(1)),
            (reg: Byte(7), d: SByte(1)),
            (reg: Byte(0), d: SByte(2)),
            (reg: Byte(1), d: SByte(2)),
            (reg: Byte(2), d: SByte(2)),
            (reg: Byte(3), d: SByte(2)),
            (reg: Byte(4), d: SByte(2)),
            (reg: Byte(5), d: SByte(2)),
            (reg: Byte(7), d: SByte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIxVal(12)
            asm.LoadRegVal(testCase.reg, 201)
            asm.LoadIxReg(testCase.reg, testCase.d)
            asm.Halt()
            asm.Data(0x11)
            asm.Data(0x22)
            asm.Data(0x33)
            asm.Data(0x44)
            asm.Data(0x55)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(5), z80.PC)
            XCTAssertEqual(201, mem[12 + testCase.d])
        }
    }

    func test_LD_at_IY_r()
    {
        [
            (reg: Byte(0), d: SByte(-2)),
            (reg: Byte(1), d: SByte(-2)),
            (reg: Byte(2), d: SByte(-2)),
            (reg: Byte(3), d: SByte(-2)),
            (reg: Byte(4), d: SByte(-2)),
            (reg: Byte(5), d: SByte(-2)),
            (reg: Byte(7), d: SByte(-2)),
            (reg: Byte(0), d: SByte(-1)),
            (reg: Byte(1), d: SByte(-1)),
            (reg: Byte(2), d: SByte(-1)),
            (reg: Byte(3), d: SByte(-1)),
            (reg: Byte(4), d: SByte(-1)),
            (reg: Byte(5), d: SByte(-1)),
            (reg: Byte(7), d: SByte(-1)),
            (reg: Byte(0), d: SByte(0)),
            (reg: Byte(1), d: SByte(0)),
            (reg: Byte(2), d: SByte(0)),
            (reg: Byte(3), d: SByte(0)),
            (reg: Byte(4), d: SByte(0)),
            (reg: Byte(5), d: SByte(0)),
            (reg: Byte(7), d: SByte(0)),
            (reg: Byte(0), d: SByte(1)),
            (reg: Byte(1), d: SByte(1)),
            (reg: Byte(2), d: SByte(1)),
            (reg: Byte(3), d: SByte(1)),
            (reg: Byte(4), d: SByte(1)),
            (reg: Byte(5), d: SByte(1)),
            (reg: Byte(7), d: SByte(1)),
            (reg: Byte(0), d: SByte(2)),
            (reg: Byte(1), d: SByte(2)),
            (reg: Byte(2), d: SByte(2)),
            (reg: Byte(3), d: SByte(2)),
            (reg: Byte(4), d: SByte(2)),
            (reg: Byte(5), d: SByte(2)),
            (reg: Byte(7), d: SByte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIyVal(12)
            asm.LoadRegVal(testCase.reg, 201)
            asm.LoadIyReg(testCase.reg, testCase.d)
            asm.Halt()
            asm.Data(0x11)
            asm.Data(0x22)
            asm.Data(0x33)
            asm.Data(0x44)
            asm.Data(0x55)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(5), z80.PC)
            XCTAssertEqual(201, mem[12 + testCase.d])
        }
    }

    func test_LD_at_HL_n()
    {
        asm.LoadReg16Val(2, 8)
        asm.LoadAtHlVal(201)
        asm.Halt()
        asm.Data(123)

        z80.Run()

        XCTAssertEqual(asm.addr - UShort(1), z80.PC)
        XCTAssertEqual(201, mem[8])
    }

    func test_LD_at_IX_n()
    {
        [
            SByte(-2),
            SByte(-1),
            SByte(0),
            SByte(1),
            SByte(2),
        ].forEach { d in
            tearDown()
            setUp()

            asm.LoadIxVal(11)
            asm.LoadAtIxVal(d, 201)
            asm.Halt()
            asm.Data(0x11)
            asm.Data(0x22)
            asm.Data(0x33)
            asm.Data(0x44)
            asm.Data(0x55)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(5), z80.PC)
            XCTAssertEqual(201, mem[11 + d])
        }
    }

    func test_LD_at_IY_n()
    {
        [
            SByte(-2),
            SByte(-1),
            SByte(0),
            SByte(1),
            SByte(2),
        ].forEach { d in
            tearDown()
            setUp()

            asm.LoadIyVal(11)
            asm.LoadIyN(d, 201)
            asm.Halt()
            asm.Data(0x11)
            asm.Data(0x22)
            asm.Data(0x33)
            asm.Data(0x44)
            asm.Data(0x55)

            z80.Run()

            XCTAssertEqual(asm.addr - UShort(5), z80.PC)
            XCTAssertEqual(201, mem[11 + d])
        }
    }

    func test_LD_A_at_BC()
    {
        asm.LoadReg16Val(0, 5)
        asm.LoadABc()
        asm.Halt()
        asm.Data(0x42)

        z80.Run()

        XCTAssertEqual(asm.addr - UShort(1), z80.PC)
        XCTAssertEqual(66, z80.A)
    }

    func test_LD_A_at_DE()
    {
        asm.LoadReg16Val(1, 5)
        asm.LoadADe()
        asm.Halt()
        asm.Data(0x42)

        z80.Run()

        XCTAssertEqual(asm.addr - UShort(1), z80.PC)
        XCTAssertEqual(66, z80.A)
    }

    func test_LD_A_at_nn()
    {
        asm.LoadAAddr(4)
        asm.Halt()
        asm.Data(0x42)

        z80.Run()

        XCTAssertEqual(asm.addr - UShort(1), z80.PC)
        XCTAssertEqual(66, z80.A)
    }

    func test_LD_at_BC_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadReg16Val(0, 0x08)
        asm.LoadBcA()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(66, mem[8])
    }

    func test_LD_at_DE_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadReg16Val(1, 0x08)
        asm.LoadDeA()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(66, mem[8])
    }

    func test_LD_at_nn_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadAddrA(0x08)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(66, mem[8])
    }

    func test_LD_I_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadIA()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(66, z80.I)
    }

    func test_LD_A_I()
    {
        [
            (val: SByte(23), sign: false, zero: false),
            (val: SByte(0), sign: false, zero: true),
            (val: SByte(-1), sign: true, zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, Byte(truncatingIfNeeded: testCase.val))
            asm.LoadIA()
            asm.LoadRegVal(7, 0xC9)
            asm.LoadAI()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(Byte(truncatingIfNeeded: testCase.val), z80.A)
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_LD_R_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadRA()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        //R is incremented by 3 machine cycles by the end.
        XCTAssertEqual(69, z80.R)
    }

    func test_LD_A_R()
    {
        [
            (val: SByte(23), sign: false, zero: false),
            (val: SByte(-5), sign: false, zero: true),
            (val: SByte(-6), sign: true, zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, Byte(truncatingIfNeeded: testCase.val))
            asm.LoadRA()
            asm.LoadRegVal(7, 0xC9)
            asm.LoadAR()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            //R is incremented by 5 machine cycles by the end.
            XCTAssertEqual(testCase.val + 5, SByte(truncatingIfNeeded: z80.A))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }
}
