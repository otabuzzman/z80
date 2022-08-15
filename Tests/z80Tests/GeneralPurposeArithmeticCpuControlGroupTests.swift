import XCTest
@testable import z80

final class GeneralPurposeArithmeticCpuControlGroupTests: XCTestCase {
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

    func test_HALT()
    {
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
    }

    func test_NOOP()
    {
        asm.Nop()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
    }

    func test_EI()
    {
        asm.Di()
        asm.Ei()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(true, z80.Iff1)
        XCTAssertEqual(true, z80.Iff2)
    }

    func test_DI()
    {
        asm.Ei()
        asm.Di()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertEqual(false, z80.Iff1)
        XCTAssertEqual(false, z80.Iff2)
    }

    func test_DAA_Add()
    {
        [
            (a: Byte(0x01), val: Byte(0x99), correct: 0x100, halfcarry: false),
            (a: Byte(0x01), val: Byte(0x98), correct: 0x99, halfcarry: false),
            (a: Byte(0x10), val: Byte(0x89), correct: 0x99, halfcarry: false),
            (a: Byte(0x01), val: Byte(0x89), correct: 0x90, halfcarry: true),
            (a: Byte(0x10), val: Byte(0x90), correct: 0x100, halfcarry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.a)
            asm.AddAVal(testCase.val)
            asm.Daa()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            let trueSum = testCase.correct
            let byteSum = Byte(trueSum % 256)
            let sbyteSum = SByte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.halfcarry, z80.FlagH, "Flag H contained the wrong value")
            let overflow = trueSum > 256
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_DAA_ByteToHex()
    {
        [
            (a: Byte(0x00), val: "0"),
            (a: Byte(0x01), val: "1"),
            (a: Byte(0x02), val: "2"),
            (a: Byte(0x03), val: "3"),
            (a: Byte(0x04), val: "4"),
            (a: Byte(0x05), val: "5"),
            (a: Byte(0x06), val: "6"),
            (a: Byte(0x07), val: "7"),
            (a: Byte(0x08), val: "8"),
            (a: Byte(0x09), val: "9"),
            (a: Byte(0x0A), val: "A"),
            (a: Byte(0x0B), val: "B"),
            (a: Byte(0x0C), val: "C"),
            (a: Byte(0x0D), val: "D"),
            (a: Byte(0x0E), val: "E"),
            (a: Byte(0x0F), val: "F"),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.a)
            asm.AndVal(0x0F)
            asm.AddAVal(0x90)
            asm.Daa()
            asm.AdcAVal(0x40)
            asm.Daa()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(Character(testCase.val).asciiValue!, z80.A)
        }
    }

    func test_DAA_Sub()
    {
        [
            (a: Byte(1), val: Byte(1), correct: 0x00, halfcarry: false),
            (a: Byte(2), val: Byte(1), correct: 0x01, halfcarry: false),
            (a: Byte(10), val: Byte(1), correct: 0x09, halfcarry: false),
            (a: Byte(16), val: Byte(1), correct: 0x15, halfcarry: true),
            (a: Byte(0xA0), val: Byte(0x10), correct: 0x90, halfcarry: false),
            (a: Byte(0xAA), val: Byte(0x11), correct: 0x99, halfcarry: false),
            (a: Byte(10), val: Byte(0), correct: 0x10, halfcarry: true),
            (a: Byte(100), val: Byte(1), correct: 99, halfcarry: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.a)
            asm.SubVal(testCase.val)
            asm.Daa()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            let trueSum = testCase.correct
            let byteSum = Byte(trueSum % 256)
            let sbyteSum = SByte(truncatingIfNeeded: byteSum)
            XCTAssertEqual(byteSum, z80.A)
            XCTAssertEqual(sbyteSum < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(z80.A == 0x00, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.halfcarry, z80.FlagH, "Flag H contained the wrong value")
            let overflow = trueSum > 256
            XCTAssertEqual(overflow, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(trueSum > 0xFF, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_CPL()
    {
        [
            Byte(0x00),
            Byte(0x08),
            Byte(0x80),
            Byte(0xFF),
        ].forEach { a in
            tearDown()
            setUp()

            asm.LoadRegVal(7, a)
            asm.Cpl()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(a ^ 0xFF, z80.A)
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_NEG()
    {
        [
            Byte(0x00),
            Byte(0x08),
            Byte(0x80),
            Byte(0xFF),
        ].forEach { a in
            tearDown()
            setUp()

            asm.LoadRegVal(7, a)
            asm.Neg()
            asm.Halt()

            z80.Run()

            let exp = -Short(a)
            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(Byte(truncatingIfNeeded: exp), z80.A)
            XCTAssertEqual(SByte(truncatingIfNeeded: exp) < 0, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(exp == 0, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual((a & 15) > 0, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(a == 0x80, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(true, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(a != 0, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_CCF()
    {
        [
            (carry: true, rest: true),
            (carry: true, rest: false),
            (carry: false, rest: true),
            (carry: false, rest: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort((testCase.carry ? 1 : 0) + (testCase.rest ? 254 : 0)))
            asm.PushReg16(2)
            asm.PopReg16(3)
            asm.Ccf()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.rest, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.rest, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.rest, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(testCase.rest, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(!testCase.carry, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_SCF()
    {
        [
            (carry: true, rest: true),
            (carry: true, rest: false),
            (carry: false, rest: true),
            (carry: false, rest: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort((testCase.carry ? 1 : 0) + (testCase.rest ? 254 : 0)))
            asm.PushReg16(2)
            asm.PopReg16(3)
            asm.Scf()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.rest, z80.FlagS, "Flag S contained the wrong value")
            XCTAssertEqual(testCase.rest, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(testCase.rest, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(testCase.rest, z80.FlagP, "Flag P contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
            XCTAssertEqual(true, z80.FlagC, "Flag C contained the wrong value")
        }
    }

    func test_IM_0()
    {
        asm.Im0()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertTrue(false, "IM 0 not implemented")
    }

    func test_IM_1()
    {
        asm.Im1()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertTrue(false, "IM 1 not implemented")
    }

    func test_IM_2()
    {
        asm.Im2()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.addr, z80.PC)
        XCTAssertTrue(false, "IM 2 not implemented")
    }
}
