import XCTest
@testable import z80

final class SixteenBitArithmeticGroupTests: XCTestCase {
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

    func test_ADD_HL_ss()
    {
        [
            (reg: Byte(0), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(0), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(0), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(0), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(1), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(1), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(1), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(1), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(2), val: Int(0x1234), val2: Int(0x1234), halfcarry: false, carry: false),
            (reg: Byte(2), val: Int(0x0FFF), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(2), val: Int(0xFFFF), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(3), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(3), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(3), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(3), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort(truncatingIfNeeded: testCase.val))
            asm.LoadReg16Val(testCase.reg, UShort(truncatingIfNeeded: testCase.val2))
            asm.AddHlReg16(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            let trueSum = testCase.val + testCase.val2
            let sixteenBitSum = UShort(truncatingIfNeeded: trueSum)
            XCTAssertEqual(sixteenBitSum, z80.HL)
            XCTAssertEqual(testCase.halfcarry, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADD_IX_ss()
    {
        [
            (reg: Byte(0), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(0), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(0), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(0), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(1), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(1), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(1), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(1), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(2), val: Int(0x1234), val2: Int(0x1234), halfcarry: false, carry: false),
            (reg: Byte(2), val: Int(0x0FFF), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(2), val: Int(0xFFFF), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(3), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(3), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(3), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(3), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIxVal(UShort(truncatingIfNeeded: testCase.val))
            asm.LoadReg16Val(testCase.reg, UShort(truncatingIfNeeded: testCase.val2))
            asm.AddIxReg16(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            let trueSum = testCase.val + testCase.val2
            let sixteenBitSum = UShort(truncatingIfNeeded: trueSum)
            XCTAssertEqual(sixteenBitSum, z80.IX)
            XCTAssertEqual(testCase.halfcarry, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADD_IY_ss()
    {
        [
            (reg: Byte(0), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(0), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(0), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(0), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(1), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(1), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(1), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(1), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(2), val: Int(0x1234), val2: Int(0x1234), halfcarry: false, carry: false),
            (reg: Byte(2), val: Int(0x0FFF), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(2), val: Int(0xFFFF), val2: Int(0xFFFF), halfcarry: true, carry: true),
            (reg: Byte(3), val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false),
            (reg: Byte(3), val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false),
            (reg: Byte(3), val: Int(0x0001), val2: Int(0x0FFF), halfcarry: true, carry: false),
            (reg: Byte(3), val: Int(0x0001), val2: Int(0xFFFF), halfcarry: true, carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadIyVal(UShort(truncatingIfNeeded: testCase.val))
            asm.LoadReg16Val(testCase.reg, UShort(truncatingIfNeeded: testCase.val2))
            asm.AddIyReg16(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            let trueSum = testCase.val + testCase.val2
            let sixteenBitSum = UShort(truncatingIfNeeded: trueSum)
            XCTAssertEqual(sixteenBitSum, z80.IY)
            XCTAssertEqual(testCase.halfcarry, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADC_HL_ss()
    {
        [
            (reg: Byte(0), useCarry: false, val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(0), useCarry: true, val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(0), useCarry: false, val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false, overflow: false),
            (reg: Byte(0), useCarry: false, val: Int(0x7FF0), val2: Int(0x0234), halfcarry: true, carry: false, overflow: true),
            (reg: Byte(0), useCarry: false, val: Int(0x9FFF), val2: Int(0xAFFF), halfcarry: true, carry: true, overflow: true),
            (reg: Byte(1), useCarry: false, val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(1), useCarry: false, val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false, overflow: false),
            (reg: Byte(1), useCarry: false, val: Int(0x7FF0), val2: Int(0x0234), halfcarry: true, carry: false, overflow: true),
            (reg: Byte(1), useCarry: false, val: Int(0x9FFF), val2: Int(0xAFFF), halfcarry: true, carry: true, overflow: true),
            (reg: Byte(2), useCarry: false, val: Int(0x1234), val2: Int(0x1234), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(2), useCarry: false, val: Int(0x6234), val2: Int(0x6234), halfcarry: false, carry: false, overflow: true),
            (reg: Byte(2), useCarry: false, val: Int(0x8234), val2: Int(0x8234), halfcarry: false, carry: true, overflow: true),
            (reg: Byte(3), useCarry: false, val: Int(0x1234), val2: Int(0x4321), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(3), useCarry: false, val: Int(0x0FFF), val2: Int(0x0001), halfcarry: true, carry: false, overflow: false),
            (reg: Byte(3), useCarry: false, val: Int(0x7FF0), val2: Int(0x0234), halfcarry: true, carry: false, overflow: true),
            (reg: Byte(3), useCarry: false, val: Int(0x9FFF), val2: Int(0xAFFF), halfcarry: true, carry: true, overflow: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(0, UShort(testCase.useCarry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, UShort(truncatingIfNeeded: testCase.val))
            asm.LoadReg16Val(testCase.reg, UShort(truncatingIfNeeded: testCase.val2))
            asm.AdcHlReg16(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            let trueSum = testCase.val + testCase.val2 + (testCase.useCarry ? 1 : 0)
            let sixteenBitSum = UShort(truncatingIfNeeded: trueSum)
            XCTAssertEqual(sixteenBitSum, z80.HL)
            XCTAssertEqual(Short(truncatingIfNeeded: sixteenBitSum & 0x8000) > 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(sixteenBitSum == 0, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.halfcarry, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SBC_HL_ss()
    {
        [
            (reg: Byte(0), useCarry: false, val: Int(0x0FFF), val2: Int(0x0001), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(0), useCarry: true, val: Int(0x0FFF), val2: Int(0x0001), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(0), useCarry: false, val: Int(0x1234), val2: Int(0x4321), halfcarry: true, carry: true, overflow: false),
            (reg: Byte(0), useCarry: false, val: Int(0x0123), val2: Int(0x0234), halfcarry: true, carry: true, overflow: false),
            (reg: Byte(0), useCarry: false, val: Int(0x0FFF), val2: Int(0x0FFF), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(1), useCarry: false, val: Int(0x0FFF), val2: Int(0x0001), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(1), useCarry: false, val: Int(0x1234), val2: Int(0x4321), halfcarry: true, carry: true, overflow: false),
            (reg: Byte(1), useCarry: false, val: Int(0x0123), val2: Int(0x0234), halfcarry: true, carry: true, overflow: false),
            (reg: Byte(1), useCarry: false, val: Int(0x0FFF), val2: Int(0x0FFF), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(2), useCarry: false, val: Int(0x1234), val2: Int(0x1234), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(3), useCarry: false, val: Int(0x0FFF), val2: Int(0x0001), halfcarry: false, carry: false, overflow: false),
            (reg: Byte(3), useCarry: false, val: Int(0x1234), val2: Int(0x4321), halfcarry: true, carry: true, overflow: false),
            (reg: Byte(3), useCarry: false, val: Int(0x0123), val2: Int(0x0234), halfcarry: true, carry: true, overflow: false),
            (reg: Byte(3), useCarry: false, val: Int(0x0FFF), val2: Int(0x0FFF), halfcarry: false, carry: false, overflow: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(0, UShort(testCase.useCarry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, UShort(truncatingIfNeeded: testCase.val))
            asm.LoadReg16Val(testCase.reg, UShort(truncatingIfNeeded: testCase.val2))
            asm.SbcHlReg16(testCase.reg)
            asm.Halt()

            z80.Run()

            let trueDiff = testCase.val - testCase.val2 - (testCase.useCarry ? 1 : 0)
            let sixteenBitDiff = UShort(truncatingIfNeeded: trueDiff)
            XCTAssertEqual(sixteenBitDiff, z80.HL)
            XCTAssertEqual((sixteenBitDiff & 0x8000) > 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(sixteenBitDiff == 0, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.halfcarry, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_INC_ss()
    {
        [
            Byte(0x00),
            Byte(0x01),
            Byte(0x02),
            Byte(0x03),
        ].forEach { reg in
            tearDown()
            setUp()

            asm.LoadReg16Val(reg, 0x1942)
            asm.IncReg16(reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            switch reg
            {
                case 0:
                    XCTAssertEqual(0x1943, z80.BC)
                    break
                case 1:
                    XCTAssertEqual(0x1943, z80.DE)
                    break
                case 2:
                    XCTAssertEqual(0x1943, z80.HL)
                    break
                case 3:
                    XCTAssertEqual(0x1943, z80.SP)
                    break
                default:
                    break
            }
        }
    }

    func test_INC_IX()
    {
        asm.LoadIxVal(0x1942)
        asm.IncIx()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1943, z80.IX)
    }

    func test_INC_IY()
    {
        asm.LoadIyVal(0x1942)
        asm.IncIy()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1943, z80.IY)
    }

    func test_DEC_ss()
    {
        [
            Byte(0x00),
            Byte(0x01),
            Byte(0x02),
            Byte(0x03),
        ].forEach { reg in
            tearDown()
            setUp()

            asm.LoadReg16Val(reg, 0x1942)
            asm.DecReg16(reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            switch reg
            {
                case 0:
                    XCTAssertEqual(0x1941, z80.BC)
                    break
                case 1:
                    XCTAssertEqual(0x1941, z80.DE)
                    break
                case 2:
                    XCTAssertEqual(0x1941, z80.HL)
                    break
                case 3:
                    XCTAssertEqual(0x1941, z80.SP)
                    break
                default:
                    break
            }
        }
    }

    func test_DEC_IX()
    {
        asm.LoadIxVal(0x1942)
        asm.DecIx()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1941, z80.IX)
    }

    func test_DEC_IY()
    {
        asm.LoadIyVal(0x1942)
        asm.DecIy()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(0x1941, z80.IY)
    }
}
