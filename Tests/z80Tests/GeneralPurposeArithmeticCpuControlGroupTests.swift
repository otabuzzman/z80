import XCTest
@testable import z80

final class GeneralPurposeArithmeticCpuControlGroupTests: XCTestCase {
    var en: TestSystem!
    var asm: Z80Asm!
    var _ram: Memory!

    override func setUp() {
        super.setUp()

        _ram = Memory(0x10000, 0)
        en = TestSystem(_ram);
        asm = Z80Asm(_ram);

        en.Reset();
        asm.Reset();
    }

    override func tearDown() {
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

    public func test_DAA_Add()
    {
		[
			(a: byte(0x01), val: byte(0x99), correct: 0x100),
			(a: byte(0x01), val: byte(0x98), correct: 0x99),
			(a: byte(0x10), val: byte(0x89), correct: 0x99),
			(a: byte(0x01), val: byte(0x89), correct: 0x90),
			(a: byte(0x10), val: byte(0x90), correct: 0x100),
		].forEach { testCase in
			tearDown()
			setUp()
			
			asm.LoadRegVal(7, testCase.a);
			asm.AddAVal(testCase.val);
			asm.Daa();
			asm.Halt();
	
			en.Run();
	
			XCTAssertEqual(asm.Position, en.PC);
			let trueSum = testCase.correct;
			let byteSum = trueSum % 256;
			let sbyteSum = (sbyte)(truncatingIfNeeded: byteSum);
			XCTAssertEqual(byte(byteSum), en.A);
			XCTAssertEqual(sbyteSum < 0, en.FlagS, "Flag S contained the wrong value");
			XCTAssertEqual(en.A == 0x00, en.FlagZ, "Flag Z contained the wrong value");
			XCTAssertEqual(false, en.FlagH, "Flag H contained the wrong value");
			let overflow = trueSum > 256;
			XCTAssertEqual(overflow, en.FlagP, "Flag P contained the wrong value");
			XCTAssertEqual(trueSum > 0xFF, en.FlagC, "Flag C contained the wrong value");
		}
    }

        public func test_DAA_ByteToHex()
        {
		[
				(a: byte(0x00), val: "0"),
				(a: byte(0x01), val: "1"),
				(a: byte(0x02), val: "2"),
				(a: byte(0x03), val: "3"),
				(a: byte(0x04), val: "4"),
				(a: byte(0x05), val: "5"),
				(a: byte(0x06), val: "6"),
				(a: byte(0x07), val: "7"),
				(a: byte(0x08), val: "8"),
				(a: byte(0x09), val: "9"),
				(a: byte(0x0A), val: "A"),
				(a: byte(0x0B), val: "B"),
				(a: byte(0x0C), val: "C"),
				(a: byte(0x0D), val: "D"),
				(a: byte(0x0E), val: "E"),
				(a: byte(0x0F), val: "F"),
		].forEach { testCase in
				tearDown()
				setUp()
				
				asm.LoadRegVal(7, testCase.a);
				asm.AndVal(0x0F);
				asm.AddAVal(0x90);
				asm.Daa();
				asm.AdcAVal(0x40);
				asm.Daa();
				asm.Halt();
	
				en.Run();
	
				XCTAssertEqual(asm.Position, en.PC);
				XCTAssertEqual(Character(testCase.val).asciiValue!, en.A);
			}
        }

        public func test_DAA_Sub()
        {
		[
(a: byte(1),     val: byte(1),    correct: 0x00),
(a: byte(2),     val: byte(1),    correct: 0x01),
(a: byte(10),    val: byte(1),    correct: 0x09),
(a: byte(16),    val: byte(1),    correct: 0x15),
(a: byte(0xA0),  val: byte(0x10), correct: 0x90),
(a: byte(0xAA),  val: byte(0x11), correct: 0x99),
(a: byte(10),    val: byte(0),    correct: 0x10),
(a: byte(100),   val: byte(1),    correct: 99),
		].forEach { testCase in
				tearDown()
				setUp()
				
			asm.LoadRegVal(7, testCase.a);
            asm.SubVal(testCase.val);
            asm.Daa();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            let trueSum = testCase.correct;
            let byteSum = trueSum % 256;
            let sbyteSum = (sbyte)(truncatingIfNeeded: byteSum);
            XCTAssertEqual(byte(byteSum), en.A);
            XCTAssertEqual(sbyteSum < 0, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(en.A == 0x00, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual(false, en.FlagH, "Flag H contained the wrong value");
            let overflow = trueSum > 256;
            XCTAssertEqual(overflow, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(trueSum > 0xFF, en.FlagC, "Flag C contained the wrong value");
			}
        }

        public func test_CPL()
        {
		[
			byte(0x00),
			byte(0x08),
			byte(0x80),
			byte(0xFF),
		].forEach { a in
				tearDown()
				setUp()
				
            asm.LoadRegVal(7, a);
            asm.Cpl();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual((byte)(a ^ 0xFF), en.A);
            XCTAssertEqual(true, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(true, en.FlagN, "Flag N contained the wrong value");
			}
        }

        public func test_NEG()
        {
		[
			byte(0x00),
			byte(0x08),
			byte(0x80),
			byte(0xFF),
		].forEach { a in
				tearDown()
				setUp()
				
            asm.LoadRegVal(7, a);
            asm.Neg();
            asm.Halt();

            en.Run();

            let exp = -short(a) //(~a) + 1 // 2's complement
            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual(byte(truncatingIfNeeded: exp), en.A);
            XCTAssertEqual(sbyte(truncatingIfNeeded: exp) < 0, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(exp == 0, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual((a & 15) > 0, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(a == 0x80, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(true, en.FlagN, "Flag N contained the wrong value");
            XCTAssertEqual(a != 0, en.FlagC, "Flag C contained the wrong value");
			}
        }

        public func test_CCF()
        {
		[
			(carry: true, rest: true),
			(carry: true, rest: false),
			(carry: false, rest: true),
			(carry: false, rest: false),
		].forEach { testCase in
				tearDown()
				setUp()
				
            asm.LoadReg16Val(2, (ushort)((testCase.carry ? 1 : 0) + (testCase.rest ? 254 : 0)));
            asm.PushReg16(2);
            asm.PopReg16(3);
            asm.Ccf();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual(testCase.rest, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(testCase.rest, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual(testCase.rest, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(testCase.rest, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(false, en.FlagN, "Flag N contained the wrong value");
            XCTAssertEqual(!testCase.carry, en.FlagC, "Flag C contained the wrong value");
			}
        }

        public func test_SCF()
        {
		[
			(carry: true, rest: true),
			(carry: true, rest: false),
			(carry: false, rest: true),
			(carry: false, rest: false),
		].forEach { testCase in
				tearDown()
				setUp()
				
            asm.LoadReg16Val(2, (ushort)((testCase.carry ? 1 : 0) + (testCase.rest ? 254 : 0)));
            asm.PushReg16(2);
            asm.PopReg16(3);
            asm.Scf();
            asm.Halt();

            en.Run();

            XCTAssertEqual(asm.Position, en.PC);
            XCTAssertEqual(testCase.rest, en.FlagS, "Flag S contained the wrong value");
            XCTAssertEqual(testCase.rest, en.FlagZ, "Flag Z contained the wrong value");
            XCTAssertEqual(testCase.rest, en.FlagH, "Flag H contained the wrong value");
            XCTAssertEqual(testCase.rest, en.FlagP, "Flag P contained the wrong value");
            XCTAssertEqual(false, en.FlagN, "Flag N contained the wrong value");
            XCTAssertEqual(true, en.FlagC, "Flag C contained the wrong value");
			}
        }

        public func test_IM_0()
        {
            asm.Im0();
            asm.Halt();

            en.Run();

			XCTAssertEqual(asm.Position, en.PC);
            XCTAssertTrue(false, "IM 0 not implemented");
        }

        public func test_IM_1()
        {
            asm.Im1();
            asm.Halt();

            en.Run();

			XCTAssertEqual(asm.Position, en.PC);
            XCTAssertTrue(false, "IM 1 not implemented");
        }

        public func test_IM_2()
        {
            asm.Im2();
            asm.Halt();

            en.Run();

			XCTAssertEqual(asm.Position, en.PC);
            XCTAssertTrue(false, "IM 2 not implemented");
        }
}
