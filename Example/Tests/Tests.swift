import UIKit
import XCTest
import CCBluetooth

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStringFromDate() {
        let dataSet = NSData(bytes: [0xE1,0x07,0x06,0x06,0x12,0x17,0x05,0xF0,0x04] as [UInt8], length: 11)
        let bluetoothDateTime = BluetoothDateTime()
        let result:String = bluetoothDateTime.dateFromData(data: dataSet)
        
        XCTAssertEqual("2017-06-06 18:23:05 GMT-04:00", result)
    }
}
