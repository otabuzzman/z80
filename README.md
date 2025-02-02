# z80
A csharp and swift emulator for the Zilog Z80 CPU.

## The project

z80 a Z80 emulator that works in real time written in C# and Swift.

These are contained:

* Z80 Emulator (`Z80`)
* Z80 Assembler backend (`Z80Asm`)
* Zilog-based Z80 tests (`z80.Tests` for C#, `Tests/z80Tests` for Swift)

The tests are a translation of the documentation, the assembler backend is needed to write tests and stay sane and the emulator is the whole point. 

There's a very basic step debugger in the tests (`TestSystem`) which basically came for free with them.

## Usage example C#

```csharp
var ram = new byte[65536];

// Load a ROM image
Array.Clear(ram, 0, ram.Length);
Array.Copy(File.ReadAllBytes("48.rom"), ram, 16384);

// Ports is something you supply to emulate I/O ports
var ports = new SamplePorts();

// Set up memory layout
var myZ80 = new Z80(new Memory(ram, 16384), ports);

// Run
while (!myZ80.Halt)
{
    myZ80.Parse();
}

// Show the registers
Console.WriteLine(myZ80.DumpState());
```

### Run test suite in VS2022

- Update project to use .NET 4.8 and NUnit 3
- Open terminal and CWD into `z80.Tests` folder
- Exec `nunit3-console bin\Debug\z80.Tests.dll` command

## Usage example Swift

Copy files from `Sources/z80` to Swift project.

```swift
import Foundation

@main
extension Z80 {
    static func main() {
        // define max 64k RAM
        var ram = Array<byte>(repeating: 0, count: 0x10000)
        // load ROM image
        let rom = NSData(contentsOfFile: "z80sample/48.rom")
        // copy ROM to RAM
        ram.replaceSubrange(0..<rom!.count, with: rom!)

        // I/O ports emulation (Sources/z80sample/Program.swift)
        let ports = SamplePorts()

        let mem = Memory(ram, 16384)
        var z80 = Z80(mem, ports)

        while (!z80.Halt)
        {
            z80.parse()
        }

        // dump CPU state
        print(z80.dumpState())
    }
}
```

### Run Swift test suite

- Open terminal window on MacOS, Linos or Winos
- Clone repository and CWD into TL folder
- Exec `swift test` command

## Status

Test Coverage: **98.29%**  
Spectrum ROM: **_Apparently_ it works**, but needs a ULA to work.

### Opcodes


The following opcodes are supported

* 8-bit load group (e.g. `LD A, 0x42`)
* 16-bit load group (e.g. `POP HL`)
* Exchange, Block Transfer, and Search group (e.g. `EX AF, AF'`)
* 8-Bit Arithmetic Group (e.g. `ADD 0x23`)
* General-Purpose Arithmetic and CPU Control Groups (e.g. `NOP`, `HALT`, ...)
* 16-Bit Arithmetic Group (e.g. `ADD HL, 0x2D5F`, ...)
* Rotate and Shift Group (e.g. `RLCA`, `RLA`, ...)
* Bit Set, Reset, and Test Group (`BIT`, `SET`, `RES`)
* Jump Group (`JP nn`, `JR e`, `DJNZ e`, ...)
* Call and Return Group (`CALL`, `RET`, `RST`)
* Undocumented opcodes (`CB`, `DDCB`, `FDCB`, `ED`)
* Input and Output Group (`IN`, `OUT`, ...)

### Other features

These other features are supported

* Address and Data bus
* R register counts machine cycles (approximately)
* Interrupts
* Other pins


## The future

The following opcodes are not done

* Undocumented opcodes (`DD`, `FD`)
* Undocumented effects (`BIT`, Memory Block Instructions, I/O Block Instructions, 16 Bit I/O ports, Block Instructions, Bit Additions, DAA Instruction)

These new features are highly desirable

* An assembler frontend thus having a full z80 assembler
* A disassembler based on the current CPU emulator code

Also, the project should have NuGet packages at some point.

## Bibliography

The following resources have been useful documentation:

* [Z80 CPU User Manual](http://www.zilog.com/manage_directlink.php?filepath=docs/z80/um0080) by Zilog
* [ZEMU - Z80 Emulator](http://www.z80.info/zip/zemu.zip) by Joe Moore
* [The Undocumented Z80 Documented](http://www.myquest.nl/z80undocumented/z80-documented-v0.91.pdf) by Sean Young
* [comp.sys.sinclair FAQ](http://www.worldofspectrum.org/faq/reference/z80reference.htm)
* [jsspeccy](https://github.com/gasman/jsspeccy) by Matt Westcott
* [The Complete Spectrum ROM Disassembly](http://dac.escet.urjc.es/~csanchez/pfcs/zxspectrum/CompleteSpectrumROMDisassemblyThe.pdf) by Dr Ian Logan & Dr Frank O&apos;Hara

## License

### Swift version

Copyright &copy; 2022, Jürgen Schuck

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the „Software“), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED „AS IS“, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### C# version

Copyright &copy; 2015, Marco Cecconi  
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

### ZX Spectrum 48k ROM image

The ZX Spectrum 48k ROM is &copy; copyright Amstrad Ltd. Amstrad have kindly given their permission for the redistribution of their copyrighted material but retain that copyright.
