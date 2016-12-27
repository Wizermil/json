//
// valueTests.m
// jsonTests
//
// Created by Mathieu Garaud on 23/07/16.
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
#include <random>
#include <vector>

@interface valueTests : XCTestCase {
    json::Document mValue;
    std::vector<json::Document> mList;
}
@end

@implementation valueTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    auto doc = json::Document(json::Kind::OBJECT);
    mValue.setObject(std::move(doc));

    json::Document value1;
    value1.setNull();
    json::Document value2;
    value2.setNumber(1);
    json::Document value3;
    value3.setBoolean(true);
    json::Document value4;
    value4.setString("toto");
    mList.push_back(std::move(value1));
    mList.push_back(std::move(value2));
    mList.push_back(std::move(value3));
    mList.push_back(std::move(value4));
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAlloc {
    json::Document value;
    XCTAssertEqual(value.getType(), json::Kind::UNKNOWN, "The default constructor doesn't set the type to UNKNOWN");
    value.setString("tata");
    XCTAssertEqual(value.getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(value.getString(), "tata", "The string is not set to \"tata\"");
    value.setBoolean(true);
    XCTAssertEqual(value.getType(), json::Kind::BOOLEAN, "The type is not set to BOOLEAN");
    XCTAssertEqual(value.getBoolean(), true, "The bool is not set to true");
    value.setNumber(1);
    XCTAssertEqual(value.getType(), json::Kind::NUMBER, "he type is not set to NUMBER");
    XCTAssertEqual(value.getShort(), 1, "The number is not set to 1");
    value.setBoolean(false);
    XCTAssertEqual(value.getType(), json::Kind::BOOLEAN, "The type is not set to BOOLEAN");
    XCTAssertEqual(value.getBoolean(), false, "The bool is not set to false");
    value.setNumber(1.2f);
    XCTAssertEqual(value.getType(), json::Kind::NUMBER_FRAC, "The type is not set to NUMBER_FRAC");
    XCTAssertEqual(value.getDouble(), 1.2f, "The number is not set to 1.2");
    value.setString("toto");
    XCTAssertEqual(value.getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(value.getString(), "toto", "The string is not set to \"toto\"");
    value.setNull();
    XCTAssertEqual(value.getType(), json::Kind::VOID, "The type is not set to NULLABLE");

    json::Document value1;
    auto doc1 = json::Document(json::Kind::OBJECT);
    value1.setObject(std::move(doc1));
    XCTAssertEqual(value1.getType(), json::Kind::OBJECT, "The type is not set to OBJECT");
    XCTAssertEqual(value1.getObject().getSize(), 0, "The document is not empty");
    XCTAssertEqual(mValue.getType(), json::Kind::OBJECT, "The type is not set to OBJECT");
    XCTAssertEqual(mValue.getObject().getSize(), 0, "The document is not empty");

    value1.setString("tata");
    XCTAssertEqual(value1.getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(value1.getString(), "tata", "The string is not set to \"tata\"");

    auto doc2 = json::Document(json::Kind::ARRAY);
    value1.setArray(std::move(doc2));
    XCTAssertEqual(value1.getType(), json::Kind::ARRAY, "The type is not set to ARRAY");
    XCTAssertEqual(value1.getArray().getSize(), 0, "The document is not empty");

    value1.setNumber(1);
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER, "he type is not set to NUMBER");
    XCTAssertEqual(value1.getInt(), 1, "The number is not set to 1");

    mValue.setString("toto");
    XCTAssertEqual(mValue.getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(mValue.getString(), "toto", "The string is not set to \"toto\"");
    mValue.setNull();
    XCTAssertEqual(mValue.getType(), json::Kind::VOID, "The type is not set to NULLABLE");

    json::Document* value2 = new json::Document();
    auto doc3 = json::Document(json::Kind::OBJECT);
    value2->setObject(std::move(doc3));
    delete value2;

    json::Document* value3 = new json::Document();
    auto doc4 = json::Document(json::Kind::ARRAY);
    value3->setArray(std::move(doc4));
    delete value3;

    json::Document value4;
    auto doc5 = json::Document(json::Kind::ARRAY);
    auto doc6 = json::Document(json::Kind::ARRAY);
    value4.setArray(std::move(doc5));
    value4.setArray(std::move(doc6));

    json::Document value5;
    auto doc7 = json::Document(json::Kind::OBJECT);
    auto doc8 = json::Document(json::Kind::OBJECT);
    value5.setObject(std::move(doc7));
    value5.setObject(std::move(doc8));

    json::Document value6;
    value6.setString("toto");
    value6.setString("titi");
    XCTAssertEqual(value6.getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(value6.getString(), "titi", "The string is not set to \"titi\"");

    json::Document value7;
    auto doc9 = json::Document(json::Kind::OBJECT);
    value7.setObject(std::move(doc9));
    value7.setBoolean(false);
    XCTAssertEqual(value7.getType(), json::Kind::BOOLEAN, "The type is not set to BOOLEAN");
    XCTAssertEqual(value7.getBoolean(), false, "The bool is not set to false");

    json::Document value8;
    auto doc10 = json::Document(json::Kind::ARRAY);
    value8.setArray(std::move(doc10));
    value8.setBoolean(true);
    XCTAssertEqual(value8.getType(), json::Kind::BOOLEAN, "The type is not set to BOOLEAN");
    XCTAssertEqual(value8.getBoolean(), true, "The bool is not set to false");

    json::Document value9;
    auto doc11 = json::Document(json::Kind::OBJECT);
    value9.setObject(std::move(doc11));
    value9.setNull();
    XCTAssertEqual(value9.getType(), json::Kind::VOID, "The type is not set to NULLABLE");

    json::Document value10;
    auto doc12 = json::Document(json::Kind::ARRAY);
    value10.setArray(std::move(doc12));
    value10.setNull();
    XCTAssertEqual(value10.getType(), json::Kind::VOID, "The type is not set to NULLABLE");
}

- (void)testAllocContainers {
    json::Document value1;
    value1.setNull();
    json::Document value2;
    value2.setNumber(1);
    json::Document value3;
    value3.setBoolean(true);
    json::Document value4;
    value4.setString("toto");

    std::vector<json::Document> list;
    list.push_back(std::move(value1));
    list.push_back(std::move(value2));
    list.push_back(std::move(value3));
    list.push_back(std::move(value4));
    XCTAssertEqual(list.front().getType(), json::Kind::VOID, "The type is not set to NULLABLE");
    XCTAssertEqual(list.back().getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(list.back().getString(), "toto", "The string is not set to \"toto\"");

    std::vector<json::Document> list1(std::move(list));
    XCTAssertEqual(list1.front().getType(), json::Kind::VOID, "The type is not set to NULLABLE");
    XCTAssertEqual(list1.back().getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(list1.back().getString(), "toto", "The string is not set to \"toto\"");

    XCTAssertEqual(mList.front().getType(), json::Kind::VOID, "The type is not set to NULLABLE");
    XCTAssertEqual(mList.back().getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(mList.back().getString(), "toto", "The string is not set to \"toto\"");
}

- (void)testAllocMove {
    json::Document value1;
    value1.setNull();
    json::Document value2(std::move(value1));
    XCTAssertEqual(value2.getType(), json::Kind::VOID, "The type is not set to NULLABLE");
    json::Document value3(std::move(value2));
    XCTAssertEqual(value3.getType(), json::Kind::VOID, "The type is not set to NULLABLE");
    value3.setString("toto");
    XCTAssertEqual(value3.getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(value3.getString(), "toto", "The string is not set to \"toto\"");
    value3.setNumber(34.567f);
    value1 = std::move(value3);
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER_FRAC, "he type is not set to NUMBER");
    XCTAssertEqual(value1.getFloat(), 34.567f, "The number is not set to 34.567");

    json::Document value4;
    value4.setString("toto");
    json::Document value5;
    value5.setString("titi");
    value5 = std::move(value4);
    XCTAssertEqual(value5.getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(value5.getString(), "toto", "The string is not set to \"toto\"");

    json::Document value6;
    auto doc6 = json::Document(json::Kind::OBJECT);
    value6.setObject(std::move(doc6));
    json::Document value7;
    auto doc7 = json::Document(json::Kind::OBJECT);
    value7.setObject(std::move(doc7));
    value7 = std::move(value6);
    XCTAssertEqual(value7.getType(), json::Kind::OBJECT, "The type is not set to OBJECT");
    XCTAssertEqual(value7.getObject().getSize(), 0, "The document is not empty");

    json::Document value8;
    auto doc8 = json::Document(json::Kind::ARRAY);
    value8.setArray(std::move(doc8));
    json::Document value9;
    auto doc9 = json::Document(json::Kind::ARRAY);
    value9.setArray(std::move(doc9));
    value9 = std::move(value8);
    XCTAssertEqual(value9.getType(), json::Kind::ARRAY, "The type is not set to ARRAY");
    XCTAssertEqual(value9.getArray().getSize(), 0, "The document is not empty");

    json::Document value10;
    value10.setString("toto");
    json::Document value11;
    value11.setNumber(10);
    value10 = std::move(value11);
    XCTAssertEqual(value10.getType(), json::Kind::NUMBER, "he type is not set to NUMBER");
    XCTAssertEqual(value10.getLong(), 10, "The number is not set to 10");

    json::Document value12;
    auto doc12 = json::Document(json::Kind::ARRAY);
    value12.setArray(std::move(doc12));
    json::Document value13;
    value13.setNumber(10);
    value12 = std::move(value13);
    XCTAssertEqual(value12.getType(), json::Kind::NUMBER, "he type is not set to NUMBER");
    XCTAssertEqual(value12.getInt(), 10, "The number is not set to 10");

    json::Document value14;
    auto doc14 = json::Document(json::Kind::OBJECT);
    value14.setObject(std::move(doc14));
    json::Document value15;
    value15.setNumber(10);
    value14 = std::move(value15);
    XCTAssertEqual(value14.getType(), json::Kind::NUMBER, "he type is not set to NUMBER");
    XCTAssertEqual(value14.getShort(), 10, "The number is not set to 10");

    json::Document value16;
    json::Document value17;
    value16 = std::move(value17);
    XCTAssertEqual(value16.getType(), json::Kind::UNKNOWN, "he type is not set to UNKNOWN");

    json::Document value18;
    json::Document value19;
    auto doc19 = json::Document(json::Kind::OBJECT);
    value19.setObject(std::move(doc19));
    value18 = std::move(value19);
    XCTAssertEqual(value18.getType(), json::Kind::OBJECT, "he type is not set to OBJECT");
    XCTAssertEqual(value18.getObject().getSize(), 0, "The document is not empty");

    json::Document value20;
    json::Document value21;
    auto doc21 = json::Document(json::Kind::ARRAY);
    value21.setArray(std::move(doc21));
    value20 = std::move(value21);
    XCTAssertEqual(value20.getType(), json::Kind::ARRAY, "he type is not set to ARRAY");
    XCTAssertEqual(value20.getArray().getSize(), 0, "The document is not empty");
}

- (void)testAllocCopy {
    json::Document value1;
    value1.setNull();
    json::Document value2(value1);
    XCTAssertEqual(value1.getType(), json::Kind::VOID);
    XCTAssertEqual(value2.getType(), json::Kind::VOID);
    json::Document value3(value2);
    XCTAssertEqual(value1.getType(), json::Kind::VOID);
    XCTAssertEqual(value2.getType(), json::Kind::VOID);
    XCTAssertEqual(value3.getType(), json::Kind::VOID);
    value3.setString("toto");
    XCTAssertEqual(value1.getType(), json::Kind::VOID);
    XCTAssertEqual(value2.getType(), json::Kind::VOID);
    XCTAssertEqual(value3.getType(), json::Kind::STRING);
    XCTAssertEqual(value3.getString(), "toto");
    value3.setNumber(34.567f);
    value1 = value3;
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER_FRAC);
    XCTAssertEqual(value1.getFloat(), 34.567f);
    XCTAssertEqual(value2.getType(), json::Kind::VOID);
    XCTAssertEqual(value3.getType(), json::Kind::NUMBER_FRAC);
    XCTAssertEqual(value3.getFloat(), 34.567f);

    json::Document value4;
    value4.setString("toto");
    XCTAssertEqual(value4.getType(), json::Kind::STRING);
    XCTAssertEqual(value4.getString(), "toto");
    json::Document value5;
    value5.setString("titi");
    XCTAssertEqual(value5.getType(), json::Kind::STRING);
    XCTAssertEqual(value5.getString(), "titi");
    value5 = value4;
    XCTAssertEqual(value4.getType(), json::Kind::STRING);
    XCTAssertEqual(value4.getString(), "toto");
    XCTAssertEqual(value5.getType(), json::Kind::STRING);
    XCTAssertEqual(value5.getString(), "toto");

    json::Document value6;
    auto doc6 = json::Document(json::Kind::OBJECT);
    value6.setObject(doc6);
    json::Document value7;
    auto doc7 = json::Document(json::Kind::OBJECT);
    value7.setObject(doc7);
    value7 = value6;
    XCTAssertEqual(value6.getType(), json::Kind::OBJECT);
    XCTAssertEqual(value6.getObject().getSize(), 0);
    XCTAssertEqual(value7.getType(), json::Kind::OBJECT);
    XCTAssertEqual(value7.getObject().getSize(), 0);

    json::Document value8;
    auto doc8 = json::Document(json::Kind::ARRAY);
    value8.setArray(doc8);
    json::Document value9;
    auto doc9 = json::Document(json::Kind::ARRAY);
    value9.setArray(doc9);
    value9 = value8;
    XCTAssertEqual(value8.getType(), json::Kind::ARRAY);
    XCTAssertEqual(value8.getArray().getSize(), 0);
    XCTAssertEqual(value9.getType(), json::Kind::ARRAY);
    XCTAssertEqual(value9.getArray().getSize(), 0);

    json::Document value10;
    value10.setString("toto");
    json::Document value11;
    value11.setNumber(10);
    value10 = value11;
    XCTAssertEqual(value10.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value10.getShort(), 10);
    XCTAssertEqual(value11.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value11.getShort(), 10);

    json::Document value12;
    auto doc12 = json::Document(json::Kind::ARRAY);
    value12.setArray(doc12);
    json::Document value13;
    value13.setNumber(10);
    value12 = value13;
    XCTAssertEqual(value12.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value12.getInt(), 10);
    XCTAssertEqual(value13.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value13.getInt(), 10);

    json::Document value14;
    auto doc14 = json::Document(json::Kind::OBJECT);
    value14.setObject(doc14);
    json::Document value15;
    value15.setNumber(10);
    value14 = value15;
    XCTAssertEqual(value14.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value14.getLong(), 10);
    XCTAssertEqual(value15.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value15.getLong(), 10);

    json::Document value16;
    json::Document value17;
    value16 = value17;
    XCTAssertEqual(value16.getType(), json::Kind::UNKNOWN);
    XCTAssertEqual(value17.getType(), json::Kind::UNKNOWN);
    XCTAssertNotEqual(&value16, &value17);

    json::Document value18;
    json::Document value19;
    auto doc19 = json::Document(json::Kind::OBJECT);
    value19.setObject(doc19);
    value18 = value19;
    XCTAssertEqual(value18.getType(), json::Kind::OBJECT);
    XCTAssertEqual(value18.getObject().getSize(), 0);
    XCTAssertEqual(value19.getType(), json::Kind::OBJECT);
    XCTAssertEqual(value19.getObject().getSize(), 0);

    json::Document value20;
    json::Document value21;
    auto doc21 = json::Document(json::Kind::ARRAY);
    value21.setArray(doc21);
    value20 = value21;
    XCTAssertEqual(value20.getType(), json::Kind::ARRAY);
    XCTAssertEqual(value20.getArray().getSize(), 0);
    XCTAssertEqual(value21.getType(), json::Kind::ARRAY);
    XCTAssertEqual(value21.getArray().getSize(), 0);

    json::Document value22;
    value22.setNumber(10);
    json::Document value23;
    value23.setString("toto");
    value22 = value23;
    XCTAssertEqual(value22.getType(), json::Kind::STRING);
    XCTAssertEqual(value22.getString(), "toto");
    XCTAssertEqual(value23.getType(), json::Kind::STRING);
    XCTAssertEqual(value23.getString(), "toto");

    json::Document value24;
    value24.setNumber(10);
    json::Document value25;
    value25.setBoolean(true);
    value24 = value25;
    XCTAssertEqual(value24.getType(), json::Kind::BOOLEAN);
    XCTAssertEqual(value24.getBoolean(), true);
    XCTAssertEqual(value25.getType(), json::Kind::BOOLEAN);
    XCTAssertEqual(value25.getBoolean(), true);
}

- (void)testMassiveAlloc {
    std::vector<json::Document> list;
    list.reserve(10);

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, 6);

    for (int i = 0; i < 1000; i++)
    {
        json::Document val;
        switch (dis(gen))
        {
            case 0: // UNKNOWN
                break;
            case 1: // OBJECT
            {
                auto doc = json::Document(json::Kind::OBJECT);
                val.setObject(std::move(doc));
                break;
            }
            case 2: // ARRAY
            {
                auto doc = json::Document(json::Kind::ARRAY);
                val.setArray(std::move(doc));
                break;
            }
            case 3: // STRING
                val.setString("toto_"+std::to_string(i));
                break;
            case 4: // NUMBER
                val.setNumber(i);
                break;
            case 5: // BOOLEAN
                val.setBoolean((i%2 == 0 ? true : false));
                break;
            case 6: // NULLABLE
                val.setNull();
                break;
        }
        list.push_back(std::move(val));
    }

    for (int i = 0; i < 1000; i++)
    {
        json::Document val;
        switch (dis(gen))
        {
            case 0: // UNKNOWN
                break;
            case 1: // OBJECT
            {
                auto doc = json::Document(json::Kind::OBJECT);
                val.setObject(std::move(doc));
                break;
            }
            case 2: // ARRAY
            {
                auto doc = json::Document(json::Kind::ARRAY);
                val.setArray(std::move(doc));
                break;
            }
            case 3: // STRING
                val.setString("toto_"+std::to_string(i));
                break;
            case 4: // NUMBER
                val.setNumber(i);
                break;
            case 5: // BOOLEAN
                val.setBoolean((i%2 == 0 ? true : false));
                break;
            case 6: // NULLABLE
                val.setNull();
                break;
        }
        list[i] = std::move(val);
    }

    XCTAssertEqual(list.size(), 1000, "The size of the vector should be 1000");

    for (auto &it : list)
    {
        it.setString("tata");
    }

    XCTAssertEqual(list[7].getType(), json::Kind::STRING, "The type is not set to STRING");
    XCTAssertEqual(list[7].getString(), "tata", "The string is not set to \"tata\"");

    std::vector<json::Document> list1;

    list.swap(list1);
    XCTAssertEqual(list.size(), 0, "The size of the vector should be 0");
}

- (void)testOperatorAssignementEqualOverload {
    json::Document value1;
    value1 = static_cast<short>(1);
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value1.getShort(), 1);
    value1 = static_cast<int>(2);
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value1.getInt(), 2);
    value1 = static_cast<long>(3);
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER);
    XCTAssertEqual(value1.getLong(), 3);
    value1 = static_cast<float>(4.4);
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER_FRAC);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 4.4f, std::numeric_limits<float>::epsilon());
    value1 = static_cast<double>(5.5);
    XCTAssertEqual(value1.getType(), json::Kind::NUMBER_FRAC);
    XCTAssertEqualWithAccuracy(value1.getDouble(), 5.5f, std::numeric_limits<double>::epsilon());
    value1 = "toto";
    XCTAssertEqual(value1.getType(), json::Kind::STRING);
    XCTAssertEqual(value1.getString(), "toto");
    value1 = std::string("tata");
    XCTAssertEqual(value1.getType(), json::Kind::STRING);
    XCTAssertEqual(value1.getString(), "tata");
    value1 = true;
    XCTAssertEqual(value1.getType(), json::Kind::BOOLEAN);
    XCTAssertEqual(value1.getBoolean(), true);
    value1 = false;
    XCTAssertEqual(value1.getType(), json::Kind::BOOLEAN);
    XCTAssertEqual(value1.getBoolean(), false);
    value1 = nullptr;
    XCTAssertEqual(value1.getType(), json::Kind::VOID);

    auto doc1 = json::Document(json::Kind::OBJECT);
    value1 = std::move(doc1);
    XCTAssertEqual(value1.getType(), json::Kind::OBJECT);
    auto doc2 = json::Document(json::Kind::ARRAY);
    value1 = std::move(doc2);
    XCTAssertEqual(value1.getType(), json::Kind::ARRAY);
}

- (void)testOperatorComparaisonEqualOverload {
    json::Document value1;
    json::Document value2;

    value1.setNull();
    XCTAssertEqual(value1 == nullptr, true);
    XCTAssertEqual(value1 == 1, false);
    XCTAssertEqual(value1 == static_cast<short>(1), false);
    XCTAssertEqual(value1 == static_cast<int>(1), false);
    XCTAssertEqual(value1 == static_cast<long>(1), false);
    XCTAssertEqual(value1 == static_cast<float>(1.1), false);
    XCTAssertEqual(value1 == static_cast<double>(1.1), false);
    XCTAssertEqual(value1 == true, false);
    XCTAssertEqual(value1 == false, false);
    XCTAssertEqual(value1 == "null", false);
    XCTAssertEqual(value1 == std::string("null"), false);
    value1.setNumber(1);
    XCTAssertEqual(value1 == static_cast<short>(1), true);
    XCTAssertEqual(value1 == static_cast<int>(1), true);
    XCTAssertEqual(value1 == static_cast<long>(1), true);
    XCTAssertEqual(value1 == static_cast<float>(1.0), true);
    XCTAssertEqual(value1 == static_cast<double>(1.0), true);
    XCTAssertEqual(value1 == nullptr, false);
    XCTAssertEqual(value1 == static_cast<short>(2), false);
    XCTAssertEqual(value1 == static_cast<int>(2), false);
    XCTAssertEqual(value1 == static_cast<long>(2), false);
    XCTAssertEqual(value1 == static_cast<float>(2.0), false);
    XCTAssertEqual(value1 == static_cast<double>(2.0), false);
    XCTAssertEqual(value1 == true, false);
    XCTAssertEqual(value1 == false, false);
    XCTAssertEqual(value1 == "null", false);
    XCTAssertEqual(value1 == std::string("null"), false);
    value1.setNumber(1.1);
    XCTAssertEqual(value1 == static_cast<float>(1.1), true);
    XCTAssertEqual(value1 == static_cast<double>(1.1), true);
    XCTAssertEqual(value1 == nullptr, false);
    XCTAssertEqual(value1 == static_cast<short>(1), false);
    XCTAssertEqual(value1 == static_cast<int>(1), false);
    XCTAssertEqual(value1 == static_cast<long>(1), false);
    XCTAssertEqual(value1 == static_cast<float>(2.0), false);
    XCTAssertEqual(value1 == static_cast<double>(2.0), false);
    XCTAssertEqual(value1 == true, false);
    XCTAssertEqual(value1 == false, false);
    XCTAssertEqual(value1 == "null", false);
    XCTAssertEqual(value1 == std::string("null"), false);
    value1.setBoolean(true);
    XCTAssertEqual(value1 == true, true);
    XCTAssertEqual(value1 == nullptr, false);
    XCTAssertEqual(value1 == static_cast<short>(1), false);
    XCTAssertEqual(value1 == static_cast<int>(1), false);
    XCTAssertEqual(value1 == static_cast<long>(1), false);
    XCTAssertEqual(value1 == static_cast<float>(1.1), false);
    XCTAssertEqual(value1 == static_cast<double>(1.1), false);
    XCTAssertEqual(value1 == false, false);
    XCTAssertEqual(value1 == "null", false);
    XCTAssertEqual(value1 == std::string("null"), false);
    value1.setBoolean(false);
    XCTAssertEqual(value1 == false, true);
    XCTAssertEqual(value1 == nullptr, false);
    XCTAssertEqual(value1 == static_cast<short>(1), false);
    XCTAssertEqual(value1 == static_cast<int>(1), false);
    XCTAssertEqual(value1 == static_cast<long>(1), false);
    XCTAssertEqual(value1 == static_cast<float>(1.1), false);
    XCTAssertEqual(value1 == static_cast<double>(1.1), false);
    XCTAssertEqual(value1 == true, false);
    XCTAssertEqual(value1 == "null", false);
    XCTAssertEqual(value1 == std::string("null"), false);
    value1.setString("toto");
    XCTAssertEqual(value1 == "toto", true);
    XCTAssertEqual(value1 == std::string("toto"), true);
    XCTAssertEqual(value1 == nullptr, false);
    XCTAssertEqual(value1 == static_cast<short>(1), false);
    XCTAssertEqual(value1 == static_cast<int>(1), false);
    XCTAssertEqual(value1 == static_cast<long>(1), false);
    XCTAssertEqual(value1 == static_cast<float>(1.1), false);
    XCTAssertEqual(value1 == static_cast<double>(1.1), false);
    XCTAssertEqual(value1 == true, false);
    XCTAssertEqual(value1 == false, false);
    XCTAssertEqual(value1 == "null", false);
    XCTAssertEqual(value1 == std::string("null"), false);
    value1.setString(std::string("toto"));
    XCTAssertEqual(value1 == "toto", true);
    XCTAssertEqual(value1 == std::string("toto"), true);
    XCTAssertEqual(value1 == nullptr, false);
    XCTAssertEqual(value1 == static_cast<short>(1), false);
    XCTAssertEqual(value1 == static_cast<int>(1), false);
    XCTAssertEqual(value1 == static_cast<long>(1), false);
    XCTAssertEqual(value1 == static_cast<float>(1.1), false);
    XCTAssertEqual(value1 == static_cast<double>(1.1), false);
    XCTAssertEqual(value1 == true, false);
    XCTAssertEqual(value1 == false, false);
    XCTAssertEqual(value1 == "null", false);
    XCTAssertEqual(value1 == std::string("null"), false);

    json::Document doc1(json::Kind::OBJECT);
    doc1["key1"] = "toto";
    value1.setObject(json::Document(std::move(doc1)));
    XCTAssertEqual(value1 == value1.getObject(), true);
    json::Document doc2(json::Kind::OBJECT);
    doc2["key1"] = "toto";
    XCTAssertEqual(value1 == doc2, true);
    doc2["key2"] = "tata";
    XCTAssertEqual(value1 == doc2, false);

    value1.getObject()["key2"] = "tata";
    value2.setObject(json::Document(std::move(doc2)));
    XCTAssertEqual(value1 == value2, true);

    value1.setNumber(1);
    value2.setNumber(1);
    XCTAssertEqual(value1 == value2, true);

    value1.setNumber(1.1);
    value2.setNumber(1.1);
    XCTAssertEqual(value1 == value2, true);

    value1.setString("toto");
    value2.setString("toto");
    XCTAssertEqual(value1 == value2, true);

    value1.setBoolean(true);
    value2.setBoolean(true);
    XCTAssertEqual(value1 == value2, true);

    value1.setBoolean(false);
    value2.setBoolean(false);
    XCTAssertEqual(value1 == value2, true);

    value1.setNull();
    value2.setNull();
    XCTAssertEqual(value1 == value2, true);


    json::Document value3;
    json::Document value4;
    json::Array doc3(json::Kind::ARRAY);
    doc3[0] = "toto";
    value3.setArray(json::Document(std::move(doc3)));
    XCTAssertEqual(value3 == value3.getArray(), true);
    json::Document doc4(json::Kind::ARRAY);
    doc4[0] = "toto";
    XCTAssertEqual(value3 == doc4, true);
    doc4[1] = "tata";
    XCTAssertEqual(value3 == doc4, false);

    value3.getArray()[1] = "tata";
    value4.setArray(json::Document(std::move(doc4)));
    XCTAssertEqual(value3 == value4, true);
}

- (void)testOperatorComparaisonNotEqualOverload {
    json::Document value1;

    value1.setNull();
    XCTAssertEqual(value1 != nullptr, false);
    XCTAssertEqual(value1 != 1, true);
    XCTAssertEqual(value1 != static_cast<short>(1), true);
    XCTAssertEqual(value1 != static_cast<int>(1), true);
    XCTAssertEqual(value1 != static_cast<long>(1), true);
    XCTAssertEqual(value1 != static_cast<float>(1.1), true);
    XCTAssertEqual(value1 != static_cast<double>(1.1), true);
    XCTAssertEqual(value1 != true, true);
    XCTAssertEqual(value1 != false, true);
    XCTAssertEqual(value1 != "null", true);
    XCTAssertEqual(value1 != std::string("null"), true);
    value1.setNumber(1);
    XCTAssertEqual(value1 != static_cast<short>(1), false);
    XCTAssertEqual(value1 != static_cast<int>(1), false);
    XCTAssertEqual(value1 != static_cast<long>(1), false);
    XCTAssertEqual(value1 != static_cast<float>(1.0), false);
    XCTAssertEqual(value1 != static_cast<double>(1.0), false);
    XCTAssertEqual(value1 != nullptr, true);
    XCTAssertEqual(value1 != static_cast<short>(2), true);
    XCTAssertEqual(value1 != static_cast<int>(2), true);
    XCTAssertEqual(value1 != static_cast<long>(2), true);
    XCTAssertEqual(value1 != static_cast<float>(2.0), true);
    XCTAssertEqual(value1 != static_cast<double>(2.0), true);
    XCTAssertEqual(value1 != true, true);
    XCTAssertEqual(value1 != false, true);
    XCTAssertEqual(value1 != "null", true);
    XCTAssertEqual(value1 != std::string("null"), true);
    value1.setNumber(1.1);
    XCTAssertEqual(value1 != static_cast<float>(1.1), false);
    XCTAssertEqual(value1 != static_cast<double>(1.1), false);
    XCTAssertEqual(value1 != nullptr, true);
    XCTAssertEqual(value1 != static_cast<short>(1), true);
    XCTAssertEqual(value1 != static_cast<int>(1), true);
    XCTAssertEqual(value1 != static_cast<long>(1), true);
    XCTAssertEqual(value1 != static_cast<float>(2.0), true);
    XCTAssertEqual(value1 != static_cast<double>(2.0), true);
    XCTAssertEqual(value1 != true, true);
    XCTAssertEqual(value1 != false, true);
    XCTAssertEqual(value1 != "null", true);
    XCTAssertEqual(value1 != std::string("null"), true);
    value1.setBoolean(true);
    XCTAssertEqual(value1 != true, false);
    XCTAssertEqual(value1 != nullptr, true);
    XCTAssertEqual(value1 != static_cast<short>(1), true);
    XCTAssertEqual(value1 != static_cast<int>(1), true);
    XCTAssertEqual(value1 != static_cast<long>(1), true);
    XCTAssertEqual(value1 != static_cast<float>(1.1), true);
    XCTAssertEqual(value1 != static_cast<double>(1.1), true);
    XCTAssertEqual(value1 != false, true);
    XCTAssertEqual(value1 != "null", true);
    XCTAssertEqual(value1 != std::string("null"), true);
    value1.setBoolean(false);
    XCTAssertEqual(value1 != false, false);
    XCTAssertEqual(value1 != nullptr, true);
    XCTAssertEqual(value1 != static_cast<short>(1), true);
    XCTAssertEqual(value1 != static_cast<int>(1), true);
    XCTAssertEqual(value1 != static_cast<long>(1), true);
    XCTAssertEqual(value1 != static_cast<float>(1.1), true);
    XCTAssertEqual(value1 != static_cast<double>(1.1), true);
    XCTAssertEqual(value1 != true, true);
    XCTAssertEqual(value1 != "null", true);
    XCTAssertEqual(value1 != std::string("null"), true);
    value1.setString("toto");
    XCTAssertEqual(value1 != "toto", false);
    XCTAssertEqual(value1 != std::string("toto"), false);
    XCTAssertEqual(value1 != nullptr, true);
    XCTAssertEqual(value1 != static_cast<short>(1), true);
    XCTAssertEqual(value1 != static_cast<int>(1), true);
    XCTAssertEqual(value1 != static_cast<long>(1), true);
    XCTAssertEqual(value1 != static_cast<float>(1.1), true);
    XCTAssertEqual(value1 != static_cast<double>(1.1), true);
    XCTAssertEqual(value1 != true, true);
    XCTAssertEqual(value1 != false, true);
    XCTAssertEqual(value1 != "null", true);
    XCTAssertEqual(value1 != std::string("null"), true);
    value1.setString(std::string("toto"));
    XCTAssertEqual(value1 != "toto", false);
    XCTAssertEqual(value1 != std::string("toto"), false);
    XCTAssertEqual(value1 != nullptr, true);
    XCTAssertEqual(value1 != static_cast<short>(1), true);
    XCTAssertEqual(value1 != static_cast<int>(1), true);
    XCTAssertEqual(value1 != static_cast<long>(1), true);
    XCTAssertEqual(value1 != static_cast<float>(1.1), true);
    XCTAssertEqual(value1 != static_cast<double>(1.1), true);
    XCTAssertEqual(value1 != true, true);
    XCTAssertEqual(value1 != false, true);
    XCTAssertEqual(value1 != "null", true);
    XCTAssertEqual(value1 != std::string("null"), true);

    json::Document doc1(json::Kind::OBJECT);
    doc1["key1"] = "toto";
    value1.setObject(json::Document(std::move(doc1)));
    XCTAssertEqual(value1 != value1.getObject(), false);
    json::Document doc2(json::Kind::OBJECT);
    doc2["key1"] = "toto";
    XCTAssertEqual(value1 != doc2, false);
    doc2["key2"] = "tata";
    XCTAssertEqual(value1 != doc2, true);
}

- (void)testCast {
    json::Document value1;

    value1.setNull();
    XCTAssertEqual(value1.getShort(), 0);
    XCTAssertEqual(value1.getInt(), 0);
    XCTAssertEqual(value1.getLong(), 0);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 0.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 0., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "null");
    XCTAssertEqual(value1.getBoolean(), false);
    XCTAssertEqual(value1.isNull(), true);

    value1.setNumber(1);
    XCTAssertEqual(value1.getShort(), 1);
    XCTAssertEqual(value1.getInt(), 1);
    XCTAssertEqual(value1.getLong(), 1);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 1.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 1., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "1");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setNumber(0);
    XCTAssertEqual(value1.getShort(), 0);
    XCTAssertEqual(value1.getInt(), 0);
    XCTAssertEqual(value1.getLong(), 0);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 0.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 0., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "0");
    XCTAssertEqual(value1.getBoolean(), false);
    XCTAssertEqual(value1.isNull(), false);

    const int shortMax = std::numeric_limits<short>::max();
    value1.setNumber(shortMax);
    XCTAssertEqual(value1.getShort(), shortMax);
    XCTAssertEqual(value1.getInt(), shortMax);
    XCTAssertEqual(value1.getLong(), shortMax);
    XCTAssertEqualWithAccuracy(value1.getFloat(), shortMax, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), shortMax, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), std::to_string(shortMax));
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setNumber(shortMax+1);
    const std::out_of_range* no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(value1.getInt(), shortMax+1);
    XCTAssertEqual(value1.getLong(), shortMax+1);
    XCTAssertEqualWithAccuracy(value1.getFloat(), shortMax+1, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), shortMax+1, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), std::to_string(shortMax+1));
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    const long intMax = std::numeric_limits<int>::max();
    value1.setNumber(intMax);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(value1.getInt(), intMax);
    XCTAssertEqual(value1.getLong(), intMax);
    XCTAssertEqualWithAccuracy(value1.getFloat(), intMax, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), intMax, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), std::to_string(intMax));
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setNumber(intMax+1);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getInt();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(value1.getLong(), intMax+1);
    XCTAssertEqualWithAccuracy(value1.getFloat(), intMax+1, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), intMax+1, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), std::to_string(intMax+1));
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    const long long longMax = std::numeric_limits<long>::max();
    value1.setNumber(longMax);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getInt();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(value1.getLong(), longMax);
    XCTAssertEqualWithAccuracy(value1.getFloat(), longMax, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), longMax, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), std::to_string(longMax));
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setNumber(9223372036854775808.);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getInt();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getLong();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 9223372036854775808., std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 9223372036854775808., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "9223372036854775808");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    const double maxFloat = std::numeric_limits<float>::max();
    value1.setNumber(maxFloat);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getInt();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getLong();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(value1.getFloat(), maxFloat, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), maxFloat, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "340282346638528859811704183484516925440");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    const double nextHighestFloat = maxFloat+std::abs(maxFloat)*std::numeric_limits<float>::epsilon();
    value1.setNumber(nextHighestFloat);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getInt();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getLong();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getFloat();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(value1.getDouble(), nextHighestFloat, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "340282387203345649263405802120670085120");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    const double maxDouble = std::numeric_limits<double>::max();
    value1.setNumber(maxDouble);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getInt();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getLong();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getFloat();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqualWithAccuracy(value1.getDouble(), maxDouble, std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    const long double nextHighestDouble = maxDouble+std::abs(maxDouble)*std::numeric_limits<double>::epsilon();
    value1.setNumber(nextHighestDouble);
    no = nullptr;
    try {
        value1.getShort();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getInt();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getLong();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getFloat();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    no = nullptr;
    try {
        value1.getDouble();
    } catch (const std::out_of_range& e) {
        no = &e;
    }
    XCTAssertNotEqual(no, nullptr);
    XCTAssertEqual(value1.getString(), "inf");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setString("toto");
    const std::invalid_argument* ia = nullptr;
    try {
        value1.getShort();
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        value1.getInt();
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        value1.getLong();
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        value1.getFloat();
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    ia = nullptr;
    try {
        value1.getDouble();
    } catch (const std::invalid_argument& e) {
        ia = &e;
    }
    XCTAssertNotEqual(ia, nullptr);
    XCTAssertEqual(value1.getString(), "toto");
    const json::BadValue* bv = nullptr;
    try {
        value1.getBoolean();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    XCTAssertEqual(value1.isNull(), false);

    value1.setString("true");
    XCTAssertEqual(value1.getShort(), 1);
    XCTAssertEqual(value1.getInt(), 1);
    XCTAssertEqual(value1.getLong(), 1);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 1.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 1., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "true");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setString("false");
    XCTAssertEqual(value1.getShort(), 0);
    XCTAssertEqual(value1.getInt(), 0);
    XCTAssertEqual(value1.getLong(), 0);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 0.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 0., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "false");
    XCTAssertEqual(value1.getBoolean(), false);
    XCTAssertEqual(value1.isNull(), false);

    value1.setString("null");
    XCTAssertEqual(value1.getShort(), 0);
    XCTAssertEqual(value1.getInt(), 0);
    XCTAssertEqual(value1.getLong(), 0);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 0.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 0., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "null");
    XCTAssertEqual(value1.getBoolean(), false);
    XCTAssertEqual(value1.isNull(), false);

    value1.setString("2");
    XCTAssertEqual(value1.getShort(), 2);
    XCTAssertEqual(value1.getInt(), 2);
    XCTAssertEqual(value1.getLong(), 2);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 2.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 2., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "2");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setString("-2");
    XCTAssertEqual(value1.getShort(), -2);
    XCTAssertEqual(value1.getInt(), -2);
    XCTAssertEqual(value1.getLong(), -2);
    XCTAssertEqualWithAccuracy(value1.getFloat(), -2.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), -2., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "-2");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setString("0");
    XCTAssertEqual(value1.getShort(), 0);
    XCTAssertEqual(value1.getInt(), 0);
    XCTAssertEqual(value1.getLong(), 0);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 0.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 0., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "0");
    XCTAssertEqual(value1.getBoolean(), false);
    XCTAssertEqual(value1.isNull(), false);

    value1.setBoolean(true);
    XCTAssertEqual(value1.getShort(), 1);
    XCTAssertEqual(value1.getInt(), 1);
    XCTAssertEqual(value1.getLong(), 1);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 1.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 1., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "true");
    XCTAssertEqual(value1.getBoolean(), true);
    XCTAssertEqual(value1.isNull(), false);

    value1.setBoolean(false);
    XCTAssertEqual(value1.getShort(), 0);
    XCTAssertEqual(value1.getInt(), 0);
    XCTAssertEqual(value1.getLong(), 0);
    XCTAssertEqualWithAccuracy(value1.getFloat(), 0.f, std::numeric_limits<float>::epsilon());
    XCTAssertEqualWithAccuracy(value1.getDouble(), 0., std::numeric_limits<double>::epsilon());
    XCTAssertEqual(value1.getString(), "false");
    XCTAssertEqual(value1.getBoolean(), false);
    XCTAssertEqual(value1.isNull(), false);

    json::Document value2;
    bv = nullptr;
    try {
        value2.getShort();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        value2.getInt();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        value2.getLong();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        value2.getFloat();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        value2.getDouble();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        value2.getString();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    bv = nullptr;
    try {
        value2.getBoolean();
    } catch (const json::BadValue& e) {
        bv = &e;
    }
    XCTAssertNotEqual(bv, nullptr);
    XCTAssertEqual(value2.isNull(), false);
}

- (void)testToto {
    json::Object toto(json::Kind::OBJECT);
    toto["key"] = json::Object(json::Kind::OBJECT);
    toto["key"]["key2"] = "tata";
}

@end
