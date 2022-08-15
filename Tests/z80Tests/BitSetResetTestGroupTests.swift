import XCTest
@testable import z80

final class BitSetResetTestGroupTests: XCTestCase {
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

    func test_BIT_B_R()
    {
        [
            (bit: Byte(0), register: Byte(0), set: Byte(0x55), zero: false),
            (bit: Byte(0), register: Byte(1), set: Byte(0x57), zero: false),
            (bit: Byte(0), register: Byte(2), set: Byte(0xA9), zero: false),
            (bit: Byte(0), register: Byte(3), set: Byte(0xA1), zero: false),
            (bit: Byte(0), register: Byte(4), set: Byte(0xD3), zero: false),
            (bit: Byte(0), register: Byte(5), set: Byte(0xF5), zero: false),
            (bit: Byte(0), register: Byte(7), set: Byte(0xD4), zero: true),
            (bit: Byte(1), register: Byte(0), set: Byte(0x7D), zero: true),
            (bit: Byte(1), register: Byte(1), set: Byte(0xD8), zero: true),
            (bit: Byte(1), register: Byte(2), set: Byte(0xF6), zero: false),
            (bit: Byte(1), register: Byte(3), set: Byte(0x5E), zero: false),
            (bit: Byte(1), register: Byte(4), set: Byte(0x08), zero: true),
            (bit: Byte(1), register: Byte(5), set: Byte(0xE4), zero: true),
            (bit: Byte(1), register: Byte(7), set: Byte(0x3D), zero: true),
            (bit: Byte(2), register: Byte(0), set: Byte(0x5F), zero: false),
            (bit: Byte(2), register: Byte(1), set: Byte(0x1E), zero: false),
            (bit: Byte(2), register: Byte(2), set: Byte(0x04), zero: false),
            (bit: Byte(2), register: Byte(3), set: Byte(0x90), zero: true),
            (bit: Byte(2), register: Byte(4), set: Byte(0x1B), zero: true),
            (bit: Byte(2), register: Byte(5), set: Byte(0x97), zero: false),
            (bit: Byte(2), register: Byte(7), set: Byte(0xE5), zero: false),
            (bit: Byte(3), register: Byte(0), set: Byte(0x68), zero: false),
            (bit: Byte(3), register: Byte(1), set: Byte(0x55), zero: true),
            (bit: Byte(3), register: Byte(2), set: Byte(0x0F), zero: false),
            (bit: Byte(3), register: Byte(3), set: Byte(0x97), zero: true),
            (bit: Byte(3), register: Byte(4), set: Byte(0x06), zero: true),
            (bit: Byte(3), register: Byte(5), set: Byte(0x1B), zero: false),
            (bit: Byte(3), register: Byte(7), set: Byte(0xEE), zero: false),
            (bit: Byte(4), register: Byte(0), set: Byte(0x48), zero: true),
            (bit: Byte(4), register: Byte(1), set: Byte(0x36), zero: false),
            (bit: Byte(4), register: Byte(2), set: Byte(0xEF), zero: true),
            (bit: Byte(4), register: Byte(3), set: Byte(0xE1), zero: true),
            (bit: Byte(4), register: Byte(4), set: Byte(0xA3), zero: true),
            (bit: Byte(4), register: Byte(5), set: Byte(0xE0), zero: true),
            (bit: Byte(4), register: Byte(7), set: Byte(0x11), zero: false),
            (bit: Byte(5), register: Byte(0), set: Byte(0x15), zero: true),
            (bit: Byte(5), register: Byte(1), set: Byte(0xF8), zero: false),
            (bit: Byte(5), register: Byte(2), set: Byte(0xC1), zero: true),
            (bit: Byte(5), register: Byte(3), set: Byte(0x06), zero: true),
            (bit: Byte(5), register: Byte(4), set: Byte(0x9D), zero: true),
            (bit: Byte(5), register: Byte(5), set: Byte(0x1C), zero: true),
            (bit: Byte(5), register: Byte(7), set: Byte(0xD1), zero: true),
            (bit: Byte(6), register: Byte(0), set: Byte(0x6A), zero: false),
            (bit: Byte(6), register: Byte(1), set: Byte(0x66), zero: false),
            (bit: Byte(6), register: Byte(2), set: Byte(0x38), zero: true),
            (bit: Byte(6), register: Byte(3), set: Byte(0x9D), zero: true),
            (bit: Byte(6), register: Byte(4), set: Byte(0x3A), zero: true),
            (bit: Byte(6), register: Byte(5), set: Byte(0x0C), zero: true),
            (bit: Byte(6), register: Byte(7), set: Byte(0x72), zero: false),
            (bit: Byte(7), register: Byte(0), set: Byte(0x44), zero: true),
            (bit: Byte(7), register: Byte(1), set: Byte(0x7F), zero: true),
            (bit: Byte(7), register: Byte(2), set: Byte(0x47), zero: true),
            (bit: Byte(7), register: Byte(3), set: Byte(0xE0), zero: false),
            (bit: Byte(7), register: Byte(4), set: Byte(0xE7), zero: false),
            (bit: Byte(7), register: Byte(5), set: Byte(0x44), zero: true),
            (bit: Byte(7), register: Byte(7), set: Byte(0xEC), zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.register, testCase.set)
            asm.BitNReg(testCase.bit, testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_BIT_B_HL()
    {
        [
            (bit: Byte(0), set: Byte(0x60), zero: true),
            (bit: Byte(1), set: Byte(0x22), zero: false),
            (bit: Byte(2), set: Byte(0x11), zero: true),
            (bit: Byte(3), set: Byte(0x87), zero: true),
            (bit: Byte(4), set: Byte(0xB9), zero: false),
            (bit: Byte(5), set: Byte(0x11), zero: true),
            (bit: Byte(6), set: Byte(0x11), zero: true),
            (bit: Byte(7), set: Byte(0x90), zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.set)
            asm.BitNAtHl(testCase.bit)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_BIT_B_IX_d()
    {
        [
            (bit: Byte(0), d: SByte(-70), set: Byte(0x55), zero: false),
            (bit: Byte(1), d: SByte(75), set: Byte(0xA7), zero: false),
            (bit: Byte(2), d: SByte(-43), set: Byte(0x35), zero: false),
            (bit: Byte(3), d: SByte(26), set: Byte(0x7C), zero: false),
            (bit: Byte(4), d: SByte(-77), set: Byte(0x26), zero: true),
            (bit: Byte(5), d: SByte(-18), set: Byte(0x57), zero: true),
            (bit: Byte(6), d: SByte(-6), set: Byte(0xDC), zero: false),
            (bit: Byte(7), d: SByte(-101), set: Byte(0xDE), zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort(0x0140) + testCase.d)
            asm.LoadAtHlVal(testCase.set)
            asm.LoadIxVal(0x0140)
            asm.BitNAtIxd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_BIT_B_IY_d()
    {
        [
            (bit: Byte(0), d: SByte(37), set: Byte(0x72), zero: true),
            (bit: Byte(1), d: SByte(-33), set: Byte(0xB4), zero: true),
            (bit: Byte(2), d: SByte(-80), set: Byte(0x16), zero: false),
            (bit: Byte(3), d: SByte(62), set: Byte(0x33), zero: true),
            (bit: Byte(4), d: SByte(-87), set: Byte(0x16), zero: false),
            (bit: Byte(5), d: SByte(-94), set: Byte(0x50), zero: true),
            (bit: Byte(6), d: SByte(50), set: Byte(0x94), zero: true),
            (bit: Byte(7), d: SByte(-117), set: Byte(0x05), zero: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort(0x0140) + testCase.d)
            asm.LoadAtHlVal(testCase.set)
            asm.LoadIyVal(0x0140)
            asm.BitNAtIyd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_SET_B_R()
    {
        [
            (register: Byte(0), bit: Byte(0), set: Byte(0x4D), res: Byte(0x4D)),
            (register: Byte(0), bit: Byte(1), set: Byte(0x94), res: Byte(0x96)),
            (register: Byte(0), bit: Byte(2), set: Byte(0x69), res: Byte(0x6D)),
            (register: Byte(0), bit: Byte(3), set: Byte(0x23), res: Byte(0x2B)),
            (register: Byte(0), bit: Byte(4), set: Byte(0xCC), res: Byte(0xDC)),
            (register: Byte(0), bit: Byte(5), set: Byte(0x40), res: Byte(0x60)),
            (register: Byte(0), bit: Byte(6), set: Byte(0xB5), res: Byte(0xF5)),
            (register: Byte(0), bit: Byte(7), set: Byte(0xF3), res: Byte(0xF3)),
            (register: Byte(1), bit: Byte(0), set: Byte(0xD4), res: Byte(0xD5)),
            (register: Byte(1), bit: Byte(1), set: Byte(0xB7), res: Byte(0xB7)),
            (register: Byte(1), bit: Byte(2), set: Byte(0x9E), res: Byte(0x9E)),
            (register: Byte(1), bit: Byte(3), set: Byte(0x39), res: Byte(0x39)),
            (register: Byte(1), bit: Byte(4), set: Byte(0x79), res: Byte(0x79)),
            (register: Byte(1), bit: Byte(5), set: Byte(0x6B), res: Byte(0x6B)),
            (register: Byte(1), bit: Byte(6), set: Byte(0xDB), res: Byte(0xDB)),
            (register: Byte(1), bit: Byte(7), set: Byte(0x8D), res: Byte(0x8D)),
            (register: Byte(2), bit: Byte(0), set: Byte(0x6A), res: Byte(0x6B)),
            (register: Byte(2), bit: Byte(1), set: Byte(0xAC), res: Byte(0xAE)),
            (register: Byte(2), bit: Byte(2), set: Byte(0xC6), res: Byte(0xC6)),
            (register: Byte(2), bit: Byte(3), set: Byte(0x25), res: Byte(0x2D)),
            (register: Byte(2), bit: Byte(4), set: Byte(0x16), res: Byte(0x16)),
            (register: Byte(2), bit: Byte(5), set: Byte(0xDA), res: Byte(0xFA)),
            (register: Byte(2), bit: Byte(6), set: Byte(0x8C), res: Byte(0xCC)),
            (register: Byte(2), bit: Byte(7), set: Byte(0x25), res: Byte(0xA5)),
            (register: Byte(3), bit: Byte(0), set: Byte(0xA9), res: Byte(0xA9)),
            (register: Byte(3), bit: Byte(1), set: Byte(0xA0), res: Byte(0xA2)),
            (register: Byte(3), bit: Byte(2), set: Byte(0x8C), res: Byte(0x8C)),
            (register: Byte(3), bit: Byte(3), set: Byte(0x9C), res: Byte(0x9C)),
            (register: Byte(3), bit: Byte(4), set: Byte(0xF2), res: Byte(0xF2)),
            (register: Byte(3), bit: Byte(5), set: Byte(0x57), res: Byte(0x77)),
            (register: Byte(3), bit: Byte(6), set: Byte(0x50), res: Byte(0x50)),
            (register: Byte(3), bit: Byte(7), set: Byte(0x97), res: Byte(0x97)),
            (register: Byte(4), bit: Byte(0), set: Byte(0xA9), res: Byte(0xA9)),
            (register: Byte(4), bit: Byte(1), set: Byte(0x1A), res: Byte(0x1A)),
            (register: Byte(4), bit: Byte(2), set: Byte(0xDA), res: Byte(0xDE)),
            (register: Byte(4), bit: Byte(3), set: Byte(0x0C), res: Byte(0x0C)),
            (register: Byte(4), bit: Byte(4), set: Byte(0xF7), res: Byte(0xF7)),
            (register: Byte(4), bit: Byte(5), set: Byte(0x78), res: Byte(0x78)),
            (register: Byte(4), bit: Byte(6), set: Byte(0x3A), res: Byte(0x7A)),
            (register: Byte(4), bit: Byte(7), set: Byte(0xA3), res: Byte(0xA3)),
            (register: Byte(5), bit: Byte(0), set: Byte(0xF5), res: Byte(0xF5)),
            (register: Byte(5), bit: Byte(1), set: Byte(0xF6), res: Byte(0xF6)),
            (register: Byte(5), bit: Byte(2), set: Byte(0x44), res: Byte(0x44)),
            (register: Byte(5), bit: Byte(3), set: Byte(0x90), res: Byte(0x98)),
            (register: Byte(5), bit: Byte(4), set: Byte(0xB3), res: Byte(0xB3)),
            (register: Byte(5), bit: Byte(5), set: Byte(0x4B), res: Byte(0x6B)),
            (register: Byte(5), bit: Byte(6), set: Byte(0x59), res: Byte(0x59)),
            (register: Byte(5), bit: Byte(7), set: Byte(0x85), res: Byte(0x85)),
            (register: Byte(7), bit: Byte(0), set: Byte(0xB9), res: Byte(0xB9)),
            (register: Byte(7), bit: Byte(1), set: Byte(0x6C), res: Byte(0x6E)),
            (register: Byte(7), bit: Byte(2), set: Byte(0x33), res: Byte(0x37)),
            (register: Byte(7), bit: Byte(3), set: Byte(0x68), res: Byte(0x68)),
            (register: Byte(7), bit: Byte(4), set: Byte(0x89), res: Byte(0x99)),
            (register: Byte(7), bit: Byte(5), set: Byte(0x9F), res: Byte(0xBF)),
            (register: Byte(7), bit: Byte(6), set: Byte(0x60), res: Byte(0x60)),
            (register: Byte(7), bit: Byte(7), set: Byte(0x72), res: Byte(0xF2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.register, testCase.set)
            asm.SetNReg(testCase.bit, testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register), String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, z80.Reg8(testCase.register)))
        }
    }

    func test_SET_B_HL()
    {
        [
            (bit: Byte(0), set: Byte(0xB0), res: Byte(0xB1)),
            (bit: Byte(1), set: Byte(0xCB), res: Byte(0xCB)),
            (bit: Byte(2), set: Byte(0x3C), res: Byte(0x3C)),
            (bit: Byte(3), set: Byte(0xBF), res: Byte(0xBF)),
            (bit: Byte(4), set: Byte(0xCB), res: Byte(0xDB)),
            (bit: Byte(5), set: Byte(0x23), res: Byte(0x23)),
            (bit: Byte(6), set: Byte(0xF7), res: Byte(0xF7)),
            (bit: Byte(7), set: Byte(0x56), res: Byte(0xD6)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.set)
            asm.SetNAtHl(testCase.bit)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.HL], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.HL]))
        }
    }

   func test_SET_B_IX_d()
   {
        [
            (bit: Byte(0), d: SByte(-78), set: Byte(0x29), res: Byte(0x29)),
            (bit: Byte(1), d: SByte(-29), set: Byte(0x27), res: Byte(0x27)),
            (bit: Byte(2), d: SByte(-54), set: Byte(0xC7), res: Byte(0xC7)),
            (bit: Byte(3), d: SByte(-56), set: Byte(0x31), res: Byte(0x39)),
            (bit: Byte(4), d: SByte(124), set: Byte(0xCE), res: Byte(0xDE)),
            (bit: Byte(5), d: SByte(-94), set: Byte(0x02), res: Byte(0x22)),
            (bit: Byte(6), d: SByte(12), set: Byte(0x2C), res: Byte(0x6C)),
            (bit: Byte(7), d: SByte(-8), set: Byte(0x83), res: Byte(0x83)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort(0x0140) + testCase.d)
            asm.LoadAtHlVal(testCase.set)
            asm.LoadIxVal(0x0140)
            asm.SetNAtIxd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.IX + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IX + testCase.d]))
        }
    }

    func test_SET_B_IY_d()
    {
        [
            (bit: Byte(0), d: SByte(-31), set: Byte(0x26), res: Byte(0x27)),
            (bit: Byte(1), d: SByte(24), set: Byte(0x3B), res: Byte(0x3B)),
            (bit: Byte(2), d: SByte(-68), set: Byte(0x47), res: Byte(0x47)),
            (bit: Byte(3), d: SByte(110), set: Byte(0x69), res: Byte(0x69)),
            (bit: Byte(4), d: SByte(43), set: Byte(0x52), res: Byte(0x52)),
            (bit: Byte(5), d: SByte(3), set: Byte(0x04), res: Byte(0x24)),
            (bit: Byte(6), d: SByte(-76), set: Byte(0xFF), res: Byte(0xFF)),
            (bit: Byte(7), d: SByte(54), set: Byte(0x52), res: Byte(0xD2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort(0x0140) + testCase.d)
            asm.LoadAtHlVal(testCase.set)
            asm.LoadIyVal(0x0140)
            asm.SetNAtIyd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.IY + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IY + testCase.d]))
        }
    }

    func test_RES_B_R()
    {
        [
            (register: Byte(0), bit: Byte(0), set: Byte(0x17), res: Byte(0x16)),
            (register: Byte(0), bit: Byte(1), set: Byte(0xFC), res: Byte(0xFC)),
            (register: Byte(0), bit: Byte(2), set: Byte(0x73), res: Byte(0x73)),
            (register: Byte(0), bit: Byte(3), set: Byte(0xBD), res: Byte(0xB5)),
            (register: Byte(0), bit: Byte(4), set: Byte(0x19), res: Byte(0x09)),
            (register: Byte(0), bit: Byte(5), set: Byte(0xF5), res: Byte(0xD5)),
            (register: Byte(0), bit: Byte(6), set: Byte(0xFD), res: Byte(0xBD)),
            (register: Byte(0), bit: Byte(7), set: Byte(0xC7), res: Byte(0x47)),
            (register: Byte(1), bit: Byte(0), set: Byte(0xD1), res: Byte(0xD0)),
            (register: Byte(1), bit: Byte(1), set: Byte(0xD9), res: Byte(0xD9)),
            (register: Byte(1), bit: Byte(2), set: Byte(0x59), res: Byte(0x59)),
            (register: Byte(1), bit: Byte(3), set: Byte(0xB2), res: Byte(0xB2)),
            (register: Byte(1), bit: Byte(4), set: Byte(0x68), res: Byte(0x68)),
            (register: Byte(1), bit: Byte(5), set: Byte(0x39), res: Byte(0x19)),
            (register: Byte(1), bit: Byte(6), set: Byte(0xC9), res: Byte(0x89)),
            (register: Byte(1), bit: Byte(7), set: Byte(0x6D), res: Byte(0x6D)),
            (register: Byte(2), bit: Byte(0), set: Byte(0x9F), res: Byte(0x9E)),
            (register: Byte(2), bit: Byte(1), set: Byte(0xA3), res: Byte(0xA1)),
            (register: Byte(2), bit: Byte(2), set: Byte(0x8B), res: Byte(0x8B)),
            (register: Byte(2), bit: Byte(3), set: Byte(0xB8), res: Byte(0xB0)),
            (register: Byte(2), bit: Byte(4), set: Byte(0x70), res: Byte(0x60)),
            (register: Byte(2), bit: Byte(5), set: Byte(0xAA), res: Byte(0x8A)),
            (register: Byte(2), bit: Byte(6), set: Byte(0xBC), res: Byte(0xBC)),
            (register: Byte(2), bit: Byte(7), set: Byte(0x50), res: Byte(0x50)),
            (register: Byte(3), bit: Byte(0), set: Byte(0x96), res: Byte(0x96)),
            (register: Byte(3), bit: Byte(1), set: Byte(0x5F), res: Byte(0x5D)),
            (register: Byte(3), bit: Byte(2), set: Byte(0x23), res: Byte(0x23)),
            (register: Byte(3), bit: Byte(3), set: Byte(0x3C), res: Byte(0x34)),
            (register: Byte(3), bit: Byte(4), set: Byte(0x2E), res: Byte(0x2E)),
            (register: Byte(3), bit: Byte(5), set: Byte(0xA9), res: Byte(0x89)),
            (register: Byte(3), bit: Byte(6), set: Byte(0xD0), res: Byte(0x90)),
            (register: Byte(3), bit: Byte(7), set: Byte(0x2D), res: Byte(0x2D)),
            (register: Byte(4), bit: Byte(0), set: Byte(0xBD), res: Byte(0xBC)),
            (register: Byte(4), bit: Byte(1), set: Byte(0xAC), res: Byte(0xAC)),
            (register: Byte(4), bit: Byte(2), set: Byte(0x30), res: Byte(0x30)),
            (register: Byte(4), bit: Byte(3), set: Byte(0x00), res: Byte(0x00)),
            (register: Byte(4), bit: Byte(4), set: Byte(0x67), res: Byte(0x67)),
            (register: Byte(4), bit: Byte(5), set: Byte(0xF4), res: Byte(0xD4)),
            (register: Byte(4), bit: Byte(6), set: Byte(0xE2), res: Byte(0xA2)),
            (register: Byte(4), bit: Byte(7), set: Byte(0x7D), res: Byte(0x7D)),
            (register: Byte(5), bit: Byte(0), set: Byte(0xF0), res: Byte(0xF0)),
            (register: Byte(5), bit: Byte(1), set: Byte(0xE5), res: Byte(0xE5)),
            (register: Byte(5), bit: Byte(2), set: Byte(0xE7), res: Byte(0xE3)),
            (register: Byte(5), bit: Byte(3), set: Byte(0x55), res: Byte(0x55)),
            (register: Byte(5), bit: Byte(4), set: Byte(0xEA), res: Byte(0xEA)),
            (register: Byte(5), bit: Byte(5), set: Byte(0x53), res: Byte(0x53)),
            (register: Byte(5), bit: Byte(6), set: Byte(0x01), res: Byte(0x01)),
            (register: Byte(5), bit: Byte(7), set: Byte(0x0E), res: Byte(0x0E)),
            (register: Byte(7), bit: Byte(0), set: Byte(0xE2), res: Byte(0xE2)),
            (register: Byte(7), bit: Byte(1), set: Byte(0xEB), res: Byte(0xE9)),
            (register: Byte(7), bit: Byte(2), set: Byte(0x93), res: Byte(0x93)),
            (register: Byte(7), bit: Byte(3), set: Byte(0xF5), res: Byte(0xF5)),
            (register: Byte(7), bit: Byte(4), set: Byte(0x58), res: Byte(0x48)),
            (register: Byte(7), bit: Byte(5), set: Byte(0xD0), res: Byte(0xD0)),
            (register: Byte(7), bit: Byte(6), set: Byte(0x5D), res: Byte(0x1D)),
            (register: Byte(7), bit: Byte(7), set: Byte(0xA8), res: Byte(0x28)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.register, testCase.set)
            asm.ResNReg(testCase.bit, testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register), String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, z80.Reg8(testCase.register)))
        }
    }

    func test_RES_B_HL()
    {
        [
            (bit: Byte(0), set: Byte(0x7E), res: Byte(0x7E)),
            (bit: Byte(1), set: Byte(0x64), res: Byte(0x64)),
            (bit: Byte(2), set: Byte(0x81), res: Byte(0x81)),
            (bit: Byte(3), set: Byte(0x08), res: Byte(0x00)),
            (bit: Byte(4), set: Byte(0x8E), res: Byte(0x8E)),
            (bit: Byte(5), set: Byte(0x91), res: Byte(0x91)),
            (bit: Byte(6), set: Byte(0xB5), res: Byte(0xB5)),
            (bit: Byte(7), set: Byte(0x55), res: Byte(0x55)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHlVal(testCase.set)
            asm.ResNAtHl(testCase.bit)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.HL], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.HL]))
        }
    }

    func test_RES_B_IX_d()
    {
        [
            (bit: Byte(0), d: SByte(-90),  set: Byte(0x3C), res: Byte(0x3C)),
            (bit: Byte(1), d: SByte(-122), set: Byte(0x3E), res: Byte(0x3C)),
            (bit: Byte(2), d: SByte(-127), set: Byte(0xE7), res: Byte(0xE3)),
            (bit: Byte(3), d: SByte(26),   set: Byte(0x26), res: Byte(0x26)),
            (bit: Byte(4), d: SByte(-26),  set: Byte(0x90), res: Byte(0x80)),
            (bit: Byte(5), d: SByte(-93),  set: Byte(0x4C), res: Byte(0x4C)),
            (bit: Byte(6), d: SByte(-102), set: Byte(0x7E), res: Byte(0x3E)),
            (bit: Byte(7), d: SByte(68),   set: Byte(0x31), res: Byte(0x31)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort(0x0140) + testCase.d)
            asm.LoadAtHlVal(testCase.set)
            asm.LoadIxVal(0x0140)
            asm.ResNAtIxd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

           XCTAssertEqual(asm.addr, z80.PC)
           XCTAssertEqual(testCase.res, mem[z80.IX + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IX + testCase.d]))
        }
    }

    func test_RES_B_IY_d()
    {
        [
            (bit: Byte(0), d: SByte(58), set: Byte(0x52), res: Byte(0x52)),
            (bit: Byte(1), d: SByte(-101), set: Byte(0x45), res: Byte(0x45)),
            (bit: Byte(2), d: SByte(57), set: Byte(0x43), res: Byte(0x43)),
            (bit: Byte(3), d: SByte(125), set: Byte(0x5A), res: Byte(0x52)),
            (bit: Byte(4), d: SByte(-123), set: Byte(0x65), res: Byte(0x65)),
            (bit: Byte(5), d: SByte(42), set: Byte(0x09), res: Byte(0x09)),
            (bit: Byte(6), d: SByte(-30), set: Byte(0x4E), res: Byte(0x0E)),
            (bit: Byte(7), d: SByte(-80), set: Byte(0x83), res: Byte(0x03)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, UShort(0x0140) + testCase.d)
            asm.LoadAtHlVal(testCase.set)
            asm.LoadIyVal(0x0140)
            asm.ResNAtIyd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.IY + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IY + testCase.d]))
        }
    }
}
