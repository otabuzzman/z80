import XCTest
@testable import z80

final class EightBitArithmeticGroupTests: XCTestCase {
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

    private func Countbits(_ value: int) -> int
    {
        var count = 0
        var v = value
        while v != 0
        {
            count += 1
            v &= v - 1
        }
        return count
    }

    // Useful ref: http://stackoverflow.com/questions/8034566/overflow-and-testCase.carry-flags-on-z80

    func test_ADD_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.AddAReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = ushort(testCase.val) + ushort(testCase.val2)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADD_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.AddAVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = ushort(testCase.val) + ushort(testCase.val2)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADD_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.AddAAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = ushort(testCase.val) + ushort(testCase.val2)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADD_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.AddAAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = ushort(testCase.val) + ushort(testCase.val2)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADD_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.AddAAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = ushort(testCase.val) + ushort(testCase.val2)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADC_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44), carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.AdcAReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueSum = ushort(testCase.val) + ushort(testCase.val2)
            if testCase.carry {
                trueSum += 1
            }
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADC_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11), carry: true),
            (val: byte(0x44), val2: byte(0x0F), carry: true),
            (val: byte(0x44), val2: byte(0xFF), carry: true),
            (val: byte(0x44), val2: byte(0x01), carry: true),
            (val: byte(0xF4), val2: byte(0x11), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), carry: true),
            (val: byte(0xF4), val2: byte(0x01), carry: true),
            (val: byte(0x44), val2: byte(0x11), carry: false),
            (val: byte(0x44), val2: byte(0x0F), carry: false),
            (val: byte(0x44), val2: byte(0xFF), carry: false),
            (val: byte(0x44), val2: byte(0x01), carry: false),
            (val: byte(0xF4), val2: byte(0x11), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), carry: false),
            (val: byte(0xF4), val2: byte(0x01), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadRegVal(7, testCase.val)
            asm.AdcAVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueSum = ushort(testCase.val) + ushort(testCase.val2)
            if testCase.carry {
                trueSum += 1
            }
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADC_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11), carry: true),
            (val: byte(0x44), val2: byte(0x0F), carry: true),
            (val: byte(0x44), val2: byte(0xFF), carry: true),
            (val: byte(0x44), val2: byte(0x01), carry: true),
            (val: byte(0xF4), val2: byte(0x11), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), carry: true),
            (val: byte(0xF4), val2: byte(0x01), carry: true),
            (val: byte(0x44), val2: byte(0x11), carry: false),
            (val: byte(0x44), val2: byte(0x0F), carry: false),
            (val: byte(0x44), val2: byte(0xFF), carry: false),
            (val: byte(0x44), val2: byte(0x01), carry: false),
            (val: byte(0xF4), val2: byte(0x11), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), carry: false),
            (val: byte(0xF4), val2: byte(0x01), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.AdcAAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueSum = ushort(testCase.val) + ushort(testCase.val2)
            if testCase.carry {
                trueSum += 1
            }
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADC_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.AdcAAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueSum = ushort(testCase.val) + ushort(testCase.val2)
            if testCase.carry {
                trueSum += 1
            }
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_ADC_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.AdcAAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueSum = ushort(testCase.val) + ushort(testCase.val2)
            if testCase.carry {
                trueSum += 1
            }
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteSum < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SUB_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.SubReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueDiff) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SUB_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.SubVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueDiff) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SUB_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.SubAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueDiff) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SUB_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.SubAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueDiff) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SUB_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.SubAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueDiff) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SBC_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF), carry: false),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF), carry: false),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01), carry: false),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44), carry: false),
            (reg: byte(0), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF), carry: true),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF), carry: true),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01), carry: true),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44), carry: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.SbcAReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueDiff = short(testCase.val) - short(testCase.val2)
            if testCase.carry {
                trueDiff -= 1
            }
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (testCase.carry ? 1 : 0) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SBC_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11), carry: true),
            (val: byte(0x44), val2: byte(0x0F), carry: true),
            (val: byte(0x44), val2: byte(0xFF), carry: true),
            (val: byte(0x44), val2: byte(0x01), carry: true),
            (val: byte(0xF4), val2: byte(0x11), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), carry: true),
            (val: byte(0xF4), val2: byte(0x01), carry: true),
            (val: byte(0x44), val2: byte(0x11), carry: false),
            (val: byte(0x44), val2: byte(0x0F), carry: false),
            (val: byte(0x44), val2: byte(0xFF), carry: false),
            (val: byte(0x44), val2: byte(0x01), carry: false),
            (val: byte(0xF4), val2: byte(0x11), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), carry: false),
            (val: byte(0xF4), val2: byte(0x01), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadRegVal(7, testCase.val)
            asm.SbcAVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueDiff = short(testCase.val) - short(testCase.val2)
            if testCase.carry {
                trueDiff -= 1
            }
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (testCase.carry ? 1 : 0) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SBC_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11), carry: true),
            (val: byte(0x44), val2: byte(0x0F), carry: true),
            (val: byte(0x44), val2: byte(0xFF), carry: true),
            (val: byte(0x44), val2: byte(0x01), carry: true),
            (val: byte(0xF4), val2: byte(0x11), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), carry: true),
            (val: byte(0xF4), val2: byte(0x01), carry: true),
            (val: byte(0x44), val2: byte(0x11), carry: false),
            (val: byte(0x44), val2: byte(0x0F), carry: false),
            (val: byte(0x44), val2: byte(0xFF), carry: false),
            (val: byte(0x44), val2: byte(0x01), carry: false),
            (val: byte(0xF4), val2: byte(0x11), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), carry: false),
            (val: byte(0xF4), val2: byte(0x01), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.SbcAAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueDiff = short(testCase.val) - short(testCase.val2)
            if testCase.carry {
                trueDiff -= 1
            }
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (testCase.carry ? 1 : 0) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SBC_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.SbcAAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueDiff = short(testCase.val) - short(testCase.val2)
            if testCase.carry {
                trueDiff -= 1
            }
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (testCase.carry ? 1 : 0) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SBC_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: true),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: true),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1), carry: false),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1), carry: false),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1), carry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(3, 0x0060)
            asm.LoadReg16Val(0, ushort(testCase.carry ? 1 : 0))
            asm.PushReg16(0)
            asm.PopReg16(3)
            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.SbcAAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            var trueDiff = short(testCase.val) - short(testCase.val2)
            if testCase.carry {
                trueDiff -= 1
            }
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(byteDiff, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) + (testCase.carry ? 1 : 0) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_AND_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.AndReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val & testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_AND_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.AndVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val & testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_AND_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.AndAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val & testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_AND_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.AndAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val & testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_AND_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.AndAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val & testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_OR_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.OrReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val | testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_OR_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val | testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_OR_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.OrAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val | testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_OR_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.OrAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val | testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_OR_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.OrAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val | testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_XOR_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.XorReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val ^ testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_XOR_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.XorVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val ^ testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_XOR_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.XorAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val ^ testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_XOR_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.XorAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val ^ testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_XOR_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.XorAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let res = byte(testCase.val ^ testCase.val2)
            let sres = sbyte(truncatingIfNeeded: res)
            XCTAssertEqual(res, z80.A)
            XCTAssertEqual(sres < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(false, z80.FlagH, "Flag H contained the wrong value")
            let parity = Countbits(int(res)) % 2 == 0
            XCTAssertEqual(parity, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_CP_A_r()
    {
        [
            (reg: byte(0), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x11)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x0F)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0xFF)),
            (reg: byte(0), val: byte(0xF4), val2: byte(0x01)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(1), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(1), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(2), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(2), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(3), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(3), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(4), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(4), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x11)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x0F)),
            (reg: byte(5), val: byte(0x44), val2: byte(0xFF)),
            (reg: byte(5), val: byte(0x44), val2: byte(0x01)),
            (reg: byte(7), val: byte(0x44), val2: byte(0x44)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.LoadRegVal(testCase.reg, testCase.val2)
            asm.CpReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(testCase.val, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.val == testCase.val2, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_CP_A_n()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.CpVal(testCase.val2)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(testCase.val, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.val == testCase.val2, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_CP_A_at_HL()
    {
        [
            (val: byte(0x44), val2: byte(0x11)),
            (val: byte(0x44), val2: byte(0x0F)),
            (val: byte(0x44), val2: byte(0xFF)),
            (val: byte(0x44), val2: byte(0x01)),
            (val: byte(0xF4), val2: byte(0x11)),
            (val: byte(0xF4), val2: byte(0x0F)),
            (val: byte(0xF4), val2: byte(0xFF)),
            (val: byte(0xF4), val2: byte(0x01)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.CpAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(testCase.val, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.val == testCase.val2, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_CP_A_at_IX()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIxVal(0x0040)
            asm.CpAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(testCase.val, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.val == testCase.val2, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_CP_A_at_IY()
    {
        [
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(0)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(0)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(1)),
            (val: byte(0x44), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0x44), val2: byte(0x01), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x11), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x0F), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0xFF), disp: sbyte(-1)),
            (val: byte(0xF4), val2: byte(0x01), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val2)
            asm.LoadRegVal(7, testCase.val)
            asm.LoadIyVal(0x0040)
            asm.CpAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueDiff = short(testCase.val) - short(testCase.val2)
            let byteDiff = byte(truncatingIfNeeded: trueDiff % 256)
            let sbyteDiff = sbyte(truncatingIfNeeded: byteDiff)
            XCTAssertEqual(testCase.val, z80.A)
            XCTAssertEqual(sbyteDiff < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val2) > (0x0F & testCase.val), z80.FlagH, "Flag H contained the wrong value")
            let overflow = ((testCase.val < 0x7F) == (testCase.val2 < 0x7F)) && ((testCase.val < 0x7F) == (sbyteDiff < 0)) // if both operands are positive and result is negative or if both are negative and result is positive
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueDiff > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_INC_r()
    {
        [
            (reg: byte(0), val: byte(0x28)),
            (reg: byte(0), val: byte(0x7F)),
            (reg: byte(1), val: byte(0x28)),
            (reg: byte(1), val: byte(0x7F)),
            (reg: byte(2), val: byte(0x28)),
            (reg: byte(2), val: byte(0x7F)),
            (reg: byte(3), val: byte(0x28)),
            (reg: byte(3), val: byte(0x7F)),
            (reg: byte(4), val: byte(0x28)),
            (reg: byte(4), val: byte(0x7F)),
            (reg: byte(5), val: byte(0x28)),
            (reg: byte(5), val: byte(0x7F)),
            (reg: byte(7), val: byte(0x28)),
            (reg: byte(7), val: byte(0x7F)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.IncReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(testCase.val) + short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.Reg8(testCase.reg))
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.Reg8(testCase.reg) == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(1 + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = testCase.val == 0x7F
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_INC_at_HL()
    {
        [
            byte(0x28),
            byte(0x7F),
        ].forEach { val in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(val)
            asm.IncAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(val) + short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, mem[0x0040])
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(mem[0x0040] == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(1 + (0x0F & val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = val == 0x7F
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_INC_at_IX()
    {
        [
            (val: byte(0x28), disp: sbyte(0)),
            (val: byte(0x7F), disp: sbyte(0)),
            (val: byte(0x28), disp: sbyte(1)),
            (val: byte(0x7F), disp: sbyte(1)),
            (val: byte(0x28), disp: sbyte(-1)),
            (val: byte(0x7F), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val)
            asm.LoadIxVal(0x0040)
            asm.IncAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(testCase.val) + short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, mem[0x0040 + testCase.disp])
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(byteSum == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(1 + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = testCase.val == 0x7F
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_INC_at_IY()
    {
        [
            (val: byte(0x28), disp: sbyte(0)),
            (val: byte(0x7F), disp: sbyte(0)),
            (val: byte(0x28), disp: sbyte(1)),
            (val: byte(0x7F), disp: sbyte(1)),
            (val: byte(0x28), disp: sbyte(-1)),
            (val: byte(0x7F), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val)
            asm.LoadIyVal(0x0040)
            asm.IncAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(testCase.val) + short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, mem[0x0040 + testCase.disp])
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(byteSum == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(1 + (0x0F & testCase.val) > 0x0F, z80.FlagH, "Flag H contained the wrong value")
            let overflow = testCase.val == 0x7F
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_DEC_r()
    {
        [
            (reg: byte(0), val: byte(0x28)),
            (reg: byte(0), val: byte(0x80)),
            (reg: byte(1), val: byte(0x28)),
            (reg: byte(1), val: byte(0x80)),
            (reg: byte(2), val: byte(0x28)),
            (reg: byte(2), val: byte(0x80)),
            (reg: byte(3), val: byte(0x28)),
            (reg: byte(3), val: byte(0x80)),
            (reg: byte(4), val: byte(0x28)),
            (reg: byte(4), val: byte(0x80)),
            (reg: byte(5), val: byte(0x28)),
            (reg: byte(5), val: byte(0x80)),
            (reg: byte(7), val: byte(0x28)),
            (reg: byte(7), val: byte(0x80)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.reg, testCase.val)
            asm.DecReg(testCase.reg)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(testCase.val) - short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.Reg8(testCase.reg))
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.Reg8(testCase.reg) == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val) == 0, z80.FlagH, "Flag H contained the wrong value")
            let overflow = testCase.val == 0x80
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_DEC_at_HL()
    {
        [
            byte(0x28),
            byte(0x80),
        ].forEach { val in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(val)
            asm.DecAddrHl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(val) - short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, mem[0x0040])
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(mem[0x0040] == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & val) == 0, z80.FlagH, "Flag H contained the wrong value")
            let overflow = val == 0x80
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_DEC_at_IX()
    {
        [
            (val: byte(0x28), disp: sbyte(0)),
            (val: byte(0x80), disp: sbyte(0)),
            (val: byte(0x28), disp: sbyte(1)),
            (val: byte(0x80), disp: sbyte(1)),
            (val: byte(0x28), disp: sbyte(-1)),
            (val: byte(0x80), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val)
            asm.LoadIxVal(0x0040)
            asm.DecAddrIx(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(testCase.val) - short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, mem[0x0040 + testCase.disp])
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(byteSum == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val) == 0, z80.FlagH, "Flag H contained the wrong value")
            let overflow = testCase.val == 0x80
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_DEC_at_IY()
    {
        [
            (val: byte(0x28), disp: sbyte(0)),
            (val: byte(0x80), disp: sbyte(0)),
            (val: byte(0x28), disp: sbyte(1)),
            (val: byte(0x80), disp: sbyte(1)),
            (val: byte(0x28), disp: sbyte(-1)),
            (val: byte(0x80), disp: sbyte(-1)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0040) + testCase.disp)
            asm.LoadAtHlVal(testCase.val)
            asm.LoadIyVal(0x0040)
            asm.DecAddrIy(testCase.disp)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            let trueSum = short(testCase.val) - short(1)
            let byteSum = byte(trueSum % 256)
            let sbyteSum = sbyte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, mem[0x0040 + testCase.disp])
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(byteSum == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((0x0F & testCase.val) == 0, z80.FlagH, "Flag H contained the wrong value")
            let overflow = testCase.val == 0x80
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(ushort(truncatingIfNeeded: trueSum) > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }
}
