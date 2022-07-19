public protocol IPorts {
    func readPort(address: UInt16) -> UInt8
    func writePort(address: UInt16, value: UInt8)

    var NMI: Bool { get }
    var INT: Bool { get }

    var data: UInt8 { get }
}
