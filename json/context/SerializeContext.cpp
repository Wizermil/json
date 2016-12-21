//
// SerializeContext.cpp
// json
//
// Created by Mathieu Garaud on 16/10/16.
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

#include "SerializeContext.hpp"

#include "../Document.hpp"

using namespace json;

SerializeContext::SerializeContext() : type(Kind::UNKNOWN)
, doc(nullptr)
, valueCount(0)
, unknownTypeCount(0)
{
}

SerializeContext::SerializeContext(SerializeContext&& other) noexcept : type(Kind::UNKNOWN)
, doc(nullptr)
, valueCount(0)
, unknownTypeCount(0)
{
    *this = std::move(other);
}

SerializeContext& SerializeContext::operator =(SerializeContext&& other) noexcept
{
    if (type == other.type)
    {
        if (type == Kind::OBJECT)
        {
            itObject = std::move(other.itObject);
            endObject = std::move(other.endObject);
        }
        else if (type == Kind::ARRAY)
        {
            itArray = std::move(other.itArray);
            endArray = std::move(other.endArray);
        }
    }
    else
    {
        if (type == Kind::OBJECT)
        {
            itObject.~iterator_object();
            endObject.~iterator_object();
        }
        else if (type == Kind::ARRAY)
        {
            itArray.~iterator_array();
            endArray.~iterator_array();
        }

        if (other.type == Kind::OBJECT)
        {
            new (&itObject) iterator_object(std::move(other.itObject));
            new (&endObject) iterator_object(std::move(other.endObject));
        }
        else if (other.type == Kind::ARRAY)
        {
            new (&itArray) iterator_array(std::move(other.itArray));
            new (&endArray) iterator_array(std::move(other.endArray));
        }
        type = other.type;
    }
    other.type = Kind::UNKNOWN;
    doc = std::move(other.doc);
    other.doc = nullptr;
    valueCount = other.valueCount;
    unknownTypeCount = other.unknownTypeCount;
    other.valueCount = 0;
    other.unknownTypeCount = 0;
    return *this;
}

SerializeContext::~SerializeContext()
{
    if (type == Kind::OBJECT)
    {
        itObject.~iterator_object();
        endObject.~iterator_object();
    }
    else if (type == Kind::ARRAY)
    {
        itArray.~iterator_array();
        endArray.~iterator_array();
    }
    doc = nullptr;
    valueCount = 0;
}
