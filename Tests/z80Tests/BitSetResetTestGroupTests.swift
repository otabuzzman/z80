import XCTest
@testable import z80

final class BitSetResetTestGroupTests: XCTestCase {
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

    func test_BIT_B_R()
    {
        [
            (bit: byte(0), register: byte(0), set: byte(0x55), zero: false),
            (bit: byte(0), register: byte(1), set: byte(0x57), zero: false),
            (bit: byte(0), register: byte(2), set: byte(0xA9), zero: false),
            (bit: byte(0), register: byte(3), set: byte(0xA1), zero: false),
            (bit: byte(0), register: byte(4), set: byte(0xD3), zero: false),
            (bit: byte(0), register: byte(5), set: byte(0xF5), zero: false),
            (bit: byte(0), register: byte(7), set: byte(0xD4), zero: true),
            (bit: byte(1), register: byte(0), set: byte(0x7D), zero: true),
            (bit: byte(1), register: byte(1), set: byte(0xD8), zero: true),
            (bit: byte(1), register: byte(2), set: byte(0xF6), zero: false),
            (bit: byte(1), register: byte(3), set: byte(0x5E), zero: false),
            (bit: byte(1), register: byte(4), set: byte(0x08), zero: true),
            (bit: byte(1), register: byte(5), set: byte(0xE4), zero: true),
            (bit: byte(1), register: byte(7), set: byte(0x3D), zero: true),
            (bit: byte(2), register: byte(0), set: byte(0x5F), zero: false),
            (bit: byte(2), register: byte(1), set: byte(0x1E), zero: false),
            (bit: byte(2), register: byte(2), set: byte(0x04), zero: false),
            (bit: byte(2), register: byte(3), set: byte(0x90), zero: true),
            (bit: byte(2), register: byte(4), set: byte(0x1B), zero: true),
            (bit: byte(2), register: byte(5), set: byte(0x97), zero: false),
            (bit: byte(2), register: byte(7), set: byte(0xE5), zero: false),
            (bit: byte(3), register: byte(0), set: byte(0x68), zero: false),
            (bit: byte(3), register: byte(1), set: byte(0x55), zero: true),
            (bit: byte(3), register: byte(2), set: byte(0x0F), zero: false),
            (bit: byte(3), register: byte(3), set: byte(0x97), zero: true),
            (bit: byte(3), register: byte(4), set: byte(0x06), zero: true),
            (bit: byte(3), register: byte(5), set: byte(0x1B), zero: false),
            (bit: byte(3), register: byte(7), set: byte(0xEE), zero: false),
            (bit: byte(4), register: byte(0), set: byte(0x48), zero: true),
            (bit: byte(4), register: byte(1), set: byte(0x36), zero: false),
            (bit: byte(4), register: byte(2), set: byte(0xEF), zero: true),
            (bit: byte(4), register: byte(3), set: byte(0xE1), zero: true),
            (bit: byte(4), register: byte(4), set: byte(0xA3), zero: true),
            (bit: byte(4), register: byte(5), set: byte(0xE0), zero: true),
            (bit: byte(4), register: byte(7), set: byte(0x11), zero: false),
            (bit: byte(5), register: byte(0), set: byte(0x15), zero: true),
            (bit: byte(5), register: byte(1), set: byte(0xF8), zero: false),
            (bit: byte(5), register: byte(2), set: byte(0xC1), zero: true),
            (bit: byte(5), register: byte(3), set: byte(0x06), zero: true),
            (bit: byte(5), register: byte(4), set: byte(0x9D), zero: true),
            (bit: byte(5), register: byte(5), set: byte(0x1C), zero: true),
            (bit: byte(5), register: byte(7), set: byte(0xD1), zero: true),
            (bit: byte(6), register: byte(0), set: byte(0x6A), zero: false),
            (bit: byte(6), register: byte(1), set: byte(0x66), zero: false),
            (bit: byte(6), register: byte(2), set: byte(0x38), zero: true),
            (bit: byte(6), register: byte(3), set: byte(0x9D), zero: true),
            (bit: byte(6), register: byte(4), set: byte(0x3A), zero: true),
            (bit: byte(6), register: byte(5), set: byte(0x0C), zero: true),
            (bit: byte(6), register: byte(7), set: byte(0x72), zero: false),
            (bit: byte(7), register: byte(0), set: byte(0x44), zero: true),
            (bit: byte(7), register: byte(1), set: byte(0x7F), zero: true),
            (bit: byte(7), register: byte(2), set: byte(0x47), zero: true),
            (bit: byte(7), register: byte(3), set: byte(0xE0), zero: false),
            (bit: byte(7), register: byte(4), set: byte(0xE7), zero: false),
            (bit: byte(7), register: byte(5), set: byte(0x44), zero: true),
            (bit: byte(7), register: byte(7), set: byte(0xEC), zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.register, testCase.set)
            asm.BitNReg(testCase.bit, testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_BIT_B_HL()
    {
        [
            (bit: byte(0), set: byte(0x60), zero: true),
            (bit: byte(1), set: byte(0x22), zero: false),
            (bit: byte(2), set: byte(0x11), zero: true),
            (bit: byte(3), set: byte(0x87), zero: true),
            (bit: byte(4), set: byte(0xB9), zero: false),
            (bit: byte(5), set: byte(0x11), zero: true),
            (bit: byte(6), set: byte(0x11), zero: true),
            (bit: byte(7), set: byte(0x90), zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHLVal(testCase.set)
            asm.BitNAtHl(testCase.bit)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_BIT_B_IX_d()
    {
        [
            (bit: byte(0), d: sbyte(-70), set: byte(0x55), zero: false),
            (bit: byte(1), d: sbyte(75), set: byte(0xA7), zero: false),
            (bit: byte(2), d: sbyte(-43), set: byte(0x35), zero: false),
            (bit: byte(3), d: sbyte(26), set: byte(0x7C), zero: false),
            (bit: byte(4), d: sbyte(-77), set: byte(0x26), zero: true),
            (bit: byte(5), d: sbyte(-18), set: byte(0x57), zero: true),
            (bit: byte(6), d: sbyte(-6), set: byte(0xDC), zero: false),
            (bit: byte(7), d: sbyte(-101), set: byte(0xDE), zero: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0140) + testCase.d)
            asm.LoadAtHLVal(testCase.set)
            asm.LoadIxVal(0x0140)
            asm.BitNAtIxd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_BIT_B_IY_d()
    {
        [
            (bit: byte(0), d: sbyte(37), set: byte(0x72), zero: true),
            (bit: byte(1), d: sbyte(-33), set: byte(0xB4), zero: true),
            (bit: byte(2), d: sbyte(-80), set: byte(0x16), zero: false),
            (bit: byte(3), d: sbyte(62), set: byte(0x33), zero: true),
            (bit: byte(4), d: sbyte(-87), set: byte(0x16), zero: false),
            (bit: byte(5), d: sbyte(-94), set: byte(0x50), zero: true),
            (bit: byte(6), d: sbyte(50), set: byte(0x94), zero: true),
            (bit: byte(7), d: sbyte(-117), set: byte(0x05), zero: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0140) + testCase.d)
            asm.LoadAtHLVal(testCase.set)
            asm.LoadIyVal(0x0140)
            asm.BitNAtIyd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.zero, z80.FlagZ, "Flag Z contained the wrong value")
            XCTAssertEqual(true, z80.FlagH, "Flag H contained the wrong value")
            XCTAssertEqual(false, z80.FlagN, "Flag N contained the wrong value")
        }
    }

    func test_SET_B_R()
    {
        [
            (register: byte(0), bit: byte(0), set: byte(0x4D), res: byte(0x4D)),
            (register: byte(0), bit: byte(1), set: byte(0x94), res: byte(0x96)),
            (register: byte(0), bit: byte(2), set: byte(0x69), res: byte(0x6D)),
            (register: byte(0), bit: byte(3), set: byte(0x23), res: byte(0x2B)),
            (register: byte(0), bit: byte(4), set: byte(0xCC), res: byte(0xDC)),
            (register: byte(0), bit: byte(5), set: byte(0x40), res: byte(0x60)),
            (register: byte(0), bit: byte(6), set: byte(0xB5), res: byte(0xF5)),
            (register: byte(0), bit: byte(7), set: byte(0xF3), res: byte(0xF3)),
            (register: byte(1), bit: byte(0), set: byte(0xD4), res: byte(0xD5)),
            (register: byte(1), bit: byte(1), set: byte(0xB7), res: byte(0xB7)),
            (register: byte(1), bit: byte(2), set: byte(0x9E), res: byte(0x9E)),
            (register: byte(1), bit: byte(3), set: byte(0x39), res: byte(0x39)),
            (register: byte(1), bit: byte(4), set: byte(0x79), res: byte(0x79)),
            (register: byte(1), bit: byte(5), set: byte(0x6B), res: byte(0x6B)),
            (register: byte(1), bit: byte(6), set: byte(0xDB), res: byte(0xDB)),
            (register: byte(1), bit: byte(7), set: byte(0x8D), res: byte(0x8D)),
            (register: byte(2), bit: byte(0), set: byte(0x6A), res: byte(0x6B)),
            (register: byte(2), bit: byte(1), set: byte(0xAC), res: byte(0xAE)),
            (register: byte(2), bit: byte(2), set: byte(0xC6), res: byte(0xC6)),
            (register: byte(2), bit: byte(3), set: byte(0x25), res: byte(0x2D)),
            (register: byte(2), bit: byte(4), set: byte(0x16), res: byte(0x16)),
            (register: byte(2), bit: byte(5), set: byte(0xDA), res: byte(0xFA)),
            (register: byte(2), bit: byte(6), set: byte(0x8C), res: byte(0xCC)),
            (register: byte(2), bit: byte(7), set: byte(0x25), res: byte(0xA5)),
            (register: byte(3), bit: byte(0), set: byte(0xA9), res: byte(0xA9)),
            (register: byte(3), bit: byte(1), set: byte(0xA0), res: byte(0xA2)),
            (register: byte(3), bit: byte(2), set: byte(0x8C), res: byte(0x8C)),
            (register: byte(3), bit: byte(3), set: byte(0x9C), res: byte(0x9C)),
            (register: byte(3), bit: byte(4), set: byte(0xF2), res: byte(0xF2)),
            (register: byte(3), bit: byte(5), set: byte(0x57), res: byte(0x77)),
            (register: byte(3), bit: byte(6), set: byte(0x50), res: byte(0x50)),
            (register: byte(3), bit: byte(7), set: byte(0x97), res: byte(0x97)),
            (register: byte(4), bit: byte(0), set: byte(0xA9), res: byte(0xA9)),
            (register: byte(4), bit: byte(1), set: byte(0x1A), res: byte(0x1A)),
            (register: byte(4), bit: byte(2), set: byte(0xDA), res: byte(0xDE)),
            (register: byte(4), bit: byte(3), set: byte(0x0C), res: byte(0x0C)),
            (register: byte(4), bit: byte(4), set: byte(0xF7), res: byte(0xF7)),
            (register: byte(4), bit: byte(5), set: byte(0x78), res: byte(0x78)),
            (register: byte(4), bit: byte(6), set: byte(0x3A), res: byte(0x7A)),
            (register: byte(4), bit: byte(7), set: byte(0xA3), res: byte(0xA3)),
            (register: byte(5), bit: byte(0), set: byte(0xF5), res: byte(0xF5)),
            (register: byte(5), bit: byte(1), set: byte(0xF6), res: byte(0xF6)),
            (register: byte(5), bit: byte(2), set: byte(0x44), res: byte(0x44)),
            (register: byte(5), bit: byte(3), set: byte(0x90), res: byte(0x98)),
            (register: byte(5), bit: byte(4), set: byte(0xB3), res: byte(0xB3)),
            (register: byte(5), bit: byte(5), set: byte(0x4B), res: byte(0x6B)),
            (register: byte(5), bit: byte(6), set: byte(0x59), res: byte(0x59)),
            (register: byte(5), bit: byte(7), set: byte(0x85), res: byte(0x85)),
            (register: byte(7), bit: byte(0), set: byte(0xB9), res: byte(0xB9)),
            (register: byte(7), bit: byte(1), set: byte(0x6C), res: byte(0x6E)),
            (register: byte(7), bit: byte(2), set: byte(0x33), res: byte(0x37)),
            (register: byte(7), bit: byte(3), set: byte(0x68), res: byte(0x68)),
            (register: byte(7), bit: byte(4), set: byte(0x89), res: byte(0x99)),
            (register: byte(7), bit: byte(5), set: byte(0x9F), res: byte(0xBF)),
            (register: byte(7), bit: byte(6), set: byte(0x60), res: byte(0x60)),
            (register: byte(7), bit: byte(7), set: byte(0x72), res: byte(0xF2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.register, testCase.set)
            asm.SetNReg(testCase.bit, testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register), String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, z80.Reg8(testCase.register)))
        }
    }

    func test_SET_B_HL()
    {
        [
            (bit: byte(0), set: byte(0xB0), res: byte(0xB1)),
            (bit: byte(1), set: byte(0xCB), res: byte(0xCB)),
            (bit: byte(2), set: byte(0x3C), res: byte(0x3C)),
            (bit: byte(3), set: byte(0xBF), res: byte(0xBF)),
            (bit: byte(4), set: byte(0xCB), res: byte(0xDB)),
            (bit: byte(5), set: byte(0x23), res: byte(0x23)),
            (bit: byte(6), set: byte(0xF7), res: byte(0xF7)),
            (bit: byte(7), set: byte(0x56), res: byte(0xD6)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHLVal(testCase.set)
            asm.SetNAtHl(testCase.bit)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.HL], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.HL]))
        }
    }

   func test_SET_B_IX_d()
   {
        [
            (bit: byte(0), d: sbyte(-78), set: byte(0x29), res: byte(0x29)),
            (bit: byte(1), d: sbyte(-29), set: byte(0x27), res: byte(0x27)),
            (bit: byte(2), d: sbyte(-54), set: byte(0xC7), res: byte(0xC7)),
            (bit: byte(3), d: sbyte(-56), set: byte(0x31), res: byte(0x39)),
            (bit: byte(4), d: sbyte(124), set: byte(0xCE), res: byte(0xDE)),
            (bit: byte(5), d: sbyte(-94), set: byte(0x02), res: byte(0x22)),
            (bit: byte(6), d: sbyte(12), set: byte(0x2C), res: byte(0x6C)),
            (bit: byte(7), d: sbyte(-8), set: byte(0x83), res: byte(0x83)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0140) + testCase.d)
            asm.LoadAtHLVal(testCase.set)
            asm.LoadIxVal(0x0140)
            asm.SetNAtIxd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.IX + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IX + testCase.d]))
        }
    }

    func test_SET_B_IY_d()
    {
        [
            (bit: byte(0), d: sbyte(-31), set: byte(0x26), res: byte(0x27)),
            (bit: byte(1), d: sbyte(24), set: byte(0x3B), res: byte(0x3B)),
            (bit: byte(2), d: sbyte(-68), set: byte(0x47), res: byte(0x47)),
            (bit: byte(3), d: sbyte(110), set: byte(0x69), res: byte(0x69)),
            (bit: byte(4), d: sbyte(43), set: byte(0x52), res: byte(0x52)),
            (bit: byte(5), d: sbyte(3), set: byte(0x04), res: byte(0x24)),
            (bit: byte(6), d: sbyte(-76), set: byte(0xFF), res: byte(0xFF)),
            (bit: byte(7), d: sbyte(54), set: byte(0x52), res: byte(0xD2)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0140) + testCase.d)
            asm.LoadAtHLVal(testCase.set)
            asm.LoadIyVal(0x0140)
            asm.SetNAtIyd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.IY + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IY + testCase.d]))
        }
    }

    func test_RES_B_R()
    {
        [
            (register: byte(0), bit: byte(0), set: byte(0x17), res: byte(0x16)),
            (register: byte(0), bit: byte(1), set: byte(0xFC), res: byte(0xFC)),
            (register: byte(0), bit: byte(2), set: byte(0x73), res: byte(0x73)),
            (register: byte(0), bit: byte(3), set: byte(0xBD), res: byte(0xB5)),
            (register: byte(0), bit: byte(4), set: byte(0x19), res: byte(0x09)),
            (register: byte(0), bit: byte(5), set: byte(0xF5), res: byte(0xD5)),
            (register: byte(0), bit: byte(6), set: byte(0xFD), res: byte(0xBD)),
            (register: byte(0), bit: byte(7), set: byte(0xC7), res: byte(0x47)),
            (register: byte(1), bit: byte(0), set: byte(0xD1), res: byte(0xD0)),
            (register: byte(1), bit: byte(1), set: byte(0xD9), res: byte(0xD9)),
            (register: byte(1), bit: byte(2), set: byte(0x59), res: byte(0x59)),
            (register: byte(1), bit: byte(3), set: byte(0xB2), res: byte(0xB2)),
            (register: byte(1), bit: byte(4), set: byte(0x68), res: byte(0x68)),
            (register: byte(1), bit: byte(5), set: byte(0x39), res: byte(0x19)),
            (register: byte(1), bit: byte(6), set: byte(0xC9), res: byte(0x89)),
            (register: byte(1), bit: byte(7), set: byte(0x6D), res: byte(0x6D)),
            (register: byte(2), bit: byte(0), set: byte(0x9F), res: byte(0x9E)),
            (register: byte(2), bit: byte(1), set: byte(0xA3), res: byte(0xA1)),
            (register: byte(2), bit: byte(2), set: byte(0x8B), res: byte(0x8B)),
            (register: byte(2), bit: byte(3), set: byte(0xB8), res: byte(0xB0)),
            (register: byte(2), bit: byte(4), set: byte(0x70), res: byte(0x60)),
            (register: byte(2), bit: byte(5), set: byte(0xAA), res: byte(0x8A)),
            (register: byte(2), bit: byte(6), set: byte(0xBC), res: byte(0xBC)),
            (register: byte(2), bit: byte(7), set: byte(0x50), res: byte(0x50)),
            (register: byte(3), bit: byte(0), set: byte(0x96), res: byte(0x96)),
            (register: byte(3), bit: byte(1), set: byte(0x5F), res: byte(0x5D)),
            (register: byte(3), bit: byte(2), set: byte(0x23), res: byte(0x23)),
            (register: byte(3), bit: byte(3), set: byte(0x3C), res: byte(0x34)),
            (register: byte(3), bit: byte(4), set: byte(0x2E), res: byte(0x2E)),
            (register: byte(3), bit: byte(5), set: byte(0xA9), res: byte(0x89)),
            (register: byte(3), bit: byte(6), set: byte(0xD0), res: byte(0x90)),
            (register: byte(3), bit: byte(7), set: byte(0x2D), res: byte(0x2D)),
            (register: byte(4), bit: byte(0), set: byte(0xBD), res: byte(0xBC)),
            (register: byte(4), bit: byte(1), set: byte(0xAC), res: byte(0xAC)),
            (register: byte(4), bit: byte(2), set: byte(0x30), res: byte(0x30)),
            (register: byte(4), bit: byte(3), set: byte(0x00), res: byte(0x00)),
            (register: byte(4), bit: byte(4), set: byte(0x67), res: byte(0x67)),
            (register: byte(4), bit: byte(5), set: byte(0xF4), res: byte(0xD4)),
            (register: byte(4), bit: byte(6), set: byte(0xE2), res: byte(0xA2)),
            (register: byte(4), bit: byte(7), set: byte(0x7D), res: byte(0x7D)),
            (register: byte(5), bit: byte(0), set: byte(0xF0), res: byte(0xF0)),
            (register: byte(5), bit: byte(1), set: byte(0xE5), res: byte(0xE5)),
            (register: byte(5), bit: byte(2), set: byte(0xE7), res: byte(0xE3)),
            (register: byte(5), bit: byte(3), set: byte(0x55), res: byte(0x55)),
            (register: byte(5), bit: byte(4), set: byte(0xEA), res: byte(0xEA)),
            (register: byte(5), bit: byte(5), set: byte(0x53), res: byte(0x53)),
            (register: byte(5), bit: byte(6), set: byte(0x01), res: byte(0x01)),
            (register: byte(5), bit: byte(7), set: byte(0x0E), res: byte(0x0E)),
            (register: byte(7), bit: byte(0), set: byte(0xE2), res: byte(0xE2)),
            (register: byte(7), bit: byte(1), set: byte(0xEB), res: byte(0xE9)),
            (register: byte(7), bit: byte(2), set: byte(0x93), res: byte(0x93)),
            (register: byte(7), bit: byte(3), set: byte(0xF5), res: byte(0xF5)),
            (register: byte(7), bit: byte(4), set: byte(0x58), res: byte(0x48)),
            (register: byte(7), bit: byte(5), set: byte(0xD0), res: byte(0xD0)),
            (register: byte(7), bit: byte(6), set: byte(0x5D), res: byte(0x1D)),
            (register: byte(7), bit: byte(7), set: byte(0xA8), res: byte(0x28)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(testCase.register, testCase.set)
            asm.ResNReg(testCase.bit, testCase.register)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.res, z80.Reg8(testCase.register), String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, z80.Reg8(testCase.register)))
        }
    }

    func test_RES_B_HL()
    {
        [
            (bit: byte(0), set: byte(0x7E), res: byte(0x7E)),
            (bit: byte(1), set: byte(0x64), res: byte(0x64)),
            (bit: byte(2), set: byte(0x81), res: byte(0x81)),
            (bit: byte(3), set: byte(0x08), res: byte(0x00)),
            (bit: byte(4), set: byte(0x8E), res: byte(0x8E)),
            (bit: byte(5), set: byte(0x91), res: byte(0x91)),
            (bit: byte(6), set: byte(0xB5), res: byte(0xB5)),
            (bit: byte(7), set: byte(0x55), res: byte(0x55)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, 0x0040)
            asm.LoadAtHLVal(testCase.set)
            asm.ResNAtHl(testCase.bit)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.HL], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.HL]))
        }
    }

    func test_RES_B_IX_d()
    {
        [
            (bit: byte(0), d: sbyte(-90),  set: byte(0x3C), res: byte(0x3C)),
            (bit: byte(1), d: sbyte(-122), set: byte(0x3E), res: byte(0x3C)),
            (bit: byte(2), d: sbyte(-127), set: byte(0xE7), res: byte(0xE3)),
            (bit: byte(3), d: sbyte(26),   set: byte(0x26), res: byte(0x26)),
            (bit: byte(4), d: sbyte(-26),  set: byte(0x90), res: byte(0x80)),
            (bit: byte(5), d: sbyte(-93),  set: byte(0x4C), res: byte(0x4C)),
            (bit: byte(6), d: sbyte(-102), set: byte(0x7E), res: byte(0x3E)),
            (bit: byte(7), d: sbyte(68),   set: byte(0x31), res: byte(0x31)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0140) + testCase.d)
            asm.LoadAtHLVal(testCase.set)
            asm.LoadIxVal(0x0140)
            asm.ResNAtIxd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

           XCTAssertEqual(asm.Position, z80.PC)
           XCTAssertEqual(testCase.res, mem[z80.IX + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IX + testCase.d]))
        }
    }

    func test_RES_B_IY_d()
    {
        [
            (bit: byte(0), d: sbyte(58), set: byte(0x52), res: byte(0x52)),
            (bit: byte(1), d: sbyte(-101), set: byte(0x45), res: byte(0x45)),
            (bit: byte(2), d: sbyte(57), set: byte(0x43), res: byte(0x43)),
            (bit: byte(3), d: sbyte(125), set: byte(0x5A), res: byte(0x52)),
            (bit: byte(4), d: sbyte(-123), set: byte(0x65), res: byte(0x65)),
            (bit: byte(5), d: sbyte(42), set: byte(0x09), res: byte(0x09)),
            (bit: byte(6), d: sbyte(-30), set: byte(0x4E), res: byte(0x0E)),
            (bit: byte(7), d: sbyte(-80), set: byte(0x83), res: byte(0x03)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadReg16Val(2, ushort(0x0140) + testCase.d)
            asm.LoadAtHLVal(testCase.set)
            asm.LoadIyVal(0x0140)
            asm.ResNAtIyd(testCase.bit, testCase.d)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.Position, z80.PC)
            XCTAssertEqual(testCase.res, mem[z80.IY + testCase.d], String(format: "Expected 0x%02X but was 0x%02X\n", testCase.res, mem[z80.IY + testCase.d]))
        }
    }
}
