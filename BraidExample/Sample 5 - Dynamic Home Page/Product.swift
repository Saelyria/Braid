import Foundation

struct Product {
    let title: String         // The title of the product.
    let price: Double         // The price of the product per its unit.
    let unitSoldBy: Unit      // The unit the product is sold in (liter, each, etc).
    let imageUrl: URL         // URL to an image of the product.
    let description: String?  // A longer description of the product.
    
    enum Unit: String, Decodable {
        case each = "ea"  // The product is packaged individually, priced by unit.
        case litre        // The product is priced by liter.
        case gram         // The product is priced by gram.
    }
}

extension Product: Decodable {
    private enum CodingKeys: CodingKey {
        case title
        case price
        case unit
        case imageUrl
        case description
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decode(Double.self, forKey: .price)
        self.unitSoldBy = try container.decode(Product.Unit.self, forKey: .unit)
        let imagePath = try container.decode(String.self, forKey: .imageUrl)
        guard let imageUrl = URL(string: imagePath) else {
            throw DecodingError.dataCorruptedError(forKey: .imageUrl, in: container, debugDescription: "URL given in the 'product' object on response was invalid")
        }
        self.imageUrl = imageUrl
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
    }
}
