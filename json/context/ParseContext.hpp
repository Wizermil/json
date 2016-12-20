//
// ParseContext.hpp
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

#pragma once

#include <cstdint>
#include <sstream>
#include "../Document.hpp"

namespace json
{

    struct ParseContext
    {
        enum struct State : std::uint8_t
        {
            UNKNOWN,
            OBJECT_START,
            OBJECT_END,
            ARRAY_START,
            ARRAY_END
        };

        enum struct StateValue : std::uint8_t
        {
            UNKNOWN,
            NEXT,
            STRING,
            NUMBER,
            VOID,
            BOOLEAN,
        };

        enum struct StateNumber : std::uint8_t
        {
            DIGIT = 0,
            SIGN = 1,
            FRAC = 2,
            EXP = 4
        };

        enum struct StateKey : std::uint8_t
        {
            UNKNOWN,
            KEY_START,
            KEY_END,
            KEY_VALID
        };

        ParseContext();
        ParseContext(ParseContext&& other) noexcept;
        ParseContext& operator=(ParseContext&& other) noexcept;
        ParseContext(const ParseContext& other) = delete;
        ParseContext& operator=(const ParseContext& other) = delete;
        ~ParseContext() = default;
        
        State state;
        StateKey keyState;
        StateValue valueState;
        std::string key;
        Document doc;
        std::size_t commaCount;
        std::size_t colonCount;
        std::size_t duplicatedKeys;
    };

    ParseContext::StateNumber operator|(const ParseContext::StateNumber& lhs, const ParseContext::StateNumber& rhs);
    ParseContext::StateNumber& operator |=(ParseContext::StateNumber& lhs, const ParseContext::StateNumber& rhs);
    ParseContext::StateNumber operator&(const ParseContext::StateNumber &lhs, const ParseContext::StateNumber &rhs);
    ParseContext::StateNumber& operator &=(ParseContext::StateNumber& lhs, const ParseContext::StateNumber& rhs);
    ParseContext::StateNumber operator~(const ParseContext::StateNumber &rhs);
}
