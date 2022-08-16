import XCTest
@testable import z80

final class RotateShiftGroupTests: XCTestCase {
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


    func test_RLCA()
    {
        [
            (val: Byte(0x01), res: Byte(0x02), carry: false),
            (val: Byte(0x81), res: Byte(0x02), carry: true),
            (val: Byte(0x42), res: Byte(0x84), carry: false),
            (val: Byte(0x84), res: Byte(0x08), carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.val)
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
            (val: Byte(0x01), res: Byte(0x04), carry: false),
            (val: Byte(0x81), res: Byte(0x05), carry: false),
            (val: Byte(0x42), res: Byte(0x08), carry: true),
            (val: Byte(0x84), res: Byte(0x11), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.val)
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
            (val: Byte(0x80), res: Byte(0x40), carry: false),
            (val: Byte(0x81), res: Byte(0x40), carry: true),
            (val: Byte(0x42), res: Byte(0x21), carry: false),
            (val: Byte(0x21), res: Byte(0x10), carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.val)
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
            (val: Byte(0x80), res: Byte(0x20), carry: false),
            (val: Byte(0x81), res: Byte(0xA0), carry: false),
            (val: Byte(0x42), res: Byte(0x10), carry: true),
            (val: Byte(0x21), res: Byte(0x88), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(7, testCase.val)
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
            (reg: Byte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(0), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(0), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(0), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(2), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(3), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(4), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(5), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(7), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.RlcReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.reg))
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
            (val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val)
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
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RlcAddrIx(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RlcAddrIy(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (reg: Byte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(0), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(0), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(0), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(1), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(2), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(3), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(4), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(5), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(7), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.RlReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.reg))
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
            (val: Byte(0x00), res: Byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (val: Byte(0x01), res: Byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (val: Byte(0x42), res: Byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Scf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val)
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
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x01), res: Byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(-1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x01), res: Byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(0), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x00), res: Byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x01), res: Byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Scf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RlAddrIx(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x01), res: Byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(-1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x01), res: Byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(0), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x00), res: Byte(0x01), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x01), res: Byte(0x03), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x03), carry: true, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x85), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(1), val: Byte(0x84), res: Byte(0x09), carry: true, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Scf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RlAddrIy(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (reg: Byte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (reg: Byte(1), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (reg: Byte(2), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (reg: Byte(3), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (reg: Byte(4), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (reg: Byte(5), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (reg: Byte(7), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.RrcReg(testCase.reg)
            asm.RrcReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.reg))
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
            (val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val)
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RrcAddrIx(testCase.d)
            asm.RrcAddrIx(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x60), carry: false, zero: false, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x90), carry: true, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x48), carry: false, zero: false, sign: false, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RrcAddrIy(testCase.d)
            asm.RrcAddrIy(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (reg: Byte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(0), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(0), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(0), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(0), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(2), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(2), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(3), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(3), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(4), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(4), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(5), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(5), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(7), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(7), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.RrReg(testCase.reg)
            asm.RrReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.reg))
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
            (val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val)
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RrAddrIx(testCase.d)
            asm.RrAddrIx(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0xA0), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x88), carry: false, zero: false, sign: true, parity: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.RrAddrIy(testCase.d)
            asm.RrAddrIy(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (reg: Byte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(0), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(0), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(0), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(1), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(2), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(3), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(4), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(5), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (reg: Byte(7), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.SlaReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.reg))
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
            (val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val)
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
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.SlaAddrIx(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(-1), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(0), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x01), res: Byte(0x02), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x02), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x84), carry: false, zero: false, sign: true, parity: true),
            (d: SByte(1), val: Byte(0x84), res: Byte(0x08), carry: true, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.SlaAddrIy(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (reg: Byte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(1), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(2), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(2), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(3), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(3), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(4), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(4), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(5), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(5), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(7), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (reg: Byte(7), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.SraReg(testCase.reg)
            asm.SraReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.reg))
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
            (val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val)
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.SraAddrIx(testCase.d)
            asm.SraAddrIx(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0xE0), carry: false, zero: false, sign: true, parity: false),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.SraAddrIy(testCase.d)
            asm.SraAddrIy(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (reg: Byte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(2), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(2), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(3), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(3), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(4), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(4), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(5), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(5), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (reg: Byte(7), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (reg: Byte(7), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.SrlReg(testCase.reg)
            asm.SrlReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.reg))
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
            (val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val)
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIxVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.SrlAddrIx(testCase.d)
            asm.SrlAddrIx(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (d: SByte(1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(-1), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(-1), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x00), res: Byte(0x00), carry: false, zero: true, sign: false, parity: true),
            (d: SByte(0), val: Byte(0x80), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x81), res: Byte(0x20), carry: false, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x42), res: Byte(0x10), carry: true, zero: false, sign: false, parity: false),
            (d: SByte(0), val: Byte(0x21), res: Byte(0x08), carry: false, zero: false, sign: false, parity: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Ccf()
            asm.LoadIyVal(0x0040)
            asm.LoadReg16Val(2, UShort(0x0040) + testCase.d)
            asm.LoadAtHlVal(testCase.val)
            asm.SrlAddrIy(testCase.d)
            asm.SrlAddrIy(testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[0x0040 + testCase.d])
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
            (a: Byte(0x7A), b: Byte(0x31), ra: Byte(0x73), rb: Byte(0x1A), zero: false, sign: false, parity: false),
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
            (a: Byte(0x84), b: Byte(0x20), ra: Byte(0x80), rb: Byte(0x42), zero: false, sign: true, parity: false),
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
