//
// ParseContext.cpp
// json
//
// Created by Mathieu Garaud on 24/07/16.
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

#include "ParseContext.hpp"

using namespace json;

ParseContext::ParseContext(ParseContextValue kind) : type(kind)
{
    switch(type)
    {
        case ParseContextValue::OBJECT:
            new(&objCtx) ParseObjectContext();
            break;
        case ParseContextValue::ARRAY:
            new(&arrCtx) ParseArrayContext();
            break;
        case ParseContextValue::STRING:
        case ParseContextValue::NUMBER:
        case ParseContextValue::BOOLEAN:
        case ParseContextValue::VOID:
        case ParseContextValue::UNKNOWN:
        case ParseContextValue::NEXT:
            break;
    }
}
ParseContext::~ParseContext()
{
    switch(type)
    {
        case ParseContextValue::OBJECT:
            objCtx.~ParseObjectContext();
            break;
        case ParseContextValue::ARRAY:
            arrCtx.~ParseArrayContext();
            break;
        case ParseContextValue::NUMBER:
        case ParseContextValue::UNKNOWN:
        case ParseContextValue::STRING:
        case ParseContextValue::VOID:
        case ParseContextValue::BOOLEAN:
        case ParseContextValue::NEXT:
            break;
    };
}

ParseContextValue ParseContext::getType() const noexcept
{
    if (type == ParseContextValue::OBJECT && objCtx.state != ParseObjectContext::State::END && objCtx.keyState == ParseObjectContext::StateKey::VALID)
    {
        return objCtx.value;
    }
    else if (type == ParseContextValue::ARRAY && arrCtx.state != ParseArrayContext::State::END)
    {
        return arrCtx.value;
    }
    else
    {
        return type;
    }
}

void ParseContext::setType(ParseContextValue t) noexcept
{
    if (type == ParseContextValue::OBJECT)
    {
        objCtx.value = t;
    }
    else if (type == ParseContextValue::ARRAY)
    {
        arrCtx.value = t;
    }
    else
    {
        type = t;
    }
}

ParseNumberContext ParseContext::getNumberContext() const noexcept
{
    if (type == ParseContextValue::OBJECT && objCtx.state != ParseObjectContext::State::END)
    {
        return objCtx.numCtx;
    }
    else if (type == ParseContextValue::ARRAY && arrCtx.state != ParseArrayContext::State::END)
    {
        return arrCtx.numCtx;
    }
    else
    {
        return numCtx;
    }
}

void ParseContext::setNumberContext(ParseNumberContext t) noexcept
{
    if (type == ParseContextValue::OBJECT)
    {
        objCtx.numCtx = t;
    }
    else if (type == ParseContextValue::ARRAY)
    {
        arrCtx.numCtx = t;
    }
    else
    {
        numCtx = t;
    }
}

ParseNumberContext json::operator|(const ParseNumberContext& lhs, const ParseNumberContext& rhs)
{
    return static_cast<ParseNumberContext>(static_cast<std::uint8_t>(lhs) | static_cast<std::uint8_t>(rhs));
}

ParseNumberContext json::operator&(const ParseNumberContext& lhs, const ParseNumberContext& rhs)
{
    return static_cast<ParseNumberContext>(static_cast<std::uint8_t>(lhs) & static_cast<std::uint8_t>(rhs));
}

ParseNumberContext json::operator~(const ParseNumberContext& rhs)
{
    return static_cast<ParseNumberContext>(~static_cast<std::uint8_t>(rhs));
}
