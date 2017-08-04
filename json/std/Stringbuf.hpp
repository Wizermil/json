//
// Stringbuf.hpp
// json
//
// Created by Mathieu Garaud on 31/08/16.
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

#if __clang_major__ > 8
#include <string_view>
#else
#include <experimental/string_view>
#endif
#include <ios>
#include <memory>
#include <mutex>
#include <streambuf>
#include <string>
#include <vector>

namespace json
{

    class Stringbuf : public std::streambuf
    {
    public:
        typedef char char_type;
        typedef std::char_traits<char> traits_type;
        typedef typename traits_type::int_type int_type;
        typedef typename traits_type::pos_type pos_type;
        typedef typename traits_type::off_type off_type;
        typedef std::allocator<char> allocator_type;

    public:
        Stringbuf() =delete;
        explicit Stringbuf(std::ios::openmode wch = std::ios::in | std::ios::out);
        explicit Stringbuf(const std::string& s, std::ios::openmode wch = std::ios::in | std::ios::out);
        Stringbuf(Stringbuf&& rhs) noexcept;
        Stringbuf& operator=(Stringbuf&& rhs) noexcept;
        Stringbuf(const Stringbuf& rhs) noexcept =delete;
        Stringbuf& operator=(const Stringbuf& rhs) noexcept =delete;
        ~Stringbuf();

        void swap(Stringbuf& rhs);

        std::string str() const;
        void str(const std::string& s);

    protected:
        virtual int_type underflow();
        virtual int_type pbackfail(int_type c = traits_type::eof());
        virtual int_type overflow (int_type c = traits_type::eof());
        virtual pos_type seekoff(off_type off, std::ios::seekdir way, std::ios::openmode wch = std::ios::in | std::ios::out);
        virtual pos_type seekpos(pos_type sp, std::ios::openmode wch = std::ios::in | std::ios::out);

    private:
        union {
            std::vector<char> _strInOut;
#if __clang_major__ > 8
            std::string_view _strIn;
#else
            std::experimental::string_view _strIn;
#endif
        };
        mutable char_type* _hm;
        std::ios::openmode _mode;
        std::once_flag _initOnce;
    };

}
