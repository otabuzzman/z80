import XCTest
@testable import z80

final class EightBitLoadGroupTests: XCTestCase {
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

    func test_LD_r_n()
    {
        [
            byte(0),
            byte(1),
            byte(2),
            byte(3),
            byte(4),
            byte(5),
            byte(7),
        ].forEach { r in
            tearDown()
            setUp()

            asm.LoadRegVal(r, 42)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(42, z80.Reg8(r))
        }
    }

    func test_LD_r1_r2()
    {
        [
            (r: byte(0), r2: byte(0)),
            (r: byte(1), r2: byte(0)),
            (r: byte(2), r2: byte(0)),
            (r: byte(3), r2: byte(0)),
            (r: byte(4), r2: byte(0)),
            (r: byte(5), r2: byte(0)),
            (r: byte(7), r2: byte(0)),
            (r: byte(0), r2: byte(1)),
            (r: byte(1), r2: byte(1)),
            (r: byte(2), r2: byte(1)),
            (r: byte(3), r2: byte(1)),
            (r: byte(4), r2: byte(1)),
            (r: byte(5), r2: byte(1)),
            (r: byte(7), r2: byte(1)),
            (r: byte(0), r2: byte(2)),
            (r: byte(1), r2: byte(2)),
            (r: byte(2), r2: byte(2)),
            (r: byte(3), r2: byte(2)),
            (r: byte(4), r2: byte(2)),
            (r: byte(5), r2: byte(2)),
            (r: byte(7), r2: byte(2)),
            (r: byte(0), r2: byte(3)),
            (r: byte(1), r2: byte(3)),
            (r: byte(2), r2: byte(3)),
            (r: byte(3), r2: byte(3)),
            (r: byte(4), r2: byte(3)),
            (r: byte(5), r2: byte(3)),
            (r: byte(7), r2: byte(3)),
            (r: byte(0), r2: byte(4)),
            (r: byte(1), r2: byte(4)),
            (r: byte(2), r2: byte(4)),
            (r: byte(3), r2: byte(4)),
            (r: byte(4), r2: byte(4)),
            (r: byte(5), r2: byte(4)),
            (r: byte(7), r2: byte(4)),
            (r: byte(0), r2: byte(5)),
            (r: byte(1), r2: byte(5)),
            (r: byte(2), r2: byte(5)),
            (r: byte(3), r2: byte(5)),
            (r: byte(4), r2: byte(5)),
            (r: byte(5), r2: byte(5)),
            (r: byte(7), r2: byte(5)),
            (r: byte(0), r2: byte(7)),
            (r: byte(1), r2: byte(7)),
            (r: byte(2), r2: byte(7)),
            (r: byte(3), r2: byte(7)),
            (r: byte(4), r2: byte(7)),
            (r: byte(5), r2: byte(7)),
            (r: byte(7), r2: byte(7)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.r, 33)
            asm.LoadRegReg(testCase.r2, testCase.r)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(33, z80.Reg8(testCase.r))
            XCTAssertEqual(33, z80.Reg8(testCase.r2))
        }
    }

    func test_LD_r_HL()
    {
        [
            byte(0),
            byte(1),
            byte(2),
            byte(3),
            byte(4),
            byte(5),
            byte(7),
        ].forEach { r in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 5)
            asm.LoadRegAtHl(r)
            asm.Halt()
            asm.Data(123)

            z80.Run()

            XCTAssertEqual(asm.Position - ushort(1), z80.PC)
            XCTAssertEqual(123, z80.Reg8(r))
        }
    }

    func test_LD_r_at_IX()
    {
        [
            (r: byte(0), d: sbyte(0)),
            (r: byte(1), d: sbyte(0)),
            (r: byte(2), d: sbyte(0)),
            (r: byte(3), d: sbyte(0)),
            (r: byte(4), d: sbyte(0)),
            (r: byte(5), d: sbyte(0)),
            (r: byte(7), d: sbyte(0)),
            (r: byte(0), d: sbyte(1)),
            (r: byte(1), d: sbyte(1)),
            (r: byte(2), d: sbyte(1)),
            (r: byte(3), d: sbyte(1)),
            (r: byte(4), d: sbyte(1)),
            (r: byte(5), d: sbyte(1)),
            (r: byte(7), d: sbyte(1)),
            (r: byte(0), d: sbyte(2)),
            (r: byte(1), d: sbyte(2)),
            (r: byte(2), d: sbyte(2)),
            (r: byte(3), d: sbyte(2)),
            (r: byte(4), d: sbyte(2)),
            (r: byte(5), d: sbyte(2)),
            (r: byte(7), d: sbyte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIxVal(8)
            asm.LoadRegAddrIx(testCase.r, testCase.d)
            asm.Halt()
            asm.Data(123)
            asm.Data(42)
            asm.Data(66)

            z80.Run()

            XCTAssertEqual(asm.Position - ushort(3), z80.PC)
            XCTAssertEqual(mem[z80.PC + testCase.d], z80.Reg8(testCase.r))
        }
    }

    func test_LD_r_at_IY()
    {
        [
            (r: byte(0), d: sbyte(0)),
            (r: byte(1), d: sbyte(0)),
            (r: byte(2), d: sbyte(0)),
            (r: byte(3), d: sbyte(0)),
            (r: byte(4), d: sbyte(0)),
            (r: byte(5), d: sbyte(0)),
            (r: byte(7), d: sbyte(0)),
            (r: byte(0), d: sbyte(1)),
            (r: byte(1), d: sbyte(1)),
            (r: byte(2), d: sbyte(1)),
            (r: byte(3), d: sbyte(1)),
            (r: byte(4), d: sbyte(1)),
            (r: byte(5), d: sbyte(1)),
            (r: byte(7), d: sbyte(1)),
            (r: byte(0), d: sbyte(2)),
            (r: byte(1), d: sbyte(2)),
            (r: byte(2), d: sbyte(2)),
            (r: byte(3), d: sbyte(2)),
            (r: byte(4), d: sbyte(2)),
            (r: byte(5), d: sbyte(2)),
            (r: byte(7), d: sbyte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIyVal(8)
            asm.LoadRegAddrIy(testCase.r, testCase.d)
            asm.Halt()
            asm.Data(123)
            asm.Data(42)
            asm.Data(66)

            z80.Run()

            XCTAssertEqual(asm.Position - ushort(3), z80.PC)
            XCTAssertEqual(mem[z80.PC + testCase.d], z80.Reg8(testCase.r))
        }
    }

    func test_LD_at_HL_r()
    {
        [
            byte(0),
            byte(1),
            byte(2),
            byte(3),
            byte(7),
        ].forEach { r in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 8)
            asm.LoadRegVal(r, 66)
            asm.LoadAtHlReg(r)
            asm.Nop()
            asm.Halt()
            asm.Data(123)

            z80.Run()

            XCTAssertEqual(asm.Position - ushort(1), z80.PC)
            XCTAssertEqual(66, mem[8])
        }
    }

    func test_LD_at_IX_r()
    {
        [
            (r: byte(0), d: sbyte(-2)),
            (r: byte(1), d: sbyte(-2)),
            (r: byte(2), d: sbyte(-2)),
            (r: byte(3), d: sbyte(-2)),
            (r: byte(4), d: sbyte(-2)),
            (r: byte(5), d: sbyte(-2)),
            (r: byte(7), d: sbyte(-2)),
            (r: byte(0), d: sbyte(-1)),
            (r: byte(1), d: sbyte(-1)),
            (r: byte(2), d: sbyte(-1)),
            (r: byte(3), d: sbyte(-1)),
            (r: byte(4), d: sbyte(-1)),
            (r: byte(5), d: sbyte(-1)),
            (r: byte(7), d: sbyte(-1)),
            (r: byte(0), d: sbyte(0)),
            (r: byte(1), d: sbyte(0)),
            (r: byte(2), d: sbyte(0)),
            (r: byte(3), d: sbyte(0)),
            (r: byte(4), d: sbyte(0)),
            (r: byte(5), d: sbyte(0)),
            (r: byte(7), d: sbyte(0)),
            (r: byte(0), d: sbyte(1)),
            (r: byte(1), d: sbyte(1)),
            (r: byte(2), d: sbyte(1)),
            (r: byte(3), d: sbyte(1)),
            (r: byte(4), d: sbyte(1)),
            (r: byte(5), d: sbyte(1)),
            (r: byte(7), d: sbyte(1)),
            (r: byte(0), d: sbyte(2)),
            (r: byte(1), d: sbyte(2)),
            (r: byte(2), d: sbyte(2)),
            (r: byte(3), d: sbyte(2)),
            (r: byte(4), d: sbyte(2)),
            (r: byte(5), d: sbyte(2)),
            (r: byte(7), d: sbyte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIxVal(12)
            asm.LoadRegVal(testCase.r, 201)
            asm.LoadIxReg(testCase.r, testCase.d)
            asm.Halt()
            asm.Data(0x11)
            asm.Data(0x22)
            asm.Data(0x33)
            asm.Data(0x44)
            asm.Data(0x55)

            z80.Run()

            XCTAssertEqual(asm.Position - ushort(5), z80.PC)
            XCTAssertEqual(201, mem[12 + testCase.d])
        }
    }

    func test_LD_at_IY_r()
    {
        [
            (r: byte(0), d: sbyte(-2)),
            (r: byte(1), d: sbyte(-2)),
            (r: byte(2), d: sbyte(-2)),
            (r: byte(3), d: sbyte(-2)),
            (r: byte(4), d: sbyte(-2)),
            (r: byte(5), d: sbyte(-2)),
            (r: byte(7), d: sbyte(-2)),
            (r: byte(0), d: sbyte(-1)),
            (r: byte(1), d: sbyte(-1)),
            (r: byte(2), d: sbyte(-1)),
            (r: byte(3), d: sbyte(-1)),
            (r: byte(4), d: sbyte(-1)),
            (r: byte(5), d: sbyte(-1)),
            (r: byte(7), d: sbyte(-1)),
            (r: byte(0), d: sbyte(0)),
            (r: byte(1), d: sbyte(0)),
            (r: byte(2), d: sbyte(0)),
            (r: byte(3), d: sbyte(0)),
            (r: byte(4), d: sbyte(0)),
            (r: byte(5), d: sbyte(0)),
            (r: byte(7), d: sbyte(0)),
            (r: byte(0), d: sbyte(1)),
            (r: byte(1), d: sbyte(1)),
            (r: byte(2), d: sbyte(1)),
            (r: byte(3), d: sbyte(1)),
            (r: byte(4), d: sbyte(1)),
            (r: byte(5), d: sbyte(1)),
            (r: byte(7), d: sbyte(1)),
            (r: byte(0), d: sbyte(2)),
            (r: byte(1), d: sbyte(2)),
            (r: byte(2), d: sbyte(2)),
            (r: byte(3), d: sbyte(2)),
            (r: byte(4), d: sbyte(2)),
            (r: byte(5), d: sbyte(2)),
            (r: byte(7), d: sbyte(2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIyVal(12)
            asm.LoadRegVal(testCase.r, 201)
            asm.LoadIyReg(testCase.r, testCase.d)
            asm.Halt()
            asm.Data(0x11)
            asm.Data(0x22)
            asm.Data(0x33)
            asm.Data(0x44)
            asm.Data(0x55)

            z80.Run()

            XCTAssertEqual(asm.Position - ushort(5), z80.PC)
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

        XCTAssertEqual(asm.Position - ushort(1), z80.PC)
        XCTAssertEqual(201, mem[8])
    }

    func test_LD_at_IX_n()
    {
        [
            sbyte(-2),
            sbyte(-1),
            sbyte(0),
            sbyte(1),
            sbyte(2),
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

            XCTAssertEqual(asm.Position - ushort(5), z80.PC)
            XCTAssertEqual(201, mem[11 + d])
        }
    }

    func test_LD_at_IY_n()
    {
        [
            sbyte(-2),
            sbyte(-1),
            sbyte(0),
            sbyte(1),
            sbyte(2),
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

            XCTAssertEqual(asm.Position - ushort(5), z80.PC)
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

        XCTAssertEqual(asm.Position - ushort(1), z80.PC)
        XCTAssertEqual(66, z80.A)
    }

    func test_LD_A_at_DE()
    {
        asm.LoadReg16Val(1, 5)
        asm.LoadADe()
        asm.Halt()
        asm.Data(0x42)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(1), z80.PC)
        XCTAssertEqual(66, z80.A)
    }

    func test_LD_A_at_nn()
    {
        asm.LoadAAddr(4)
        asm.Halt()
        asm.Data(0x42)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(1), z80.PC)
        XCTAssertEqual(66, z80.A)
    }

    func test_LD_at_BC_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadReg16Val(0, 0x08)
        asm.LoadBcA()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(66, mem[8])
    }

    func test_LD_at_DE_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadReg16Val(1, 0x08)
        asm.LoadDeA()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(66, mem[8])
    }

    func test_LD_at_nn_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadAddrA(0x08)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(66, mem[8])
    }

    func test_LD_I_A()
    {
        asm.LoadRegVal(7, 0x42)
        asm.LoadIA()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(66, z80.I)
    }

    func test_LD_A_I()
    {
        [
            (val: sbyte(23), sign: false, zero: false),
            (val: sbyte(0), sign: false, zero: true),
            (val: sbyte(-1), sign: true, zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, byte(truncatingIfNeeded: testCase.val))
            asm.LoadIA()
            asm.LoadRegVal(7, 0xC9)
            asm.LoadAI()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(byte(truncatingIfNeeded: testCase.val), z80.A)
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

        XCTAssertEqual(asm.Position, z80.PC)
        //R is incremented by 3 machine cycles by the end.
        XCTAssertEqual(69, z80.R)
    }

    func test_LD_A_R()
    {
        [
            (val: sbyte(23), sign: false, zero: false),
            (val: sbyte(-5), sign: false, zero: true),
            (val: sbyte(-6), sign: true, zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, byte(truncatingIfNeeded: testCase.val))
            asm.LoadRA()
            asm.LoadRegVal(7, 0xC9)
            asm.LoadAR()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            //R is incremented by 5 machine cycles by the end.
            XCTAssertEqual(testCase.val + 5, sbyte(truncatingIfNeeded: z80.A))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }
}
