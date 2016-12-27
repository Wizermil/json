//
// Document.cpp
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

#include "Document.hpp"

#include "exception/BadValue.hpp"
#include "exception/InvalidCharacter.hpp"

#include "context/ParseContext.hpp"
#include "context/ParseErrorContext.hpp"
#include "context/ParseStringContext.hpp"
#include "context/SerializeContext.hpp"

#include "std/OStringStream.hpp"
#include "std/Stringbuf.hpp"

#include <algorithm>
#include <cassert>
#include <cmath>
#include <fstream>
#include <limits>
#include <memory>
#include <sstream>
#include <stack>
#include <stdexcept>

using namespace json;
using namespace std;

Document::Document() : _type(Kind::UNKNOWN)
{
}

Document::Document(Kind type) : _type(type)
{
    switch (_type)
    {
        case Kind::ARRAY:
            new(&_array) std::vector<std::shared_ptr<Document>>();
            break;
        case Kind::OBJECT:
            new(&_object) std::unordered_map<std::string, std::shared_ptr<Document>>();
            break;
        case Kind::STRING:
            new(&_s) std::string();
            break;
        case Kind::UNKNOWN:
        case Kind::NUMBER:
        case Kind::NUMBER_FRAC:
        case Kind::VOID:
        case Kind::BOOLEAN:
            break;
    }
}

Document::~Document()
{
    clean();
}

Document::Document(const Document& other) : _type(Kind::UNKNOWN)
{
    *this = other;
}

Document& Document::operator =(const Document& other)
{
    if (_type == Kind::STRING && other._type == Kind::STRING)
        _s = other._s;
    else if (_type == Kind::OBJECT && other._type == Kind::OBJECT)
        _object = other._object;
    else if (_type == Kind::ARRAY && other._type == Kind::ARRAY)
        _array = other._array;
    else
    {
        clean();
        switch (other._type)
        {
            case Kind::STRING:
                new(&_s) std::string(other._s);
                break;
            case Kind::OBJECT:
                new(&_object) std::unordered_map<std::string, std::shared_ptr<Document>>(other._object);
                break;
            case Kind::ARRAY:
                new(&_array) std::vector<std::shared_ptr<Document>>(other._array);
                break;
            case Kind::NUMBER:
            case Kind::NUMBER_FRAC:
                _n = other._n;
                break;
            case Kind::BOOLEAN:
                _b = other._b;
                break;
            case Kind::UNKNOWN:
            case Kind::VOID:
                break;
        }
        _type = other._type;
    }
    return *this;
}

Document::Document(Document&& other) noexcept : _type(Kind::UNKNOWN)
{
    *this = std::move(other);
}

Document& Document::operator=(Document&& other) noexcept
{
    if (_type == Kind::STRING && other._type == Kind::STRING)
        _s = std::move(other._s);
    else if (_type == Kind::OBJECT && other._type == Kind::OBJECT)
        _object = std::move(other._object);
    else if (_type == Kind::ARRAY && other._type == Kind::ARRAY)
        _array = std::move(other._array);
    else
    {
        clean();
        switch (other._type)
        {
            case Kind::STRING:
                new(&_s) std::string(std::move(other._s));
                break;
            case Kind::OBJECT:
                new(&_object) std::unordered_map<std::string, std::shared_ptr<Document>>(std::move(other._object));
                break;
            case Kind::ARRAY:
                new(&_array) std::vector<std::shared_ptr<Document>>(std::move(other._array));
                break;
            case Kind::NUMBER:
            case Kind::NUMBER_FRAC:
                _n = other._n;
                break;
            case Kind::BOOLEAN:
                _b = other._b;
                break;
            case Kind::UNKNOWN:
            case Kind::VOID:
                break;
        }
        _type = other._type;
    }
    other._type = Kind::UNKNOWN;
    return *this;
}

void Document::setObject(const Object& val) noexcept
{
    assert(val._type == Kind::OBJECT);
    *this = val;
}

void Document::setObject(Object&& val) noexcept
{
    assert(val._type == Kind::OBJECT);
    *this = std::move(val);
}

void Document::setArray(const Array& val) noexcept
{
    assert(val._type == Kind::ARRAY);
    *this = val;
}

void Document::setArray(Array&& val) noexcept
{
    assert(val._type == Kind::ARRAY);
    *this = std::move(val);
}

void Document::setString(const std::string& val) noexcept
{
    if (_type == Kind::STRING)
        _s = val;
    else
    {
        clean();
        _type = Kind::STRING;
        new(&_s) std::string(val);
    }
}

void Document::setNumber(const long double val) noexcept
{
    clean();

    const long double ldVal = std::floor(val);
    if (ldVal > val || ldVal < val)
        _type = Kind::NUMBER_FRAC;
    else
        _type = Kind::NUMBER;
    _n = val;
}

void Document::setBoolean(bool val) noexcept
{
    clean();
    _type = Kind::BOOLEAN;
    _b = val;
}

void Document::setNull() noexcept
{
    clean();
    _type = Kind::VOID;
}

Kind Document::getType() const noexcept
{
    return _type;
}

std::size_t Document::getSize() const noexcept
{
    std::size_t ret = 0;
    switch(_type)
    {
        case Kind::OBJECT:
            ret = _object.size();
            break;
        case Kind::ARRAY:
            ret = _array.size();
            break;
        case Kind::UNKNOWN:
        case Kind::NUMBER:
        case Kind::NUMBER_FRAC:
        case Kind::VOID:
        case Kind::BOOLEAN:
        case Kind::STRING:
            break;
    }

    return ret;
}

void Document::clean() noexcept
{
    if (_type == Kind::STRING)
        _s.~string();
    else if (_type == Kind::OBJECT)
        _object.~unordered_map<std::string, std::shared_ptr<Document>>();
    else if (_type == Kind::ARRAY)
        _array.~vector<std::shared_ptr<Document>>();
}

short Document::getShort() const
{
    long double ret = 0;
    switch (_type)
    {
        case Kind::UNKNOWN:
        case Kind::OBJECT:
        case Kind::ARRAY:
            throw BadValue();
        case Kind::STRING:
        {
            std::string tmp(_s);
            std::transform(_s.begin(), _s.end(), tmp.begin(), ::tolower);
            if (tmp == "true")
                ret = 1;
            else if (tmp == "false" || tmp == "null")
                ret = 0;
            else
                ret = std::stold(_s);
            break;
        }
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            ret = _n;
            break;
        case Kind::BOOLEAN:
            ret = _b?1:0;
            break;
        case Kind::VOID:
            ret = 0;
            break;
    }
    if (ret < std::numeric_limits<short>::min() || ret > std::numeric_limits<short>::max())
        throw std::out_of_range("reach short limit");
    return static_cast<short>(ret);
}

short Document::getShortSafe(short def) const noexcept
{
    try
    {
        return getShort();
    }
    catch(...)
    {
    }
    return def;
}

int Document::getInt() const
{
    long double ret = 0;
    switch (_type)
    {
        case Kind::UNKNOWN:
        case Kind::OBJECT:
        case Kind::ARRAY:
            throw BadValue();
        case Kind::STRING:
        {
            std::string tmp(_s);
            std::transform(_s.begin(), _s.end(), tmp.begin(), ::tolower);
            if (tmp == "true")
                ret = 1;
            else if (tmp == "false" || tmp == "null")
                ret = 0;
            else
                ret = std::stold(_s);
            break;
        }
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            ret = _n;
            break;
        case Kind::BOOLEAN:
            ret = _b?1:0;
            break;
        case Kind::VOID:
            ret = 0;
            break;
    }
    if (ret < std::numeric_limits<int>::min() || ret > std::numeric_limits<int>::max())
        throw std::out_of_range("reach int limit");
    return static_cast<int>(ret);
}

int Document::getIntSafe(int def) const noexcept
{
    try
    {
        return getInt();
    }
    catch(...)
    {
    }
    return def;
}

long Document::getLong() const
{
    long double ret = 0;
    switch (_type)
    {
        case Kind::UNKNOWN:
        case Kind::OBJECT:
        case Kind::ARRAY:
            throw BadValue();
        case Kind::STRING:
        {
            std::string tmp(_s);
            std::transform(_s.begin(), _s.end(), tmp.begin(), ::tolower);
            if (tmp == "true")
                ret = 1;
            else if (tmp == "false" || tmp == "null")
                ret = 0;
            else
                ret = std::stold(_s);
            break;
        }
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            ret = _n;
            break;
        case Kind::BOOLEAN:
            ret = _b?1:0;
            break;
        case Kind::VOID:
            ret = 0;
            break;
    }
    if (ret < std::numeric_limits<long>::min() || ret > std::numeric_limits<long>::max())
        throw std::out_of_range("reach long limit");
    return static_cast<long>(ret);
}

long Document::getLongSafe(long def) const noexcept
{
    try
    {
        return getLong();
    }
    catch(...)
    {
    }
    return def;
}

long long Document::getLongLong() const
{
    long double ret = 0;
    switch (_type)
    {
        case Kind::UNKNOWN:
        case Kind::OBJECT:
        case Kind::ARRAY:
            throw BadValue();
        case Kind::STRING:
        {
            std::string tmp(_s);
            std::transform(_s.begin(), _s.end(), tmp.begin(), ::tolower);
            if (tmp == "true")
                ret = 1;
            else if (tmp == "false" || tmp == "null")
                ret = 0;
            else
                ret = std::stold(_s);
            break;
        }
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            ret = _n;
            break;
        case Kind::BOOLEAN:
            ret = _b?1:0;
            break;
        case Kind::VOID:
            ret = 0;
            break;
    }
    if (ret < std::numeric_limits<long long>::min() || ret > std::numeric_limits<long long>::max())
        throw std::out_of_range("reach long long limit");
    return static_cast<long long>(ret);
}

long long Document::getLongLongSafe(long long def) const noexcept
{
    try
    {
        return getLongLong();
    }
    catch(...)
    {
    }
    return def;
}

float Document::getFloat() const
{
    long double ret = 0;
    switch (_type)
    {
        case Kind::UNKNOWN:
        case Kind::OBJECT:
        case Kind::ARRAY:
            throw BadValue();
        case Kind::STRING:
        {
            std::string tmp(_s);
            std::transform(_s.begin(), _s.end(), tmp.begin(), ::tolower);
            if (tmp == "true")
                ret = 1;
            else if (tmp == "false" || tmp == "null")
                ret = 0;
            else
                ret = std::stold(_s);
            break;
        }
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            ret = _n;
            break;
        case Kind::BOOLEAN:
            ret = _b?1:0;
            break;
        case Kind::VOID:
            ret = 0;
            break;
    }
    if (ret < static_cast<long double>(std::numeric_limits<float>::lowest()) || ret > static_cast<long double>(std::numeric_limits<float>::max()))
        throw std::out_of_range("reach float limit");
    return static_cast<float>(ret);
}

float Document::getFloatSafe(float def) const noexcept
{
    try
    {
        return getFloat();
    }
    catch(...)
    {
    }
    return def;
}

double Document::getDouble() const
{
    long double ret = 0;
    switch (_type)
    {
        case Kind::UNKNOWN:
        case Kind::OBJECT:
        case Kind::ARRAY:
            throw BadValue();
        case Kind::STRING:
        {
            std::string tmp(_s);
            std::transform(_s.begin(), _s.end(), tmp.begin(), ::tolower);
            if (tmp == "true")
                ret = 1;
            else if (tmp == "false" || tmp == "null")
                ret = 0;
            else
                ret = std::stold(_s);
            break;
        }
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            ret = _n;
            break;
        case Kind::BOOLEAN:
            ret = _b?1:0;
            break;
        case Kind::VOID:
            ret = 0;
            break;
    }
    if (ret < static_cast<long double>(std::numeric_limits<double>::lowest()) || ret > static_cast<long double>(std::numeric_limits<double>::max()))
        throw std::out_of_range("reach double limit");
    return static_cast<double>(ret);
}

double Document::getDoubleSafe(double def) const noexcept
{
    try
    {
        return getDouble();
    }
    catch(...)
    {
    }
    return def;
}

std::string Document::getString() const
{
    std::string ret("");
    switch (_type)
    {
        case Kind::UNKNOWN:
            throw BadValue();
        case Kind::OBJECT:
        case Kind::ARRAY:
            ret = serialize();
            break;
        case Kind::STRING:
            ret = _s;
            break;
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            ret = removeTraillingZero(_n);
            break;
        case Kind::BOOLEAN:
            ret = _b?"true":"false";
            break;
        case Kind::VOID:
            ret = "null";
            break;
    }
    return ret;
}

std::string Document::getStringSafe(const std::string& def) const noexcept
{
    try
    {
        return getString();
    }
    catch(...)
    {
    }
    return def;
}

bool Document::getBoolean() const
{
    bool ret = false;
    switch (_type)
    {
        case Kind::VOID:
            break;
        case Kind::UNKNOWN:
        case Kind::OBJECT:
        case Kind::ARRAY:
            throw BadValue();
        case Kind::STRING:
        {
            std::string tmp(_s);
            std::transform(_s.begin(), _s.end(), tmp.begin(), ::tolower);
            if (tmp == "true")
                ret = true;
            else if (tmp == "false" || tmp == "null")
                ret = false;
            else
            {
                try
                {
                    if (std::abs(std::stold(_s)) < std::numeric_limits<long double>::epsilon())
                        ret = false;
                    else
                        ret = true;
                }
                catch(...)
                {
                    throw BadValue();
                }
            }
            break;
        }
        case Kind::NUMBER_FRAC:
        case Kind::NUMBER:
            if (std::abs(_n) < std::numeric_limits<long double>::epsilon())
                ret = false;
            else
                ret = true;
            break;
        case Kind::BOOLEAN:
            ret = _b;
            break;
    }
    return ret;
}

bool Document::getBooleanSafe(bool def) const noexcept
{
    try
    {
        return getBoolean();
    }
    catch(...)
    {
    }
    return def;
}

Object& Document::getObject() const
{
    if (_type == Kind::OBJECT)
        return const_cast<Object&>(*this);
    else
        throw BadValue();
}

Object& Document::getObjectSafe(const Object& def) const noexcept
{
    try
    {
        return getObject();
    }
    catch(...)
    {
    }
    return const_cast<Object&>(def);
}

Array& Document::getArray() const
{
    if (_type == Kind::ARRAY)
        return const_cast<Array&>(*this);
    else
        throw BadValue();
}

Array& Document::getArraySafe(const Array& def) const noexcept
{
    try
    {
        return getArray();
    }
    catch(...)
    {
    }
    return const_cast<Array&>(def);
}

bool Document::isNull() const noexcept
{
    bool ret = false;
    if (_type == Kind::VOID)
        ret = true;
    return ret;
}

short Document::getShortAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getShort();
    }
    else
        throw BadValue();
}

int Document::getIntAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getInt();
    }
    else
        throw BadValue();
}

long Document::getLongAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getLong();
    }
    else
        throw BadValue();
}

long long Document::getLongLongAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getLongLong();
    }
    else
        throw BadValue();
}

float Document::getFloatAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getFloat();
    }
    else
        throw BadValue();
}

double Document::getDoubleAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getDouble();
    }
    else
        throw BadValue();
}

std::string Document::getStringAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getString();
    }
    else
        throw BadValue();
}

bool Document::getBooleanAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getBoolean();
    }
    else
        throw BadValue();
}

Object& Document::getObjectAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getObject();
    }
    else
        throw BadValue();
}

Array& Document::getArrayAt(std::size_t index) const
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        return _array[index]->getArray();
    }
    else
        throw BadValue();
}

bool Document::isNullAt(std::size_t index) const
{
    bool ret(true);
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        ret = _array[index]->isNull();
    }
    else
        throw BadValue();
    return ret;
}

void Document::removeAt(std::size_t index)
{
    if (_type == Kind::ARRAY)
    {
        if (index >= _array.size())
            throw std::out_of_range("wrong index");
        _array.erase(_array.begin() + index);
    }
    else
        throw BadValue();
}

short Document::getShortSafeAt(std::size_t index, short def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getShortSafe(def);
    else
        return def;
}

int Document::getIntSafeAt(std::size_t index, int def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getIntSafe(def);
    else
        return def;
}

long Document::getLongSafeAt(std::size_t index, long def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getLongSafe(def);
    else
        return def;
}

long long Document::getLongLongSafeAt(std::size_t index, long long def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getLongLongSafe(def);
        else
            return def;
}

float Document::getFloatSafeAt(std::size_t index, float def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getFloatSafe(def);
    else
        return def;
}

double Document::getDoubleSafeAt(std::size_t index, double def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getDoubleSafe(def);
    else
        return def;
}

std::string Document::getStringSafeAt(std::size_t index, const std::string& def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getStringSafe(def);
    else
        return def;
}

bool Document::getBooleanSafeAt(std::size_t index, bool def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getBooleanSafe(def);
    else
        return def;
}

Object& Document::getObjectSafeAt(std::size_t index, const Object& def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getObjectSafe(def);
    else
        return const_cast<Object&>(def);
}

Array& Document::getArraySafeAt(std::size_t index, const Array& def) const noexcept
{
    if (_type == Kind::ARRAY && index < _array.size())
        return _array[index]->getArraySafe(def);
    else
        return const_cast<Array&>(def);
}

short Document::getShortFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getShort();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

int Document::getIntFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getInt();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

long Document::getLongFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getLong();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

long long Document::getLongLongFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getLongLong();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

float Document::getFloatFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getFloat();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

double Document::getDoubleFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getDouble();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

std::string Document::getStringFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getString();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

bool Document::getBooleanFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getBoolean();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

Object& Document::getObjectFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getObject();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

Array& Document::getArrayFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getArray();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

bool Document::isNullFrom(const std::string& key) const
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->isNull();
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

bool Document::hasMember(const std::string& key) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return true;
    }
    return false;
}

void Document::removeFrom(const std::string& key)
{
    if (_type == Kind::OBJECT)
    {
        auto it = _object.find(key);
        if (it != _object.end())
            _object.erase(it);
        else
            throw std::out_of_range("wrong key");
    }
    else
        throw BadValue();
}

short Document::getShortSafeFrom(const std::string& key, short def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getShortSafe(def);
    }
    return def;
}

int Document::getIntSafeFrom(const std::string& key, int def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getIntSafe(def);
    }
    return def;
}

long Document::getLongSafeFrom(const std::string& key, long def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getLongSafe(def);
    }
    return def;
}

long long Document::getLongLongSafeFrom(const std::string& key, long long def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getLongLongSafe(def);
    }
    return def;
}

float Document::getFloatSafeFrom(const std::string& key, float def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getFloatSafe(def);
    }
    return def;
}

double Document::getDoubleSafeFrom(const std::string& key, double def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getDoubleSafe(def);
    }
    return def;
}

std::string Document::getStringSafeFrom(const std::string& key, const std::string& def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getStringSafe(def);
    }
    return def;
}

bool Document::getBooleanSafeFrom(const std::string& key, bool def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getBooleanSafe(def);
    }
    return def;
}

Object& Document::getObjectSafeFrom(const std::string& key, const Object& def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getObjectSafe(def);
    }
    return const_cast<Object&>(def);
}

Array& Document::getArraySafeFrom(const std::string& key, const Array& def) const noexcept
{
    if (_type == Kind::OBJECT)
    {
        const auto& it = _object.find(key);
        if (it != _object.end())
            return it->second->getArraySafe(def);
    }
    return const_cast<Array&>(def);
}

Document& Document::operator[](std::size_t index)
{
    if (_type == Kind::UNKNOWN)
    {
        new(&_array) std::vector<std::shared_ptr<Document>>();
        _type = Kind::ARRAY;
    }
    if (_type == Kind::ARRAY)
    {
        if (index == _array.size())
            _array.emplace_back(std::make_shared<Document>());
        if (index > _array.size())
            throw std::out_of_range("wrong index");
        return *_array[index];
    }
    else
        throw BadValue();
}

Document& Document::operator[](const std::string& key)
{
    if (_type == Kind::UNKNOWN)
    {
        new(&_object) std::unordered_map<std::string, std::shared_ptr<Document>>();
        _type = Kind::OBJECT;
    }
    if (_type == Kind::OBJECT)
    {
        auto ret = _object.emplace(std::piecewise_construct,  std::forward_as_tuple(key), std::forward_as_tuple(std::make_shared<Document>()));
        return *ret.first->second;
    }
    else
        throw BadValue();
}

std::string Document::removeTraillingZero(long double n) const noexcept
{
    std::ostringstream buffer("", std::ios::ate);
    buffer.precision(std::numeric_limits<long double>::digits10);
    buffer << std::fixed << n;
    std::string ret(buffer.str());
    ret.erase(ret.find_last_not_of('0')+1, std::string::npos);
    if (ret.back() == '.')
        ret.pop_back();
    return ret;
}

void Document::pushBackArray(const short val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setNumber(val);
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setNumber(val);
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const int val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it;
            for (it = _array.rbegin(); it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setNumber(val);
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setNumber(val);
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const long val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setNumber(val);
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setNumber(val);
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const long long val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setNumber(val);
                return;
            }
        }
        
        auto newValue = std::make_shared<Document>();
        newValue->setNumber(val);
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const float val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setNumber(static_cast<long double>(val));
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setNumber(static_cast<long double>(val));
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const double val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setNumber(static_cast<long double>(val));
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setNumber(static_cast<long double>(val));
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const char* val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setString(val);
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setString(val);
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const std::string& val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setString(val);
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setString(val);
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const bool val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setBoolean(val);
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setBoolean(val);
        _array.emplace_back(std::move(newValue));
    }
}
void Document::pushBackArray(const std::nullptr_t val) noexcept
{
    if (_type == Kind::ARRAY)
    {
        if (_array.size() > 0)
        {
            std::vector<std::shared_ptr<Document>>::reverse_iterator it = _array.rbegin();
            for (; it != _array.rend(); ++it)
            {
                if (it->get()->_type != Kind::UNKNOWN)
                {
                    break;
                }
            }
            if (it != _array.rbegin())
            {
                (--it)->get()->setNull();
                return;
            }
        }

        auto newValue = std::make_shared<Document>();
        newValue->setNull();
        _array.emplace_back(std::move(newValue));
    }
}

Document& Document::operator =(const short val)
{
    setNumber(val);
    return *this;
}

Document& Document::operator =(const int val)
{
    setNumber(val);
    return *this;
}

Document& Document::operator =(const long val)
{
    setNumber(val);
    return *this;
}
    
Document& Document::operator =(const long long val)
{
    setNumber(val);
    return *this;
}

Document& Document::operator =(const float val)
{
    setNumber(static_cast<long double>(val));
    return *this;
}

Document& Document::operator =(const double val)
{
    setNumber(static_cast<long double>(val));
    return *this;
}

Document& Document::operator =(const char* val)
{
    setString(val);
    return *this;
}

Document& Document::operator =(const std::string& val)
{
    setString(val);
    return *this;
}

Document& Document::operator =(const bool val)
{
    setBoolean(val);
    return *this;
}

Document& Document::operator =(const std::nullptr_t)
{
    setNull();
    return *this;
}

bool Document::operator ==(const short val) const
{
    bool ret(false);
    if (_type == Kind::NUMBER && std::abs(_n-val) < std::numeric_limits<long double>::epsilon())
        ret = true;
    return ret;
}

bool Document::operator ==(const int val) const
{
    bool ret(false);
    if (_type == Kind::NUMBER && std::abs(_n-val) < std::numeric_limits<long double>::epsilon())
        ret = true;
    return ret;
}

bool Document::operator ==(const long val) const
{
    bool ret(false);
    if (_type == Kind::NUMBER && std::abs(_n-val) < std::numeric_limits<long double>::epsilon())
        ret = true;
    return ret;
}
    
bool Document::operator ==(const long long val) const
{
    bool ret(false);
    if (_type == Kind::NUMBER && std::abs(_n-val) < std::numeric_limits<long double>::epsilon())
        ret = true;
    return ret;
}

bool Document::operator ==(const float val) const
{
    bool ret(false);
    if ((_type == Kind::NUMBER || _type == Kind::NUMBER_FRAC) && std::abs(static_cast<float>(_n)-val) < std::numeric_limits<float>::epsilon())
        ret = true;
    return ret;
}

bool Document::operator ==(const double val) const
{
    bool ret(false);
    if ((_type == Kind::NUMBER || _type == Kind::NUMBER_FRAC) && std::abs(static_cast<double>(_n)-val) < std::numeric_limits<double>::epsilon())
        ret = true;
    return ret;
}

bool Document::operator ==(const char* val) const
{
    bool ret(false);
    if (_type == Kind::STRING && val == _s)
        ret = true;
    return ret;
}

bool Document::operator ==(const std::string& val) const
{
    bool ret(false);
    if (_type == Kind::STRING && val == _s)
        ret = true;
    return ret;
}

bool Document::operator ==(const bool val) const
{
    bool ret(false);
    if (_type == Kind::BOOLEAN && val == _b)
        ret = true;
    return ret;
}

bool Document::operator ==(const std::nullptr_t) const
{
    bool ret(false);
    if (_type == Kind::VOID)
        ret = true;
    return ret;
}

bool Document::operator ==(const Document& val) const
{
    bool ret(false);
    if (_type == val._type)
    {
        switch (_type) {
            case Kind::BOOLEAN:
                ret = (_b == val._b);
                break;
            case Kind::STRING:
                ret = (_s == val._s);
                break;
            case Kind::NUMBER_FRAC:
            case Kind::NUMBER:
                ret = (std::abs(_n-val._n) < std::numeric_limits<long double>::epsilon());
                break;
            case Kind::ARRAY:
                ret = _array.size() == val._array.size() && std::equal(_array.begin(), _array.end(), val._array.begin(), [](const std::shared_ptr<Document>& i, const std::shared_ptr<Document>& j) {
                    return *i == *j;
                });
                break;
            case Kind::OBJECT:
            {
                if (_object.size() == val._object.size())
                {
                    for (std::unordered_map<std::string, std::shared_ptr<Document>>::const_iterator i = _object.begin(), ex = _object.end(), ey = val._object.end(); i != ex; ++i)
                    {
                        std::unordered_map<std::string, std::shared_ptr<Document>>::const_iterator j = val._object.find(i->first);
                        if (j == ey || !(*i->second == *j->second))
                        {
                            ret = true;
                            break;
                        }
                    }
                    ret = !ret; // Check 4 lines above to understand this line. It's just to not introduce an extra temp variable and keep only 1 return by method/function.
                }
                break;
            }
            case Kind::UNKNOWN:
            case Kind::VOID:
                ret = true;
                break;
        }
    }
    return ret;
}

bool Document::operator !=(const Document& val) const
{
    return !(*this == val);
}

std::string Document::serialize() const
{
    OStringStream ret("", std::ios::ate);
    OStringStream buffer("", std::ios::ate);

    SerializeContext current;
    current.type = _type;
    if (_type == Kind::OBJECT)
    {
        current.itObject = _object.begin();
        current.endObject = _object.end();

        for (const auto& itTmp : _object)
        {
            if (itTmp.second->_type == Kind::UNKNOWN)
            {
                ++current.unknownTypeCount;
            }
        }
    }
    else if (_type == Kind::ARRAY)
    {
        current.itArray = _array.begin();
        current.endArray = _array.end();
        for (const auto& itTmp : _array)
        {
            if (itTmp->_type == Kind::UNKNOWN)
            {
                ++current.unknownTypeCount;
            }
        }
    }
    current.doc = this;

    std::stack<std::unique_ptr<SerializeContext>> stack;
    bool breakLoop = false;

    if (current.type == Kind::OBJECT)
        ret << '{';
    else if (current.type == Kind::ARRAY)
        ret << '[';

    do
    {
        if (current.type == Kind::OBJECT)
        {
            if (current.doc->_object.begin() != current.itObject && (current.doc->_object.size()-current.unknownTypeCount) > 1 && ++current.valueCount < (current.doc->_object.size()-current.unknownTypeCount))
                ret << ',';
            breakLoop = false;
            for (auto& it = current.itObject; it != current.endObject; it++)
            {
                switch (it->second->_type)
                {
                    case Kind::UNKNOWN:
                        continue;
                    case Kind::OBJECT:
                    case Kind::ARRAY:
                    {
                        ret << '"';
                        writeEscapeCharForJSON(ret, it->first);
                        ret << '"' << ':';

                        SerializeContext c;
                        c.type = it->second->_type;
                        if (c.type == Kind::OBJECT)
                        {
                            ret << '{';
                            c.itObject = it->second->_object.begin();
                            c.endObject = it->second->_object.end();

                            for (const auto& itTmp : it->second->_object)
                            {
                                if (itTmp.second->_type == Kind::UNKNOWN)
                                {
                                    c.unknownTypeCount++;
                                }
                            }
                        }
                        else if (c.type == Kind::ARRAY)
                        {
                            ret << '[';
                            c.itArray = it->second->_array.begin();
                            c.endArray = it->second->_array.end();

                            for (const auto& itTmp : it->second->_array)
                            {
                                if (itTmp->_type == Kind::UNKNOWN)
                                {
                                    c.unknownTypeCount++;
                                }
                            }
                        }
                        c.doc = it->second.get();

                        it++;
                        stack.push(std::make_unique<SerializeContext>(std::move(current)));
                        current = std::move(c);
                        breakLoop = true;
                        break;
                    }
                    case Kind::STRING:
                        ret << '"';
                        writeEscapeCharForJSON(ret, it->first);
                        ret << '"' << ':' << '"';
                        writeEscapeCharForJSON(ret, it->second->getString());
                        ret << '"';
                        break;
                    case Kind::NUMBER:
                    case Kind::NUMBER_FRAC:
                        ret << '"';
                        writeEscapeCharForJSON(ret, it->first);
                        ret << '"' << ':' << it->second->getString();
                        break;
                    case Kind::BOOLEAN:
                        ret << '"';
                        writeEscapeCharForJSON(ret, it->first);
                        ret << '"' << ':' << (it->second->getBoolean()?"true":"false");
                        break;
                    case Kind::VOID:
                        ret << '"';
                        writeEscapeCharForJSON(ret, it->first);
                        ret << '"' << ':' << "null";
                        break;
                }
                if (breakLoop)
                    break;
                if ((current.doc->_object.size()-current.unknownTypeCount) > 1 && ++current.valueCount < (current.doc->_object.size()-current.unknownTypeCount))
                    ret << ',';
            }
        }
        else if (current.type == Kind::ARRAY)
        {
            if (current.doc->_array.begin() != current.itArray && (current.doc->_array.size()-current.unknownTypeCount) > 1 && ++current.valueCount < (current.doc->_array.size()-current.unknownTypeCount))
                ret << ',';
            breakLoop = false;
            for (auto& it = current.itArray; it != current.endArray; it++)
            {
                switch ((*it)->_type)
                {
                    case Kind::UNKNOWN:
                        continue;
                    case Kind::OBJECT:
                    case Kind::ARRAY:
                    {
                        SerializeContext c;
                        c.type = (*it)->_type;
                        if (c.type == Kind::OBJECT)
                        {
                            ret << '{';
                            c.itObject = (*it)->_object.begin();
                            c.endObject = (*it)->_object.end();

                            for (const auto& itTmp : (*it)->_object)
                            {
                                if (itTmp.second->_type == Kind::UNKNOWN)
                                {
                                    c.unknownTypeCount++;
                                }
                            }
                        }
                        else if (c.type == Kind::ARRAY)
                        {
                            ret << '[';
                            c.itArray = (*it)->_array.begin();
                            c.endArray = (*it)->_array.end();

                            for (const auto& itTmp : (*it)->_array)
                            {
                                if (itTmp->_type == Kind::UNKNOWN)
                                {
                                    c.unknownTypeCount++;
                                }
                            }
                        }
                        c.doc = (*it).get();

                        it++;
                        stack.push(std::make_unique<SerializeContext>(std::move(current)));
                        current = std::move(c);
                        breakLoop = true;
                        break;
                    }
                    case Kind::STRING:
                        ret << '"';
                        writeEscapeCharForJSON(ret, (*it)->getString());
                        ret << '"';
                        break;
                    case Kind::NUMBER:
                    case Kind::NUMBER_FRAC:
                        ret << (*it)->getString();
                        break;
                    case Kind::BOOLEAN:
                        ret << ((*it)->getBoolean()?"true":"false");
                        break;
                    case Kind::VOID:
                        ret << "null";
                        break;
                }
                if (breakLoop)
                    break;
                if ((current.doc->_array.size()-current.unknownTypeCount) > 1 && ++current.valueCount < (current.doc->_array.size()-current.unknownTypeCount))
                    ret << ',';
            }
        }

        if (current.type == Kind::OBJECT && current.itObject == current.endObject)
        {
            ret << '}';

            while (!stack.empty() && ((current.type == Kind::OBJECT && current.itObject == current.endObject) || (current.type == Kind::ARRAY && current.itArray == current.endArray)))
            {
                current = std::move(*stack.top());
                stack.pop();

                if (current.type == Kind::OBJECT && current.itObject == current.endObject)
                    ret << '}';
                else if (current.type == Kind::ARRAY && current.itArray == current.endArray)
                    ret << ']';
            }
        }
        else if (current.type == Kind::ARRAY && current.itArray == current.endArray)
        {
            ret << ']';

            while (!stack.empty() && ((current.type == Kind::OBJECT && current.itObject == current.endObject) || (current.type == Kind::ARRAY && current.itArray == current.endArray)))
            {
                current = std::move(*stack.top());
                stack.pop();

                if (current.type == Kind::OBJECT && current.itObject == current.endObject)
                    ret << '}';
                else if (current.type == Kind::ARRAY && current.itArray == current.endArray)
                    ret << ']';
            }
        }
    } while(!stack.empty() || ((current.type == Kind::OBJECT && current.itObject != current.endObject) || (current.type == Kind::ARRAY && current.itArray != current.endArray)));

    return ret.str();
}

void Document::deserialize(const std::string& data, Encoding enc)
{
    Stringbuf buf(data, std::ios::in);
    std::istream is(&buf);

    ParseErrorContext errorCtx;
    errorCtx.stream = &is;
    errorCtx.enc = enc;
    errorCtx.filename = "";

    deserialize(errorCtx);
}

void Document::deserialize(const std::string& data, const Kind def, Encoding enc) noexcept
{
    assert(def == Kind::ARRAY || def == Kind::OBJECT);
    try
    {
        deserialize(data, enc);
    }
    catch(...)
    {
        clean();
        switch (def)
        {
            case Kind::ARRAY:
                new(&_array) std::vector<std::shared_ptr<Document>>();
                break;
            case Kind::OBJECT:
                new(&_object) std::unordered_map<std::string, std::shared_ptr<Document>>();
                break;
            case Kind::UNKNOWN:
            case Kind::NUMBER:
            case Kind::NUMBER_FRAC:
            case Kind::VOID:
            case Kind::BOOLEAN:
            case Kind::STRING:
                break;
        }
    }
}

void Document::deserializeFromPath(const std::string& path, Encoding enc)
{
    std::ifstream is(path, std::ios::in|std::ios::binary);

    ParseErrorContext errorCtx;
    errorCtx.stream = &is;
    errorCtx.enc = enc;
    errorCtx.filename = path;
    
    deserialize(errorCtx);
}

void Document::deserializeFromPath(const std::string& path, const Kind def, Encoding enc) noexcept
{
    try
    {
        deserializeFromPath(path, enc);
    }
    catch(...)
    {
        clean();
        switch (def)
        {
            case Kind::ARRAY:
                new(&_array) std::vector<std::shared_ptr<Document>>();
                break;
            case Kind::OBJECT:
                new(&_object) std::unordered_map<std::string, std::shared_ptr<Document>>();
                break;
            case Kind::STRING:
                new(&_s) std::string();
                break;
            case Kind::UNKNOWN:
            case Kind::NUMBER:
            case Kind::NUMBER_FRAC:
            case Kind::VOID:
            case Kind::BOOLEAN:
                break;
        }
    }
}

bool Document::operator !=(const std::nullptr_t val) const
{
    return !(*this == val);
}

bool Document::operator !=(const short val) const
{
    return !(*this == val);
}

bool Document::operator !=(const int val) const
{
    return !(*this == val);
}

bool Document::operator !=(const long b) const
{
    return !(*this == b);
}
    
bool Document::operator !=(const long long b) const
{
    return !(*this == b);
}

bool Document::operator !=(const float val) const
{
    return !(*this == val);
}

bool Document::operator !=(const double val) const
{
    return !(*this == val);
}

bool Document::operator !=(const char* val) const
{
    return !(*this == val);
}

bool Document::operator !=(const std::string& val) const
{
    return !(*this == val);
}

bool Document::operator !=(const bool val) const
{
    return !(*this == val);
}

std::vector<std::shared_ptr<Document>>::iterator Document::beginArray()
{
    if (_type == Kind::ARRAY)
        return _array.begin();
    else
        throw BadValue();
}

std::vector<std::shared_ptr<Document>>::const_iterator Document::beginArray() const
{
    if (_type == Kind::ARRAY)
        return _array.begin();
    else
        throw BadValue();
}

std::vector<std::shared_ptr<Document>>::iterator Document::endArray()
{
    if (_type == Kind::ARRAY)
        return _array.end();
    else
        throw BadValue();
}

std::vector<std::shared_ptr<Document>>::const_iterator Document::endArray() const
{
    if (_type == Kind::ARRAY)
        return _array.end();
    else
        throw BadValue();
}

std::unordered_map<std::string, std::shared_ptr<Document>>::iterator Document::beginObject()
{
    if (_type == Kind::OBJECT)
        return _object.begin();
    else
        throw BadValue();
}

std::unordered_map<std::string, std::shared_ptr<Document>>::const_iterator Document::beginObject() const
{
    if (_type == Kind::OBJECT)
        return _object.begin();
    else
        throw BadValue();
}

std::unordered_map<std::string, std::shared_ptr<Document>>::iterator Document::endObject()
{
    if (_type == Kind::OBJECT)
        return _object.end();
    else
        throw BadValue();
}

std::unordered_map<std::string, std::shared_ptr<Document>>::const_iterator Document::endObject() const
{
    if (_type == Kind::OBJECT)
        return _object.end();
    else
        throw BadValue();
}

void Document::deserialize(ParseErrorContext& errorCtx)
{
    // Cleanup the memory if you are using the same document multiple json data.
    if (_type == Kind::OBJECT)
        _object.~unordered_map<std::string, std::shared_ptr<Document>>();
    else if (_type == Kind::ARRAY)
        _array.~vector<std::shared_ptr<Document>>();
    _type = Kind::UNKNOWN;

    if (errorCtx.stream->good())
    {
        std::uint32_t previousChar = 0; // Required to detect new line and check cooherence in char flow
        std::uint32_t c = 0; // current code point /!\ Real value no UTF-X

        OStringStream buffer("", std::ios::ate); // Buffer to extract or convert string to the right format

        // Context required to keep track of elements during the parsing
        ParseContext ctx;
        std::stack<std::unique_ptr<ParseContext>> stack; // Required for nested JSON Document or Array
        ParseStringContext stringCtx;
        ParseContext::StateNumber stateNumber = ParseContext::StateNumber::DIGIT;

        for (c = nextChar(errorCtx.stream, &errorCtx, errorCtx.enc);!errorCtx.stream->eof() && errorCtx.stream->good();c = nextChar(errorCtx.stream, &errorCtx, errorCtx.enc))
        {
            errorCtx.column++;

            switch(ctx.state)
            {
                case ParseContext::State::UNKNOWN: // Looking for hints about the json
                {
                    if (!isInsignificantWhitespace(c)) // it can only be { or [
                    {
                        Document* doc = this;
                        if (ctx.doc._type != Kind::UNKNOWN)
                            doc = &ctx.doc;
                        switch (c)
                        {
                            case '{':
                            {
                                ctx.state = ParseContext::State::OBJECT_START;
                                doc->_type = Kind::OBJECT;
                                new(&doc->_object) std::unordered_map<std::string, std::shared_ptr<Document>>();
                                break;
                            }
                            case '[':
                            {
                                ctx.state = ParseContext::State::ARRAY_START;
                                doc->_type = Kind::ARRAY;
                                new(&doc->_array) std::vector<std::shared_ptr<Document>>();
                                break;
                            }
                            default:
                                throw InvalidCharacter("JSON payload should an object or array", &errorCtx);
                        }
                    }
                    break;
                }
                case ParseContext::State::OBJECT_START:
                case ParseContext::State::ARRAY_START:
                {
                    // If it's an Object we need it's key first
                    if (ctx.state == ParseContext::State::OBJECT_START && (ctx.keyState != ParseContext::StateKey::KEY_VALID))
                    {
                        switch (ctx.keyState)
                        {
                            case ParseContext::StateKey::UNKNOWN:
                            {
                                if (!isInsignificantWhitespace(c)) // So it can only be \" or the
                                {
                                    switch (c)
                                    {
                                        case '\"':
                                            stringCtx.reset();
                                            ctx.keyState = ParseContext::StateKey::KEY_START;
                                            break;
                                        case '}':
                                            ctx.state = ParseContext::State::OBJECT_END;
                                            break;
                                        default:
                                            throw InvalidCharacter("Expect double quote(\") to start a new key or curly bracket(}) to end the object.", &errorCtx);
                                    }
                                }
                                break;
                            }
                            case ParseContext::StateKey::KEY_START:
                            {
                                if (stringCtx.count == 0 && c == '"') // End of the key string
                                {
                                    if (stringCtx.surrogate > 0) // Surrogate UTF-16 can't be truncated
                                        throw InvalidCharacter("Unexpected end of string in the middle of UTF-16 surrogate character.", &errorCtx);
                                    ctx.key = buffer.str(); // We extract the key from the buffer.
                                    ctx.keyState = ParseContext::StateKey::KEY_END;
                                    // Reset the buffer for next value
                                    buffer.clear();
                                    buffer.seekp(std::ios::beg);
                                }
                                else
                                    parseString(previousChar, c, stringCtx, buffer, errorCtx);
                                break;
                            }
                            case ParseContext::StateKey::KEY_END:
                                if (!isInsignificantWhitespace(c))
                                {
                                    if (c == ':')
                                    {
                                        ++ctx.colonCount;
                                        ctx.keyState = ParseContext::StateKey::KEY_VALID;
                                    }
                                    else
                                        throw InvalidCharacter("Expect colon(:) before the value.", &errorCtx);
                                }
                                break;
                            case ParseContext::StateKey::KEY_VALID: // You should never be able to reach this code.
                                break;
                        }
                    }
                    else // Extraction of the value
                    {
                        switch (ctx.valueState)
                        {
                            case ParseContext::StateValue::UNKNOWN: // Looking for hints about the value
                                if (!isInsignificantWhitespace(c)) // So it can only be \"-, [0-9], n for null, f for false, t for true, {, [, } or ]
                                {
                                    switch (c)
                                    {
                                        case '"':
                                            stringCtx.reset();
                                            ctx.valueState = ParseContext::StateValue::STRING;
                                            break;
                                        case '-':
                                            ctx.valueState = ParseContext::StateValue::NUMBER;
                                            stateNumber = ParseContext::StateNumber::SIGN;
                                            buffer << '-';
                                            break;
                                        case '0':
                                        case '1':
                                        case '2':
                                        case '3':
                                        case '4':
                                        case '5':
                                        case '6':
                                        case '7':
                                        case '8':
                                        case '9':
                                            ctx.valueState = ParseContext::StateValue::NUMBER;
                                            stateNumber = ParseContext::StateNumber::DIGIT;
                                            buffer << static_cast<char>(c);
                                            break;
                                        case 'n':
                                            ctx.valueState = ParseContext::StateValue::VOID;
                                            buffer << 'n';
                                            break;
                                        case 'f':
                                        case 't':
                                            ctx.valueState = ParseContext::StateValue::BOOLEAN;
                                            buffer << static_cast<char>(c);
                                            break;
                                        case '{':
                                        {
                                            stack.push(std::make_unique<ParseContext>(std::move(ctx)));
                                            ctx = ParseContext();
                                            ctx.state = ParseContext::State::OBJECT_START;
                                            ctx.doc = Object(Kind::OBJECT);
                                            break;
                                        }
                                        case '[':
                                        {
                                            stack.push(std::make_unique<ParseContext>(std::move(ctx)));
                                            ctx = ParseContext();
                                            ctx.state = ParseContext::State::ARRAY_START;
                                            ctx.doc = Array(Kind::ARRAY);
                                            break;
                                        }
                                        case ']':
                                            if (ctx.state == ParseContext::State::ARRAY_START)
                                                ctx.state = ParseContext::State::ARRAY_END;
                                            else
                                                throw InvalidCharacter("Expect curly bracket(}) to end an object.", &errorCtx);
                                            break;
                                        case '}':
                                            if (ctx.state == ParseContext::State::OBJECT_START)
                                                ctx.state = ParseContext::State::OBJECT_END;
                                            else
                                                throw InvalidCharacter("Expect square bracket(]) to end an array.", &errorCtx);
                                            break;
                                        default:
                                            throw InvalidCharacter("Invalid character to start a new value.", &errorCtx);
                                    }
                                }
                                break;
                            case ParseContext::StateValue::NEXT:
                                if (!isInsignificantWhitespace(c))
                                {
                                    switch (c)
                                    {
                                        case ',':
                                            ++ctx.commaCount;
                                            checkCommaCount(ctx, errorCtx);
                                            if (ctx.state == ParseContext::State::OBJECT_START)
                                                ctx.keyState = ParseContext::StateKey::UNKNOWN;
                                            ctx.valueState = ParseContext::StateValue::UNKNOWN;
                                            break;
                                        case ']':
                                            if (ctx.state == ParseContext::State::ARRAY_START)
                                                ctx.state = ParseContext::State::ARRAY_END;
                                            else
                                                throw InvalidCharacter("Expect curly bracket(}) to end an object.", &errorCtx);
                                            break;
                                        case '}':
                                            if (ctx.state == ParseContext::State::OBJECT_START)
                                                ctx.state = ParseContext::State::OBJECT_END;
                                            else
                                                throw InvalidCharacter("Expect square bracket(]) to end an array.", &errorCtx);
                                            break;
                                        default:
                                            throw InvalidCharacter("Invalid character to separate values.", &errorCtx);
                                    }
                                }
                                break;
                            case ParseContext::StateValue::STRING:
                            {
                                checkValidKey(ctx, errorCtx);
                                if (stringCtx.count == 0 && c == '"')
                                {
                                    if (stringCtx.surrogate > 0)
                                        throw InvalidCharacter("Unexpected end of string in the middle of UTF-16 surrogate character.", &errorCtx);
                                    Document val;
                                    val.setString(buffer.str());
                                    addValue(ctx, std::move(val), buffer, errorCtx);
                                    ctx.valueState = ParseContext::StateValue::NEXT;
                                }
                                else
                                {
                                    parseString(previousChar, c, stringCtx, buffer, errorCtx);
                                }
                                break;
                            }
                            case ParseContext::StateValue::NUMBER:
                            {
                                checkValidKey(ctx, errorCtx);
                                switch(previousChar)
                                {
                                    case '+':
                                    case '-':
                                    case '.':
                                        if (c < '0' || c > '9')
                                            throw InvalidCharacter("Expect a number([0-9]) after the signs: plus(+), minus(-) and dot(.).", &errorCtx);
                                        break;
                                    case 'e':
                                    case 'E':
                                        if (c != '+' && c != '-' && (c < '0' || c > '9'))
                                            throw InvalidCharacter("Expect a number([0-9]) or a sign either plus(+) or minus(-) after exponential(e or E).", &errorCtx);
                                        break;
                                    case '0':
                                        if (((buffer.tellp() == 1 && stateNumber == ParseContext::StateNumber::DIGIT) || (buffer.tellp() == 2 && stateNumber == ParseContext::StateNumber::SIGN)) && c != '.' && c != 'e' && c != 'E' && c != ',' && c != '}' && c != ']' && !isInsignificantWhitespace(c))
                                            throw InvalidCharacter("Expect dot(.) or exponential(e or E) or comma(,) after zero(0).", &errorCtx);
                                        break;
                                    default:
                                        break;
                                }

                                switch(c)
                                {
                                    case '0':
                                    case '1':
                                    case '2':
                                    case '3':
                                    case '4':
                                    case '5':
                                    case '6':
                                    case '7':
                                    case '8':
                                    case '9':
                                        buffer << static_cast<char>(c);
                                        break;
                                    case '+':
                                    case '-':
                                        if ((stateNumber & ParseContext::StateNumber::SIGN) == ParseContext::StateNumber::SIGN)
                                            throw InvalidCharacter("Unexpected minus(-) or plus(+).", &errorCtx);
                                        if ((buffer.tellp() == std::ios::beg && c == '-') || previousChar == 'e' || previousChar == 'E')
                                        {
                                            stateNumber |= ParseContext::StateNumber::SIGN;
                                            buffer << static_cast<char>(c);
                                        }
                                        else
                                            throw InvalidCharacter("Expect minus(-) at the begining of the number or after exponential(e or E).", &errorCtx);
                                        break;
                                    case '.':
                                        if ((stateNumber & ParseContext::StateNumber::FRAC) == ParseContext::StateNumber::FRAC)
                                            throw InvalidCharacter("Unexpected dot(.).", &errorCtx);
                                        if ((stateNumber & ParseContext::StateNumber::EXP) == ParseContext::StateNumber::EXP)
                                            throw InvalidCharacter("Unexpected dot(.).", &errorCtx);
                                        stateNumber |= ParseContext::StateNumber::FRAC;
                                        buffer << '.';
                                        break;
                                    case 'e':
                                    case 'E':
                                        if ((stateNumber & ParseContext::StateNumber::EXP) == ParseContext::StateNumber::EXP)
                                            throw InvalidCharacter("Unexpected exponential(e or E)", &errorCtx);
                                        stateNumber |= ParseContext::StateNumber::EXP;
                                        stateNumber &= ~ParseContext::StateNumber::SIGN; // Rest Flag to accept one sign + or -
                                        buffer << static_cast<char>(c);
                                        break;
                                    case '}': // Final Element of the Object
                                    {
                                        if (ctx.state == ParseContext::State::OBJECT_START)
                                        {
                                            Document val;
                                            val.setNumber(std::stold(buffer.str()));
                                            addValue(ctx, std::move(val), buffer, errorCtx);
                                            ctx.state = ParseContext::State::OBJECT_END;
                                            ctx.valueState = ParseContext::StateValue::UNKNOWN;
                                        }
                                        else
                                            throw InvalidCharacter("Expect square bracket(]) to end an array.", &errorCtx);
                                        break;
                                    }
                                    case ']': // Final Element of the Array
                                    {
                                        if (ctx.state == ParseContext::State::ARRAY_START)
                                        {
                                            Document val;
                                            val.setNumber(std::stold(buffer.str()));
                                            addValue(ctx, std::move(val), buffer, errorCtx);
                                            ctx.state = ParseContext::State::ARRAY_END;
                                            ctx.valueState = ParseContext::StateValue::UNKNOWN;
                                        }
                                        else
                                            throw InvalidCharacter("Expect curly bracket(}) to end an object.", &errorCtx);
                                        break;
                                    }
                                    case ' ':
                                    case '\t':
                                    case '\n':
                                    case '\r':
                                    {
                                        Document val;
                                        val.setNumber(std::stold(buffer.str()));
                                        addValue(ctx, std::move(val), buffer, errorCtx);
                                        ctx.valueState = ParseContext::StateValue::NEXT;
                                        break;
                                    }
                                    case ',':
                                    {
                                        Document val;
                                        val.setNumber(std::stold(buffer.str()));
                                        addValue(ctx, std::move(val), buffer, errorCtx);
                                        ++ctx.commaCount;
                                        checkCommaCount(ctx, errorCtx);
                                        if (ctx.state == ParseContext::State::OBJECT_START && ctx.keyState == ParseContext::StateKey::KEY_VALID)
                                            ctx.keyState = ParseContext::StateKey::UNKNOWN;
                                        ctx.valueState = ParseContext::StateValue::UNKNOWN;
                                        break;
                                    }
                                    default:
                                        throw InvalidCharacter("Invalid character to describe a number value.", &errorCtx);
                                }
                                break;
                            }
                            case ParseContext::StateValue::BOOLEAN:
                            {
                                checkValidKey(ctx, errorCtx);
                                if ((previousChar == 't' && c == 'r') || (previousChar == 'r' && c == 'u') || (previousChar == 'f' && c == 'a') || (previousChar == 'a' && c == 'l') || (previousChar == 'l' && c == 's'))
                                {
                                }
                                else if (previousChar == 'u' && c == 'e')
                                {
                                    Document val;
                                    val.setBoolean(true);
                                    addValue(ctx, std::move(val), buffer, errorCtx);
                                    ctx.valueState = ParseContext::StateValue::NEXT;
                                }
                                else if (previousChar == 's' && c == 'e')
                                {
                                    Document val;
                                    val.setBoolean(false);
                                    addValue(ctx, std::move(val), buffer, errorCtx);
                                    ctx.valueState = ParseContext::StateValue::NEXT;
                                }
                                else
                                    throw InvalidCharacter("Invalid character to describe a boolean value.", &errorCtx);
                                break;
                            }
                            case ParseContext::StateValue::VOID:
                            {
                                checkValidKey(ctx, errorCtx);
                                if ((previousChar == 'n' && c == 'u') || (previousChar == 'u' && c == 'l'))
                                {
                                }
                                else if (previousChar == 'l' && c == 'l')
                                {
                                    Document val;
                                    val.setNull();
                                    addValue(ctx, std::move(val), buffer, errorCtx);
                                    ctx.valueState = ParseContext::StateValue::NEXT;
                                }
                                else
                                    throw InvalidCharacter("Invalid character to describe a null value.", &errorCtx);
                                break;
                            }
                        }
                    }
                    break;
                }
                case ParseContext::State::OBJECT_END:
                case ParseContext::State::ARRAY_END:
                    if (!isInsignificantWhitespace(c))
                        throw InvalidCharacter("Invalid character after the end of object or array.", &errorCtx);
                    break;
            }

            switch(ctx.state)
            {
                case ParseContext::State::OBJECT_END:
                {
                    checkCommaCount(ctx, errorCtx);
                    checkColonCount(ctx, errorCtx);
                    if (stack.size() > 0)
                    {
                        Document val;
                        val.setObject(std::move(ctx.doc));
                        ctx = std::move(*stack.top());
                        stack.pop();
                        addValue(ctx, std::move(val), buffer, errorCtx);
                        ctx.valueState = ParseContext::StateValue::NEXT;
                    }
                    break;
                }
                case ParseContext::State::ARRAY_END:
                {
                    checkCommaCount(ctx, errorCtx);
                    checkColonCount(ctx, errorCtx);
                    if (stack.size() > 0)
                    {
                        Document val;
                        val.setArray(std::move(ctx.doc));
                        ctx = std::move(*stack.top());
                        stack.pop();
                        addValue(ctx, std::move(val), buffer, errorCtx);
                        ctx.valueState = ParseContext::StateValue::NEXT;
                    }
                    break;
                }
                case ParseContext::State::UNKNOWN:
                case ParseContext::State::ARRAY_START:
                case ParseContext::State::OBJECT_START:
                    break;
            }

            if (c == '\r' || (previousChar != '\r' && c == '\n')) // Compute line number for Windows, Mac and Unix
            {
                errorCtx.line++;
                errorCtx.column=0;
            }

            previousChar = c;
        }

        if (ctx.state == ParseContext::State::OBJECT_START)
            throw InvalidCharacter("Expect object to be closed.", &errorCtx);
        if (ctx.state == ParseContext::State::ARRAY_START)
            throw InvalidCharacter("Expect array to be closed.", &errorCtx);
    }
}

void Document::addValue(ParseContext& ctx, Document&& val, OStringStream& buffer, const ParseErrorContext& errorCtx)
{
    Document* doc = this;
    if (ctx.doc._type != Kind::UNKNOWN)
        doc = &ctx.doc;
    if (ctx.state == ParseContext::State::OBJECT_START)
    {
        if (ctx.keyState == ParseContext::StateKey::KEY_VALID)
        {
            if (doc->_object.find(ctx.key) != doc->_object.end())
                ctx.duplicatedKeys++;
            doc->_object[ctx.key] = std::make_shared<Document>(std::move(val));
        }
        else
            throw InvalidCharacter("Miss a valid key to add a value.", &errorCtx);
    }
    else
        doc->_array.emplace_back(std::make_shared<Document>(std::move(val)));

    buffer.clear();
    buffer.seekp(std::ios::beg);
}

void Document::checkValidKey(const json::ParseContext& ctx, const ParseErrorContext& errorCtx) const
{
    if (ctx.state == ParseContext::State::OBJECT_START && ctx.keyState != ParseContext::StateKey::KEY_VALID)
        throw InvalidCharacter("Invalid key.", &errorCtx);
}

void Document::checkColonCount(const ParseContext& ctx, const ParseErrorContext& errorCtx) const
{
    const Document* doc = this;
    if (ctx.doc._type != Kind::UNKNOWN)
        doc = &ctx.doc;
    if (ctx.state == ParseContext::State::OBJECT_END && ctx.colonCount > 0 && doc->_object.size() != (ctx.colonCount-ctx.duplicatedKeys))
        throw InvalidCharacter("Unexpected number of colons(:) and values.", &errorCtx);
}

void Document::checkCommaCount(const ParseContext& ctx, const ParseErrorContext& errorCtx) const
{
    const Document* doc = this;
    if (ctx.doc._type != Kind::UNKNOWN)
        doc = &ctx.doc;
    if (ctx.commaCount > 0 && ((ctx.state == ParseContext::State::ARRAY_END && doc->_array.size() != (ctx.commaCount+1)) || (ctx.state == ParseContext::State::OBJECT_END && doc->_object.size() != (ctx.commaCount-ctx.duplicatedKeys+1))))
        throw InvalidCharacter("Unexpected number of commas(,) and values.", &errorCtx);
}

std::uint32_t Document::nextChar(std::istream* stream, const ParseErrorContext* errorCtx, Encoding enc) const
{
    std::uint8_t unicodeCount = 0;
    std::istream::char_type ch = 0;
    std::uint8_t uCh = 0;
    std::uint32_t c = 0;

    for (stream->get(ch); !stream->eof() && stream->good(); stream->get(ch))
    {
        if (enc == Encoding::UTF8)
        {
            uCh = static_cast<std::uint8_t>(ch);
            if (unicodeCount == 0)
            {
                c = 0;
                if (uCh <= 0x7F)
                {
                    c = uCh;
                    unicodeCount = 0;
                }
                else if (uCh <= 0xDF)
                {
                    c = uCh & 0x1F;
                    c <<= 6;
                    unicodeCount = 1;
                }
                else if (uCh <= 0xEF)
                {
                    c = uCh & 0x0F;
                    c <<= 12;
                    unicodeCount = 2;
                }
                else if (uCh <= 0xFF)
                {
                    c = uCh & 0x07;
                    c <<= 18;
                    unicodeCount = 3;
                }
            }
            else if (uCh >= 0x80 && uCh <= 0xBF)
            {
                --unicodeCount;
                c |= static_cast<std::uint32_t>(0x003F & uCh) << (6*unicodeCount);
            }
            else
                throw InvalidCharacter("Invalid UTF-8 character.", errorCtx);
            if (unicodeCount == 0)
                break;
        }
        else if (enc == Encoding::UTF16)
        {
            if (unicodeCount == 0)
            {
                c = 0;
                c |= uCh;
                c <<= 8;
                unicodeCount=1;
            }
            else if (--unicodeCount == 0)
            {
                c |= uCh;
                if (c >= 0xD800 && c <= 0xDFFF)
                {
                    c &= 0x3FF;
                    c <<=10;
                    unicodeCount=3; // It's a nasty trick to avoid an extra variable for surrogate characters.
                }
            }
            else if (unicodeCount == 2)
            {
                std::uint16_t tmp = uCh;
                tmp &= 0x03;
                tmp <<= 8;
                c |= tmp;
            }
            else if (unicodeCount == 1)
            {
                c |= uCh;
                c |= 0x10000;
                unicodeCount=0;
            }
            if (unicodeCount == 0)
                break;
        }
        else if (enc == Encoding::UTF32)
        {
            if (unicodeCount == 0)
            {
                c = 0;
                c |= uCh;
                c <<= 24;
                unicodeCount=3;
            }
            else
            {
                unicodeCount--;
                std::uint32_t tmp = uCh;
                tmp <<= (unicodeCount*8);
                c |= tmp;
            }
            if (unicodeCount == 0)
                break;
        }
    }

    if (unicodeCount != 0)
        throw InvalidCharacter("Invalid UTF-X character.", errorCtx);

    return c;
}

void Document::writeChar(OStringStream& buffer, const std::uint32_t c) const noexcept
{
    if (c <= 0x7F)
        buffer << static_cast<char>(c);
    else if (c <= 0x7FF)
        buffer << static_cast<char>((0x1F & (c >> 6)) | 0xC0) << static_cast<char>((0x3F & c) | 0x80);
    else if (c <= 0xFFFF)
        buffer << static_cast<char>((0x0F & (c >> 12)) | 0xE0) << static_cast<char>((0x3F & (c >> 6)) | 0x80) << static_cast<char>((0x3F & c) | 0x80);
    else if (c <= 0x10FFFF)
        buffer << static_cast<char>((0x07 & (c >> 18)) | 0xF0) << static_cast<char>((0x3F & (c >> 12)) | 0x80) << static_cast<char>((0x3F & (c >> 6)) | 0x80) <<static_cast<char>((0x3F & c) | 0x80);
}

void Document::parseString(const std::uint32_t previousChar, const std::uint32_t c, ParseStringContext& stringCtx, OStringStream& buffer, const ParseErrorContext& errorCtx)
{
    if (stringCtx.surrogate > 0 && ((c != '\\' && stringCtx.count == 0) || (previousChar == '\\' && c != 'u' && stringCtx.count == 1)))
        throw InvalidCharacter("Unexpected character separating UTF-16 surrogate.", &errorCtx);
    else if(c == '\\' && stringCtx.count == 0)
        stringCtx.count = 1;
    else if (stringCtx.count == 1 && previousChar == '\\' && (c == '"' || c == '\\' || c == '/'))
    {
        stringCtx.count = 0;
        buffer << static_cast<char>(c);
    }
    else if (stringCtx.count == 1 && previousChar == '\\' && c == 'b')
    {
        stringCtx.count = 0;
        buffer << '\b';
    }
    else if (stringCtx.count == 1 && previousChar == '\\' && c == 'f')
    {
        stringCtx.count = 0;
        buffer << '\f';
    }
    else if (stringCtx.count == 1 && previousChar == '\\' && c == 'n')
    {
        stringCtx.count = 0;
        buffer << '\n';
    }
    else if (stringCtx.count == 1 && previousChar == '\\' && c == 'r')
    {
        stringCtx.count = 0;
        buffer << '\r';
    }
    else if (stringCtx.count == 1 && previousChar == '\\' && c == 't')
    {
        stringCtx.count = 0;
        buffer << '\t';
    }
    else if ((stringCtx.count > 0 && previousChar == '\\' && c == 'u') || stringCtx.count > 1)
    {
        if (stringCtx.count == 1)
            stringCtx.count++;
        else if (isHexadecimal(c))
        {
            stringCtx.charString[stringCtx.count-2] = static_cast<char>(c);
            stringCtx.count++;
            if (stringCtx.count == 6)
            {
                const std::uint16_t escapedNum = static_cast<std::uint16_t>(std::stoul(stringCtx.charString, 0, 16));
                if (escapedNum >= 0xD800 && escapedNum <= 0xDFFF)
                {
                    if (stringCtx.surrogate == 0) // high surrogate (1st 4 hex digits)
                    {
                        stringCtx.high = escapedNum;
                        stringCtx.surrogate = 1;
                    }
                    else // low surrogate (2nd 4 hex digits)
                    {
                        writeChar(buffer, (0x10000 | static_cast<std::uint32_t>(((stringCtx.high & 0x03FF) << 10) | (escapedNum & 0x03FF))));
                        stringCtx.surrogate = 0;
                    }
                    stringCtx.count = 0;
                }
                else if (stringCtx.surrogate > 0 && (escapedNum < 0xD800 || escapedNum > 0xDFFF))
                    throw InvalidCharacter("Invalid UTF-16 character.", &errorCtx);
                else
                {
                    writeChar(buffer, escapedNum);
                    stringCtx.count = 0;
                }
            }
        }
        else
            throw InvalidCharacter("Expect hexadecimal value([0-9A-Fa-f]).", &errorCtx);
    }
    else if (stringCtx.count == 1 && previousChar == '\\')
        throw InvalidCharacter("Invalid escaped character.", &errorCtx);
    else if (isControlCharacter(c))
        throw InvalidCharacter("Unexpected control character.", &errorCtx);
    else
        writeChar(buffer, c);
}

bool Document::isHexadecimal(const std::uint32_t c) const noexcept
{
    bool ret = false;
    if ((c >= '0' && c <= '9')||(c>='A' && c <= 'F')||(c >= 'a' && c <= 'f'))
        ret = true;
    return ret;
}

bool Document::isControlCharacter(const std::uint32_t c) const noexcept
{
    bool ret = false;
    if (c<= 0x1F || c == 0x7F || (c >= 0x80 && c <= 0x9F))
        ret = true;
    
    return ret;
}

bool Document::isInsignificantWhitespace(const std::uint32_t c) const noexcept
{
    bool ret = false;
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
        ret = true;
    
    return ret;
}

void Document::writeEscapeCharForJSON(OStringStream& buffer, const std::string& u8) const
{
    Stringbuf buf(u8, std::ios::in);
    std::istream data(&buf);
    
    for (auto c = nextChar(&data, nullptr, Encoding::UTF8); !data.eof() && data.good(); c = nextChar(&data, nullptr, Encoding::UTF8))
    {
        switch(c)
        {
            case '"':
            case '\\':
            case '/':
                buffer << '\\' << static_cast<char>(c);
                break;
            case '\b':
                buffer << '\\' << 'b';
                break;
            case '\f':
                buffer << '\\' << 'f';
                break;
            case '\n':
                buffer << '\\' << 'n';
                break;
            case '\r':
                buffer << '\\' << 'r';
                break;
            case '\t':
                buffer << '\\' << 't';
                break;
            default:
                writeChar(buffer, c);
                break;
        }
    }
}
