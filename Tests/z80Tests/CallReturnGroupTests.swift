import XCTest
@testable import z80

final class CallReturnGroupTests: XCTestCase {
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

    func test_CALL_nn()
    {
        asm.Call(0x0005)
        asm.Halt()
        asm.Halt()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x06, z80.PC)
        XCTAssertEqual(0xFFFD, z80.SP)
        XCTAssertEqual(0x03, mem[0xFFFD])
        XCTAssertEqual(0x00, mem[0xFFFE])
    }

    func test_CALL_NZ_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x09), branch: true),
            (val: byte(0x00), addr: short(0x07), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.CallNz(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x06, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
            else
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
        }
    }

    func test_CALL_Z_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x07), branch: false),
            (val: byte(0x00), addr: short(0x09), branch: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.CallZ(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x06, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
            else
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
        }
    }

    func test_CALL_NC_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x07), branch: false),
            (val: byte(0x00), addr: short(0x09), branch: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.CallNc(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x06, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
            else
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
        }
    }

    func test_CALL_C_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x09), branch: true),
            (val: byte(0x00), addr: short(0x07), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.CallC(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x06, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
            else
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
        }
    }

    func test_CALL_PO_nn()
    {
        [
            (val: byte(0x7F), addr: short(0x07), branch: false),
            (val: byte(0x00), addr: short(0x09), branch: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.CallPo(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x06, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
            else
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
        }
    }

    func test_CALL_PE_nn()
    {
        [
            (val: byte(0x7F), addr: short(0x09), branch: true),
            (val: byte(0x00), addr: short(0x07), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.CallPe(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
        }
    }

    func test_CALL_P_nn()
    {
        [
            (val: byte(0x01), addr: short(0x09), branch: true),
            (val: byte(0x80), addr: short(0x07), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.CallP(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x06, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
            else
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
        }
    }

    func test_CALL_M_nn()
    {
        [
            (val: byte(0x01), addr: short(0x07), branch: false),
            (val: byte(0x80), addr: short(0x09), branch: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.CallM(0x0008)
            asm.Halt()
            asm.Halt()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x06, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
            else
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
        }
    }

    func test_RET_nn()
    {
        asm.Call(0x0004)
        asm.Halt()
        asm.Ret()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x04, z80.PC)
        XCTAssertEqual(0xFFFF, z80.SP)
    }

    func test_RET_NZ_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x04), branch: true),
            (val: byte(0x00), addr: short(0x09), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.RetNz()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RET_Z_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x09), branch: false),
            (val: byte(0x00), addr: short(0x04), branch: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.RetZ()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RET_NC_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x09), branch: false),
            (val: byte(0x00), addr: short(0x04), branch: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.RetNc()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RET_C_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x04), branch: true),
            (val: byte(0x00), addr: short(0x09), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.RetC()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RET_PO_nn()
    {
        [
            (val: byte(0x00), addr: short(0x04), branch: true),
            (val: byte(0x7F), addr: short(0x09), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.RetPo()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RET_PE_nn()
    {
        [
            (val: byte(0x7F), addr: short(0x04), branch: true),
            (val: byte(0x00), addr: short(0x09), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.IncReg(7)
            asm.RetPe()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RET_P_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x09), branch: false),
            (val: byte(0x00), addr: short(0x04), branch: true),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.RetP()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RET_M_nn()
    {
        [
            (val: byte(0xFF), addr: short(0x04), branch: true),
            (val: byte(0x00), addr: short(0x09), branch: false),
        ].forEach { testCase in
            tearDown()
            setUp()

            asm.Call(0x0004)
            asm.Halt()
            asm.LoadRegVal(7, testCase.val)
            asm.OrReg(7)
            asm.RetM()
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(truncatingIfNeeded: testCase.addr), z80.PC)
            if testCase.branch
            {
                XCTAssertEqual(0xFFFF, z80.SP)
            }
            else
            {
                XCTAssertEqual(0xFFFD, z80.SP)
                XCTAssertEqual(0x03, mem[0xFFFD])
                XCTAssertEqual(0x00, mem[0xFFFE])
            }
        }
    }

    func test_RETI_nn()
    {
        asm.Ei()
        asm.Call(0x0005)
        asm.Halt()
        asm.RetI()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x05, z80.PC)
        XCTAssertEqual(0xFFFF, z80.SP)
        XCTAssertEqual(z80.Iff2, z80.Iff1)
    }

    func test_RETN_nn()
    {
        asm.Ei()
        asm.Call(0x0005)
        asm.Halt()
        asm.RetN()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(0x05, z80.PC)
        XCTAssertEqual(0xFFFF, z80.SP)
        XCTAssertEqual(z80.Iff2, z80.Iff1)
    }

    func test_RST_nn()
    {
        [
            byte(0),
            byte(1),
            byte(2),
            byte(3),
            byte(4),
            byte(5),
            byte(6),
            byte(7),
        ].forEach { page in
            tearDown()
            setUp()

            asm.CpVal(0xFF)
            asm.JpZ(0x1000)
            asm.Halt()
            asm.Position = 0x0008
            asm.Halt()
            asm.Position = 0x0010
            asm.Halt()
            asm.Position = 0x0018
            asm.Halt()
            asm.Position = 0x0020
            asm.Halt()
            asm.Position = 0x0028
            asm.Halt()
            asm.Position = 0x0030
            asm.Halt()
            asm.Position = 0x0038
            asm.Halt()
            asm.Position = 0x1000
            asm.XorReg(7)
            asm.Rst(page)
            asm.Halt()

            z80.Run()

            XCTAssertEqual(ushort(page), z80.PC / 8)
            XCTAssertEqual(0xFFFD, z80.SP)
            XCTAssertEqual(0x02, mem[0xFFFD])
            XCTAssertEqual(0x10, mem[0xFFFE])
        }
    }
}
