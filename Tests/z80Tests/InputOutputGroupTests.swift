import XCTest
@testable import z80

final class InputOutputTests: XCTestCase {
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

    func test_IN_A_n()
    {
        [
            byte(0x00),
            byte(0x42),
        ].forEach { val in
            tearDown()
            setUp()

            asm.LoadRegVal(7, val)
            asm.InAPort(0x34)
            asm.Halt()

            z80.testPorts.SetInput(ushort(val) * 256 + 0x34, 0x56)
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(0x56, z80.A)
        }
    }

    func test_IN_r_BC()
    {
        [
            (reg: byte(2), val: byte(0x3C), sign: false, zero: false, parity: true),
            (reg: byte(3), val: byte(0xBB), sign: true, zero: false, parity: true),
            (reg: byte(2), val: byte(0xEB), sign: true, zero: false, parity: true),
            (reg: byte(0), val: byte(0x38), sign: false, zero: false, parity: false),
            (reg: byte(7), val: byte(0x9A), sign: true, zero: false, parity: true),
            (reg: byte(2), val: byte(0x47), sign: false, zero: false, parity: true),
            (reg: byte(3), val: byte(0x8D), sign: true, zero: false, parity: true),
            (reg: byte(5), val: byte(0x71), sign: false, zero: false, parity: true),
            (reg: byte(2), val: byte(0x58), sign: false, zero: false, parity: false),
            (reg: byte(7), val: byte(0x45), sign: false, zero: false, parity: false),
            (reg: byte(3), val: byte(0x56), sign: false, zero: false, parity: true),
            (reg: byte(1), val: byte(0x91), sign: true, zero: false, parity: false),
            (reg: byte(1), val: byte(0x00), sign: false, zero: true, parity: true),
            (reg: byte(2), val: byte(0xC0), sign: true, zero: false, parity: true),
            (reg: byte(1), val: byte(0x79), sign: false, zero: false, parity: false),
            (reg: byte(7), val: byte(0x5A), sign: false, zero: false, parity: true),
            (reg: byte(4), val: byte(0x9A), sign: true, zero: false, parity: true),
            (reg: byte(0), val: byte(0x07), sign: false, zero: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(0, 0x1234)
            asm.InRegBc(testCase.reg)
            asm.Halt()

            z80.testPorts.SetInput(0x1234, testCase.val)
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.val, z80.Reg8(testCase.reg))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_INI()
    {
        [
            (b: byte(0x03), zero: false),
            (b: byte(0x01), zero: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadReg16Val(0, ushort(testCase.b) * 256 + 0x34)
            asm.Ini()
            asm.Halt()

            z80.testPorts.SetInput(ushort(testCase.b) * 256 + 0x34, 0x01)
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(0x01, mem[0x0040])
            XCTAssertEqual(testCase.b - 1, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x0041, z80.HL)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_IND()
    {
        [
            (b: byte(0x03), zero: false),
            (b: byte(0x01), zero: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadReg16Val(0, ushort(testCase.b) * 256 + 0x34)
            asm.Ind()
            asm.Halt()

            z80.testPorts.SetInput(ushort(testCase.b)	 * 256 + 0x34, 0x01)
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(0x01, mem[0x0040])
            XCTAssertEqual(testCase.b - 1, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x003F, z80.HL)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_INIR()
    {
        [
            byte(0x03),
            byte(0x01),
        ].forEach { b in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadReg16Val(0, ushort(b) * 256 + 0x34)
            asm.Inir()
            asm.Halt()

            for i: byte in (1...b).reversed() {
                z80.testPorts.SetInput(ushort(i) * 256 + 0x34, i)
            }
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            for i: byte in 0..<b {
                XCTAssertEqual(b - i, mem[0x0040 + i])
            }
            XCTAssertEqual(0, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x0040 + b, z80.HL)
            XCTAssertEqual(true, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_INDR()
    {
        [
            byte(0x03),
            byte(0x01),
        ].forEach { b in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadReg16Val(0, ushort(b) * 256 + 0x34)
            asm.Indr()
            asm.Halt()

            for i: byte in (1...b).reversed() {
                z80.testPorts.SetInput(ushort(i) * 256 + 0x34, i)
            }
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            for i: byte in 0..<b {
                XCTAssertEqual(b - i, mem[0x0040 - i])
            }
            XCTAssertEqual(0, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x0040 - b, z80.HL)
            XCTAssertEqual(true, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_OUT_n_A()
    {
        [
            byte(0x00),
            byte(0x42),
        ].forEach { val in
            tearDown()
            setUp()

            asm.LoadRegVal(7, val)
            asm.OutPortA(0x34)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(val, z80.testPorts.GetOutput(ushort(val) * 256 + 0x34))
        }
    }

    func test_OUT_BC_r()
    {
        [
            (reg: byte(2), val: byte(0x3C), sign: false, zero: false, parity: true),
            (reg: byte(3), val: byte(0xBB), sign: true, zero: false, parity: true),
            (reg: byte(2), val: byte(0xEB), sign: true, zero: false, parity: true),
            (reg: byte(4), val: byte(0x38), sign: false, zero: false, parity: false),
            (reg: byte(7), val: byte(0x9A), sign: true, zero: false, parity: true),
            (reg: byte(2), val: byte(0x47), sign: false, zero: false, parity: true),
            (reg: byte(3), val: byte(0x8D), sign: true, zero: false, parity: true),
            (reg: byte(5), val: byte(0x71), sign: false, zero: false, parity: true),
            (reg: byte(2), val: byte(0x58), sign: false, zero: false, parity: false),
            (reg: byte(7), val: byte(0x45), sign: false, zero: false, parity: false),
            (reg: byte(3), val: byte(0x56), sign: false, zero: false, parity: true),
            (reg: byte(7), val: byte(0x91), sign: true, zero: false, parity: false),
            (reg: byte(5), val: byte(0x00), sign: false, zero: true, parity: true),
            (reg: byte(2), val: byte(0xC0), sign: true, zero: false, parity: true),
            (reg: byte(2), val: byte(0x79), sign: false, zero: false, parity: false),
            (reg: byte(7), val: byte(0x5A), sign: false, zero: false, parity: true),
            (reg: byte(4), val: byte(0x9A), sign: true, zero: false, parity: true),
            (reg: byte(3), val: byte(0x07), sign: false, zero: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(0, 0x1234)
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.OutBcReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.val, z80.testPorts.GetOutput(0x1234))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_OUTI()
    {
        [
            (b: byte(0x03), zero: false),
            (b: byte(0x01), zero: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHLVal(0x01)
            asm.LoadReg16Val(0, ushort(testCase.b) * 256 + 0x34)
            asm.Outi()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(0x01, z80.testPorts.GetOutput(ushort(testCase.b) * 256 + 0x34))
            XCTAssertEqual(testCase.b - 1, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x0041, z80.HL)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_OUTD()
    {
        [
            (b: byte(0x03), zero: false),
            (b: byte(0x01), zero: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHLVal(0x01)
            asm.LoadReg16Val(0, ushort(testCase.b) * 256 + 0x34)
            asm.Outd()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(0x01, z80.testPorts.GetOutput(ushort(testCase.b) * 256 + 0x34))
            XCTAssertEqual(testCase.b - 1, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x003F, z80.HL)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_OUTIR()
    {
        [
            byte(0x03),
            byte(0x01),
        ].forEach { b in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadReg16Val(0, ushort(b) * 256 + 0x34)
            asm.Outir()
            asm.Halt()

            for i: byte in 0..<b {
                mem[0x0040 + i] = b - i
            }
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            for i: byte in (1...b).reversed() {
                XCTAssertEqual(i, z80.testPorts.GetOutput(ushort(i) * 256 + 0x34))
            }
            XCTAssertEqual(0, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x0040 + b, z80.HL)
            XCTAssertEqual(true, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_OUTDR()
    {
        [
            byte(0x03),
            byte(0x01),
        ].forEach { b in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadReg16Val(0, ushort(b) * 256 + 0x34)
            asm.Outdr()
            asm.Halt()

            for i: byte in 0..<b {
                mem[0x0040 - i] = b - i
            }
            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            for i: byte in (1...b).reversed() {
                XCTAssertEqual(i, z80.testPorts.GetOutput(ushort(i) * 256 + 0x34))
            }
            XCTAssertEqual(0, z80.B)
            XCTAssertEqual(0x34, z80.C)
            XCTAssertEqual(0x0040 - b, z80.HL)
            XCTAssertEqual(true, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }
}
