public protocol IPorts {
    func readPort(_ address: UInt8) -> UInt8
    func writePort(_ address: UInt8, _ value: UInt8)

    var NMI: Bool { get }
    var INT: Bool { get }

    var data: UInt8 { get }
}
