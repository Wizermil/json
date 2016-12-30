//
// Document.hpp
// json
//
// Created by Mathieu Garaud on 22/07/16.
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

#pragma once

#include <cstddef>
#include <cstdint>
#include <istream>
#include <iterator>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>
#include <stack>

namespace json
{

    struct ParseContext;
    struct ParseStringContext;
    struct ParseErrorContext;
    class Stringbuf;
    class OStringStream;
    class Document;
    typedef Document Object;
    typedef Document Array;

    enum struct Encoding : std::uint8_t
    {
        UTF8,
        UTF16,
        UTF32,
    };

    enum struct Kind : std::uint8_t
    {
        UNKNOWN,
        OBJECT,
        ARRAY,
        STRING,
        NUMBER,
        NUMBER_FRAC,
        BOOLEAN,
        VOID
    };

    class Document
    {
    public:
        Document();
        Document(Kind type);
        Document(Document&& other) noexcept;
        Document& operator =(Document&& other) noexcept;
        Document(const Document& other);
        Document& operator =(const Document& other);
        ~Document();

        void setObject(Object&& val) noexcept;
        void setObject(const Object& val) noexcept;
        void setArray(Array&& val) noexcept;
        void setArray(const Array& val) noexcept;
        void setString(const std::string& val) noexcept;
        void setNumber(const long double val) noexcept;
        void setBoolean(bool val) noexcept;
        void setNull() noexcept;

        Kind getType() const noexcept;

        /**
         Cast values to short if it can otherwise throw.

         - Throws:
         `json::BadValue` if we can't convert the value to short: UNKNOWN, OBJECT and ARRAY.
         `json::NumberOverflow` if the short value is greater than what a short value can store.
         `std::invalid_argument` if there is a STRING conversion issue due to std::stold.
         `std::out_of_range` if there is a STRING conversion issue due to std::stold.

         Returns: a short representation of the value.
         */
        short getShort() const;
        short getShortSafe(short def = -1) const noexcept;
        /**
         Cast values to int if it can otherwise throw.

         - Throws:
         `json::BadValue` if we can't convert the value to short: UNKNOWN, OBJECT and ARRAY.
         `json::NumberOverflow` if the short value is greater than what a short value can store.
         `std::invalid_argument` if there is a STRING conversion issue due to std::stold.
         `std::out_of_range` if there is a STRING conversion issue due to std::stold.

         Returns: a int representation of the value.
         */
        int getInt() const;
        int getIntSafe(int def = -1) const noexcept;
        /**
         Cast values to long if it can otherwise throw.

         - Throws:
         `json::BadValue` if we can't convert the value to short: UNKNOWN, OBJECT and ARRAY.
         `json::NumberOverflow` if the short value is greater than what a short value can store.
         `std::invalid_argument` if there is a STRING conversion issue due to std::stold.
         `std::out_of_range` if there is a STRING conversion issue due to std::stold.

         Returns: a long representation of the value.
         */
        long getLong() const;
        long getLongSafe(long def = -1) const noexcept;
        /**
         Cast values to long long if it can otherwise throw.
         
         - Throws:
         `json::BadValue` if we can't convert the value to short: UNKNOWN, OBJECT and ARRAY.
         `json::NumberOverflow` if the short value is greater than what a short value can store.
         `std::invalid_argument` if there is a STRING conversion issue due to std::stold.
         `std::out_of_range` if there is a STRING conversion issue due to std::stold.
         
         Returns: a long representation of the value.
         */
        long long getLongLong() const;
        long long getLongLongSafe(long long def = -1) const noexcept;
        /**
         Cast values to float if it can otherwise throw.

         - Throws:
         `json::BadValue` if we can't convert the value to short: UNKNOWN, OBJECT and ARRAY.
         `json::NumberOverflow` if the short value is greater than what a short value can store.
         `std::invalid_argument` if there is a STRING conversion issue due to std::stold.
         `std::out_of_range` if there is a STRING conversion issue due to std::stold.

         Returns: a float representation of the value.
         */
        float getFloat() const;
        float getFloatSafe(float def = -1) const noexcept;
        /**
         Cast values to double if it can otherwise throw.

         - Throws:
         `json::BadValue` if we can't convert the value to short: UNKNOWN, OBJECT and ARRAY.
         `json::NumberOverflow` if the short value is greater than what a short value can store.
         `std::invalid_argument` if there is a STRING conversion issue due to std::stold.
         `std::out_of_range` if there is a STRING conversion issue due to std::stold.

         Returns: a double representation of the value.
         */
        double getDouble() const;
        double getDoubleSafe(double def = -1) const noexcept;
        /**
         Cast values to std::string if it can otherwise throw.

         - Throws:
         `json::BadValue` if we can't convert the value to short: UNKNOWN.
         `json::InvalidCharacter` if there is an issue when creating OBJECT or ARRAY string.

         Returns: a std::string representation of the value.
         */
        std::string getString() const;
        std::string getStringSafe(const std::string& def = "") const noexcept;
        bool getBoolean() const;
        bool getBooleanSafe(bool def = false) const noexcept;
        Object& getObject() const;
        Object& getObjectSafe(const Object& def = json::Object(Kind::OBJECT)) const noexcept;
        Array& getArray() const;
        Array& getArraySafe(const Array& def = json::Array(Kind::ARRAY)) const noexcept;
        bool isNull() const noexcept;

        std::size_t getSize() const noexcept;

        short getShortAt(std::size_t index) const;
        short getShortSafeAt(std::size_t index, short def = -1) const noexcept;
        int getIntAt(std::size_t index) const;
        int getIntSafeAt(std::size_t index, int def = -1) const noexcept;
        long getLongAt(std::size_t index) const;
        long getLongSafeAt(std::size_t index, long def = -1) const noexcept;
        long long getLongLongAt(std::size_t index) const;
        long long getLongLongSafeAt(std::size_t index, long long def = -1) const noexcept;
        float getFloatAt(std::size_t index) const;
        float getFloatSafeAt(std::size_t index, float def = -1) const noexcept;
        double getDoubleAt(std::size_t index) const;
        double getDoubleSafeAt(std::size_t index, double def = -1) const noexcept;
        std::string getStringAt(std::size_t index) const;
        std::string getStringSafeAt(std::size_t index, const std::string& def = "") const noexcept;
        bool getBooleanAt(std::size_t index) const;
        bool getBooleanSafeAt(std::size_t index, bool def = false) const noexcept;
        Object& getObjectAt(std::size_t index) const;
        Object& getObjectSafeAt(std::size_t index, const Object& def = Object(Kind::OBJECT)) const noexcept;
        Array& getArrayAt(std::size_t index) const;
        Array& getArraySafeAt(std::size_t index, const Array& def = Array(Kind::ARRAY)) const noexcept;
        bool isNullAt(std::size_t index) const;
        void removeAt(std::size_t index);

        void pushBackArray(const short val) noexcept;
        void pushBackArray(const int val) noexcept;
        void pushBackArray(const long val) noexcept;
        void pushBackArray(const long long val) noexcept;
        void pushBackArray(const float val) noexcept;
        void pushBackArray(const double val) noexcept;
        void pushBackArray(const char* val) noexcept;
        void pushBackArray(const std::string& val) noexcept;
        void pushBackArray(const bool val) noexcept;
        void pushBackArray(const std::nullptr_t val) noexcept;


        Document& operator[](std::size_t key);

        short getShortFrom(const std::string& key) const;
        short getShortSafeFrom(const std::string& key, short def = -1) const noexcept;
        int getIntFrom(const std::string& key) const;
        int getIntSafeFrom(const std::string& key, int def = -1) const noexcept;
        long getLongFrom(const std::string& key) const;
        long getLongSafeFrom(const std::string& key, long def = -1) const noexcept;
        long long getLongLongFrom(const std::string& key) const;
        long long getLongLongSafeFrom(const std::string& key, long long def = -1) const noexcept;
        float getFloatFrom(const std::string& key) const;
        float getFloatSafeFrom(const std::string& key, float def = -1) const noexcept;
        double getDoubleFrom(const std::string& key) const;
        double getDoubleSafeFrom(const std::string& key, double def = -1) const noexcept;
        std::string getStringFrom(const std::string& key) const;
        std::string getStringSafeFrom(const std::string& key, const std::string& def = "") const noexcept;
        bool getBooleanFrom(const std::string& key) const;
        bool getBooleanSafeFrom(const std::string& key, bool def = false) const noexcept;
        Object& getObjectFrom(const std::string& key) const;
        Object& getObjectSafeFrom(const std::string& key, const Object& def = Object(Kind::OBJECT)) const noexcept;
        Array& getArrayFrom(const std::string& key) const;
        Array& getArraySafeFrom(const std::string& key, const Array& def = Array(Kind::ARRAY)) const noexcept;
        bool isNullFrom(const std::string& key) const;
        bool hasMember(const std::string& key) const noexcept;
        void removeFrom(const std::string& key);

        Document& operator[](const std::string& key);

        std::string serialize() const;

        void deserialize(const std::string& data, Encoding enc = Encoding::UTF8);
        void deserialize(const std::string& data, const Document& def, Encoding enc = Encoding::UTF8) noexcept;
        void deserializeFromPath(const std::string& path, Encoding enc = Encoding::UTF8);
        void deserializeFromPath(const std::string& path, const Document& def, Encoding enc = Encoding::UTF8) noexcept;

        std::vector<std::shared_ptr<Document>>::iterator beginArray();
        std::vector<std::shared_ptr<Document>>::const_iterator beginArray() const;
        std::vector<std::shared_ptr<Document>>::iterator endArray();
        std::vector<std::shared_ptr<Document>>::const_iterator endArray() const;

        std::unordered_map<std::string, std::shared_ptr<Document>>::iterator beginObject();
        std::unordered_map<std::string, std::shared_ptr<Document>>::const_iterator beginObject() const;
        std::unordered_map<std::string, std::shared_ptr<Document>>::iterator endObject();
        std::unordered_map<std::string, std::shared_ptr<Document>>::const_iterator endObject() const;

        Document& operator =(const short val);
        Document& operator =(const int val);
        Document& operator =(const long val);
        Document& operator =(const long long val);
        Document& operator =(const float val);
        Document& operator =(const double val);
        Document& operator =(const char* val);
        Document& operator =(const std::string& val);
        Document& operator =(const bool val);
        Document& operator =(const std::nullptr_t val);

        /**
         Used to easily compare Document or Document.

         - Parameters:
            - b: second Document to compare to.

         Returns: a boolean if the values are equal.
         */
        bool operator ==(const Document& val) const;
        bool operator !=(const Document& val) const;

        bool operator ==(const short val) const;
        bool operator ==(const int val) const;
        bool operator ==(const long val) const;
        bool operator ==(const long long val) const;
        bool operator ==(const float val) const;
        bool operator ==(const double val) const;
        bool operator ==(const char* val) const;
        bool operator ==(const std::string& val) const;
        bool operator ==(const bool val) const;
        bool operator ==(const std::nullptr_t val) const;

        bool operator !=(const short val) const;
        bool operator !=(const int val) const;
        bool operator !=(const long val) const;
        bool operator !=(const long long val) const;
        bool operator !=(const float val) const;
        bool operator !=(const double val) const;
        bool operator !=(const char* val) const;
        bool operator !=(const std::string& val) const;
        bool operator !=(const bool val) const;
        bool operator !=(const std::nullptr_t val) const;

    private:
        /**
         Placement Delete of the Document or string depending of the Kind of value stotred.
         */
        void clean() noexcept;
        /**
         Remove trailling zeros for decimal numbers.

         - Parameters:
            - n: decimal long double number.

         Returns: a string without trailling zeros.
         */
        std::string removeTraillingZero(long double n) const noexcept;
        /**
         Parse a stream representing JSON to a std::vector or std::unordered_map depending of the nature of the data.

         - Parameters:
         - stream: The stream to parse.
         - enc: Encoding of the stream (default: UTF-8)

         - Throws:
         `json::InvalidCharacter` if there is an unexpected character.
         `std::invalid_argument` if there is a problem extracting number using std::stod.
         `std::out_of_range` if there is a problem extracting number using std::stod.
         */
        void deserialize(ParseErrorContext& errorCtx);
        /**
         Add json::Document (string, number, boolean, null) to the underliying storage: std::vector or std::unordered_map.

         - Parameters:
         - ctx: Context in charge of storing parsing information.
         - val: Struct to save string, number, boolean or null.
         - buffer: Buffer used to extract values.
         - errorCtx: Context used to throw exception with maximun details.

         - Throws:
         `json::InvalidCharacter` if you try to add value without a valid key.
         */
        void addValue(ParseContext* ctx, Document&& val, OStringStream& buffer, const ParseErrorContext& errorCtx);
        /**
         Check that a key is specified before parsing a value.

         - Parameters:
         - ctx: Context in charge of storing parsing information.
         - errorCtx: Context used to throw exception with maximun details.

         - Throws:
         `json::InvalidCharacter` if you try to add value without a valid key.
         */
        void checkValidKey(const ParseContext* ctx, const ParseErrorContext& errorCtx) const;
        /**
         Check that the number of colon match the number of keys in the std::unordered_map.

         - Parameters:
         - ctx: Context in charge of storing parsing information.
         - errorCtx: Context used to throw exception with maximun details.

         - Throws:
         `json::InvalidCharacter` if you try to add value without a valid key.
         */
        void checkColonCount(const ParseContext* ctx, const ParseErrorContext& errorCtx) const;
        /**
         Check that the number of comma match the number of values in the std::vector or std::unordered_map.

         - Parameters:
         - ctx: Context in charge of storing parsing information.
         - errorCtx: Context used to throw exception with maximun details.

         - Throws:
         `json::InvalidCharacter` if you try to add value without a valid key.
         */
        void checkCommaCount(const ParseContext* ctx, const ParseErrorContext& errorCtx) const;
        /**
         Check that the character is a control character (https://en.wikipedia.org/wiki/Unicode_control_characters).

         - Parameters:
         - c: 32bit code point of the character to check.

         - Returns: `true` if it's a control character.
         */
        bool isControlCharacter(const std::uint32_t c) const noexcept;
        /**
         Check that the character is insignificant based on RFC7159 (https://tools.ietf.org/html/rfc7159).

         - Parameters:
         - c: 32bit code point of the character to check.

         - Returns: `true` if it's Space or Horizontal tab or Line feed or New line or Carriage return.
         */
        bool isInsignificantWhitespace(const std::uint32_t c) const noexcept;
        /**
         Convert a 32bit character to it's UTF-8 representation and add it to the buffer.

         - Parameters:
         - buffer: Buffer used to save UTF-8 character.
         - c: 32bit code point of the character to convert to UTF-8.

         - Throws:
         `json::InvalidCharacter` if the character is greater than 0x10FFFF.
         */
        void writeChar(OStringStream& buffer, const std::uint32_t c) const noexcept;
        /**
         Parse string value taking into account escaped character including UTF-16.

         - Parameters:
         - ctx: Context in charge of storing parsing information.
         - previousChar: 32bit code point of the previous character.
         - c: 32bit code point of the character.
         - stringCtx: Context used to properly extract string.
         - buffer: Buffer used to extract values.
         - errorCtx: Context used to throw exception with maximun details.

         - Throws:
         `json::InvalidCharacter` if during the parsing we find wrongly escaped characters or errors with surrogates.
         `std::invalid_argument` if there is a problem during the parsing of escaped 4 hex digits
         `std::out_of_range` if there is a problem during the parsing of escaped 4 hex digits
         */
        void parseString(const std::uint32_t previousChar, const std::uint32_t c, ParseStringContext& stringCtx, OStringStream& buffer, const ParseErrorContext& errorCtx);
        /**
         Decode any UTF-X characters to std::uint32_t based on the decoding selected.

         - Parameters:
         - stream: The stream to parse.
         - errorCtx: Context used to throw exception with maximun details.
         - enc: Encoding of the stream (default: UTF-8)

         - Throws:
         `json::InvalidCharacter` if we are not able to decode the characters due to incompatibilities.
         */
        std::uint32_t nextChar(std::istream* stream, const ParseErrorContext* errorCtx, Encoding enc) const;

        /**
         Write UTF-8 string escaping quotation mark, reverse solidus, solidus, backspace, formfeed, newline, carriage return, horizontal tab to be compliant with JSON definition of string.

         - Parameters:
         - buffer: Buffer used to write the string.
         - u8: the UTF-8 key or string value that could contained characters that must be escaped.

         - Returns: a string with the escaped values.
         */
        void writeEscapeCharForJSON(OStringStream& buffer, const std::string& u8) const;


        ParseContext* findValueKind(std::uint32_t c, std::stack<std::unique_ptr<ParseContext>>& stack, ParseStringContext& stringCtx, OStringStream& buffer, ParseErrorContext& errorCtx);
        
        bool isHexadecimal(const std::uint32_t c) const noexcept;
    private:
        Kind _type;
        union {
            std::vector<std::shared_ptr<Document>> _array;
            std::unordered_map<std::string, std::shared_ptr<Document>> _object;
            std::string _s; // Store the string value.
            long double _n; // Store number value.
            bool _b; // Store bolean value.
        };
    };
}
