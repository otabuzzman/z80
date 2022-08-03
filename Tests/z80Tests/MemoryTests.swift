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
        let ram: [byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 0)

        for i in 0..<ram.count
        {
            XCTAssertEqual(byte(i), sut[ushort(i)])
        }
    }

    func test_ReadInRom()
    {
        let ram: [byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 10)

        for i in 0..<ram.count
        {
            XCTAssertEqual(byte(i), sut[ushort(i)])
        }
    }

    func test_WriteInRam()
    {
        let ram: [byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 0)

        for i in 0..<ram.count
        {
            sut[ushort(i)] = byte(0xFF ^ i)
            XCTAssertEqual(byte(0xFF ^ i), sut[ushort(i)])
        }
    }

    func test_WriteInRom()
    {
        let ram: [byte] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let sut = Memory(ram, 10)

        for i in 0..<ram.count
        {
            sut[ushort(i)] = byte(0xFF ^ i)
            XCTAssertEqual(byte(i), sut[ushort(i)])
        }
    }
}
