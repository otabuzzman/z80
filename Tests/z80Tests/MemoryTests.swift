import XCTest
@testable import z80

final class MemoryTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_ReadInRam()
    {
        let ram: [Byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 0)

        for i in 0..<ram.count
        {
            XCTAssertEqual(Byte(i), sut[UShort(i)])
        }
    }

    func test_ReadInRom()
    {
        let ram: [Byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 10)

        for i in 0..<ram.count
        {
            XCTAssertEqual(Byte(i), sut[UShort(i)])
        }
    }

    func test_WriteInRam()
    {
        let ram: [Byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 0)

        for i in 0..<ram.count
        {
            sut[UShort(i)] = Byte(0xFF ^ i)
            XCTAssertEqual(Byte(0xFF ^ i), sut[UShort(i)])
        }
    }

    func test_WriteInRom()
    {
        let ram: [Byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 10)

        for i in 0..<ram.count
        {
            sut[UShort(i)] = Byte(0xFF ^ i)
            XCTAssertEqual(Byte(i), sut[UShort(i)])
        }
    }
}
