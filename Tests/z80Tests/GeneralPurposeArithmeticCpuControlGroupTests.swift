import XCTest
@testable import z80

final class GeneralPurposeArithmeticCpuControlGroupTests: XCTestCase {
    var en: TestSystem!
    var asm: Z80Asm!
    var _ram: Memory!

    override func setUp() {
        // called before invocation of each test method
        super.setUp()

        _ram = Memory(0x10000, 0)
        en = TestSystem(_ram);
        asm = Z80Asm(_ram);

        en.Reset();
        asm.Reset();
    }

    override func tearDown() {
        // called after invocation of each test method
        super.tearDown()
    }

    func test_HALT() throws {
        asm.Halt();

        en.Run();

        XCTAssertEqual(asm.Position, en.PC);
    }

    public func test_NOOP()
    {
        asm.Noop();
        asm.Halt();

        en.Run();

        XCTAssertEqual(asm.Position, en.PC);
    }

    public func test_EI()
    {
        asm.Di();
        asm.Ei();
        asm.Halt();

        en.Run();

        XCTAssertEqual(asm.Position, en.PC);
        XCTAssertEqual(true, en.Iff1);
        XCTAssertEqual(true, en.Iff2);
    }

    public func test_DI()
    {
        asm.Ei();
        asm.Di();
        asm.Halt();

        en.Run();

        XCTAssertEqual(asm.Position, en.PC);
        XCTAssertEqual(false, en.Iff1);
        XCTAssertEqual(false, en.Iff2);
    }

    //[TestCase(0x01, 0x99, 0x100)]
    //[TestCase(0x01, 0x98, 0x99)]
    //[TestCase(0x10, 0x89, 0x99)]
    //[TestCase(0x01, 0x89, 0x90)]
    //[TestCase(0x10, 0x90, 0x100)]
//    public func test_DAA_Add()
//    {
//		let a: byte = 0x10
//		let val: byte = 0x90
//		let correct: int = 0x100
//        asm.LoadRegVal(7, a);
//        asm.AddAVal(val);
//        asm.Daa();
//        asm.Halt();
//
//        en.Run();
//            en.DumpCpu();
//
//        XCTAssertEqual(asm.Position, en.PC);
//        let trueSum = correct;
//        let byteSum: byte = byte(trueSum % 256);
//        let sbyteSum = (sbyte)(byteSum);
//        XCTAssertEqual(byteSum, en.A);
//        XCTAssertEqual(sbyteSum < 0, en.FlagS, "Flag S contained the wrong value");
//        XCTAssertEqual(en.A == 0x00, en.FlagZ, "Flag Z contained the wrong value");
//        XCTAssertEqual(false, en.FlagH, "Flag H contained the wrong value");
//        let overflow = trueSum > 256;
//        XCTAssertEqual(overflow, en.FlagP, "Flag P contained the wrong value");
//        XCTAssertEqual(trueSum > 0xFF, en.FlagC, "Flag C contained the wrong value");
//    }

        //[TestCase(0x00, '0')]
        //[TestCase(0x01, '1')]
        //[TestCase(0x02, '2')]
        //[TestCase(0x03, '3')]
        //[TestCase(0x04, '4')]
        //[TestCase(0x05, '5')]
        //[TestCase(0x06, '6')]
        //[TestCase(0x07, '7')]
        //[TestCase(0x08, '8')]
        //[TestCase(0x09, '9')]
        //[TestCase(0x0A, 'A')]
        //[TestCase(0x0B, 'B')]
        //[TestCase(0x0C, 'C')]
        //[TestCase(0x0D, 'D')]
        //[TestCase(0x0E, 'E')]
        //[TestCase(0x0F, 'F')]
        public func test_DAA_ByteToHex()
        {
            let a: byte = 0x0F
			let val: byte = 0x46 // 'F'
			asm.LoadRegVal(7, a);
            asm.AndVal(0x0F);
            asm.AddAVal(0x90);
            asm.Daa();
            asm.AdcAVal(0x40);
            asm.Daa();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual(val, en.A);
        }

        //[TestCase(1, 1, 0x00)]
        //[TestCase(2, 1, 0x01)]
        //[TestCase(10, 1, 0x09)]
        //[TestCase(16, 1, 0x15)]
        //[TestCase(0xA0, 0x10, 0x90)]
        //[TestCase(0xAA, 0x11, 0x99)]
        //[TestCase(10, 0, 0x10)]
        //[TestCase(100, 1, 99)]
        public func test_DAA_Sub()
        {
            let a: byte = 100
			let val: byte = 1
			let correct: int = 99
			asm.LoadRegVal(7, a);
            asm.SubVal(val);
            asm.Daa();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            let trueSum = correct;
            let byteSum: byte = byte(trueSum % 256);
            let sbyteSum = (sbyte)(byteSum);
            XCTAssertEqual(byteSum, en.A);
            XCTAssertEqual(sbyteSum < 0, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(en.A == 0x00, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual(false, en.FlagH, "Flag H contained the wrong value");
            let overflow = trueSum > 256;
            XCTAssertEqual(overflow, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(trueSum > 0xFF, en.FlagC, "Flag C contained the wrong value");
        }

        //[TestCase(0x00)]
        //[TestCase(0x08)]
        //[TestCase(0x80)]
        //[TestCase(0xFF)]
        public func test_CPL()
        {
			let a: byte = 0xFF
            asm.LoadRegVal(7, a);
            asm.Cpl();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual((byte)(a ^ 0xFF), en.A);
            XCTAssertEqual(true, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(true, en.FlagN, "Flag N contained the wrong value");
        }

        //[TestCase(0x00)]
        //[TestCase(0x08)]
        //[TestCase(0x80)]
        //[TestCase(0xFF)]
        public func test_NEG()
        {
			let a: byte = 0xFF
            asm.LoadRegVal(7, a);
            asm.Neg();
            asm.Halt();

            en.Run();

            let exp = (~a) + 1 // 2's complement
            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual(exp, en.A);
            XCTAssertEqual(exp < 0, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(exp == 0, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual((a & 15) > 0, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(a == 0x80, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(true, en.FlagN, "Flag N contained the wrong value");
            XCTAssertEqual(a != 0, en.FlagC, "Flag C contained the wrong value");
        }

        //[TestCase(true, true)]
        //[TestCase(true, false)]
        //[TestCase(false, true)]
        //[TestCase(false, false)]
        public func test_CCF()
        {
			let carry = false
			let rest = false
            asm.LoadReg16Val(2, (ushort)((carry ? 1 : 0) + (rest ? 254 : 0)));
            asm.PushReg16(2);
            asm.PopReg16(3);
            asm.Ccf();
            asm.Halt();

            en.Run();

            en.DumpCpu();

            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual(rest, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(rest, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual(rest, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(rest, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(false, en.FlagN, "Flag N contained the wrong value");
            XCTAssertEqual(!carry, en.FlagC, "Flag C contained the wrong value");
        }

        //[TestCase(true, true)]
        //[TestCase(true, false)]
        //[TestCase(false, true)]
        //[TestCase(false, false)]
        public func test_SCF()
        {
			let carry = false
			let rest = false
            asm.LoadReg16Val(2, (ushort)((carry ? 1 : 0) + (rest ? 254 : 0)));
            asm.PushReg16(2);
            asm.PopReg16(3);
            asm.Scf();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual(rest, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(rest, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual(rest, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(rest, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(false, en.FlagN, "Flag N contained the wrong value");
            XCTAssertEqual(true, en.FlagC, "Flag C contained the wrong value");
        }

        //[Test, Ignore]
        public func test_IM_0()
        {
            asm.Im0();
            asm.Halt();

            en.Run();

			XCTAssertEqual(asm.Position, en.PC);
            XCTSkip("IM 0 not implemented");
        }

        //[Test, Ignore]
        public func test_IM_1()
        {
            asm.Im1();
            asm.Halt();

            en.Run();

			XCTAssertEqual(asm.Position, en.PC);
            XCTSkip("IM 1 not implemented");
        }

        //[Test, Ignore]
        public func test_IM_2()
        {
            asm.Im2();
            asm.Halt();

            en.Run();

			XCTAssertEqual(asm.Position, en.PC);
            XCTSkip("IM 2 not implemented");
        }
}
