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

#include "../Document.hpp"
#include "ParseArrayContext.hpp"
#include "ParseObjectContext.hpp"
#include <cstdint>
#include <memory>
#include <sstream>

namespace json
{
    enum struct ParseContextValue : std::uint8_t
    {
        UNKNOWN,
        NEXT,
        STRING,
        NUMBER,
        VOID,
        BOOLEAN,
        OBJECT,
        ARRAY
    };

    enum struct ParseNumberContext : std::uint8_t
    {
        DIGIT = 1 << 0,
        SIGN = 1 << 1,
        FRAC = 1 << 2,
        EXP = 1 << 3
    };

    struct ParseContext
    {
        ParseContext() =delete;
        ParseContext(ParseContextValue kind);
        ParseContext(ParseContext&& other) noexcept =delete;
        ParseContext& operator=(ParseContext&& other) noexcept =delete;
        ParseContext(const ParseContext& other) = delete;
        ParseContext& operator=(const ParseContext& other) = delete;
        ~ParseContext();


        ParseContextValue getType() const noexcept;
        void setType(ParseContextValue t) noexcept;

        ParseNumberContext getNumberContext() const noexcept;
        void setNumberContext(ParseNumberContext t) noexcept;
        
        ParseContextValue type;
        union {
            ParseObjectContext objCtx;
            ParseArrayContext arrCtx;
            ParseNumberContext numCtx;
        };

    };

    ParseNumberContext operator|(const ParseNumberContext& lhs, const ParseNumberContext& rhs);
    ParseNumberContext operator&(const ParseNumberContext& lhs, const ParseNumberContext& rhs);
    ParseNumberContext operator~(const ParseNumberContext& rhs);
}
