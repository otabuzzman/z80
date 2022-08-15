import XCTest
@testable import z80

final class JumpGroupTests: XCTestCase {
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

    func test_JP_nn()
    {
        asm.Jp(0x0005)
        asm.Halt()
        asm.Halt()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x06, z80.PC)
    }

    func test_JP_NZ_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x09)),
            (val: Byte(0x00), addr: Short(0x07)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.JpNz(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }


    func test_JP_Z_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x07)),
            (val: Byte(0x00), addr: Short(0x09)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.JpZ(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JP_NC_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x07)),
            (val: Byte(0x00), addr: Short(0x09)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.JpNc(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JP_C_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x09)),
            (val: Byte(0x00), addr: Short(0x07)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.JpC(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JP_PO_nn()
    {
        [
            (val: Byte(0x7F), addr: Short(0x07)),
            (val: Byte(0x00), addr: Short(0x09)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.JpPo(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JP_PE_nn()
    {
        [
            (val: Byte(0x7F), addr: Short(0x09)),
            (val: Byte(0x00), addr: Short(0x07)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.JpPe(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JP_P_nn()
    {
        [
            (val: Byte(0x01), addr: Short(0x09)),
            (val: Byte(0x80), addr: Short(0x07)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.JpP(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JP_M_nn()
    {
        [
            (val: Byte(0x01), addr: Short(0x07)),
            (val: Byte(0x80), addr: Short(0x09)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.JpM(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JR_nn()
    {
        asm.Jr(0x04)
        asm.Halt()
        asm.Halt()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x05, z80.PC)
    }

    func test_JR_NZ_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x08)),
            (val: Byte(0x00), addr: Short(0x06)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.JrNz(0x04)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JR_Z_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x06)),
            (val: Byte(0x00), addr: Short(0x08)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.JrZ(0x04)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JR_NC_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x06)),
            (val: Byte(0x00), addr: Short(0x08)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.JrNc(0x04)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JR_C_nn()
    {
        [
            (val: Byte(0xFF), addr: Short(0x08)),
            (val: Byte(0x00), addr: Short(0x06)),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.JrC(0x04)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(UShort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_JP_HL()
    {
        asm.LoadReg16Val(2, 0x0006)
        asm.JpHl()
        asm.Halt()
        asm.Halt()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x07, z80.PC)
    }

    func test_JP_IX()
    {
        asm.LoadIxVal(0x0008)
        asm.JpIx()
        asm.Halt()
        asm.Halt()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x09, z80.PC)
    }

    func test_JP_IY()
    {
        asm.LoadIyVal(0x0008)
        asm.JpIy()
        asm.Halt()
        asm.Halt()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x09, z80.PC)
    }

    func test_DJNZ_e()
    {
        [
            Byte(0x01),
            Byte(0x42),
        ].forEach { loops in
            tearDown()
            setUp()

            asm.LoadRegVal(0, loops)
            asm.XorReg(7)
            asm.IncReg(7)
            asm.Djnz(-1)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(asm.addr, z80.PC)
            XCTAssertEqual(loops, z80.A)
            XCTAssertEqual(0, z80.B)
        }
    }
}
