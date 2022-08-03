import XCTest
@testable import z80

final class SixteenBitLoadGroupTests: XCTestCase {
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

    func test_LD_BC_nn()
    {
        asm.LoadReg16Val(0, 0x1942)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x19, z80.B)
        XCTAssertEqual(0x42, z80.C)
    }

    func test_LD_DE_nn()
    {
        asm.LoadReg16Val(1, 0x1942)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x19, z80.D)
        XCTAssertEqual(0x42, z80.E)
    }

    func test_LD_HL_nn()
    {
        asm.LoadReg16Val(2, 0x1942)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x19, z80.H)
        XCTAssertEqual(0x42, z80.L)
    }

    func test_LD_SP_nn()
    {
        asm.LoadReg16Val(3, 0x1942)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x1942, z80.SP)
    }

    func test_LD_IX_nn()
    {
        asm.LoadIxVal(0x1942)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x1942, z80.IX)
    }

    func test_LD_IY_nn()
    {
        asm.LoadIyVal(0x1942)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x1942, z80.IY)
    }

    func test_LD_HL_at_nn()
    {
        asm.LoadHlAddr(0x04)
        asm.Halt()
        asm.Data(0x42)
        asm.Data(0x19)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x19, z80.H)
        XCTAssertEqual(0x42, z80.L)
    }

    func test_LD_BC_at_nn()
    {
        asm.LoadReg16Addr(0, 0x05)
        asm.Halt()
        asm.Data(0x42)
        asm.Data(0x19)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x19, z80.B)
        XCTAssertEqual(0x42, z80.C)
    }

    func test_LD_DE_at_nn()
    {
        asm.LoadReg16Addr(1, 0x05)
        asm.Halt()
        asm.Data(0x42)
        asm.Data(0x19)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x19, z80.D)
        XCTAssertEqual(0x42, z80.E)
    }

    func test_LD_HL_at_nn_alt()
    {
        asm.LoadReg16Addr(2, 0x05)
        asm.Halt()
        asm.Data(0x42)
        asm.Data(0x19)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x19, z80.H)
        XCTAssertEqual(0x42, z80.L)
    }

    func test_LD_SP_at_nn()
    {
        asm.LoadReg16Addr(3, 0x05)
        asm.Halt()
        asm.Data(0x42)
        asm.Data(0x19)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x1942, z80.SP)
    }

    func test_LD_IX_at_nn()
    {
        asm.LoadIXAddr(0x05)
        asm.Halt()
        asm.Data(0x42)
        asm.Data(0x19)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x1942, z80.IX)
    }

    func test_LD_IY_at_nn()
    {
        asm.LoadIYAddr(0x05)
        asm.Halt()
        asm.Data(0x42)
        asm.Data(0x19)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x1942, z80.IY)
    }

    func test_LD_at_nn_HL()
    {
        asm.LoadReg16Val(2, 0x1942)
        asm.LoadAddrHl(0x0008)
        asm.Halt()
        asm.Data(0x11)
        asm.Data(0x22)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x42, mem[asm.Position - ushort(1)])
        XCTAssertEqual(0x19, mem[asm.Position])
    }

    func test_LD_at_nn_BC()
    {
        asm.LoadReg16Val(0, 0x1942)
        asm.LoadAddrReg16(0, 0x0009)
        asm.Halt()
        asm.Data(0x11)
        asm.Data(0x22)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x42, mem[asm.Position - ushort(1)])
        XCTAssertEqual(0x19, mem[asm.Position])
    }

    func test_LD_at_nn_DE()
    {
        asm.LoadReg16Val(1, 0x1942)
        asm.LoadAddrReg16(1, 0x0009)
        asm.Halt()
        asm.Data(0x11)
        asm.Data(0x22)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x42, mem[asm.Position - ushort(1)])
        XCTAssertEqual(0x19, mem[asm.Position])
    }

    func test_LD_at_nn_HL_alt()
    {
        asm.LoadReg16Val(2, 0x1942)
        asm.LoadAddrReg16(2, 0x0009)
        asm.Halt()
        asm.Data(0x11)
        asm.Data(0x22)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x42, mem[asm.Position - ushort(1)])
        XCTAssertEqual(0x19, mem[asm.Position])
    }

    func test_LD_at_nn_SP()
    {
        asm.LoadReg16Val(3, 0x1942)
        asm.LoadAddrReg16(3, 0x0009)
        asm.Halt()
        asm.Data(0x11)
        asm.Data(0x22)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x42, mem[asm.Position - ushort(1)])
        XCTAssertEqual(0x19, mem[asm.Position])
    }

    func test_LD_at_nn_IX()
    {
        asm.LoadIxVal(0x1942)
        asm.LoadAddrIx(0x000A)
        asm.Halt()
        asm.Data(0x11)
        asm.Data(0x22)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x42, mem[asm.Position - ushort(1)])
        XCTAssertEqual(0x19, mem[asm.Position])
    }

    func test_LD_at_nn_IY()
    {
        asm.LoadIyVal(0x1942)
        asm.LoadAddrIy(0x000A)
        asm.Halt()
        asm.Data(0x11)
        asm.Data(0x22)

        z80.Run()

        XCTAssertEqual(asm.Position - ushort(2), z80.PC)
        XCTAssertEqual(0x42, mem[asm.Position - ushort(1)])
        XCTAssertEqual(0x19, mem[asm.Position])
    }

    func test_LD_SP_HL()
    {
        asm.LoadReg16Val(2, 0x1942)
        asm.LoadSpHl()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x1942, z80.SP)
    }

    func test_LD_SP_IX()
    {
        asm.LoadIxVal(0x1942)
        asm.LoadSpIx()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x1942, z80.SP)
    }

    func test_LD_SP_IY()
    {
        asm.LoadIyVal(0x1942)
        asm.LoadSpIy()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x1942, z80.SP)
    }

    func test_PUSH_BC()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(0, 0x1942)
        asm.PushReg16(0)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x000E, z80.SP)
        XCTAssertEqual(z80.B, mem[z80.SP + ushort(1)])
        XCTAssertEqual(z80.C, mem[z80.SP])
    }

    func test_PUSH_DE()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(1, 0x1942)
        asm.PushReg16(1)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x000E, z80.SP)
        XCTAssertEqual(z80.D, mem[z80.SP + ushort(1)])
        XCTAssertEqual(z80.E, mem[z80.SP])
    }

    func test_PUSH_HL()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(2, 0x1942)
        asm.PushReg16(2)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x000E, z80.SP)
        XCTAssertEqual(z80.H, mem[z80.SP + ushort(1)])
        XCTAssertEqual(z80.L, mem[z80.SP])
    }

    func test_PUSH_AF()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadRegVal(7, 0x42)
        asm.PushReg16(3)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x000E, z80.SP)
        XCTAssertEqual(z80.A, mem[z80.SP + ushort(1)])
        XCTAssertEqual(z80.F, mem[z80.SP])
    }

    func test_PUSH_IX()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadIxVal(0x1942)
        asm.PushIx()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x000E, z80.SP)
        XCTAssertEqual(z80.IX, ushort(mem[z80.SP + ushort(1)]) * 256 + mem[z80.SP])
    }

    func test_PUSH_IY()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadIxVal(0x1942)
        asm.PushIy()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x000E, z80.SP)
        XCTAssertEqual(z80.IY, ushort(mem[z80.SP + ushort(1)]) * 256 + mem[z80.SP])
    }

    func test_POP_BC()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(1, 0x1942)
        asm.PushReg16(1)
        asm.PopReg16(0)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x0010, z80.SP)
        XCTAssertEqual(0x1942, z80.BC)
    }

    func test_POP_DE()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(0, 0x1942)
        asm.PushReg16(0)
        asm.PopReg16(1)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x0010, z80.SP)
        XCTAssertEqual(0x1942, z80.DE)
    }

    func test_POP_HL()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(0, 0x1942)
        asm.PushReg16(0)
        asm.PopReg16(2)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x0010, z80.SP)
        XCTAssertEqual(0x1942, z80.HL)
    }

    func test_POP_AF()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(0, 0x1942)
        asm.PushReg16(0)
        asm.PopReg16(3)
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x0010, z80.SP)
        XCTAssertEqual(0x4219, z80.AF)
    }

    func test_POP_IX()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(0, 0x1942)
        asm.PushReg16(0)
        asm.PopIx()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x0010, z80.SP)
        XCTAssertEqual(0x1942, z80.IX)
    }

    func test_POP_IY()
    {
        asm.LoadReg16Val(3, 0x0010)
        asm.LoadReg16Val(0, 0x1942)
        asm.PushReg16(0)
        asm.PopIy()
        asm.Halt()

        z80.Run()

        XCTAssertEqual(asm.Position, z80.PC)
        XCTAssertEqual(0x0010, z80.SP)
        XCTAssertEqual(0x1942, z80.IY)
    }
}
