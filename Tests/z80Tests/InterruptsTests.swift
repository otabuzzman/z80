import XCTest
@testable import z80

final class InterruptsTests: XCTestCase {
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

    func test_NMI_Run()
    {
        asm.Ei()
        asm.Nop()

        asm.addr = 0x66
        asm.Nop()

        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(false)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x66, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertTrue(z80.Iff2)
    }

    func test_NMI_Halt()
    {
        asm.Ei()
        asm.Halt()

        asm.addr = 0x66
        asm.Nop()

        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(false)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x66, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertTrue(z80.Iff2)
    }

    func test_NMI_Halt_DisabledInterrupts()
    {
        asm.Di()
        asm.Halt()

        asm.addr = 0x66
        asm.Nop()

        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(false)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x66, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_NMI_RetN()
    {
        asm.Ei()
        asm.Halt()

        asm.addr = 0x66
        asm.RetN()

        _ = z80.Step()
        _ = z80.Step()
        z80.RaiseInterrupt(false)
        _ = z80.Step()

        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x02, z80.PC)
        XCTAssertTrue(z80.Iff1)
        XCTAssertTrue(z80.Iff2)
    }

    func test_MI_IM0_Run()
    {
        asm.Ei()
        asm.Im0()
        asm.Nop()

        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true, 0xC7 /*RST 0*/)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x00, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM0_Halt()
    {
        asm.Ei()
        asm.Im0()
        asm.Halt()


        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true, 0xC7) // RST 0
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x00, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM0_Halt_DisabledInterrupts()
    {
        asm.Di()
        asm.Im0()
        asm.Halt()


        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true, 0xC7) // RST 0
        let halted = z80.Step()

        XCTAssertTrue(halted)
        XCTAssertEqual(0x04, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM0_RetI()
    {
        asm.Ei()
        asm.Im0()
        asm.Halt()

        asm.addr = 0x38
        asm.Ei()
        asm.RetN()

        _ = z80.Step()
        _ = z80.Step()
        z80.RaiseInterrupt(true, 0xFF) // RST 7
        _ = z80.Step()
        _ = z80.Step()

        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x03, z80.PC)
        XCTAssertTrue(z80.Iff1)
        XCTAssertTrue(z80.Iff2)
    }

    func test_MI_IM1_Run()
    {
        asm.Ei()
        asm.Im1()
        asm.Nop()

        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x38, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM1_Halt()
    {
        asm.Ei()
        asm.Im1()
        asm.Halt()


        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x38, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM1_Halt_DisabledInterrupts()
    {
        asm.Di()
        asm.Im1()
        asm.Halt()


        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true)
        let halted = z80.Step()

        XCTAssertTrue(halted)
        XCTAssertEqual(0x04, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM1_RetI()
    {
        asm.Ei()
        asm.Im1()
        asm.Halt()

        asm.addr = 0x38
        asm.Ei()
        asm.RetN()

        _ = z80.Step()
        _ = z80.Step()
        z80.RaiseInterrupt(true)
        _ = z80.Step()
        _ = z80.Step()

        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x03, z80.PC)
        XCTAssertTrue(z80.Iff1)
        XCTAssertTrue(z80.Iff2)
    }

    func test_MI_IM2_Run()
    {
        asm.Ei()
        asm.LoadRegVal(7, 0x12)
        asm.LoadIA()
        asm.Im2()
        asm.Nop()

        asm.addr = 0x1234
        asm.Data(0x56)
        asm.Data(0x78)

        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true, 0x34)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x5678, z80.PC, String(format: "PC: 0x%04X", z80.PC))
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM2_Halt()
    {
        asm.Ei()
        asm.LoadRegVal(7, 0x12)
        asm.LoadIA()
        asm.Im2()
        asm.Halt()

        asm.addr = 0x1234
        asm.Data(0x56)
        asm.Data(0x78)

        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true, 0x34)
        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x5678, z80.PC, String(format: "PC: 0x%04X", z80.PC))
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM2_Halt_DisabledInterrupts()
    {
        asm.Di()
        asm.LoadRegVal(7, 0x12)
        asm.LoadIA()
        asm.Im2()
        asm.Halt()

        asm.addr = 0x1234
        asm.Data(0x56)
        asm.Data(0x78)

        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()
        _ = z80.Step()

        z80.RaiseInterrupt(true, 0xC7) // RST 0
        let halted = z80.Step()

        XCTAssertTrue(halted)
        XCTAssertEqual(0x08, z80.PC)
        XCTAssertFalse(z80.Iff1)
        XCTAssertFalse(z80.Iff2)
    }

    func test_MI_IM2_RetI()
    {
        asm.Ei()
        asm.Im2()
        asm.Halt()

        asm.addr = 0x38
        asm.Ei()
        asm.RetN()

        _ = z80.Step()
        _ = z80.Step()
        z80.RaiseInterrupt(true, 0xFF) // RST 7
        _ = z80.Step()
        _ = z80.Step()

        let halted = z80.Step()

        XCTAssertFalse(halted)
        XCTAssertEqual(0x03, z80.PC)
        XCTAssertTrue(z80.Iff1)
        XCTAssertTrue(z80.Iff2)
    }
}
