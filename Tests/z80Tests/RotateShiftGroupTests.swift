import XCTest
@testable import z80

final class RotateShiftGroupTests: XCTestCase {
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


    func test_RLCA()
    {
        [
            (reg: byte(0x01), res: byte(0x02), carry: false),
            (reg: byte(0x81), res: byte(0x02), carry: true),
            (reg: byte(0x42), res: byte(0x84), carry: false),
            (reg: byte(0x84), res: byte(0x08), carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.reg)
            asm.Rlca()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.A)
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RLA()
    {
        [
            (reg: byte(0x01), res: byte(0x04), carry: false),
            (reg: byte(0x81), res: byte(0x05), carry: false),
            (reg: byte(0x42), res: byte(0x08), carry: true),
            (reg: byte(0x84), res: byte(0x11), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.reg)
            asm.Rla()
            asm.Rla()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.A)
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RRCA()
    {
        [
            (reg: byte(0x80), res: byte(0x40), carry: false),
            (reg: byte(0x81), res: byte(0x40), carry: true),
            (reg: byte(0x42), res: byte(0x21), carry: false),
            (reg: byte(0x21), res: byte(0x10), carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.reg)
            asm.Rrca()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.A)
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RRA()
    {
        [
            (reg: byte(0x80), res: byte(0x20), carry: false),
            (reg: byte(0x81), res: byte(0xA0), carry: false),
            (reg: byte(0x42), res: byte(0x10), carry: true),
            (reg: byte(0x21), res: byte(0x88), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.reg)
            asm.Rra()
            asm.Rra()
            asm.Halt()

            z80.Run()



            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.A)
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RLC_r()
    {
        [
            (register: byte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(0), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(0), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (register: byte(0), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (register: byte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (register: byte(2), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(2), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (register: byte(2), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(2), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (register: byte(3), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(3), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (register: byte(3), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(4), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (register: byte(4), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(4), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (register: byte(5), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(5), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (register: byte(5), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(5), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (register: byte(7), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(7), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (register: byte(7), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(7), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.register, testCase.reg)
            asm.RlcReg(testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RLC_HL()
    {
        [
            (reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.reg)
            asm.RlcAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RLC_IX_d()
    {
        [
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RlcAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RLC_IY_d()
    {
        [
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RlcAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RL_r()
    {
        [
            (register: byte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(0), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(0), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(0), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(1), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(2), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(2), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(3), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(4), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(4), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(5), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(5), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(7), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(7), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.register, testCase.reg)
            asm.RlReg(testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RL_HL()
    {
        [
            (reg: byte(0x00), res: byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (reg: byte(0x01), res: byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: byte(0x42), res: byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Scf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.reg)
            asm.RlAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RL_IX_d()
    {
        [
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x01), res: byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(-1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x01), res: byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(0), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x01), res: byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Scf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RlAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RL_IY_d()
    {
        [
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x01), res: byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(-1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x01), res: byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(0), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x01), res: byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(1), reg: byte(0x84), res: byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Scf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RlAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RRC_r()
    {
        [
            (register: byte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (register: byte(1), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (register: byte(1), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (register: byte(2), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(2), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (register: byte(2), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (register: byte(2), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (register: byte(3), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(3), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (register: byte(3), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (register: byte(3), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (register: byte(4), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(4), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (register: byte(4), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (register: byte(4), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (register: byte(5), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(5), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (register: byte(5), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (register: byte(5), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (register: byte(7), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(7), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (register: byte(7), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (register: byte(7), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.register, testCase.reg)
            asm.RrcReg(testCase.register)
            asm.RrcReg(testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RRC_HL()
    {
        [
            (reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.reg)
            asm.RrcAddrHl()
            asm.RrcAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RRC_IX_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RrcAddrIx(testCase.disp)
            asm.RrcAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RRC_IY_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RrcAddrIy(testCase.disp)
            asm.RrcAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RR_r()
    {
        [
            (register: byte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(0), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(0), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (register: byte(0), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(0), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (register: byte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (register: byte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (register: byte(2), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(2), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (register: byte(2), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (register: byte(3), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(3), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (register: byte(3), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (register: byte(4), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(4), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (register: byte(4), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (register: byte(5), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(5), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (register: byte(5), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (register: byte(7), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(7), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (register: byte(7), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.register, testCase.reg)
            asm.RrReg(testCase.register)
            asm.RrReg(testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RR_HL()
    {
        [
            (reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.reg)
            asm.RrAddrHl()
            asm.RrAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RR_IX_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RrAddrIx(testCase.disp)
            asm.RrAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RR_IY_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.RrAddrIy(testCase.disp)
            asm.RrAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SLA_r()
    {
        [
            (register: byte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(0), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(0), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(0), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(1), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(2), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(2), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(3), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(4), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(4), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(5), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(5), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(7), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (register: byte(7), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.register, testCase.reg)
            asm.SlaReg(testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SLA_HL()
    {
        [
            (reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.reg)
            asm.SlaAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SLA_IX_d()
    {
        [
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.SlaAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SLA_IY_d()
    {
        [
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(-1), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(0), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x01), res: byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (disp: sbyte(1), reg: byte(0x84), res: byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.SlaAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRA_r()
    {
        [
            (register: byte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(1), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(1), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(2), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(2), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(2), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(3), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(3), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(3), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(4), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(4), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(4), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(5), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(5), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(5), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(7), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(7), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (register: byte(7), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.register, testCase.reg)
            asm.SraReg(testCase.register)
            asm.SraReg(testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRA_HL()
    {
        [
            (reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.reg)
            asm.SraAddrHl()
            asm.SraAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRA_IX_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.SraAddrIx(testCase.disp)
            asm.SraAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRA_IY_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.SraAddrIy(testCase.disp)
            asm.SraAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRL_r()
    {
        [
            (register: byte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(2), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(2), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(3), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(3), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(4), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(4), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(5), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(5), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (register: byte(7), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (register: byte(7), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.register, testCase.reg)
            asm.SrlReg(testCase.register)
            asm.SrlReg(testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register))
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRL_HL()
    {
        [
            (reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.reg)
            asm.SrlAddrHl()
            asm.SrlAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRL_IX_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.SrlAddrIx(testCase.disp)
            asm.SrlAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SRL_IY_d()
    {
        [
            (disp: sbyte(1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(-1), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(-1), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x00), res: byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (disp: sbyte(0), reg: byte(0x80), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x81), res: byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x42), res: byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (disp: sbyte(0), reg: byte(0x21), res: byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.reg)
            asm.SrlAddrIy(testCase.disp)
            asm.SrlAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.disp])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_RLD()
    {
        [
            (a: byte(0x7A), b: byte(0x31), ra: byte(0x73), rb: byte(0x1A), zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.b)
            asm.LoadRegVal(7, testCase.a)
            asm.Rld()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.ra, z80.A)
            XCTAssertEqual(testCase.rb, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_RRD()
    {
        [
            (a: byte(0x84), b: byte(0x20), ra: byte(0x80), rb: byte(0x42), zero: false, sign: true, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.b)
            asm.LoadRegVal(7, testCase.a)
            asm.Rrd()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.ra, z80.A)
            XCTAssertEqual(testCase.rb, mem[0x0040])
            XCTAssertEqual(testCase.sign, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }
}
