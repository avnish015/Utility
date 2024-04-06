import Foundation

//It will decode any type array, dictionry or singalValue
struct AnyCodable: Decodable {
    
    var value: Any
    
    struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }
    
    init(from decoder: Decoder) throws {
        
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { key in
                result[key.stringValue] = try container.decode(AnyCodable.self, forKey: key).value
            }
            value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyCodable.self).value)
            }
            value = result
        } else if let container = try? decoder.singleValueContainer() {
            if let intValue = try?  container.decode(Int.self) {
                value = intValue
            } else if let doubleValue = try? container.decode(Double.self) {
                value = doubleValue
            } else if let stringValue = try? container.decode(String.self) {
                value = stringValue
            } else if let boolValue = try? container.decode(Bool.self) {
                value = boolValue
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Can't serialize")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Can't decode"))
        }
    }
}


if let url = Bundle.main.url(forResource: "Sample", withExtension: "json"), let data = try? Data(contentsOf: url) {
    do {
        let decodedData = try JSONDecoder().decode(AnyCodable.self, from: data)
        print(decodedData.value)
    } catch {
        print(error.localizedDescription)
    }
}

