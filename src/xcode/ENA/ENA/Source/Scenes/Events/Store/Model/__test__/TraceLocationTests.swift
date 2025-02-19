////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationTests: CWATestCase {

	// This test is aligend with a test on the backend side. To ensure that the hashing algorithm returns the same value. Backend test: https://github.com/corona-warn-app/cwa-server/pull/1302/commits/5ce7d27a74fbf4f2ed560772f97ac17e2189ad33#diff-756ac98ac622ebe84967e1057450c3042e440b3c13c1378f5ec592fe5e662983R141-R150

	func test_Given_AnId_When_HashingTheId_Then_CorrectHashIsReturned() {
		let locationId = "afa27b44d43b02a9fea41d13cedc2e4016cfcf87c5dbf990e593669aa8ce286d"
		let data = locationId.dataWithHexString()
		let traceLocation = createMockTraceLocation(id: data)

		guard let idHash = traceLocation.idHash else {
			XCTFail("Could not create id hash.")
			return
		}

		let idHashString = idHash.hexEncodedString().lowercased()

		XCTAssertEqual(idHashString, "0f37dac11d1b8118ea0b44303400faa5e3b876da9d758058b5ff7dc2e5da8230")
	}

	func createMockTraceLocation(id: Data) -> TraceLocation {
		TraceLocation(
			id: id,
			version: 0,
			type: .locationTypePermanentCraft,
			description: "Some Description",
			address: "Some Address",
			startDate: Date(),
			endDate: Date(),
			defaultCheckInLengthInMinutes: 15,
			cryptographicSeed: Data(),
			cnPublicKey: Data()
		)
	}
}

private extension String {
	func dataWithHexString() -> Data {
		var hex = self
		var data = Data()
		while !hex.isEmpty {
			let subIndex = hex.index(hex.startIndex, offsetBy: 2)
			let c = String(hex[..<subIndex])
			hex = String(hex[subIndex...])
			var ch: UInt32 = 0
			Scanner(string: c).scanHexInt32(&ch)
			var char = UInt8(ch)
			data.append(&char, count: 1)
		}
		return data
	}
}

private extension Data {
	func hexEncodedString() -> String {
		let format = "%02hhx"
		return self.map { String(format: format, $0) }.joined()
	}
}
