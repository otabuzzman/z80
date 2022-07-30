@testable import z80

    final class TestPorts: IPorts
    {
        private(set) var inputs = Array<byte>(repeating: 0, count: 0x10000)
        private(set) var outputs = Array<byte>(repeating: 0, count: 0x10000)
        private(set) var _data: byte = 0
        private(set) var _mi: bool = false
        private(set) var _nmi: bool = false

        public func ReadPort(_ address: ushort) -> byte
        {
            return inputs[address];
        }

        public func SetInput(_ address: ushort, _ value: byte)
        {
            inputs[address] = value;
        }

        public func GetOutput(_ address: ushort) -> byte
        {
            return outputs[address];
        }

        public func WritePort(_ address: ushort, _ value: byte)
        {
            outputs[address] = value;
        }

        public var NMI: bool
        {
            get
            {
                let ret = _nmi;
                _nmi = false;
                return ret;
            }
            set { _nmi = newValue; }
        }

        public var MI: bool
        {
            get
            {
                let ret = _mi;
                _mi = false;
                return ret;
            }
            set { _mi = newValue; }
        }

        public var Data: byte
        {
            get
            {
                let ret = _data;
                _data = 0x00;
                return ret;
            }
            set { _data = newValue; }
        }

    }
