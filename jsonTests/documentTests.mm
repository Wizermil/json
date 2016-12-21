//
// documentTests.mm
// json
//
// Created by Mathieu Garaud on 09/08/16.
//
// MIT License
//
// Copyright © 2016 Pretty Simple
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <XCTest/XCTest.h>
#import <json/json.h>
#include <iomanip>
#include <iterator>
#include <limits>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>

@interface documentTests : XCTestCase

@end

@implementation documentTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAlloc {
    json::Document doc;
    XCTAssertEqual(doc.getType(), json::Kind::UNKNOWN, "The type is not set to UNKNOWN");

    json::Document* doc1 = new json::Document();
    XCTAssertEqual(doc1->getType(), json::Kind::UNKNOWN, "The type is not set to UNKNOWN");
    delete doc1;

    json::Document doc2(json::Kind::OBJECT);
    XCTAssertEqual(doc2.getType(), json::Kind::OBJECT, "The type is not set to OBJECT");

    json::Document doc3(json::Kind::ARRAY);
    XCTAssertEqual(doc3.getType(), json::Kind::ARRAY, "The type is not set to ARRAY");

    auto doc4 = std::make_unique<json::Document>(json::Kind::UNKNOWN);
    XCTAssertEqual(doc4->getType(), json::Kind::UNKNOWN, "The type is not set to UNKNOWN");
}

- (void)testAllocMove {
    json::Document doc;
    XCTAssertEqual(doc.getType(), json::Kind::UNKNOWN, "The type is not set to UNKNOWN");
    json::Document doc1 = json::Document(std::move(doc));
    XCTAssertEqual(doc1.getType(), json::Kind::UNKNOWN, "The type is not set to UNKNOWN");

    json::Document* doc2 = new json::Document(json::Kind::OBJECT);
    XCTAssertEqual(doc2->getType(), json::Kind::OBJECT, "The type is not set to OBJECT");
    json::Document* doc3 = new json::Document(std::move(*doc2));
    XCTAssertEqual(doc3->getType(), json::Kind::OBJECT, "The type is not set to ARRAY");
    delete doc3;
    delete doc2;

    auto doc4 = std::make_unique<json::Document>(json::Kind::ARRAY);
    XCTAssertEqual(doc4->getType(), json::Kind::ARRAY, "The type is not set to ARRAY");
    auto doc5 = std::make_unique<json::Document>(std::move(*doc4.release()));
    XCTAssertEqual(doc5->getType(), json::Kind::ARRAY, "The type is not set to ARRAY");

    json::Document doc6(json::Kind::OBJECT);
    XCTAssertEqual(doc6.getType(), json::Kind::OBJECT, "The type is not set to OBJECT");
    json::Document* doc7 = new json::Document();
    *doc7 = std::move(doc6);
    XCTAssertEqual(doc7->getType(), json::Kind::OBJECT, "The type is not set to ARRAY");
    delete doc7;

    auto doc8 = std::make_unique<json::Document>(json::Kind::ARRAY);
    XCTAssertEqual(doc8->getType(), json::Kind::ARRAY, "The type is not set to ARRAY");
    auto doc9 = std::move(*doc8.release());
    XCTAssertEqual(doc9.getType(), json::Kind::ARRAY, "The type is not set to ARRAY");

    json::Document doc10(json::Kind::OBJECT);
    json::Document doc11(json::Kind::OBJECT);
    doc11 = std::move(doc10);
    XCTAssertEqual(doc11.getType(), json::Kind::OBJECT, "The type is not set to OBJECT");

    json::Document doc12(json::Kind::ARRAY);
    json::Document doc13(json::Kind::ARRAY);
    doc13 = std::move(doc12);
    XCTAssertEqual(doc13.getType(), json::Kind::ARRAY, "The type is not set to ARRAY");

    json::Document doc14(json::Kind::OBJECT);
    json::Document doc15;
    doc15 = std::move(doc14);
    XCTAssertEqual(doc11.getType(), json::Kind::OBJECT, "The type is not set to OBJECT");

    json::Document doc16(json::Kind::ARRAY);
    json::Document doc17;
    doc17 = std::move(doc16);
    XCTAssertEqual(doc17.getType(), json::Kind::ARRAY, "The type is not set to ARRAY");

    json::Document doc18;
    json::Document doc19(json::Kind::ARRAY);
    doc19 = std::move(doc18);
    XCTAssertEqual(doc19.getType(), json::Kind::UNKNOWN, "The type is not set to UNKNOWN");

    json::Document doc20;
    json::Document doc21(json::Kind::OBJECT);
    doc21 = std::move(doc20);
    XCTAssertEqual(doc21.getType(), json::Kind::UNKNOWN, "The type is not set to UNKNOWN");
}

- (void)testParsingSmallestJSON {
    json::Document doc;

    XCTAssertNoThrow(doc.deserialize(""));

    XCTAssertNoThrow(doc.deserialize("{}"));
    XCTAssertNoThrow(doc.deserialize(" {}"));
    XCTAssertNoThrow(doc.deserialize(" { }"));
    XCTAssertNoThrow(doc.deserialize(" { } "));
    XCTAssertNoThrow(doc.deserialize(" {} "));
    XCTAssertNoThrow(doc.deserialize("{} "));
    XCTAssertNoThrow(doc.deserialize("{ } "));
    XCTAssertNoThrow(doc.deserialize("{ }"));

    XCTAssertNoThrow(doc.deserialize("\n{}"));
    XCTAssertNoThrow(doc.deserialize("\n\n{\r }"));
    XCTAssertNoThrow(doc.deserialize("\r\n{\t} "));
    XCTAssertNoThrow(doc.deserialize("\r\n{}\n"));
    XCTAssertNoThrow(doc.deserialize("{}\t\r\n   \t\r"));
    XCTAssertNoThrow(doc.deserialize("{ }\n"));
    XCTAssertNoThrow(doc.deserialize("{\r\r}"));

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("{");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    XCTAssertNoThrow(doc.deserialize("[]"));
    XCTAssertNoThrow(doc.deserialize(" [\t]"));
    XCTAssertNoThrow(doc.deserialize(" [\r\n\r\n]"));
    XCTAssertNoThrow(doc.deserialize(" [ ] "));

    ic = nullptr;
    try {
        doc.deserialize("[");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("a");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("1");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("\"");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize(":");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize(",");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{:}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{,}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[:]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[,]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\":}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\"::}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\":]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    ic = nullptr;
    try {
        doc.deserialize("{},");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{}a");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{}{");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{}[");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{}:");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{}1");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[a");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\"     ");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingSmallestNestedJSON {
    json::Document doc;
}

- (void)testParsingArrayBasic {
    json::Array doc;

    doc.deserialize("[\"tata\",\"tete titi\",\"toto\"]");
    XCTAssertEqual(doc.getStringAt(0), "tata");
    XCTAssertEqual(doc.getStringAt(0).size(), 4);
    XCTAssertEqual(doc[1].getString(), "tete titi");
    XCTAssertEqual(doc[1].getString().size(), 9);
    doc.deserialize("[ \"tata\" , \"tete titi\" ]");
    XCTAssertEqual(doc.getStringAt(0), "tata");
    XCTAssertEqual(doc.getStringAt(0).size(), 4);
    XCTAssertEqual(doc[1].getString(), "tete titi");
    XCTAssertEqual(doc[1].getString().size(), 9);
    doc.deserialize(" [ \"tata\" , \"tete titi\" ] ");
    XCTAssertEqual(doc.getStringAt(0), "tata");
    XCTAssertEqual(doc.getStringAt(0).size(), 4);
    XCTAssertEqual(doc[1].getString(), "tete titi");
    XCTAssertEqual(doc[1].getString().size(), 9);
    doc.deserialize("[\"tata\"   , \"tete titi\"\r\n]");
    XCTAssertEqual(doc.getStringAt(0), "tata");
    XCTAssertEqual(doc.getStringAt(0).size(), 4);
    XCTAssertEqual(doc[1].getString(), "tete titi");
    XCTAssertEqual(doc[1].getString().size(), 9);

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("[\"tata\",\n\t,\"tete titi\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"tata\",\"tete titi\",\r   ]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[,\"tata\",\"tete titi\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("[0,-1]");
    XCTAssertEqual(doc.getShortAt(0), 0);
    XCTAssertEqual(doc.getIntAt(0), 0);
    XCTAssertEqual(doc.getLongAt(0), 0);
    XCTAssertEqual(doc.getShortAt(1), -1);
    XCTAssertEqual(doc.getIntAt(1), -1);
    XCTAssertEqual(doc.getLongAt(1), -1);
    doc.deserialize("[ 0 , -1 ]");
    XCTAssertEqual(doc.getShortAt(0), 0);
    XCTAssertEqual(doc.getIntAt(0), 0);
    XCTAssertEqual(doc.getLongAt(0), 0);
    XCTAssertEqual(doc.getShortAt(1), -1);
    XCTAssertEqual(doc.getIntAt(1), -1);
    XCTAssertEqual(doc.getLongAt(1), -1);
    doc.deserialize(" [ 0 , -1 ] ");
    XCTAssertEqual(doc.getShortAt(0), 0);
    XCTAssertEqual(doc.getIntAt(0), 0);
    XCTAssertEqual(doc.getLongAt(0), 0);
    XCTAssertEqual(doc.getShortAt(1), -1);
    XCTAssertEqual(doc.getIntAt(1), -1);
    XCTAssertEqual(doc.getLongAt(1), -1);
    doc.deserialize("   [0\t\n\r,-1]");
    XCTAssertEqual(doc.getShortAt(0), 0);
    XCTAssertEqual(doc.getIntAt(0), 0);
    XCTAssertEqual(doc.getLongAt(0), 0);
    XCTAssertEqual(doc.getShortAt(1), -1);
    XCTAssertEqual(doc.getIntAt(1), -1);
    XCTAssertEqual(doc.getLongAt(1), -1);

    ic = nullptr;
    try {
        doc.deserialize("[\r,1,2]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1,\t,2]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1,2,]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("[0.1,-1.5]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getFloatAt(1), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(1), -1.5, std::numeric_limits<double>::epsilon());
    doc.deserialize("[ 0.1 , -1.5 ]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getFloatAt(1), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(1), -1.5, std::numeric_limits<double>::epsilon());
    doc.deserialize(" [ 0.1 , -1.5 ] ");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getFloatAt(1), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(1), -1.5, std::numeric_limits<double>::epsilon());

    ic = nullptr;
    try {
        doc.deserialize("[\r\n,0.1,-1.5]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[0.1, ,-1.5]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[0.1,-1.5,     \n]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("[true,false]");
    XCTAssertEqual(doc.getBooleanAt(0), true);
    XCTAssertEqual(doc.getBooleanAt(1), false);
    doc.deserialize("[ true , false ]");
    XCTAssertEqual(doc.getBooleanAt(0), true);
    XCTAssertEqual(doc.getBooleanAt(1), false);
    doc.deserialize("[ true, false]");
    XCTAssertEqual(doc.getBooleanAt(0), true);
    XCTAssertEqual(doc.getBooleanAt(1), false);
    doc.deserialize(" [true\t\t, \tfalse]");
    XCTAssertEqual(doc.getBooleanAt(0), true);
    XCTAssertEqual(doc.getBooleanAt(1), false);
    doc.deserialize("[ true\t\t, \tfalse ]\r\n");
    XCTAssertEqual(doc.getBooleanAt(0), true);
    XCTAssertEqual(doc.getBooleanAt(1), false);

    ic = nullptr;
    try {
        doc.deserialize("[\n  ,true, false]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,   ,false]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true, false , \n    \n]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("[null,null]");
    XCTAssertEqual(doc.isNullAt(0), true);
    XCTAssertEqual(doc.isNullAt(1), true);
    doc.deserialize("[ null , null ]");
    XCTAssertEqual(doc.isNullAt(0), true);
    XCTAssertEqual(doc.isNullAt(1), true);
    doc.deserialize(" [ null, null ] ");
    XCTAssertEqual(doc.isNullAt(0), true);
    XCTAssertEqual(doc.isNullAt(1), true);
    doc.deserialize("[null\t\t,   \tnull   ]  ");
    XCTAssertEqual(doc.isNullAt(0), true);
    XCTAssertEqual(doc.isNullAt(1), true);

    ic = nullptr;
    try {
        doc.deserialize("[\t  , null , null]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,,null]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null, null , \t    \t]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("[null, null,   1,\"tata\",true \r,-102.1456 ,\"titi\",false]");
    XCTAssertEqual(doc.isNullAt(0), true);
    XCTAssertEqual(doc.isNullAt(1), true);
    XCTAssertEqual(doc.getShortAt(2), 1);
    XCTAssertEqual(doc.getIntAt(2), 1);
    XCTAssertEqual(doc.getLongAt(2), 1);
    XCTAssertEqual(doc.getStringAt(3), "tata");
    XCTAssertEqual(doc.getStringAt(3).size(), 4);
    XCTAssertEqual(doc.getBooleanAt(4), true);
    XCTAssertEqualWithAccuracy(doc.getFloatAt(5), -102.1456f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(5), -102.1456, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(doc.getStringAt(6), "titi");
    XCTAssertEqual(doc.getStringAt(6).size(), 4);
    XCTAssertEqual(doc.getBooleanAt(7), false);
}

- (void)testParsingArrayNumber {
    json::Document doc;

    doc.deserialize("[1]");
    XCTAssertEqual(doc.getShortAt(0), 1);
    XCTAssertEqual(doc.getIntAt(0), 1);
    XCTAssertEqual(doc.getLongAt(0), 1);
    doc.deserialize("[-1]");
    XCTAssertEqual(doc.getShortAt(0), -1);
    XCTAssertEqual(doc.getIntAt(0), -1);
    XCTAssertEqual(doc.getLongAt(0), -1);
    doc.deserialize("[1000]");
    XCTAssertEqual(doc.getShortAt(0), 1000);
    XCTAssertEqual(doc.getIntAt(0), 1000);
    XCTAssertEqual(doc.getLongAt(0), 1000);
    doc.deserialize("[-1000]");
    XCTAssertEqual(doc.getShortAt(0), -1000);
    XCTAssertEqual(doc.getIntAt(0), -1000);
    XCTAssertEqual(doc.getLongAt(0), -1000);
    doc.deserialize("[10001]");
    XCTAssertEqual(doc.getShortAt(0), 10001);
    XCTAssertEqual(doc.getIntAt(0), 10001);
    XCTAssertEqual(doc.getLongAt(0), 10001);
    doc.deserialize("[1.1000]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), 1.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), 1.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("[-1.1000]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), -1.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), -1.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("[1e0]");
    XCTAssertEqual(doc.getShortAt(0), 1);
    XCTAssertEqual(doc.getIntAt(0), 1);
    XCTAssertEqual(doc.getLongAt(0), 1);
    doc.deserialize("[1e000]");
    XCTAssertEqual(doc.getShortAt(0), 1);
    XCTAssertEqual(doc.getIntAt(0), 1);
    XCTAssertEqual(doc.getLongAt(0), 1);
    doc.deserialize("[1e+00]");
    XCTAssertEqual(doc.getShortAt(0), 1);
    XCTAssertEqual(doc.getIntAt(0), 1);
    XCTAssertEqual(doc.getLongAt(0), 1);
    doc.deserialize("[1e-0]");
    XCTAssertEqual(doc.getShortAt(0), 1);
    XCTAssertEqual(doc.getIntAt(0), 1);
    XCTAssertEqual(doc.getLongAt(0), 1);
    doc.deserialize("[1e0001]");
    XCTAssertEqual(doc.getShortAt(0), 10);
    XCTAssertEqual(doc.getIntAt(0), 10);
    XCTAssertEqual(doc.getLongAt(0), 10);
    doc.deserialize("[-1e0001]");
    XCTAssertEqual(doc.getShortAt(0), -10);
    XCTAssertEqual(doc.getIntAt(0), -10);
    XCTAssertEqual(doc.getLongAt(0), -10);
    doc.deserialize("[1e+1]");
    XCTAssertEqual(doc.getShortAt(0), 10);
    XCTAssertEqual(doc.getIntAt(0), 10);
    XCTAssertEqual(doc.getLongAt(0), 10);
    doc.deserialize("[1e-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), .1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), .1, std::numeric_limits<double>::epsilon());
    doc.deserialize("[-1e+1]");
    XCTAssertEqual(doc.getShortAt(0), -10);
    XCTAssertEqual(doc.getIntAt(0), -10);
    XCTAssertEqual(doc.getLongAt(0), -10);
    doc.deserialize("[-1e-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), -.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), -.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("[1E1]");
    XCTAssertEqual(doc.getShortAt(0), 10);
    XCTAssertEqual(doc.getIntAt(0), 10);
    XCTAssertEqual(doc.getLongAt(0), 10);
    doc.deserialize("[-1E1]");
    XCTAssertEqual(doc.getShortAt(0), -10);
    XCTAssertEqual(doc.getIntAt(0), -10);
    XCTAssertEqual(doc.getLongAt(0), -10);
    doc.deserialize("[1E+1]");
    XCTAssertEqual(doc.getShortAt(0), 10);
    XCTAssertEqual(doc.getIntAt(0), 10);
    XCTAssertEqual(doc.getLongAt(0), 10);
    doc.deserialize("[1E-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), .1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), .1, std::numeric_limits<double>::epsilon());
    doc.deserialize("[-1E+1]");
    XCTAssertEqual(doc.getShortAt(0), -10);
    XCTAssertEqual(doc.getIntAt(0), -10);
    XCTAssertEqual(doc.getLongAt(0), -10);
    doc.deserialize("[-1E-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), -.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), -.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("[1.1e1]");
    XCTAssertEqual(doc.getShortAt(0), 11);
    XCTAssertEqual(doc.getIntAt(0), 11);
    XCTAssertEqual(doc.getLongAt(0), 11);
    doc.deserialize("[-1.1e1]");
    XCTAssertEqual(doc.getShortAt(0), -11);
    XCTAssertEqual(doc.getIntAt(0), -11);
    XCTAssertEqual(doc.getLongAt(0), -11);
    doc.deserialize("[1.1e+1]");
    XCTAssertEqual(doc.getShortAt(0), 11);
    XCTAssertEqual(doc.getIntAt(0), 11);
    XCTAssertEqual(doc.getLongAt(0), 11);
    doc.deserialize("[1.1e-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), .11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), .11, std::numeric_limits<double>::epsilon());
    doc.deserialize("[-1.1e-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), -.11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), -.11, std::numeric_limits<double>::epsilon());
    doc.deserialize("[1.1E1]");
    XCTAssertEqual(doc.getShortAt(0), 11);
    XCTAssertEqual(doc.getIntAt(0), 11);
    XCTAssertEqual(doc.getLongAt(0), 11);
    doc.deserialize("[-1.1E1]");
    XCTAssertEqual(doc.getShortAt(0), -11);
    XCTAssertEqual(doc.getIntAt(0), -11);
    XCTAssertEqual(doc.getLongAt(0), -11);
    doc.deserialize("[1.1E+1]");
    XCTAssertEqual(doc.getShortAt(0), 11);
    XCTAssertEqual(doc.getIntAt(0), 11);
    XCTAssertEqual(doc.getLongAt(0), 11);
    doc.deserialize("[1.1E-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), .11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), .11, std::numeric_limits<double>::epsilon());
    doc.deserialize("[-1.1E-1]");
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), -.11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), -.11, std::numeric_limits<double>::epsilon());

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("[+ ]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[00]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[0 0]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1 1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[-00]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[-000]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[+000]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[+1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1+1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1-1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[+1.1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[+a]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[-]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[-1111-1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[-1111+1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[-a]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1.]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1.a]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1.+]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1.-]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1ea]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e+]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e-]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e+a]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e-a]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e1e]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e11e]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1E1e]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e1-1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e11E-1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e11e1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1e1.1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1E11+1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1a]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[12   }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[11.111.1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[11..1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[11ee1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[11e111e1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[,1,1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1,,1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[1,1,]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingArrayNumberOverflow {
    json::Document doc;

    // SHORT OVERFLOW
    std::ostringstream json("[", std::ios::ate);
    const int minShort = std::numeric_limits<short>::min();
    json << minShort << "]";
    doc.deserialize(json.str());
    XCTAssertEqual(doc.getShortAt(0), minShort);
    XCTAssertEqual(doc.getIntAt(0), minShort);
    XCTAssertEqual(doc.getLongAt(0), minShort);

    const std::out_of_range* no = nullptr;
    json.str("[");
    json << (minShort-1) << "]";
    doc.deserialize(json.str());
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntAt(0), minShort-1);
    XCTAssertEqual(doc.getLongAt(0), minShort-1);

    const int maxShort = std::numeric_limits<short>::max();
    json.str("[");
    json << maxShort << "]";
    doc.deserialize(json.str());
    XCTAssertEqual(doc.getShortAt(0), maxShort);
    XCTAssertEqual(doc.getIntAt(0), maxShort);
    XCTAssertEqual(doc.getLongAt(0), maxShort);

    json.str("[");
    json << (maxShort+1) << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntAt(0), maxShort+1);
    XCTAssertEqual(doc.getLongAt(0), maxShort+1);

    // INT OVERFLOW
    const long minInt = std::numeric_limits<int>::min();
    json.str("[");
    json << minInt << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntAt(0), minInt);
    XCTAssertEqual(doc.getLongAt(0), minInt);

    json.str("[");
    json << (minInt-1) << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongAt(0), minInt-1);

    const long maxInt = std::numeric_limits<int>::max();
    json.str("[");
    json << maxInt << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntAt(0), maxInt);
    XCTAssertEqual(doc.getLongAt(0), maxInt);

    json.str("[");
    json << (maxInt+1) << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongAt(0), maxInt+1);

    // LONG OVERFLOW
    const long long minLong = std::numeric_limits<long>::min();
    json.str("[");
    json << minLong << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongAt(0), minLong);

    doc.deserialize("[-9223372036854775809]");
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getLongAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);

    const long long maxLong = std::numeric_limits<long>::max();
    json.str("[");
    json << maxLong << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongAt(0), maxLong);

    doc.deserialize("[9223372036854775808]");
    no = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getLongAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);

    // FLOAT
    const double minFloat = std::numeric_limits<float>::lowest();
    json.str("[");
    json << std::fixed << minFloat << "]";
    doc.deserialize(json.str());
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), minFloat, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), minFloat, std::numeric_limits<double>::epsilon());

    const double nextLowestFloat = minFloat-std::abs(minFloat)*std::numeric_limits<float>::epsilon();
    json.str("[");
    json << std::fixed << nextLowestFloat << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), nextLowestFloat, std::numeric_limits<double>::epsilon());

    const double maxFloat = std::numeric_limits<float>::max();
    json.str("[");
    json << std::fixed << maxFloat << "]";
    doc.deserialize(json.str());
    XCTAssertEqualWithAccuracy(doc.getFloatAt(0), maxFloat, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), maxFloat, std::numeric_limits<double>::epsilon());

    const double nextHighestFloat = maxFloat+std::abs(maxFloat)*std::numeric_limits<float>::epsilon();
    json.str("[");
    json << std::fixed << nextHighestFloat << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), nextHighestFloat, std::numeric_limits<double>::epsilon());

    // DOUBLE
    const long double minDouble = std::numeric_limits<double>::lowest();
    json.str("[");
    json << std::fixed << minDouble << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), minDouble, std::numeric_limits<double>::epsilon());

    const long double nextLowestDouble = minDouble-std::abs(minDouble)*std::numeric_limits<double>::epsilon();
    json.str("[");
    json << std::fixed << nextLowestDouble << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getDoubleAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);

    const long double maxDouble = std::numeric_limits<double>::max();
    json.str("[");
    json << std::fixed << maxDouble << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleAt(0), maxDouble, std::numeric_limits<double>::epsilon());

    const long double nextHighestDouble = maxDouble+std::abs(maxDouble)*std::numeric_limits<double>::epsilon();
    json.str("[");
    json << std::fixed << nextHighestDouble << "]";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getDoubleAt(0);
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
}

- (void)testParsingArrayNullable {
    json::Document doc;

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("[null,nUll]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,nuLl]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[nll]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,nulL]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,nulla]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,null1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,null_]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,null:]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,nulll]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null   }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null  null ]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[nllll]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[nullnull]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,null,]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[,null,null]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[null,,null]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingArrayBoolean {
    json::Document doc;

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("[true,tRue]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[,true,true]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,,true]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,true,]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,trUe]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,truE]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,truea]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,true1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,true_]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true,true:]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[trse]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[truefalse]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true false]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[truetrue]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true true]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[tue]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[ue]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[faue]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[lse]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[alse]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[se]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    ic = nullptr;
    try {
        doc.deserialize("[false,fAlse]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[,false,false]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,,false]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,false,]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,faLse]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,falSe]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,falsE]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,falsea]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,false1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,false_]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false,false:]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[fue]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[fase]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[falsetrue]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false true]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[falsefalse]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false false]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[false   }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[true   }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingArrayWrongType {
    json::Document doc;

    doc.deserialize("[1.2]");
    XCTAssertEqual(doc.getShortAt(0), 1);
    XCTAssertEqual(doc.getIntAt(0), 1);
    XCTAssertEqual(doc.getLongAt(0), 1);
}

- (void)testParsingArrayBadValue {
    json::Document doc;
    const std::invalid_argument* ia = nullptr;
    doc.deserialize("[\"value\"]");
    try {
        doc.getShortAt(0);
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getLongAt(0);
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getDoubleAt(0);
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    const json::BadValue* bv = nullptr;
    try {
        doc.getBooleanAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getObjectAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);

    doc.deserialize("[true]");
    XCTAssertEqual(doc.getShortAt(0), 1);
    XCTAssertEqual(doc.getIntAt(0), 1);
    XCTAssertEqual(doc.getLongAt(0), 1);
    XCTAssertEqual(doc.getFloatAt(0), 1);
    XCTAssertEqual(doc.getDoubleAt(0), 1);
    XCTAssertEqual(doc.getStringAt(0), "true");
    bv = nullptr;
    try {
        doc.getObjectAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);

    doc.deserialize("[false]");
    XCTAssertEqual(doc.getShortAt(0), 0);
    XCTAssertEqual(doc.getIntAt(0), 0);
    XCTAssertEqual(doc.getLongAt(0), 0);
    XCTAssertEqual(doc.getFloatAt(0), 0);
    XCTAssertEqual(doc.getDoubleAt(0), 0);
    XCTAssertEqual(doc.getStringAt(0), "false");
    bv = nullptr;
    try {
        doc.getObjectAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);

    doc.deserialize("[null]");
    XCTAssertEqual(doc.getShortAt(0), 0);
    XCTAssertEqual(doc.getIntAt(0), 0);
    XCTAssertEqual(doc.getLongAt(0), 0);
    XCTAssertEqual(doc.getFloatAt(0), 0);
    XCTAssertEqual(doc.getDoubleAt(0), 0);
    XCTAssertEqual(doc.getStringAt(0), "null");
    XCTAssertEqual(doc.getBooleanAt(0), false);
    bv = nullptr;
    try {
        doc.getObjectAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);

    doc.deserialize("[1]");
    XCTAssertEqual(doc.getStringAt(0), "1");
    XCTAssertEqual(doc.getBooleanAt(0), true);
    bv = nullptr;
    try {
        doc.getObjectAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayAt(0);
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
}

- (void)testParsingArrayWrongIndex {
    json::Document doc;

    doc.deserialize("[1]");
    const std::out_of_range* wi = nullptr;
    try {
        doc.getShortAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getIntAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getLongAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getStringAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getBooleanAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getDoubleAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getFloatAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.isNullAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getObjectAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
    wi = nullptr;
    try {
        doc.getArrayAt(1);
    } catch (const std::out_of_range& e) {
        wi = &e;
    }
    XCTAssertNotEqual(wi, nullptr);
}

- (void)testParsingArrayBadArray {
    json::Document doc;

    doc.deserialize("{\"key\":1.2}");
    const json::BadValue* ba = nullptr;
    try {
        doc.getShortAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getIntAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getLongAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getStringAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getBooleanAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getObjectAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getArrayAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.isNullAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getFloatAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
    ba = nullptr;
    try {
        doc.getDoubleAt(0);
    } catch (const json::BadValue& e) {
        ba = &e;
    }
    XCTAssertNotEqual(ba, nullptr);
}

- (void)testParsingNestedArrayBasic {
    json::Document doc;
    json::Document innerDoc;

    doc.deserialize("[[\"tata\",\"tete titi\"],[\"toto\",\"tutu\"],[\"tyty\"]]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getStringAt(0), "tata");
    XCTAssertEqual(innerDoc.getStringAt(1), "tete titi");
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getStringAt(0), "toto");
    XCTAssertEqual(innerDoc.getStringAt(1), "tutu");
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getStringAt(0), "tyty");
    doc.deserialize("[[\"tata\", \r\"tete titi\"\t], [\r\n\"toto\",\t   \"tutu\"],\r   [   \"tyty\"]    \r\n]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getStringAt(0), "tata");
    XCTAssertEqual(innerDoc.getStringAt(1), "tete titi");
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getStringAt(0), "toto");
    XCTAssertEqual(innerDoc.getStringAt(1), "tutu");
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getStringAt(0), "tyty");
    doc.deserialize("[   [    \"tata\",\r\"tete titi\"\t ], [\r\n\"toto\"  ,\t   \"tutu\"],\r   [   \"tyty\"]    \r\n]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getStringAt(0), "tata");
    XCTAssertEqual(innerDoc.getStringAt(1), "tete titi");
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getStringAt(0), "toto");
    XCTAssertEqual(innerDoc.getStringAt(1), "tutu");
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getStringAt(0), "tyty");

    doc.deserialize("[[0,-1],[2,-3],[4]]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getShortAt(0), 0);
    XCTAssertEqual(innerDoc.getIntAt(0), 0);
    XCTAssertEqual(innerDoc.getLongAt(0), 0);
    XCTAssertEqual(innerDoc.getShortAt(1), -1);
    XCTAssertEqual(innerDoc.getIntAt(1), -1);
    XCTAssertEqual(innerDoc.getLongAt(1), -1);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getShortAt(0), 2);
    XCTAssertEqual(innerDoc.getIntAt(0), 2);
    XCTAssertEqual(innerDoc.getLongAt(0), 2);
    XCTAssertEqual(innerDoc.getShortAt(1), -3);
    XCTAssertEqual(innerDoc.getIntAt(1), -3);
    XCTAssertEqual(innerDoc.getLongAt(1), -3);
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getShortAt(0), 4);
    XCTAssertEqual(innerDoc.getIntAt(0), 4);
    XCTAssertEqual(innerDoc.getLongAt(0), 4);
    doc.deserialize("[ [ 0 , -1]\r\n,\t[2\n,\r-3]   ,  [  4\r\n]\n\n\n]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getShortAt(0), 0);
    XCTAssertEqual(innerDoc.getIntAt(0), 0);
    XCTAssertEqual(innerDoc.getLongAt(0), 0);
    XCTAssertEqual(innerDoc.getShortAt(1), -1);
    XCTAssertEqual(innerDoc.getIntAt(1), -1);
    XCTAssertEqual(innerDoc.getLongAt(1), -1);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getShortAt(0), 2);
    XCTAssertEqual(innerDoc.getIntAt(0), 2);
    XCTAssertEqual(innerDoc.getLongAt(0), 2);
    XCTAssertEqual(innerDoc.getShortAt(1), -3);
    XCTAssertEqual(innerDoc.getIntAt(1), -3);
    XCTAssertEqual(innerDoc.getLongAt(1), -3);
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getShortAt(0), 4);
    XCTAssertEqual(innerDoc.getIntAt(0), 4);
    XCTAssertEqual(innerDoc.getLongAt(0), 4);

    doc.deserialize("[[0.1,-1.5],[0.2,-2.43,1e-4],[0.45,0.46,0.0e+1]]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.2f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.2, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -2.43f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -2.43, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 0.0001f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 0.0001, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.45f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.45, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), 0.46f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), 0.46, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 0.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 0.0, std::numeric_limits<double>::epsilon());
    doc.deserialize("[[ 0.1,\t\r\n  -1.5    ]\r, [\n0.2\n,   -2.43,      1e-4 ],[0.45,\r\n0.46\n,  \t0.0e+1]   ]\r\n");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.2f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.2, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -2.43f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -2.43, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 0.0001f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 0.0001, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.45f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.45, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), 0.46f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), 0.46, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 0.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 0.0, std::numeric_limits<double>::epsilon());

    doc.deserialize("[[true,false],[true,false,false],[true]]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getBooleanAt(1), false);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getBooleanAt(1), false);
    XCTAssertEqual(innerDoc.getBooleanAt(2), false);
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    doc.deserialize(" [   [\ttrue,\tfalse\n]\n,  [  true , \rfalse,   false] , \r\n[true\r]\n]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getBooleanAt(1), false);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getBooleanAt(1), false);
    XCTAssertEqual(innerDoc.getBooleanAt(2), false);
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);

    doc.deserialize("[[null,null],[null,null,null],[null]]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    XCTAssertEqual(innerDoc.isNullAt(2), true);
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    doc.deserialize(" [   [\tnull,\tnull\n]\n,  [  null , \rnull,   null] , \r\n[null\r]\n]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    XCTAssertEqual(innerDoc.isNullAt(2), true);
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.isNullAt(0), true);

    doc.deserialize("[[\"tata tete\",null],[true,1,1.5],[\"titi\",-1E2]]");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getStringAt(0), "tata tete");
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getShortAt(1), 1);
    XCTAssertEqual(innerDoc.getIntAt(1), 1);
    XCTAssertEqual(innerDoc.getLongAt(1), 1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), 1.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), 1.0, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getStringAt(0), "titi");
    XCTAssertEqual(innerDoc.getShortAt(1), -100);
    XCTAssertEqual(innerDoc.getIntAt(1), -100);
    XCTAssertEqual(innerDoc.getLongAt(1), -100);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -100.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -100.0, std::numeric_limits<double>::epsilon());
    doc.deserialize("\t\t[\n\n[  \"tata tete\"\n,  null  ] \t,\n[true ,1  , 1.5 ]\n,[\t\"titi\"\t,\t-1E2\t]\t]\n");
    innerDoc = doc.getArrayAt(0);
    XCTAssertEqual(innerDoc.getStringAt(0), "tata tete");
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    innerDoc = doc.getArrayAt(1);
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getShortAt(1), 1);
    XCTAssertEqual(innerDoc.getIntAt(1), 1);
    XCTAssertEqual(innerDoc.getLongAt(1), 1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), 1.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), 1.0, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayAt(2);
    XCTAssertEqual(innerDoc.getStringAt(0), "titi");
    XCTAssertEqual(innerDoc.getShortAt(1), -100);
    XCTAssertEqual(innerDoc.getIntAt(1), -100);
    XCTAssertEqual(innerDoc.getLongAt(1), -100);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -100.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -100.0, std::numeric_limits<double>::epsilon());
}

- (void)testParsingArrayString {
    json::Document doc;

    doc.deserialize("[\"tata\"]");
    XCTAssertEqual(doc.getStringAt(0), "tata");
    doc.deserialize("[\t  \"tata\"\r   \t   \r\n   \n, \"tete\"]");
    XCTAssertEqual(doc.getStringAt(0), "tata");
    XCTAssertEqual(doc.getStringAt(1), "tete");
    doc.deserialize("[\"\\\"\"]");
    XCTAssertEqual(doc.getStringAt(0), "\"");
    doc.deserialize("[\"\\\\\"]");
    XCTAssertEqual(doc.getStringAt(0), "\\");
    doc.deserialize("[\"\\/\"]");
    XCTAssertEqual(doc.getStringAt(0), "/");
    doc.deserialize("[\"\\b\"]");
    XCTAssertEqual(doc.getStringAt(0), "\b");
    doc.deserialize("[\"\\f\"]");
    XCTAssertEqual(doc.getStringAt(0), "\f");
    doc.deserialize("[\"\\n\"]");
    XCTAssertEqual(doc.getStringAt(0), "\n");
    doc.deserialize("[\"\\r\"]");
    XCTAssertEqual(doc.getStringAt(0), "\r");
    doc.deserialize("[\"\\t\"]");
    XCTAssertEqual(doc.getStringAt(0), "\t");
    doc.deserialize("[\"\\/\\\\\\\"\\uCAFE\\uBABE\"]");
    XCTAssertEqual(doc.getStringAt(0), "/\\\"\uCAFE\uBABE");
    XCTAssertEqual(doc.getStringAt(0), "/\\\"쫾몾");
    doc.deserialize("[\"쫾\"]");
    XCTAssertEqual(doc.getStringAt(0), "쫾");
    doc.deserialize("[\"⟦\"]");
    XCTAssertEqual(doc.getStringAt(0), "⟦");
    doc.deserialize("[\"ȃ\"]");
    XCTAssertEqual(doc.getStringAt(0), "ȃ");
    doc.deserialize("[\"A\"]");
    XCTAssertEqual(doc.getStringAt(0), "A");

    doc.deserialize("[[\"🍀\", \"🍁\", [\"🍇\",\"🍋\"],[\"🍄\",\"🌽\"]], \"🌺\", \"🌻\"]");
    XCTAssertEqual(doc.getArrayAt(0).getStringAt(0), "🍀");
    XCTAssertEqual(doc.getArrayAt(0).getStringAt(1), "🍁");
    XCTAssertEqual(doc.getArrayAt(0).getArrayAt(2).getStringAt(0), "🍇");
    XCTAssertEqual(doc.getArrayAt(0).getArrayAt(2).getStringAt(1), "🍋");
    XCTAssertEqual(doc.getArrayAt(0).getArrayAt(3).getStringAt(0), "🍄");
    XCTAssertEqual(doc.getArrayAt(0).getArrayAt(3).getStringAt(1), "🌽");
    XCTAssertEqual(doc.getStringAt(1), "🌺");
    XCTAssertEqual(doc.getStringAt(2), "🌻");

    doc.deserialize("[\"🍌\"]");
    XCTAssertEqual(doc.getStringAt(0), "🍌");
    XCTAssertEqual(doc.getStringAt(0), "\xF0\x9F\x8D\x8C");
    doc.deserialize("[\"\\uD83C\\uDF4C\"]");
    XCTAssertEqual(doc.getStringAt(0), "🍌");
    XCTAssertEqual(doc.getStringAt(0), "\xF0\x9F\x8D\x8C");
    doc.deserialize("[\"\\uFFFF\"]");
    XCTAssertEqual(doc.getStringAt(0), "\uFFFF");
    XCTAssertEqual(doc.getStringAt(0), "\xEF\xBF\xBF");
    doc.deserialize("[\"\\uD800\\uDC00\"]"); // 1st UTF16 Surrogate Char
    XCTAssertEqual(doc.getStringAt(0), "𐀀");
    XCTAssertEqual(doc.getStringAt(0), "\xF0\x90\x80\x80");

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\xDE\xCF\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83Cz\\uDF4C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83C \\uDF4C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83Ca\\uDF4C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83C1\\uDF4C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83C\\t\\uDF4C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83C\\n\\uDF4C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"\\uD83C\\f\\uDF4C\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("[\"tata\"\r\n \"tata\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingObjectBasic {
    json::Document doc;

    doc.deserialize("{\"key1\":\"tata\",\"key2\":\"tete titi\"}");
    XCTAssertEqual(doc.getStringFrom("key1"), "tata");
    XCTAssertEqual(doc.getStringFrom("key1").size(), 4);
    XCTAssertEqual(doc.getStringFrom("key2"), "tete titi");
    XCTAssertEqual(doc.getStringFrom("key2").size(), 9);
    doc.deserialize("{ \"key1\":\"tata\" , \"key2\" : \"tete titi\" }");
    XCTAssertEqual(doc.getStringFrom("key1"), "tata");
    XCTAssertEqual(doc.getStringFrom("key1").size(), 4);
    XCTAssertEqual(doc.getStringFrom("key2"), "tete titi");
    XCTAssertEqual(doc.getStringFrom("key2").size(), 9);
    doc.deserialize(" { \"key1\": \"tata\" , \"key2\" : \"tete titi\" } ");
    XCTAssertEqual(doc.getStringFrom("key1"), "tata");
    XCTAssertEqual(doc.getStringFrom("key1").size(), 4);
    XCTAssertEqual(doc.getStringFrom("key2"), "tete titi");
    XCTAssertEqual(doc.getStringFrom("key2").size(), 9);
    doc.deserialize("{\"key1\":\"tata\"   ,\"key2\"    \t:\t \"tete titi\"\r\n}");
    XCTAssertEqual(doc.getStringFrom("key1"), "tata");
    XCTAssertEqual(doc.getStringFrom("key1").size(), 4);
    XCTAssertEqual(doc.getStringFrom("key2"), "tete titi");
    XCTAssertEqual(doc.getStringFrom("key2").size(), 9);

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("{\"key2\"\"tata\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"  \n\"tata\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"  \n\"tata\"");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\" : \n\"tata\"");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\"tata\",\n\t,\"key2\":\"tete titi\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\"tata\",\n\t\"key2\",\"key3\":\"tete titi\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\"tata\",\n\t\"key2\":,\"key3\":\"tete titi\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\"tata\",\"key2\":\"tete titi\",\r   }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\"tata\",\"key2\":\"tete titi\",\r\"key3\"   }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\"tata\",\"key2\":\"tete titi\",\r\"key3\":   }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{,\"key2\":\"tata\",\"key3\":\"tete titi\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\t   \n,\"key2\":\"tata\",\"key3\":\"tete titi\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\r\n,\"key2\":\"tata\",\"key3\":\"tete titi\"]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("{\"key1\":0,\"key2\":-1}");
    XCTAssertEqual(doc.getShortFrom("key1"), 0);
    XCTAssertEqual(doc.getIntFrom("key1"), 0);
    XCTAssertEqual(doc.getLongFrom("key1"), 0);
    XCTAssertEqual(doc.getShortFrom("key2"), -1);
    XCTAssertEqual(doc.getIntFrom("key2"), -1);
    XCTAssertEqual(doc.getLongFrom("key2"), -1);
    doc.deserialize("{ \"key1\" : 0 , \"key2\": -1 }");
    XCTAssertEqual(doc.getShortFrom("key1"), 0);
    XCTAssertEqual(doc.getIntFrom("key1"), 0);
    XCTAssertEqual(doc.getLongFrom("key1"), 0);
    XCTAssertEqual(doc.getShortFrom("key2"), -1);
    XCTAssertEqual(doc.getIntFrom("key2"), -1);
    XCTAssertEqual(doc.getLongFrom("key2"), -1);
    doc.deserialize(" { \"key1\":0 , \"key2\" :   -1 } ");
    XCTAssertEqual(doc.getShortFrom("key1"), 0);
    XCTAssertEqual(doc.getIntFrom("key1"), 0);
    XCTAssertEqual(doc.getLongFrom("key1"), 0);
    XCTAssertEqual(doc.getShortFrom("key2"), -1);
    XCTAssertEqual(doc.getIntFrom("key2"), -1);
    XCTAssertEqual(doc.getLongFrom("key2"), -1);
    doc.deserialize("   {\"key1\":0\t\n\r,\"key2\":-1}");
    XCTAssertEqual(doc.getShortFrom("key1"), 0);
    XCTAssertEqual(doc.getIntFrom("key1"), 0);
    XCTAssertEqual(doc.getLongFrom("key1"), 0);
    XCTAssertEqual(doc.getShortFrom("key2"), -1);
    XCTAssertEqual(doc.getIntFrom("key2"), -1);
    XCTAssertEqual(doc.getLongFrom("key2"), -1);

    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"  1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\r,\"key2\":1,\"key3\":2}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\r\"key1\",\"key2\":1,\"key3\":2}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\r\"key1\"  :\t,\"key2\":1,\"key3\":2}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\r\n: 1,\t,\"key3\":2}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\r\n: 1,\t\"key2\",\"key3\":2}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\r\n: 1,\t\"key2\":\t \r\n,\"key3\":2}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":1,\"key2\":2,}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":1,\"key2\":2,\t\n\"key3\"     }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":1,\"key2\":2,\"key3\"\t\r\n:}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("{\"key1\":0.1,\"key2\":-1.5}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key1"), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key1"), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key2"), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key2"), -1.5, std::numeric_limits<double>::epsilon());
    doc.deserialize("{ \"key1\" :0.1 , \"key2\" : -1.5 }");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key1"), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key1"), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key2"), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key2"), -1.5, std::numeric_limits<double>::epsilon());
    doc.deserialize(" { \"key1\" : 0.1 ,  \"key2\":-1.5 } ");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key1"), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key1"), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key2"), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key2"), -1.5, std::numeric_limits<double>::epsilon());

    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"0.1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\" \t\r\n0.1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\r\n,\"key2\":\r\n  0.1,\n\"key3\"    : \t-1.5}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\r\n,\"key2\":\r\n  0.1,\n\"key3\"    : \t-1.5}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\r\n\"key1\"  :\r\n,\"key2\":\r\n  0.1,\n\"key3\"    : \t-1.5}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\n :  0.1, ,  \t \r\n  \"key3\"\n:  -1.5}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\n :  0.1,\"key2\" \n,  \t \r\n  \"key3\"\n:  -1.5}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\"\n :  0.1, \"key2\" :,  \t \r\n  \"key3\"\n:  -1.5}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":0.1,\"key2\":-1.5,     \n}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":0.1,\"key2\":-1.5,     \n\"key3\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":0.1,\"key2\":-1.5,     \n  \"key3\" \t:}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("{\"key1\":true,\"key2\":false}");
    XCTAssertEqual(doc.getBooleanFrom("key1"), true);
    XCTAssertEqual(doc.getBooleanFrom("key2"), false);
    doc.deserialize("{ \"key1\": true , \"key2\" :false }");
    XCTAssertEqual(doc.getBooleanFrom("key1"), true);
    XCTAssertEqual(doc.getBooleanFrom("key2"), false);
    doc.deserialize("{ \"key1\" : true, \"key2\":  false}");
    XCTAssertEqual(doc.getBooleanFrom("key1"), true);
    XCTAssertEqual(doc.getBooleanFrom("key2"), false);
    doc.deserialize(" {\"key1\" :true\t\t, \"key2\"\r: \tfalse}");
    XCTAssertEqual(doc.getBooleanFrom("key1"), true);
    XCTAssertEqual(doc.getBooleanFrom("key2"), false);
    doc.deserialize("{ \"key1\"\r\n:true\t\t, \"key2\":\tfalse }\r\n");
    XCTAssertEqual(doc.getBooleanFrom("key1"), true);
    XCTAssertEqual(doc.getBooleanFrom("key2"), false);

    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"true}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\" \ntrue}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"false}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"\t  false}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\n  ,\"key2\":true, \"key3\" : false}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\n \"key1\" ,\"key2\":true,\"key3\":false}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\n \"key1\": ,\"key2\"  :true,\"key3\":false}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,   ,\"key3\":false}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\ttrue\n, \"key2\"  ,\r\n\"key3\":  false  }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{ \"key1\" :    true,  \"key2\":\r\n,\"key3\":false}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true, \"key2\" : false , \n    \n}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\t\"key1\"\t:\ttrue, \"key2\" :  false , \n  \"key3\"  \n}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":false , \n    \n \"key3\":}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("{\"key1\":null,\"key2\":null}");
    XCTAssertEqual(doc.isNullFrom("key1"), true);
    XCTAssertEqual(doc.isNullFrom("key2"), true);
    doc.deserialize("{ \"key1\" : null , \"key2\": null }");
    XCTAssertEqual(doc.isNullFrom("key1"), true);
    XCTAssertEqual(doc.isNullFrom("key2"), true);
    doc.deserialize(" { \"key1\" :null, \"key2\" :   null } ");
    XCTAssertEqual(doc.isNullFrom("key1"), true);
    XCTAssertEqual(doc.isNullFrom("key2"), true);
    doc.deserialize("{\"key1\":null\t\t,   \t\"key2\"\r\n:\tnull   }  ");
    XCTAssertEqual(doc.isNullFrom("key1"), true);
    XCTAssertEqual(doc.isNullFrom("key2"), true);

    ic = nullptr;
    try {
        doc.deserialize("{\"key2\"null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key2\" \t\nnull}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\n  ,\"key2\":null, \"key3\" : null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\n \"key1\" ,\"key2\":null,\"key3\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\n \"key1\": ,\"key2\"  :null,\"key3\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,   ,\"key3\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":\tnull\n, \"key2\"  ,\r\n\"key3\":  null  }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{ \"key1\" :    null,  \"key2\":\r\n,\"key3\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null, \"key2\" : null , \n    \n}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\t\"key1\"\t:\tnull, \"key2\" :  null , \n  \"key3\"  \n}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":null , \n    \n \"key3\":}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    doc.deserialize("{\"key1\":null, \"key2\" :null, \"key3\"\t :  1,\"key4\":\"tata\",\"key5\" :true \r,\"key6\":    -102.1456 ,\t\r\"key7\":\"titi\",  \"key8\" : false}");
    XCTAssertEqual(doc.isNullFrom("key1"), true);
    XCTAssertEqual(doc.isNullFrom("key2"), true);
    XCTAssertEqual(doc.getShortFrom("key3"), 1);
    XCTAssertEqual(doc.getIntFrom("key3"), 1);
    XCTAssertEqual(doc.getLongFrom("key3"), 1);
    XCTAssertEqual(doc.getStringFrom("key4"), "tata");
    XCTAssertEqual(doc.getBooleanFrom("key5"), true);
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key6"), -102.1456f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key6"), -102.1456, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(doc.getStringFrom("key7"), "titi");
    XCTAssertEqual(doc.getBooleanFrom("key8"), false);
}

- (void)testParsingNestedObjectBasic {
    json::Document doc;
    json::Document innerDoc;

    doc.deserialize("{\"key1\":{\"key1\":\"tata\",\"key2\":\"tete titi\"},\"key2\":{\"key1\":\"toto\",\"key2\":\"tutu\"},\"key3\":{\"key1\":\"tyty\"}}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tata");
    XCTAssertEqual(innerDoc.getStringFrom("key2"), "tete titi");
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "toto");
    XCTAssertEqual(innerDoc.getStringFrom("key2"), "tutu");
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tyty");
    doc.deserialize("{\"key1\": {\"key1\" : \"tata\",\"key2\"\n: \r\"tete titi\"\t}, \"key2\":{ \"key1\"\t:\t\r\n\"toto\",\t \"key2\"  \n:  \"tutu\"},\r \"key3\":  { \"key1\":\"tyty\"}    \r\n}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tata");
    XCTAssertEqual(innerDoc.getStringFrom("key2"), "tete titi");
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "toto");
    XCTAssertEqual(innerDoc.getStringFrom("key2"), "tutu");
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tyty");

    doc.deserialize("{\"key1\":{\"key1\":0,\"key2\":-1},\"key2\":{\"key1\":2,\"key2\":-3},\"key3\":{\"key1\":4}}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -1);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -1);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -1);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -3);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -3);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -3);
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 4);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 4);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 4);
    doc.deserialize("{ \"key1\": {  \"key1\"\n : 0 , \"key2\"\t:\t -1}\r\n,\"key2\":\t{\"key1\"\t:2\n,\"key2\"\n:\r-3}   , \"key3\"\t:\t { \"key1\"   :  4\r\n}\n\n\n}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -1);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -1);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -1);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -3);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -3);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -3);
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 4);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 4);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 4);

    doc.deserialize("{\"key1\":{\"key1\":0.1,\"key2\":-1.5},\"key2\":{\"key1\":0.2,\"key2\":-2.43,\"key3\":1e-4},\"key3\":{\"key1\":0.45,\"key2\":0.46,\"key3\":0.0e+1}}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.2f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.2, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -2.43f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -2.43, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 0.0001f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 0.0001, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.45f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.45, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), 0.46f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), 0.46, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 0.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 0.0, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key1\" :\t{\"key1\": 0.1,\t\r\"key2\"\t:\n  -1.5    }\r, \"key2\":{\n\"key1\":0.2\n, \"key2\"  :  -2.43,  \"key3\" :    1e-4 },\"key3\":{\"key1\":0.45,\r\"key2\":\n0.46\n, \"key3\" \r\n: \t0.0e+1}   }\r\n");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.2f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.2, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -2.43f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -2.43, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 0.0001f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 0.0001, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.45f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.45, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), 0.46f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), 0.46, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 0.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 0.0, std::numeric_limits<double>::epsilon());

    doc.deserialize("{\"key1\":{\"key1\":true,\"key2\":false},\"key2\":{\"key1\":true,\"key2\":false,\"key3\":false},\"key3\":{\"key1\":true}}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getBooleanFrom("key2"), false);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getBooleanFrom("key2"), false);
    XCTAssertEqual(innerDoc.getBooleanFrom("key3"), false);
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    doc.deserialize(" {  \"key1\" : {\"key1\"\t:\ttrue,\n\"key2\"\t:\tfalse\n}\n, \"key2\" : { \"key1\" : true , \"key2\"\r\n  : \rfalse, \"key3\"\n\n:  false} , \"key3\":\r\n{\"key1\":true\r}\n}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getBooleanFrom("key2"), false);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getBooleanFrom("key2"), false);
    XCTAssertEqual(innerDoc.getBooleanFrom("key3"), false);
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);

    doc.deserialize("{\"key1\":{\"key1\":null,\"key2\":null},\"key2\":{\"key1\":null,\"key2\":null,\"key3\":null},\"key3\":{\"key1\":null}}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key3"), true);
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);
    doc.deserialize(" {  \"key1\"\t: {\"key1\" : \tnull,\n\"key2\"\r\n:\tnull\n}\n, \"key2\"\r: { \"key1\":  null ,\t\"key2\": \rnull, \"key3\"   :  null} , \"key3\":\r\n{ \"key1\":null\r}\n}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key3"), true);
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);

    doc.deserialize("{\"key1\":{\"key1\":\"tata tete\",\"key2\":null},\"key2\":{\"key1\":true,\"key2\":1,\"key3\":1.5},\"key3\":{\"key1\":\"titi\",\"key2\":-1E2}}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tata tete");
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), 1);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), 1);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), 1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), 1.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), 1.0, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "titi");
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -100);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -100);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -100);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -100.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -100.0, std::numeric_limits<double>::epsilon());
    doc.deserialize("\t\t{\n\"key1\"\n:\n{ \"key1\" : \"tata tete\"\n, \t\"key2\"\t: null  } \t,\"key2\":\n{\"key1\"\n:\ntrue ,\"key2\":1  ,\"key3\"\r\n: 1.5 }\n,\"key3\"\r\n:\r\n{\"key1\":\t\"titi\"\t,\t\"key2\":-1E2\t}\t}\n");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tata tete");
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    innerDoc = doc.getObjectFrom("key2");
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), 1);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), 1);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), 1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), 1.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), 1.0, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectFrom("key3");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "titi");
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -100);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -100);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -100);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -100.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -100.0, std::numeric_limits<double>::epsilon());
}

- (void)testParsingObjectNullable {
    json::Document doc;

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":nUll}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":nll}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":nuLl}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":nulL}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":nulla}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":null1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":null_}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":null:}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null,\"key2\":nulll}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":null  ]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":nullnull}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":null,null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":null \"key\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":null\r\n\"key\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":null,,\"key\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{,\"key\":null,\"key\":null}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":null,\"key\":null,}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingObjectBoolean {
    json::Document doc;

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":tRue}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":trUe}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":tse}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":tue}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":fue}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":fse}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":truE}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":truea}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":true1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":true_}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true,\"key2\":true:}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false,\"key2\":fAlse}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false,\"key2\":faLse}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("\"key1\":false,\"key2\":falSe}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false,\"key2\":falsE}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false,\"key2\":falsea}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false,\"key2\":false1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false,\"key2\":false_}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false,\"key2\":false:}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":false  ]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":true  ]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingObjectNumber {
    json::Document doc;

    doc.deserialize("{\"key\":1}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
    doc.deserialize("{\"key\":-1}");
    XCTAssertEqual(doc.getShortFrom("key"), -1);
    XCTAssertEqual(doc.getIntFrom("key"), -1);
    XCTAssertEqual(doc.getLongFrom("key"), -1);
    doc.deserialize("{\"key\":-1000}");
    XCTAssertEqual(doc.getShortFrom("key"), -1000);
    XCTAssertEqual(doc.getIntFrom("key"), -1000);
    XCTAssertEqual(doc.getLongFrom("key"), -1000);
    doc.deserialize("{\"key\":1000}");
    XCTAssertEqual(doc.getShortFrom("key"), 1000);
    XCTAssertEqual(doc.getIntFrom("key"), 1000);
    XCTAssertEqual(doc.getLongFrom("key"), 1000);
    doc.deserialize("{\"key\":10001}");
    XCTAssertEqual(doc.getShortFrom("key"), 10001);
    XCTAssertEqual(doc.getIntFrom("key"), 10001);
    XCTAssertEqual(doc.getLongFrom("key"), 10001);
    doc.deserialize("{\"key\":1.1000}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), 1.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), 1.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":-1.1000}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), -1.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), -1.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":1e0001}");
    XCTAssertEqual(doc.getShortFrom("key"), 10);
    XCTAssertEqual(doc.getIntFrom("key"), 10);
    XCTAssertEqual(doc.getLongFrom("key"), 10);
    doc.deserialize("{\"key\":-1e0001}");
    XCTAssertEqual(doc.getShortFrom("key"), -10);
    XCTAssertEqual(doc.getIntFrom("key"), -10);
    XCTAssertEqual(doc.getLongFrom("key"), -10);
    doc.deserialize("{\"key\":1e+1}");
    XCTAssertEqual(doc.getShortFrom("key"), 10);
    XCTAssertEqual(doc.getIntFrom("key"), 10);
    XCTAssertEqual(doc.getLongFrom("key"), 10);
    doc.deserialize("{\"key\":1e-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), .1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), .1, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":-1e+1}");
    XCTAssertEqual(doc.getShortFrom("key"), -10);
    XCTAssertEqual(doc.getIntFrom("key"), -10);
    XCTAssertEqual(doc.getLongFrom("key"), -10);
    doc.deserialize("{\"key\":-1e-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), -.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), -.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":1}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
    doc.deserialize("{\"key\":1.1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), 1.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), 1.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":1E0}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
    doc.deserialize("{\"key\":1E+00}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
    doc.deserialize("{\"key\":1E-0}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
    doc.deserialize("{\"key\":1E000}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
    doc.deserialize("{\"key\":1E1}");
    XCTAssertEqual(doc.getShortFrom("key"), 10);
    XCTAssertEqual(doc.getIntFrom("key"), 10);
    XCTAssertEqual(doc.getLongFrom("key"), 10);
    doc.deserialize("{\"key\":-1E1}");
    XCTAssertEqual(doc.getShortFrom("key"), -10);
    XCTAssertEqual(doc.getIntFrom("key"), -10);
    XCTAssertEqual(doc.getLongFrom("key"), -10);
    doc.deserialize("{\"key\":1E+1}");
    XCTAssertEqual(doc.getShortFrom("key"), 10);
    XCTAssertEqual(doc.getIntFrom("key"), 10);
    XCTAssertEqual(doc.getLongFrom("key"), 10);
    doc.deserialize("{\"key\":1E-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), .1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), .1, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":-1E+1}");
    XCTAssertEqual(doc.getShortFrom("key"), -10);
    XCTAssertEqual(doc.getIntFrom("key"), -10);
    XCTAssertEqual(doc.getLongFrom("key"), -10);
    doc.deserialize("{\"key\":-1E-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), -.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), -.1, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":1.1e1}");
    XCTAssertEqual(doc.getShortFrom("key"), 11);
    XCTAssertEqual(doc.getIntFrom("key"), 11);
    XCTAssertEqual(doc.getLongFrom("key"), 11);
    doc.deserialize("{\"key\":-1.1e1}");
    XCTAssertEqual(doc.getShortFrom("key"), -11);
    XCTAssertEqual(doc.getIntFrom("key"), -11);
    XCTAssertEqual(doc.getLongFrom("key"), -11);
    doc.deserialize("{\"key\":1.1e+1}");
    XCTAssertEqual(doc.getShortFrom("key"), 11);
    XCTAssertEqual(doc.getIntFrom("key"), 11);
    XCTAssertEqual(doc.getLongFrom("key"), 11);
    doc.deserialize("{\"key\":1.1e-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), .11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), .11, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":-1.1e-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), -.11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), -.11, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":1.1E1}");
    XCTAssertEqual(doc.getShortFrom("key"), 11);
    XCTAssertEqual(doc.getIntFrom("key"), 11);
    XCTAssertEqual(doc.getLongFrom("key"), 11);
    doc.deserialize("{\"key\":-1.1E1}");
    XCTAssertEqual(doc.getShortFrom("key"), -11);
    XCTAssertEqual(doc.getIntFrom("key"), -11);
    XCTAssertEqual(doc.getLongFrom("key"), -11);
    doc.deserialize("{\"key\":1.1E+1}");
    XCTAssertEqual(doc.getShortFrom("key"), 11);
    XCTAssertEqual(doc.getIntFrom("key"), 11);
    XCTAssertEqual(doc.getLongFrom("key"), 11);
    doc.deserialize("{\"key\":1.1E-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), .11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), .11, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key\":-1.1E-1}");
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), -.11f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), -.11, std::numeric_limits<double>::epsilon());
    doc.deserialize("{\"key1\":1\t,\"key2\":1}");
    XCTAssertEqual(doc.getShortFrom("key1"), 1);
    XCTAssertEqual(doc.getIntFrom("key1"), 1);
    XCTAssertEqual(doc.getLongFrom("key1"), 1);
    XCTAssertEqual(doc.getShortFrom("key2"), 1);
    XCTAssertEqual(doc.getIntFrom("key2"), 1);
    XCTAssertEqual(doc.getLongFrom("key2"), 1);

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("{\"key\":+ }");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":+1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":+1.1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1.1+1.1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1.1-1.1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":+a}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":-}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":-1111-1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":-1111+1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":-a}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1.}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1.a}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1.+}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1.-}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1ea}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e+}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e-}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e+a}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e-a}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e1.1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e1.1e1+1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e1+1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1E1-1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1e1E11e-1}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":1]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    doc.deserialize("{\"\":1}");
    XCTAssertEqual(doc.getShortFrom(""), 1);
    XCTAssertEqual(doc.getIntFrom(""), 1);
    XCTAssertEqual(doc.getLongFrom(""), 1);
    XCTAssertEqualWithAccuracy(doc.getFloatFrom(""), 1.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom(""), 1., std::numeric_limits<double>::epsilon());

    doc.deserialize("{\"key\":1, \"key\":2}");
    XCTAssertEqual(doc.getShortFrom("key"), 2);
    XCTAssertEqual(doc.getIntFrom("key"), 2);
    XCTAssertEqual(doc.getLongFrom("key"), 2);
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), 2.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), 2., std::numeric_limits<double>::epsilon());

    ic = nullptr;
    try {
        doc.deserialize("{\"key1\":12  ]");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingObjectWrongKey {
    json::Document doc;

    doc.deserialize("{\"key\":1}");
    const std::out_of_range* wk = nullptr;
    try {
        doc.getShortFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getIntFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getLongFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getStringFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getBooleanFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getDoubleFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getFloatFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.isNullFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getObjectFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
    wk = nullptr;
    try {
        doc.getArrayFrom("key1");
    } catch (const std::out_of_range& e) {
        wk = &e;
    }
    XCTAssertNotEqual(wk, nullptr);
}

- (void)testParsingObjectBadValue {
    json::Document doc;

    doc.deserialize("{\"key\":\"value\"}");
    const std::invalid_argument* ia = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getLongFrom("key");
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        doc.getDoubleFrom("key");
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    const json::BadValue* bv = nullptr;
    try {
        doc.getBooleanFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getObjectFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);

    doc.deserialize("{\"key\":true}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
    XCTAssertEqual(doc.getFloatFrom("key"), 1);
    XCTAssertEqual(doc.getDoubleFrom("key"), 1);
    XCTAssertEqual(doc.getStringFrom("key"), "true");
    bv = nullptr;
    try {
        doc.getObjectFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);

    doc.deserialize("{\"key\":false}");
    XCTAssertEqual(doc.getShortFrom("key"), 0);
    XCTAssertEqual(doc.getIntFrom("key"), 0);
    XCTAssertEqual(doc.getLongFrom("key"), 0);
    XCTAssertEqual(doc.getFloatFrom("key"), 0);
    XCTAssertEqual(doc.getDoubleFrom("key"), 0);
    XCTAssertEqual(doc.getStringFrom("key"), "false");
    bv = nullptr;
    try {
        doc.getObjectFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);

    doc.deserialize("{\"key\":null}");
    XCTAssertEqual(doc.getShortFrom("key"), 0);
    XCTAssertEqual(doc.getIntFrom("key"), 0);
    XCTAssertEqual(doc.getLongFrom("key"), 0);
    XCTAssertEqual(doc.getFloatFrom("key"), 0);
    XCTAssertEqual(doc.getDoubleFrom("key"), 0);
    XCTAssertEqual(doc.getStringFrom("key"), "null");
    bv = nullptr;
    try {
        doc.getObjectFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    XCTAssertEqual(doc.getBooleanFrom("key"), false);

    doc.deserialize("{\"key\":1}");
    XCTAssertEqual(doc.getStringFrom("key"), "1");
    bv = nullptr;
    try {
        doc.getObjectFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        doc.getArrayFrom("key");
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    XCTAssertEqual(doc.getBooleanFrom("key"), true);
}

- (void)testParsingObjectWrongType {
    json::Document doc;

    doc.deserialize("{\"key\":1.2}");
    XCTAssertEqual(doc.getShortFrom("key"), 1);
    XCTAssertEqual(doc.getIntFrom("key"), 1);
    XCTAssertEqual(doc.getLongFrom("key"), 1);
}

- (void)testParsingObjectNumberOverflow {
    json::Document doc;

    // SHORT OVERFLOW
    std::ostringstream json("{\"key\":", std::ios::ate);
    const int minShort = std::numeric_limits<short>::min();
    json << minShort << "}";
    doc.deserialize(json.str());
    XCTAssertEqual(doc.getShortFrom("key"), minShort);
    XCTAssertEqual(doc.getIntFrom("key"), minShort);
    XCTAssertEqual(doc.getLongFrom("key"), minShort);

    const std::out_of_range* no = nullptr;
    json.str("{\"key\":");
    json << (minShort-1) << "}";
    doc.deserialize(json.str());
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntFrom("key"), minShort-1);
    XCTAssertEqual(doc.getLongFrom("key"), minShort-1);

    const int maxShort = std::numeric_limits<short>::max();
    json.str("{\"key\":");
    json << maxShort << "}";
    doc.deserialize(json.str());
    XCTAssertEqual(doc.getShortFrom("key"), maxShort);
    XCTAssertEqual(doc.getIntFrom("key"), maxShort);
    XCTAssertEqual(doc.getLongFrom("key"), maxShort);

    json.str("{\"key\":");
    json << (maxShort+1) << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntFrom("key"), maxShort+1);
    XCTAssertEqual(doc.getLongFrom("key"), maxShort+1);

    // INT OVERFLOW
    const long minInt = std::numeric_limits<int>::min();
    json.str("{\"key\":");
    json << minInt << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntFrom("key"), minInt);
    XCTAssertEqual(doc.getLongFrom("key"), minInt);

    json.str("{\"key\":");
    json << (minInt-1) << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongFrom("key"), minInt-1);

    const long maxInt = std::numeric_limits<int>::max();
    json.str("{\"key\":");
    json << maxInt << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getIntFrom("key"), maxInt);
    XCTAssertEqual(doc.getLongFrom("key"), maxInt);

    json.str("{\"key\":");
    json << (maxInt+1) << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongFrom("key"), maxInt+1);

    // LONG OVERFLOW
    const long minLong = std::numeric_limits<long>::min();
    json.str("{\"key\":");
    json << minLong << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongFrom("key"), minLong);

    doc.deserialize("{\"key\":-9223372036854775809}");
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getLongFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);

    const long maxLong = std::numeric_limits<long>::max();
    json.str("{\"key\":");
    json << maxLong << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(doc.getLongFrom("key"), maxLong);

    doc.deserialize("{\"key\":9223372036854775808}");
    no = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getLongFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);

    // FLOAT
    const double minFloat = std::numeric_limits<float>::lowest();
    json.str("{\"key\":");
    json << std::fixed << minFloat << "}";
    doc.deserialize(json.str());
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), minFloat, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), minFloat, std::numeric_limits<double>::epsilon());

    const double nextLowestFloat = minFloat-std::abs(minFloat)*std::numeric_limits<float>::epsilon();
    json.str("{\"key\":");
    json << std::fixed << nextLowestFloat << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), nextLowestFloat, std::numeric_limits<double>::epsilon());

    const double maxFloat = std::numeric_limits<float>::max();
    json.str("{\"key\":");
    json << std::fixed << maxFloat << "}";
    doc.deserialize(json.str());
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key"), maxFloat, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), maxFloat, std::numeric_limits<double>::epsilon());

    const double nextHighestFloat = maxFloat+std::abs(maxFloat)*std::numeric_limits<float>::epsilon();
    json.str("{\"key\":");
    json << std::fixed << nextHighestFloat << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), nextHighestFloat, std::numeric_limits<double>::epsilon());

    // DOUBLE
    const long double minDouble = std::numeric_limits<double>::lowest();
    json.str("{\"key\":");
    json << std::fixed << minDouble << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), minDouble, std::numeric_limits<double>::epsilon());

    const long double nextLowestDouble = minDouble-std::abs(minDouble)*std::numeric_limits<double>::epsilon();
    json.str("{\"key\":");
    json << std::fixed << nextLowestDouble << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getDoubleFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);

    const long double maxDouble = std::numeric_limits<double>::max();
    json.str("{\"key\":");
    json << std::fixed << maxDouble << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key"), maxDouble, std::numeric_limits<double>::epsilon());

    const long double nextHighestDouble = maxDouble+std::abs(maxDouble)*std::numeric_limits<double>::epsilon();
    json.str("{\"key\":");
    json << std::fixed << nextHighestDouble << "}";
    doc.deserialize(json.str());
    no = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        doc.getDoubleFrom("key");
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
}

- (void)testParsingObjectBadObject {
    json::Document doc;

    doc.deserialize("[1.2]");
    const json::BadValue* bo = nullptr;
    try {
        doc.getShortFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getIntFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getLongFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getStringFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getBooleanFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getObjectFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getArrayFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.isNullFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getFloatFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
    bo = nullptr;
    try {
        doc.getDoubleFrom("key");
    } catch (const json::BadValue& e) {
        bo = &e;
    }
    XCTAssertNotEqual(bo, nullptr);
}

- (void)testParsingObjectString {
    json::Document doc;

    doc.deserialize("{\"key\":\"tata\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "tata");
    doc.deserialize("{\t \"key1\"  : \"tata\"\r   \t   \r\n   \n,  \"key2\"\r\n: \"tete\"}");
    XCTAssertEqual(doc.getStringFrom("key1"), "tata");
    XCTAssertEqual(doc.getStringFrom("key2"), "tete");
    doc.deserialize("{\"key\":\"\\\"\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\"");
    doc.deserialize("{\"key\":\"\\\\\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\\");
    doc.deserialize("{\"key\":\"\\/\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "/");
    doc.deserialize("{\"key\":\"\\b\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\b");
    doc.deserialize("{\"key\":\"\\f\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\f");
    doc.deserialize("{\"key\":\"\\n\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\n");
    doc.deserialize("{\"key\":\"\\r\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\r");
    doc.deserialize("{\"key\":\"\\t\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\t");
    doc.deserialize("{\"key\":\"\\/\\\\\\\"\\uCAFE\\uBABE\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "/\\\"\uCAFE\uBABE");
    XCTAssertEqual(doc.getStringFrom("key"), "/\\\"쫾몾");
    doc.deserialize("{\"key\":\"쫾\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "쫾");
    doc.deserialize("{\"key\":\"⟦\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "⟦");
    doc.deserialize("{\"key\":\"ȃ\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "ȃ");
    doc.deserialize("{\"key\":\"A\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "A");
    doc.deserialize("{\"\\/\\\\\\\"\\uCAFE\\uBABE\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("/\\\"\uCAFE\uBABE"), "value");
    XCTAssertEqual(doc.getStringFrom("/\\\"쫾몾"), "value");
    doc.deserialize("{\"쫾\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("쫾"), "value");
    doc.deserialize("{\"⟦\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("⟦"), "value");
    doc.deserialize("{\"ȃ\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("ȃ"), "value");
    doc.deserialize("{\"A\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("A"), "value");

    doc.deserialize("{\"key\":\"🍌\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "🍌");
    XCTAssertEqual(doc.getStringFrom("key"), "\xF0\x9F\x8D\x8C");
    doc.deserialize("{\"key\":\"\\uD83C\\uDF4C\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "🍌");
    XCTAssertEqual(doc.getStringFrom("key"), "\xF0\x9F\x8D\x8C");
    doc.deserialize("{\"key\":\"\\uFFFF\"}");
    XCTAssertEqual(doc.getStringFrom("key"), "\uFFFF");
    XCTAssertEqual(doc.getStringFrom("key"), "\xEF\xBF\xBF");
    doc.deserialize("{\"key\":\"\\uD800\\uDC00\"}"); // 1st UTF16 Surrogate Char
    XCTAssertEqual(doc.getStringFrom("key"), "𐀀");
    XCTAssertEqual(doc.getStringFrom("key"), "\xF0\x90\x80\x80");

    doc.deserialize("{\"🍌\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("🍌"), "value");
    XCTAssertEqual(doc.getStringFrom("\xF0\x9F\x8D\x8C"), "value");
    doc.deserialize("{\"\\uD83C\\uDF4C\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("🍌"), "value");
    XCTAssertEqual(doc.getStringFrom("\xF0\x9F\x8D\x8C"), "value");
    doc.deserialize("{\"\\uFFFF\":\"value\"}");
    XCTAssertEqual(doc.getStringFrom("\uFFFF"), "value");
    XCTAssertEqual(doc.getStringFrom("\xEF\xBF\xBF"), "value");
    doc.deserialize("{\"\\uD800\\uDC00\":\"value\"}"); // 1st UTF16 Surrogate Char
    XCTAssertEqual(doc.getStringFrom("𐀀"), "value");
    XCTAssertEqual(doc.getStringFrom("\xF0\x90\x80\x80"), "value");

    const json::InvalidCharacter* ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83Cz\\uDF4C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83C \\uDF4C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83Ca\\uDF4C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83C1\\uDF4C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83C\\t\\uDF4C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83C\\n\\uDF4C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"key\":\"\\uD83C\\f\\uDF4C\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);

    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83Cz\\uDF4C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83C \\uDF4C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83Ca\\uDF4C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83C1\\uDF4C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83C1\\t\\uDF4C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83C1\\n\\uDF4C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\\uD83C1\\f\\uDF4C\":\"value\"}");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
    ic = nullptr;
    try {
        doc.deserialize("{\"\"  : \"   ");
    } catch (const json::InvalidCharacter& e) {
        ic = &e;
    }
    XCTAssertNotEqual(ic, nullptr);
}

- (void)testParsingNestedMixedBasic {
    json::Document doc;
    json::Document innerDoc;

    doc.deserialize("\r\n \t{  \"key1\"  : \t[\"tata\", \"tete titi\"\n\n],  \"key2\":[\t\t\"toto\",  \r\n\"tutu\"]  ,   \"key3\" :[ \"tyty\" ]\n\n , \"key4\" : \"baba\" } \r\n");
    innerDoc = doc.getArrayFrom("key1");
    XCTAssertEqual(innerDoc.getStringAt(0), "tata");
    XCTAssertEqual(innerDoc.getStringAt(1), "tete titi");
    innerDoc = doc.getArrayFrom("key2");
    XCTAssertEqual(innerDoc.getStringAt(0), "toto");
    XCTAssertEqual(innerDoc.getStringAt(1), "tutu");
    innerDoc = doc.getArrayFrom("key3");
    XCTAssertEqual(innerDoc.getStringAt(0), "tyty");
    XCTAssertEqual(doc.getStringFrom("key4"), "baba");
    doc.deserialize("[  {\"key1\" : \"tata\",\"key2\"\n: \r\"tete titi\"\t}, { \"key1\"\t:\t\r\n\"toto\",\t \"key2\"  \n:  \"tutu\"},\r  { \"key1\":\"tyty\"} , \"baba\"   \r\n]");
    innerDoc = doc.getObjectAt(0);
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tata");
    XCTAssertEqual(innerDoc.getStringFrom("key2"), "tete titi");
    innerDoc = doc.getObjectAt(1);
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "toto");
    XCTAssertEqual(innerDoc.getStringFrom("key2"), "tutu");
    innerDoc = doc.getObjectAt(2);
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tyty");
    XCTAssertEqual(doc.getStringAt(3), "baba");

    doc.deserialize("{\"key1\":[0, \r\n-1\t],\"key2\":[  2, \t\r\n-3],\"key3\"\t:   [4\t\t]   , \"key4\": 23}   ");
    innerDoc = doc.getArrayFrom("key1");
    XCTAssertEqual(innerDoc.getShortAt(0), 0);
    XCTAssertEqual(innerDoc.getIntAt(0), 0);
    XCTAssertEqual(innerDoc.getLongAt(0), 0);
    XCTAssertEqual(innerDoc.getShortAt(1), -1);
    XCTAssertEqual(innerDoc.getIntAt(1), -1);
    XCTAssertEqual(innerDoc.getLongAt(1), -1);
    innerDoc = doc.getArrayFrom("key2");
    XCTAssertEqual(innerDoc.getShortAt(0), 2);
    XCTAssertEqual(innerDoc.getIntAt(0), 2);
    XCTAssertEqual(innerDoc.getLongAt(0), 2);
    XCTAssertEqual(innerDoc.getShortAt(1), -3);
    XCTAssertEqual(innerDoc.getIntAt(1), -3);
    XCTAssertEqual(innerDoc.getLongAt(1), -3);
    innerDoc = doc.getArrayFrom("key3");
    XCTAssertEqual(innerDoc.getShortAt(0), 4);
    XCTAssertEqual(innerDoc.getIntAt(0), 4);
    XCTAssertEqual(innerDoc.getLongAt(0), 4);
    XCTAssertEqual(doc.getShortFrom("key4"), 23);
    XCTAssertEqual(doc.getIntFrom("key4"), 23);
    XCTAssertEqual(doc.getLongFrom("key4"), 23);
    doc.deserialize("[  {  \"key1\"\n : 0 , \"key2\"\t:\t -1}\r\n,\t{\"key1\"\t:2\n,\"key2\"\n:\r-3}   , \t { \"key1\"   :  4\r\n}\n\n,23\n]");
    innerDoc = doc.getObjectAt(0);
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 0);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -1);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -1);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -1);
    innerDoc = doc.getObjectAt(1);
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 2);
    XCTAssertEqual(innerDoc.getShortFrom("key2"), -3);
    XCTAssertEqual(innerDoc.getIntFrom("key2"), -3);
    XCTAssertEqual(innerDoc.getLongFrom("key2"), -3);
    innerDoc = doc.getObjectAt(2);
    XCTAssertEqual(innerDoc.getShortFrom("key1"), 4);
    XCTAssertEqual(innerDoc.getIntFrom("key1"), 4);
    XCTAssertEqual(innerDoc.getLongFrom("key1"), 4);
    XCTAssertEqual(doc.getShortAt(3), 23);
    XCTAssertEqual(doc.getIntAt(3), 23);
    XCTAssertEqual(doc.getLongAt(3), 23);

    doc.deserialize("{\"key1\":[0.1,-1.5],\"key2\":[0.2,-2.43,1e-4],\"key3\":[0.45,0.46,0.0e+1]}");
    innerDoc = doc.getArrayFrom("key1");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayFrom("key2");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.2f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.2, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), -2.43f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), -2.43, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 0.0001f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 0.0001, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getArrayFrom("key3");
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(0), 0.45f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(0), 0.45, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), 0.46f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), 0.46, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 0.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 0.0, std::numeric_limits<double>::epsilon());
    doc.deserialize("[ \t{\"key1\": 0.1,\t\r\"key2\"\t:\n  -1.5    }\r, {\n\"key1\":0.2\n, \"key2\"  :  -2.43,  \"key3\" :    1e-4 },\t{\"key1\":0.45,\r\"key2\":\n0.46\n, \"key3\" \r\n: \t0.0e+1}  ]\r\n");
    innerDoc = doc.getObjectAt(0);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.1f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.1, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -1.5, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectAt(1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.2f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.2, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), -2.43f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), -2.43, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 0.0001f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 0.0001, std::numeric_limits<double>::epsilon());
    innerDoc = doc.getObjectAt(2);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key1"), 0.45f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key1"), 0.45, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key2"), 0.46f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key2"), 0.46, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatFrom("key3"), 0.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleFrom("key3"), 0.0, std::numeric_limits<double>::epsilon());

    doc.deserialize("{\"key1\":[true,false],\"key2\":[true,false,false],\"key3\":[true]}");
    innerDoc = doc.getArrayFrom("key1");
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getBooleanAt(1), false);
    innerDoc = doc.getArrayFrom("key2");
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getBooleanAt(1), false);
    XCTAssertEqual(innerDoc.getBooleanAt(2), false);
    innerDoc = doc.getArrayFrom("key3");
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    doc.deserialize(" [  {\"key1\"\t:\ttrue,\n\"key2\"\t:\tfalse\n}\n, { \"key1\" : true , \"key2\"\r\n  : \rfalse, \"key3\"\n\n:  false} , \r\n{\"key1\":true\r}\n]");
    innerDoc = doc.getObjectAt(0);
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getBooleanFrom("key2"), false);
    innerDoc = doc.getObjectAt(1);
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);
    XCTAssertEqual(innerDoc.getBooleanFrom("key2"), false);
    XCTAssertEqual(innerDoc.getBooleanFrom("key3"), false);
    innerDoc = doc.getObjectAt(2);
    XCTAssertEqual(innerDoc.getBooleanFrom("key1"), true);

    doc.deserialize("{\"key1\":[null,null],\"key2\":[null,null,null],\"key3\":[null]}");
    innerDoc = doc.getArrayFrom("key1");
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    innerDoc = doc.getArrayFrom("key2");
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    XCTAssertEqual(innerDoc.isNullAt(1), true);
    XCTAssertEqual(innerDoc.isNullAt(2), true);
    innerDoc = doc.getArrayFrom("key3");
    XCTAssertEqual(innerDoc.isNullAt(0), true);
    doc.deserialize(" [   {\"key1\" : \tnull,\n\"key2\"\r\n:\tnull\n}\n,  { \"key1\":  null ,\t\"key2\": \rnull, \"key3\"   :  null} , \r\n{ \"key1\":null\r}\n]");
    innerDoc = doc.getObjectAt(0);
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    innerDoc = doc.getObjectAt(1);
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    XCTAssertEqual(innerDoc.isNullFrom("key3"), true);
    innerDoc = doc.getObjectAt(2);
    XCTAssertEqual(innerDoc.isNullFrom("key1"), true);

    doc.deserialize("{\"key1\":{\"key1\":\"tata tete\",\"key2\":null},\"key2\":[true,1,1.5],\"key3\":\"titi\",\"key4\":-1E2}");
    innerDoc = doc.getObjectFrom("key1");
    XCTAssertEqual(innerDoc.getStringFrom("key1"), "tata tete");
    XCTAssertEqual(innerDoc.isNullFrom("key2"), true);
    innerDoc = doc.getArrayFrom("key2");
    XCTAssertEqual(innerDoc.getBooleanAt(0), true);
    XCTAssertEqual(innerDoc.getShortAt(1), 1);
    XCTAssertEqual(innerDoc.getIntAt(1), 1);
    XCTAssertEqual(innerDoc.getLongAt(1), 1);
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(1), 1.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(1), 1.0, std::numeric_limits<double>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getFloatAt(2), 1.5f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(innerDoc.getDoubleAt(2), 1.5, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(doc.getStringFrom("key3"), "titi");
    XCTAssertEqual(doc.getShortFrom("key4"), -100);
    XCTAssertEqual(doc.getIntFrom("key4"), -100);
    XCTAssertEqual(doc.getLongFrom("key4"), -100);
    XCTAssertEqualWithAccuracy(doc.getFloatFrom("key4"), -100.0f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(doc.getDoubleFrom("key4"), -100.0, std::numeric_limits<double>::epsilon());
}

- (void)testParsinggetString {
    json::Document doc;

    doc[""] = "";
    std::string str = doc.serialize();


    doc.deserialize("{}");
    XCTAssertEqual(doc.serialize(), "{}");
    doc.deserialize("{\"\":\"\"}");
    XCTAssertEqual(doc.serialize(), "{\"\":\"\"}");
    doc.deserialize("[]");
    XCTAssertEqual(doc.serialize(), "[]");
    doc.deserialize("[\"value\"]");
    XCTAssertEqual(doc.serialize(), "[\"value\"]");
    doc.deserialize("{\"key\":\"value\"}");
    XCTAssertEqual(doc.serialize(), "{\"key\":\"value\"}");
    doc.deserialize("[\"\\uCAFE\"]");
    XCTAssertEqual(doc.serialize(), "[\"쫾\"]");
    doc.deserialize("{\"key\":\"\\uCAFE\"}");
    XCTAssertEqual(doc.serialize(), "{\"key\":\"쫾\"}");
    doc.deserialize("[\"\\uD83D\\uDC2D\"]");
    XCTAssertEqual(doc.serialize(), "[\"🐭\"]");
    doc.deserialize("{\"key\":\"\\uD83D\\uDC2D\"}");
    XCTAssertEqual(doc.serialize(), "{\"key\":\"🐭\"}");
    doc.deserialize("[1]");
    XCTAssertEqual(doc.serialize(), "[1]");
    doc.deserialize("{\"key\":1}");
    XCTAssertEqual(doc.serialize(), "{\"key\":1}");
    doc.deserialize("[9223372036854775807]");
    XCTAssertEqual(doc.serialize(), "[9223372036854775807]");
    doc.deserialize("{\"key\":9223372036854775807}");
    XCTAssertEqual(doc.serialize(), "{\"key\":9223372036854775807}");
    doc.deserialize("[-9223372036854775807]");
    XCTAssertEqual(doc.serialize(), "[-9223372036854775807]");
    doc.deserialize("{\"key\":-9223372036854775807}");
    XCTAssertEqual(doc.serialize(), "{\"key\":-9223372036854775807}");
    doc.deserialize("[-1]");
    XCTAssertEqual(doc.serialize(), "[-1]");
    doc.deserialize("{\"key\":-1}");
    XCTAssertEqual(doc.serialize(), "{\"key\":-1}");
    doc.deserialize("[1e1]");
    XCTAssertEqual(doc.serialize(), "[10]");
    doc.deserialize("{\"key\":1e1}");
    XCTAssertEqual(doc.serialize(), "{\"key\":10}");
    doc.deserialize("[1e-1]");
    XCTAssertEqual(doc.serialize(), "[0.1]");
    doc.deserialize("{\"key\":1e-1}");
    XCTAssertEqual(doc.serialize(), "{\"key\":0.1}");
    doc.deserialize("[1e-2]");
    XCTAssertEqual(doc.serialize(), "[0.01]");
    doc.deserialize("{\"key\":1e-2}");
    XCTAssertEqual(doc.serialize(), "{\"key\":0.01}");
    doc.deserialize("[true]");
    XCTAssertEqual(doc.serialize(), "[true]");
    doc.deserialize("{\"key\":true}");
    XCTAssertEqual(doc.serialize(), "{\"key\":true}");
    doc.deserialize("[false]");
    XCTAssertEqual(doc.serialize(), "[false]");
    doc.deserialize("{\"key\":false}");
    XCTAssertEqual(doc.serialize(), "{\"key\":false}");
    doc.deserialize("[null]");
    XCTAssertEqual(doc.serialize(), "[null]");
    doc.deserialize("{\"key\":null}");
    XCTAssertEqual(doc.serialize(), "{\"key\":null}");
    doc.deserialize("{\"🐭\":\"🧀\"}");
    XCTAssertEqual(doc.serialize(), "{\"🐭\":\"🧀\"}");
    doc.deserialize("{\"key\":[\"tata\",1,true,2,false,3,null]}");
    XCTAssertEqual(doc.serialize(), "{\"key\":[\"tata\",1,true,2,false,3,null]}");
    doc.deserialize("{\"key\":[{\"1\":1},{\"2\":\"2\"},{\"3\":true},{\"4\":false},{\"5\":null},[null]]}");
    XCTAssertEqual(doc.serialize(), "{\"key\":[{\"1\":1},{\"2\":\"2\"},{\"3\":true},{\"4\":false},{\"5\":null},[null]]}");
    doc.deserialize("{\"key\":[[\"tata\"],[1],[true],[2],[false],[3],[null]]}");
    XCTAssertEqual(doc.serialize(), "{\"key\":[[\"tata\"],[1],[true],[2],[false],[3],[null]]}");

    doc.deserialize("{\"key\":null}");
    doc["key2"].getType();
    XCTAssertEqual(doc.serialize(), "{\"key\":null}");
    doc.deserialize("[\"value1\",null]");
    doc[2].getType();
    XCTAssertEqual(doc.serialize(), "[\"value1\",null]");

    doc.deserialize("{\"key\":null,\"key2\":{\"key21\":1}, \"key3\":\"3\"}");
    doc["key4"].getType();
    XCTAssertEqual(doc.serialize(), "{\"key3\":\"3\",\"key2\":{\"key21\":1},\"key\":null}");
    doc["key2"]["key22"].getType();
    XCTAssertEqual(doc.serialize(), "{\"key3\":\"3\",\"key2\":{\"key21\":1},\"key\":null}");
    doc.deserialize("[\"value1\",{\"key\":null},null,[1,2]]");
    doc[4].getType();
    std::string test = doc.serialize();
    XCTAssertEqual(doc.serialize(), "[\"value1\",{\"key\":null},null,[1,2]]");
    doc[1]["key2"].getType();
    XCTAssertEqual(doc.serialize(), "[\"value1\",{\"key\":null},null,[1,2]]");
    doc[3][2].getType();
    XCTAssertEqual(doc.serialize(), "[\"value1\",{\"key\":null},null,[1,2]]");
}

- (void)testAccessOverload {
    json::Document doc;
    doc.deserialize("{\"key1\":\"tata\",\"key2\":true,\"key3\":false,\"key4\":null,\"key5\":1,\"key6\":1.1,\"key7\":[true, false],\"key8\":[\"tata\",\"toto\"],\"key9\":[null,null],\"key10\":[1,-2],\"key11\":[1.2,-3.4]}");
    doc["key1"] = "toto";
    XCTAssertEqual(doc.hasMember("key1"), true);
    XCTAssertEqual(doc.getStringFrom("key1"), "toto");
    // Test key not present
    XCTAssertEqual(doc.hasMember("zogzog"), false);
    XCTAssertEqual(doc.getStringSafeFrom("zogzog"), "");
    XCTAssertEqual(doc.getStringSafeFrom("zogzog", "A Value"), "A Value");
    // Access key not present
    XCTAssertEqual(doc["zogzog"].getType(), json::Kind::UNKNOWN);
    XCTAssertEqual(doc.serialize(),
                   "{\"key9\":[null,null],\"key8\":[\"tata\",\"toto\"],\"key1\":\"toto\",\"key2\":true,\"key6\":1.1,\"key5\":1,\"key3\":false,\"key4\":null,\"key11\":[1.2,-3.4],\"key10\":[1,-2],\"key7\":[true,false]}");
}

- (void)testRemove {
    json::Document doc;
    doc.deserialize("{\"key1\":\"tata\",\"key2\":true,\"key3\":false,\"key4\":null,\"key5\":1,\"key6\":1.1,\"key7\":[true, false],\"key8\":[\"tata\",\"toto\"],\"key9\":[null,null],\"key10\":[1,-2],\"key11\":[1.2,-3.4]}");
    doc.removeFrom("key3");
    XCTAssertEqual(doc.serialize(),
                   "{\"key9\":[null,null],\"key8\":[\"tata\",\"toto\"],\"key6\":1.1,\"key5\":1,\"key4\":null,\"key11\":[1.2,-3.4],\"key10\":[1,-2],\"key2\":true,\"key7\":[true,false],\"key1\":\"tata\"}");
    doc["key8"].removeAt(1);
    XCTAssertEqual(doc.serialize(),
                   "{\"key9\":[null,null],\"key8\":[\"tata\"],\"key6\":1.1,\"key5\":1,\"key4\":null,\"key11\":[1.2,-3.4],\"key10\":[1,-2],\"key2\":true,\"key7\":[true,false],\"key1\":\"tata\"}");

    
}

- (void)testRange {
    json::Document doc;
    doc.deserialize("{\"key1\":\"tata\",\"key2\":true,\"key3\":false,\"key4\":null,\"key5\":1,\"key6\":1.1,\"key7\":[true, false],\"key8\":[\"tata\",\"toto\"],\"key9\":[null,null],\"key10\":[1,-2],\"key11\":[1.2,-3.4]}");
    for (auto it = doc.beginObject(), end = doc.endObject(); it != end; it++)
    {
        if (it->first == "key1")
            XCTAssertEqual(it->second->getString(), "tata");
        else if (it->first == "key2")
            XCTAssertEqual(it->second->getBoolean(), true);
        else if (it->first == "key3")
            XCTAssertEqual(it->second->getBoolean(), false);
        else if (it->first == "key4")
            XCTAssertEqual(it->second->getType(), json::Kind::VOID);
        else if (it->first == "key5")
            XCTAssertEqual(it->second->getInt(), 1);
        else if (it->first == "key6")
            XCTAssertEqualWithAccuracy(it->second->getFloat(), 1.1f, std::numeric_limits<float>::epsilon());
        else if (it->first == "key7")
        {
            XCTAssertEqual(it->second->getType(), json::Kind::ARRAY);
            XCTAssertEqual(it->second->getArray().getBooleanAt(0), true);
            XCTAssertEqual((*it->second)[1].getBoolean(), false);
        }
        else if (it->first == "key8")
        {
            XCTAssertEqual(it->second->getType(), json::Kind::ARRAY);
            XCTAssertEqual(it->second->getArray().getStringAt(0), "tata");
            XCTAssertEqual((*it->second)[1].getString(), "toto");
        }
        else if (it->first == "key9")
        {
            XCTAssertEqual(it->second->getType(), json::Kind::ARRAY);
            XCTAssertEqual(it->second->getArray().isNullAt(0), true);
            XCTAssertEqual((*it->second)[1].isNull(), true);
        }
        else if (it->first == "key10")
        {
            XCTAssertEqual(it->second->getType(), json::Kind::ARRAY);

            for (auto ait = it->second->getArray().beginArray(), aend = it->second->getArray().endArray(); ait != aend; ait++)
            {
                if (std::distance(it->second->getArray().beginArray(), ait) == 0)
                    XCTAssertEqual((*ait)->getInt(), 1);
                else if (std::distance(it->second->getArray().beginArray(), ait) == 1)
                    XCTAssertEqual((*ait)->getInt(), -2);
            }

            XCTAssertEqual((*it->second)[0].getInt(), 1);
            XCTAssertEqual((*it->second)[1].getInt(), -2);

            XCTAssertEqual((*it->second)[0].getShort(), 1);
            XCTAssertEqual((*it->second)[1].getShort(), -2);
            XCTAssertEqual(it->second->getIntAt(0), 1);
            XCTAssertEqual(it->second->getIntAt(1), -2);
            XCTAssertEqual(it->second->getLongAt(0), 1);
            XCTAssertEqual(it->second->getLongAt(1), -2);
            XCTAssertEqualWithAccuracy(it->second->getFloatAt(0), 1, std::numeric_limits<float>::epsilon());
            XCTAssertEqualWithAccuracy(it->second->getFloatAt(1), -2, std::numeric_limits<float>::epsilon());
            XCTAssertEqualWithAccuracy(it->second->getDoubleAt(0), 1, std::numeric_limits<double>::epsilon());
            XCTAssertEqualWithAccuracy(it->second->getDoubleAt(1), -2, std::numeric_limits<double>::epsilon());
        }
        else if (it->first == "key11")
        {
            XCTAssertEqual(it->second->getType(), json::Kind::ARRAY);
            XCTAssertEqualWithAccuracy(it->second->getFloatAt(0), 1.2, std::numeric_limits<float>::epsilon());
            XCTAssertEqualWithAccuracy(it->second->getFloatAt(1), -3.4, std::numeric_limits<float>::epsilon());
            XCTAssertEqualWithAccuracy((*it->second)[0].getDouble(), 1.2, std::numeric_limits<double>::epsilon());
            XCTAssertEqualWithAccuracy((*it->second)[1].getDouble(), -3.4, std::numeric_limits<double>::epsilon());
        }
    }
}

- (void)testObjectHasMember {
    json::Document doc;
    doc.deserialize("{\"key1\":\"tata\",\"key2\":true,\"key3\":false,\"key4\":null,\"key5\":1,\"key6\":1.1,\"key7\":[true, false],\"key8\":[\"tata\",\"toto\"],\"key9\":[null,null],\"key10\":[1,-2],\"key11\":[1.2,-3.4]}");
    XCTAssertEqual(doc.hasMember("key1"), true);
    XCTAssertEqual(doc.hasMember("key7"), true);
    XCTAssertEqual(doc["key7"].hasMember("key1"), false);
    XCTAssertEqual(doc.hasMember("key12"), false);

    doc.deserialize("{\"key1\":\"tata\",\"key2\":{\"key21\":21,\"key22\":22}}");
    XCTAssertEqual(doc.hasMember("key2"), true);
    XCTAssertEqual(doc["key2"].hasMember("key21"), true);
    XCTAssertEqual(doc["key2"].hasMember("key23"), false);

    doc.deserialize("{\"key1\":\"tata\",\"key2\":{\"key21\":21,\"key22\":22}}");
    XCTAssertEqual(doc.hasMember("key3"), false);
    doc["key3"].getType();
    XCTAssertEqual(doc.hasMember("key3"), true);

    doc.deserialize("[\"key1\", \"key2\"]");
    XCTAssertEqual(doc.hasMember("key1"), false);
    doc[2].getType();
    XCTAssertEqual(doc.hasMember("3"), false);
}

- (void)testArrayPushBack {
    json::Document doc;
    doc.deserialize("[]");

    short sVal = 1;
    doc.pushBackArray(sVal);
    XCTAssertEqual(doc[0].getShort(), 1);
    int iVal = 2;
    doc.pushBackArray(iVal);
    XCTAssertEqual(doc[1].getInt(), 2);
    long lVal = 3;
    doc.pushBackArray(lVal);
    XCTAssertEqual(doc[2].getLong(), 3);
    float fVal = 4.1f;
    doc.pushBackArray(fVal);
    XCTAssertEqualWithAccuracy(doc[3].getFloat(), 4.1f, std::numeric_limits<float>::epsilon());
    double dVal = 5.1;
    doc.pushBackArray(dVal);
    XCTAssertEqualWithAccuracy(doc[4].getDouble(), 5.1, std::numeric_limits<double>::epsilon());
    const char* ccVal = "const char*";
    doc.pushBackArray(ccVal);
    XCTAssertEqual(doc[5].getString(), "const char*");
    std::string strVal = "string";
    doc.pushBackArray(strVal);
    XCTAssertEqual(doc[6].getString(), "string");
    bool bVal = false;
    doc.pushBackArray(bVal);
    XCTAssertEqual(doc[7].getBoolean(), false);
    std::nullptr_t nVal = nullptr;
    doc.pushBackArray(nVal);
    XCTAssertEqual(doc[8].isNull(), true);


    doc.deserialize("[]");

    doc[0].getType();
    doc.pushBackArray(sVal);
    XCTAssertEqual(doc[0].getShort(), 1);
    doc[1].getType();
    doc.pushBackArray(iVal);
    XCTAssertEqual(doc[1].getInt(), 2);
    doc[2].getType();
    doc.pushBackArray(lVal);
    XCTAssertEqual(doc[2].getLong(), 3);
    doc[3].getType();
    doc.pushBackArray(fVal);
    XCTAssertEqualWithAccuracy(doc[3].getFloat(), 4.1f, std::numeric_limits<float>::epsilon());
    doc[4].getType();
    doc.pushBackArray(dVal);
    XCTAssertEqualWithAccuracy(doc[4].getDouble(), 5.1, std::numeric_limits<double>::epsilon());
    doc[5].getType();
    doc.pushBackArray(ccVal);
    XCTAssertEqual(doc[5].getString(), "const char*");
    doc[6].getType();
    doc.pushBackArray(strVal);
    XCTAssertEqual(doc[6].getString(), "string");
    doc[7].getType();
    doc.pushBackArray(bVal);
    XCTAssertEqual(doc[7].getBoolean(), false);
    doc[8].getType();
    doc.pushBackArray(nVal);
    XCTAssertEqual(doc[8].isNull(), true);

    doc.deserialize("[]");

    doc[0].getType();
    doc[1].getType();
    doc[2].getType();
    doc[3].getType();
    doc[4].getType();
    doc[5].getType();
    doc[6].getType();
    doc[7].getType();
    doc[8].getType();
    doc[9].getType();
    doc.pushBackArray(sVal);
    XCTAssertEqual(doc[0].getShort(), 1);
    doc.pushBackArray(iVal);
    XCTAssertEqual(doc[1].getInt(), 2);
    doc.pushBackArray(lVal);
    XCTAssertEqual(doc[2].getLong(), 3);
    doc.pushBackArray(fVal);
    XCTAssertEqualWithAccuracy(doc[3].getFloat(), 4.1f, std::numeric_limits<float>::epsilon());
    doc.pushBackArray(dVal);
    XCTAssertEqualWithAccuracy(doc[4].getDouble(), 5.1, std::numeric_limits<double>::epsilon());
    doc.pushBackArray(ccVal);
    XCTAssertEqual(doc[5].getString(), "const char*");
    doc.pushBackArray(strVal);
    XCTAssertEqual(doc[6].getString(), "string");
    doc.pushBackArray(bVal);
    XCTAssertEqual(doc[7].getBoolean(), false);
    doc.pushBackArray(nVal);
    XCTAssertEqual(doc[8].isNull(), true);

    doc.deserialize("{\"key\":\"value\"}");
    doc.pushBackArray(1);
    XCTAssertEqual(doc.serialize(), "{\"key\":\"value\"}");
    doc["key"].pushBackArray("2");
    XCTAssertEqual(doc.serialize(), "{\"key\":\"value\"}");
}

@end
