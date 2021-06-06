//
// 🦠 Corona-Warn-App
//

import AVFoundation
import Foundation
import XCTest
@testable import ENA

final class TestableExposureSubmissionQRScannerViewModel: ExposureSubmissionQRScannerViewModel {

	private var fakeIsScanning: Bool = false

	override var isScanningActivated: Bool {
		return fakeIsScanning
	}

	override func activateScanning() {
		fakeIsScanning = true
	}

	override func deactivateScanning() {
		fakeIsScanning = false
	}

	#if !targetEnvironment(simulator)
	override func startCaptureSession() {
		if isScanningActivated {
			deactivateScanning()
		} else {
			activateScanning()
		}
	}
	
	override func setupCaptureSession() {
		guard isScanningActivated else {
			onError(.cameraPermissionDenied, {})
			return
		}
	}
	#endif
}
// swiftlint:disable:next type_body_length
final class ExposureSubmissionQRScannerViewModelTests: CWATestCase {

	func testSuccessfulPcrScan() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .pcr(let scannedGuid):
					XCTAssertEqual(scannedGuid, guid)
				case .antigen:
					XCTFail("Expected PCR test")
				case .teleTAN:
					XCTFail("Expected PCR test")
				}
				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(guid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
	
	func testSuccessfulAntigenScan_Base64URL() throws {
		let payload = "eyJ0aW1lc3RhbXAiOjE2MTk2MTcyNjksInNhbHQiOiI3QkZBMDZCNUFEOTMxMUI4NzE5QkI4MDY2MUM1NEVBRCIsInRlc3RpZCI6ImI0YTQwYzZjLWUwMmMtNDQ0OC1iOGFiLTBiNWI3YzM0ZDYwYSIsImhhc2giOiIxZWE0YzIyMmZmMGMwZTRlZDczNzNmMjc0Y2FhN2Y3NWQxMGZjY2JkYWM1NmM2MzI3NzFjZDk1OTIxMDJhNTU1IiwiZm4iOiJIZW5yeSIsImxuIjoiUGluemFuaSIsImRvYiI6IjE5ODktMDgtMzAifQ"
		let validAntigenHash = try XCTUnwrap(self.validAntigenHash(validPayload: payload))

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .antigen(let testInformation):
					XCTAssertEqual(testInformation.hash, validAntigenHash)
				case .pcr:
					XCTFail("Expected antigen test")
				case .teleTAN:
					XCTFail("Expected antigen test")
				}

				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://s.coronawarn.app/?v=1#\(payload)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
	func testSuccessfulAntigenScan_base64() throws {
		let payload = "eyJ0aW1lc3RhbXAiOjE2MTk2MTc5NjIsInNhbHQiOiI2MTc4QjY2NjI5RTRFQTk2QzNGRkM4NDVBNDg3QUQzRiIsInRlc3RpZCI6ImVhYWY4ZGIwLWRmOGMtNDI2ZC1hZmMwLWRkMDAyZjNhMzBkMiIsImhhc2giOiI4Zjg2N2MxMTdiZjg0OWMwNzYzM2E3MmE2MTlmNGNjNDI4N2ZkNTRkNWVhOWRmNzc2YWU0NWYwNzRlMzIxNzQ0IiwiZm4iOiJEdXN0aW4iLCJsbiI6IkFsYmxhcyIsImRvYiI6IjE5NjYtMDEtMDcifQ=="
		let validAntigenHash = try XCTUnwrap(self.validAntigenHash(validPayload: payload))

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .antigen(let testInformation):
					XCTAssertEqual(testInformation.hash, validAntigenHash)
				case .pcr:
					XCTFail("Expected antigen test")
				case .teleTAN:
					XCTFail("Expected antigen test")
				}

				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://s.coronawarn.app/?v=1#\(payload)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one successful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
	}
	func testUnsuccessfulScan() {
		let emptyGuid = ""

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 2

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		viewModel.activateScanning()
		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(emptyGuid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		// Check that scanning is deactivated after one unsuccessful scan
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
		XCTAssertFalse(viewModel.isScanningActivated)
	}

	func testScanningIsDeactivatedInitially() {
		let guid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"

		let onSuccessExpectation = expectation(description: "onSuccess not called")
		onSuccessExpectation.isInverted = true

		let onErrorExpectation = expectation(description: "onError not called")
		// first onError call will happen on ViewModel init
		onErrorExpectation.expectedFulfillmentCount = 1

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { _ in
				onSuccessExpectation.fulfill()
			},
			onError: { _, _ in
				onErrorExpectation.fulfill()
			}
		)

		let metaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(guid)")
		viewModel.didScan(metadataObjects: [metaDataObject])

		waitForExpectations(timeout: .short)
		XCTAssertFalse(viewModel.isScanningActivated)
	}

	func testInitalUnsuccessfulScanWithSuccessfulRetry() {
		let validGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let emptyGuid = ""

		let onSuccessExpectation = expectation(description: "onSuccess called")
		onSuccessExpectation.expectedFulfillmentCount = 1

		let onErrorExpectation = expectation(description: "onError called")
		onErrorExpectation.expectedFulfillmentCount = 2

		let viewModel = TestableExposureSubmissionQRScannerViewModel(
			onSuccess: { testInformation in
				switch testInformation {
				case .pcr(let scannedGuid):
					XCTAssertEqual(scannedGuid, validGuid)
				case .antigen:
					XCTFail("Expected PCR test")
				case .teleTAN:
					XCTFail("Expected PCR test")
				}
				onSuccessExpectation.fulfill()
			},
			onError: { error, reactivateScanning in
				switch error {
				case .cameraPermissionDenied:
					onErrorExpectation.fulfill()
					reactivateScanning()

				case .codeNotFound:
					onErrorExpectation.fulfill()
					reactivateScanning()

				case .other:
					XCTFail("unexpected error")
				}
			}
		)

		viewModel.activateScanning()

		let invalidMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(emptyGuid)")
		viewModel.didScan(metadataObjects: [invalidMetaDataObject])

		wait(for: [onErrorExpectation], timeout: .short)

		let validMetaDataObject = FakeMetadataMachineReadableCodeObject(stringValue: "https://localhost/?\(validGuid)")
		viewModel.activateScanning()
		viewModel.didScan(metadataObjects: [validMetaDataObject])

		wait(for: [onSuccessExpectation], timeout: .short)
	}

	func testQRCodeExtraction_EmptyString() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_InputLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: String(repeating: "x", count: 150))

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_WrongURL() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://wrong.app/?\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_someUTF8Text() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "This is a Test ん鞠")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingURL() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "?\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testQRCodeExtraction_MissingQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/\(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_AdditionalSpaceAfterQuestionMark() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "? \(validPcrGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_GUIDLengthExceeded() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid)-BEEF")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_GUIDTooShort() {
		let viewModel = createViewModel()

		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.dropLast(4))")

		XCTAssertNil(result)
	}
	
	func testPcrQRCodeExtraction_GUIDStructureWrong() {
		let viewModel = createViewModel()

		let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(wrongGuid)")

		XCTAssertNil(result)
	}

	func testPcrQRCodeExtraction_ValidWithUppercaseString() {
		let viewModel = createViewModel()

		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.uppercased())") else {
			XCTFail("Result is nil")
			return
		}

		switch  result {
		case .antigen:
			XCTFail("Expected PCR test")
		case .pcr(let result):
			XCTAssertEqual(result, validPcrGuid)
		case .teleTAN:
			XCTFail("Expected PCR test")
		}
	}

	func testPcrQRCodeExtraction_ValidWithLowercaseString() {
		let viewModel = createViewModel()

		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.lowercased())") else {
			XCTFail("Result is nil")
			return
		}
		switch  result {
		case .antigen:
			XCTFail("Expected PCR test")
		case .pcr(let result):
			XCTAssertEqual(result, validPcrGuid.lowercased())
		case .teleTAN:
			XCTFail("Expected PCR test")
		}
	}

	func testPcrQRCodeExtraction_ValidWithMixedcaseString() {
		let viewModel = createViewModel()
		
		let mixedCaseGuid = "3D6d08-3567F3f2-4DcF-43A3-8737-4CD1F87d6FDa"
		
		guard let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost/?\(mixedCaseGuid)") else {
			XCTFail("Result is nil")
			return
		}
		switch  result {
		case .antigen:
			XCTFail("Expected PCR test")
		case .pcr(let result):
			XCTAssertEqual(result, mixedCaseGuid)
		case .teleTAN:
			XCTFail("Expected PCR test")
		}
	}

	func testGIVEN_ViewModelWithScanningEnabled_WHEN_stop_THEN_scanningIsDisabled() {
		// GIVEN
		let viewModel = ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })

		// WHEN
		viewModel.stopCaptureSession()

		// THEN
		XCTAssertFalse(viewModel.isScanningActivated, "Scanning is still enabled")
	}

	func testGIVEN_ViewModelWithScanningDisabled_WHEN_stop_THEN_scanningIsDisabled() {
		// GIVEN
		let viewModel = ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })

		// WHEN
		viewModel.stopCaptureSession()

		// THEN
		XCTAssertFalse(viewModel.isScanningActivated, "Scanning is still enabled")
	}

	func testGIVEN_upperCasedHost_WHEN_extractGuid_THEN_isFound() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?\(validPcrGuid)")

		// THEN
		XCTAssertNotNil(result)
	}

	func testGIVEN_invalidPath_WHEN_extractPcrGuid_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.coronaTestQRCodeInformation(from: "https://localhost//?A9652E-3BE0486D-0678-40A8-BEFD-07846B41993C")

		// THEN
		XCTAssertNil(result)
	}
	
	func testGIVEN_invalidPath_WHEN_extractAntigenPayload_THEN_isInvalid() {
		// GIVEN
		let viewModel = createViewModel()

		// WHEN
		let result = viewModel.coronaTestQRCodeInformation(from: "https://s.coronawarn.app/?v=1#//?eyJ0aW1lc3RhbXAiOjE2MTgyMzM5NzksImd1aWQiOiIwQzg5MjItMEM4OTIyNjMtQTM0Qy00RjM1LTg5QUMtMTcyMzlBMzQ2QUZEIiwiZm4iOiJDYW1lcm9uIiwibG4iOiJIdWRzb24iLCJkb2IiOiIxOTkyLTA4LTA3In0")

		// THEN
		XCTAssertNil(result)
	}
	func testAntigen_hashIsTooShort() {
		let invalidHash = "f1200d9650f1fd673d58f52811f98f1427fab40b4996e9c2d0da8b741446408"
		let antigenTestInformation = AntigenTestQRCodeInformation.mock(hash: invalidHash)
		
		do {
			let payloadData = try XCTUnwrap(JSONEncoder().encode(antigenTestInformation))
			let payloadString = payloadData.base64EncodedString()
			let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
			let route = Route(url)
			XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidHash))), "incorrect hash should trigger an error")
		} catch {
			XCTFail("Caught an error while trying to encode the Antigen test")
		}
	}
	func testAntigen_hashIsNotHex() {
		let invalidHash = "f1200d9650f1fd673d58f52811f98f1427fab40b4996e9c2d0da8b741446408G"
		let antigenTestInformation = AntigenTestQRCodeInformation.mock(hash: invalidHash)
		
		do {
			let payloadData = try XCTUnwrap(JSONEncoder().encode(antigenTestInformation))
			let payloadString = payloadData.base64EncodedString()
			let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
			let route = Route(url)
			XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidHash))), "incorrect hash should trigger an error")
		} catch {
			XCTFail("Caught an error while trying to encode the Antigen test")
		}
	}
	func testAntigen_InvalidTestedPersonInformation() {
		let antigenTestInformation = AntigenTestQRCodeInformation.mock(
			hash: "584b5177c687f2a007778b2f1d2365770ca318b0a8cda0593f691c0d17d18d01",
			timestamp: 5,
			firstName: "Jon",
			lastName: nil,
			cryptographicSalt: "C520E70759CC69B28CAA219A8B57DAB4",
			testID: "40352cb5-e44b-409b-b4c9-2d8aac60f805",
			dateOfBirth: Date(timeIntervalSince1970: 1619618081)
		)
		do {
			let payloadData = try XCTUnwrap(JSONEncoder().encode(antigenTestInformation))
			let payloadString = payloadData.base64EncodedString()
			let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
			let route = Route(url)
			XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidTestedPersonInformation))), "incorrect Personal info Hash should trigger an error")
		} catch {
			XCTFail("Caught an error while trying to encode the Antigen test")
		}
	}
	func testAntigen_InvalidTimeStamp() {
		let antigenTestInformation = AntigenTestQRCodeInformation.mock(
			hash: "584b5177c687f2a007778b2f1d2365770ca318b0a8cda0593f691c0d17d18d01",
			timestamp: -5,
			firstName: "Jon",
			lastName: "Bird",
			cryptographicSalt: "C520E70759CC69B28CAA219A8B57DAB4",
			testID: "40352cb5-e44b-409b-b4c9-2d8aac60f805",
			dateOfBirth: Date(timeIntervalSince1970: 1619618081)
		)
		do {
			let payloadData = try XCTUnwrap(JSONEncoder().encode(antigenTestInformation))
			let payloadString = payloadData.base64EncodedString()
			let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
			let route = Route(url)
			XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidTimeStamp))), "incorrect TimeStamp should trigger an error")
		} catch {
			XCTFail("Caught an error while trying to encode the Antigen test")
		}
	}
	func testAntigen_HashMismatch() {
		let antigenTestInformation = AntigenTestQRCodeInformation.mock(
			hash: "584b5177c687f2a007778b2f1d2365770ca318b0a8cda0593f691c0d17d18d01",
			timestamp: 5,
			firstName: "Jon",
			lastName: "Bird",
			cryptographicSalt: "C520E70759CC69B28CAA219A8B57DAB4",
			testID: "40352cb5-e44b-409b-b4c9-2d8aac60f805",
			dateOfBirth: Date(timeIntervalSince1970: 1619618081)
		)
		do {
			let payloadData = try XCTUnwrap(JSONEncoder().encode(antigenTestInformation))
			let payloadString = payloadData.base64EncodedString()
			let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
			let route = Route(url)
			XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.hashMismatch))), "incorrect recalculated Hash should trigger an error")
		} catch {
			XCTFail("Caught an error while trying to encode the Antigen test")
		}
	}
	
	private let validPcrGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
	private func validAntigenHash(validPayload: String) -> String? {
		let jsonData: Data
		if validPayload.isBase64Encoded {
			guard let parsedData = Data(base64Encoded: validPayload) else {
				return nil
			}
			jsonData = parsedData
		} else {
			guard let parsedData = Data(base64URLEncoded: validPayload) else {
				return nil
			}
			jsonData = parsedData
		}
		do {
			let jsonDecoder = JSONDecoder()
			jsonDecoder.dateDecodingStrategy = .custom({ decoder -> Date in
				let container = try decoder.singleValueContainer()
				let stringDate = try container.decode(String.self)
				guard let date = ISO8601DateFormatter.justUTCDateFormatter.date(from: stringDate) else {
					throw DecodingError.dataCorruptedError(in: container, debugDescription: "failed to decode date \(stringDate)")
				}
				return date
			})

			let testInformation = try jsonDecoder.decode(AntigenTestQRCodeInformation.self, from: jsonData)
			return testInformation.hash
		} catch {
			Log.debug("Failed to read / parse district json", log: .ppac)
			return nil
		}
	}
	
	private func createViewModel() -> ExposureSubmissionQRScannerViewModel {
		ExposureSubmissionQRScannerViewModel(onSuccess: { _ in }, onError: { _, _ in })
	}
}
