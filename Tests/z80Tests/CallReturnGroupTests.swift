﻿import XCTest
@testable import z80

final class CallReturnGroupTests: XCTestCase {
/*
        public void Test_CALL_nn()
        {
            asm.Call(0x0005);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(0x06, en.PC);
            Assert.AreEqual(0xFFFD, en.SP);
            Assert.AreEqual(0x03, _ram[0xFFFD]);
            Assert.AreEqual(0x00, _ram[0xFFFE]);
        }

        [Test]
        [TestCase(0xFF, 0x09, true)]
        [TestCase(0x00, 0x07, false)]
        public void Test_CALL_NZ_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.CallNz(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x06, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
            else
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
        }
        [Test]
        [TestCase(0xFF, 0x07, false)]
        [TestCase(0x00, 0x09, true)]
        public void Test_CALL_Z_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.CallZ(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x06, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
            else
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
        }
        [Test]
        [TestCase(0xFF, 0x07, false)]
        [TestCase(0x00, 0x09, true)]
        public void Test_CALL_NC_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.CallNc(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x06, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
            else
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
        }
        [Test]
        [TestCase(0xFF, 0x09, true)]
        [TestCase(0x00, 0x07, false)]
        public void Test_CALL_C_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.CallC(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x06, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
            else
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
        }
        [Test]
        [TestCase(0x7F, 0x07, false)]
        [TestCase(0x00, 0x09, true)]
        public void Test_CALL_PO_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.CallPo(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x06, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
            else
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
        }
        [Test]
        [TestCase(0x7F, 0x09, true)]
        [TestCase(0x00, 0x07, false)]
        public void Test_CALL_PE_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.CallPe(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
        }
        [Test]
        [TestCase(0x01, 0x09, true)]
        [TestCase(0x80, 0x07, false)]
        public void Test_CALL_P_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.CallP(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x06, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
            else
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
        }
        [Test]
        [TestCase(0x01, 0x07, false)]
        [TestCase(0x80, 0x09, true)]
        public void Test_CALL_M_nn(byte val, short addr, bool branch)
        {
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.CallM(0x0008);
            asm.Halt();
            asm.Halt();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x06, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
            else
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
        }

        [Test]
        public void Test_RET_nn()
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.Ret();
            asm.Halt();

            en.Run();

            Assert.AreEqual(0x04, en.PC);
            Assert.AreEqual(0xFFFF, en.SP);
        }
        [Test]
        [TestCase(0xFF, 0x04, true)]
        [TestCase(0x00, 0x09, false)]
        public void Test_RET_NZ_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.RetNz();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        [TestCase(0xFF, 0x09, false)]
        [TestCase(0x00, 0x04, true)]
        public void Test_RET_Z_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.RetZ();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        [TestCase(0xFF, 0x09, false)]
        [TestCase(0x00, 0x04, true)]
        public void Test_RET_NC_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.RetNc();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        [TestCase(0xFF, 0x04, true)]
        [TestCase(0x00, 0x09, false)]
        public void Test_RET_C_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.RetC();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        [TestCase(0x00, 0x04, true)]
        [TestCase(0x7F, 0x09, false)]
        public void Test_RET_PO_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.RetPo();
            asm.Halt();

            en.Run();

            en.DumpCpu();
            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        [TestCase(0x7F, 0x04, true)]
        [TestCase(0x00, 0x09, false)]
        public void Test_RET_PE_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.IncReg(7);
            asm.RetPe();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        [TestCase(0xFF, 0x09, false)]
        [TestCase(0x00, 0x04, true)]
        public void Test_RET_P_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.RetP();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        [TestCase(0xFF, 0x04, true)]
        [TestCase(0x00, 0x09, false)]
        public void Test_RET_M_nn(byte val, short addr, bool branch)
        {
            asm.Call(0x0004);
            asm.Halt();
            asm.LoadRegVal(7, val);
            asm.OrReg(7);
            asm.RetM();
            asm.Halt();

            en.Run();

            Assert.AreEqual(addr, en.PC);
            if (branch)
            {
                Assert.AreEqual(0xFFFF, en.SP);
            }
            else
            {
                Assert.AreEqual(0xFFFD, en.SP);
                Assert.AreEqual(0x03, _ram[0xFFFD]);
                Assert.AreEqual(0x00, _ram[0xFFFE]);
            }
        }
        [Test]
        public void Test_RETI_nn()
        {
            asm.Ei();
            asm.Call(0x0005);
            asm.Halt();
            asm.RetI();
            asm.Halt();

            en.Run();

            Assert.AreEqual(0x05, en.PC);
            Assert.AreEqual(0xFFFF, en.SP);
            Assert.AreEqual(en.Iff2, en.Iff1);
        }
        [Test]
        public void Test_RETN_nn()
        {
            asm.Ei();
            asm.Call(0x0005);
            asm.Halt();
            asm.RetN();
            asm.Halt();

            en.Run();

            Assert.AreEqual(0x05, en.PC);
            Assert.AreEqual(0xFFFF, en.SP);
            Assert.AreEqual(en.Iff2, en.Iff1);
        }
        [Test]
        [TestCase(0)]
        [TestCase(1)]
        [TestCase(2)]
        [TestCase(3)]
        [TestCase(4)]
        [TestCase(5)]
        [TestCase(6)]
        [TestCase(7)]
        public void Test_RST_nn(byte page)
        {
            asm.CpVal(0xFF);
            asm.JpZ(0x1000);
            asm.Halt();
            asm.Position = 0x0008;
            asm.Halt();
            asm.Position = 0x0010;
            asm.Halt();
            asm.Position = 0x0018;
            asm.Halt();
            asm.Position = 0x0020;
            asm.Halt();
            asm.Position = 0x0028;
            asm.Halt();
            asm.Position = 0x0030;
            asm.Halt();
            asm.Position = 0x0038;
            asm.Halt();
            asm.Position = 0x1000;
            asm.XorReg(7);
            asm.Rst(page);
            asm.Halt();

            en.Run();

            Assert.AreEqual(page, en.PC / 8);
            Assert.AreEqual(0xFFFD, en.SP);
            Assert.AreEqual(0x02, _ram[0xFFFD]);
            Assert.AreEqual(0x10, _ram[0xFFFE]);
        }
    }
*/
}
