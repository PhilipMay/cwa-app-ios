////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AddCertificateCellModelTests: XCTestCase {

	func testGIVEN_CellModel_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = AddCertificateCellModel()

		// THEN
		XCTAssertEqual(cellViewModel.textColorPublisher.value, UIColor.enaColor(for: .textPrimary1))
		XCTAssertEqual(cellViewModel.iconImagePublisher.value, UIImage(named: "Icons_qrScan"))
	}

	func testGIVEN_CellModel_WHEN_SetEnabled_THEN_TextColorAndButtonStateChange() {
		// GIVEN
		let cellViewModel = AddCertificateCellModel()

		// WHEN
		cellViewModel.setEnabled(false)

		// THEN
		XCTAssertEqual(cellViewModel.textColorPublisher.value, UIColor.enaColor(for: .textPrimary2))
		XCTAssertEqual(cellViewModel.iconImagePublisher.value, UIImage(named: "Icons_qrScan_Grey"))
	}

}
