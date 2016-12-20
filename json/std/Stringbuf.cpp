//
// Stringbuf.cpp
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

#include "Stringbuf.hpp"

#include <algorithm>
#include <cstddef>
#include <utility>

using namespace json;
using namespace std;
using namespace std::experimental;

Stringbuf::Stringbuf(std::ios::openmode wch) : std::streambuf()
, _hm(0)
, _mode(wch)
{
    str("");
}

Stringbuf::Stringbuf(const std::string& s, std::ios::openmode wch) : std::streambuf()
, _hm(0)
, _mode(wch)
{
    str(s);
}

Stringbuf::~Stringbuf()
{
    if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
        _strIn.~string_view();
    else
        _strInOut.~vector<char>();
}

Stringbuf::Stringbuf(Stringbuf&& rhs) noexcept
{
    *this = std::move(rhs);
}

Stringbuf& Stringbuf::operator=(Stringbuf&& rhs) noexcept
{
    char_type* p = nullptr;
    if ((rhs._mode & std::ios::in) == std::ios::in && (rhs._mode & std::ios::out) != std::ios::out)
        p = const_cast<char_type*>(rhs._strIn.data());
    else
        p = const_cast<char_type*>(rhs._strInOut.data());
    std::ptrdiff_t binp = -1;
    std::ptrdiff_t ninp = -1;
    std::ptrdiff_t einp = -1;
    if (rhs.eback() != nullptr)
    {
        binp = rhs.eback() - p;
        ninp = rhs.gptr() - p;
        einp = rhs.egptr() - p;
    }
    std::ptrdiff_t bout = -1;
    std::ptrdiff_t nout = -1;
    std::ptrdiff_t eout = -1;
    if (rhs.pbase() != nullptr)
    {
        bout = rhs.pbase() - p;
        nout = rhs.pptr() - p;
        eout = rhs.epptr() - p;
    }
    std::ptrdiff_t hm = rhs._hm == nullptr ? -1 : rhs._hm - p;
    if ((rhs._mode & std::ios::in) == std::ios::in && (rhs._mode & std::ios::out) != std::ios::out)
    {
        if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
            _strIn = std::move(rhs._strIn);
        else
        {
            _strInOut.~vector<char>();
            new(&_strIn) std::experimental::string_view(std::move(rhs._strIn));
        }
        p = const_cast<char_type*>(_strIn.data());
    }
    else
    {
        if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
        {
            _strIn.~string_view();
            new(&_strInOut) std::vector<char>(std::move(rhs._strInOut));
        }
        else
            _strInOut = std::move(rhs._strInOut);
        p = const_cast<char_type*>(_strInOut.data());
    }
    if (binp != -1)
        this->setg(p + binp, p + ninp, p + einp);
    else
        this->setg(nullptr, nullptr, nullptr);
    if (bout != -1)
    {
        this->setp(p + bout, p + eout);
        this->pbump(static_cast<int>(nout));
    }
    else
        this->setp(nullptr, nullptr);

    _hm = hm == -1 ? nullptr : p + hm;
    _mode = rhs._mode;
    if ((rhs._mode & std::ios::in) == std::ios::in && (rhs._mode & std::ios::out) != std::ios::out)
        p = const_cast<char_type*>(rhs._strIn.data());
    else
        p = const_cast<char_type*>(rhs._strInOut.data());
    rhs.setg(p, p, p);
    rhs.setp(p, p);
    rhs._hm = p;
    this->pubimbue(rhs.getloc());
    return *this;
}

void Stringbuf::swap(Stringbuf& rhs)
{
    char_type* p = nullptr;
    if ((rhs._mode & std::ios::in) == std::ios::in && (rhs._mode & std::ios::out) != std::ios::out)
        p = const_cast<char_type*>(rhs._strIn.data());
    else
        p = const_cast<char_type*>(rhs._strInOut.data());
    std::ptrdiff_t rbinp = -1;
    std::ptrdiff_t rninp = -1;
    std::ptrdiff_t reinp = -1;
    if (rhs.eback() != nullptr)
    {
        rbinp = rhs.eback() - p;
        rninp = rhs.gptr() - p;
        reinp = rhs.egptr() - p;
    }
    std::ptrdiff_t rbout = -1;
    std::ptrdiff_t rnout = -1;
    std::ptrdiff_t reout = -1;
    if (rhs.pbase() != nullptr)
    {
        rbout = rhs.pbase() - p;
        rnout = rhs.pptr() - p;
        reout = rhs.epptr() - p;
    }
    std::ptrdiff_t rhm = rhs._hm == nullptr ? -1 : rhs._hm - p;
    if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
        p = const_cast<char_type*>(_strIn.data());
    else
        p = const_cast<char_type*>(_strInOut.data());
    std::ptrdiff_t lbinp = -1;
    std::ptrdiff_t lninp = -1;
    std::ptrdiff_t leinp = -1;
    if (this->eback() != nullptr)
    {
        lbinp = this->eback() - p;
        lninp = this->gptr() - p;
        leinp = this->egptr() - p;
    }
    std::ptrdiff_t lbout = -1;
    std::ptrdiff_t lnout = -1;
    std::ptrdiff_t leout = -1;
    if (this->pbase() != nullptr)
    {
        lbout = this->pbase() - p;
        lnout = this->pptr() - p;
        leout = this->epptr() - p;
    }
    std::ptrdiff_t lhm = _hm == nullptr ? -1 : _hm - p;

    if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
    {
        if ((rhs._mode & std::ios::in) == std::ios::in && (rhs._mode & std::ios::out) != std::ios::out)
        {
            _strIn.swap(rhs._strIn);
            p = const_cast<char_type*>(_strIn.data());
        }
        else
        {
            const std::experimental::string_view tmpStringView(std::move(_strIn));
            _strIn.~string_view();
            new(&_strInOut) std::vector<char>(std::move(rhs._strInOut));
            rhs._strInOut.~vector<char>();
            new(&rhs._strIn) std::experimental::string_view(std::move(tmpStringView));
            p = const_cast<char_type*>(_strInOut.data());
        }
    }
    else
    {
        if ((rhs._mode & std::ios::in) == std::ios::in && (rhs._mode & std::ios::out) != std::ios::out)
        {
            const std::vector<char> tmpVector(std::move(_strInOut));
            _strInOut.~vector<char>();
            new(&_strIn) std::experimental::string_view(std::move(rhs._strIn));
            rhs._strIn.~string_view();
            new(&rhs._strInOut) std::vector<char>(std::move(tmpVector));
            p = const_cast<char_type*>(_strIn.data());
        }
        else
        {
            _strInOut.swap(rhs._strInOut);
            p = const_cast<char_type*>(_strInOut.data());
        }
    }
    std::swap(_mode, rhs._mode);
    if (rbinp != -1)
        this->setg(p + rbinp, p + rninp, p + reinp);
    else
        this->setg(nullptr, nullptr, nullptr);
    if (rbout != -1)
    {
        this->setp(p + rbout, p + reout);
        this->pbump(static_cast<int>(rnout));
    }
    else
        this->setp(nullptr, nullptr);
    _hm = rhm == -1 ? nullptr : p + rhm;
    if ((rhs._mode & std::ios::in) == std::ios::in && (rhs._mode & std::ios::out) != std::ios::out)
        p = const_cast<char_type*>(rhs._strIn.data());
    else
        p = const_cast<char_type*>(rhs._strInOut.data());
    if (lbinp != -1)
        rhs.setg(p + lbinp, p + lninp, p + leinp);
    else
        rhs.setg(nullptr, nullptr, nullptr);
    if (lbout != -1)
    {
        rhs.setp(p + lbout, p + leout);
        rhs.pbump(static_cast<int>(lnout));
    }
    else
        rhs.setp(nullptr, nullptr);
    rhs._hm = lhm == -1 ? nullptr : p + lhm;
    locale tl = rhs.getloc();
    rhs.pubimbue(this->getloc());
    this->pubimbue(tl);
}

std::string Stringbuf::str() const
{
    if ((_mode & std::ios::out) == std::ios::out)
    {
        //if (_hm < this->pptr())
        //    _hm = this->pptr();
        //return std::string(this->pbase(), _hm);
        return std::string(this->pbase(), this->pptr());
    }
    else if ((_mode & std::ios::in) == std::ios::in)
        return std::string(this->eback(), this->egptr());
    return std::string();
}

void Stringbuf::str(const std::string& s)
{
    bool init = false;
    std::call_once(_initOnce, [this, &s, &init]() {
        if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
            new(&_strIn) std::experimental::string_view(s);
        else
            new(&_strInOut) std::vector<char>(s.begin(), s.end());
        init = true;
    });
    if (init == false)
    {
        if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
            _strIn = std::experimental::string_view(s);
        else
            _strInOut = std::vector<char>(s.begin(), s.end());
    }
    _hm = 0;
    if ((_mode & std::ios::in) == std::ios::in)
    {
        if ((_mode & std::ios::out) != std::ios::out)
        {
            _hm = const_cast<char_type*>(_strIn.data()) + _strIn.size();
            this->setg(const_cast<char_type*>(_strIn.data()), const_cast<char_type*>(_strIn.data()), _hm);
        }
        else
        {
            _hm = const_cast<char_type*>(_strInOut.data()) + _strInOut.size();
            this->setg(const_cast<char_type*>(_strInOut.data()), const_cast<char_type*>(_strInOut.data()), _hm);
        }
    }
    if ((_mode & std::ios::out) == std::ios::out)
    {
        typename std::string::size_type sz = _strInOut.size();
        _hm = const_cast<char_type*>(_strInOut.data()) + sz;
        _strInOut.resize(_strInOut.capacity());
        this->setp(const_cast<char_type*>(_strInOut.data()), const_cast<char_type*>(_strInOut.data()) + _strInOut.size());
        if ((_mode & (std::ios::app | std::ios::ate)) == (std::ios::app | std::ios::ate))
            this->pbump(static_cast<int>(sz));
    }
}

Stringbuf::int_type Stringbuf::underflow()
{
    if (_hm < this->pptr())
        _hm = this->pptr();
    if ((_mode & std::ios::in) == std::ios::in)
    {
        if (this->egptr() < _hm)
            this->setg(this->eback(), this->gptr(), _hm);
        if (this->gptr() < this->egptr())
            return traits_type::to_int_type(*this->gptr());
    }
    return traits_type::eof();
}

Stringbuf::int_type Stringbuf::pbackfail(int_type c)
{
    if (_hm < this->pptr())
        _hm = this->pptr();
    if (this->eback() < this->gptr())
    {
        if (traits_type::eq_int_type(c, traits_type::eof()))
        {
            this->setg(this->eback(), this->gptr()-1, _hm);
            return traits_type::not_eof(c);
        }
        if (((_mode & std::ios::out) == std::ios::out) || traits_type::eq(traits_type::to_char_type(c), this->gptr()[-1]))
        {
            this->setg(this->eback(), this->gptr()-1, _hm);
            *this->gptr() = traits_type::to_char_type(c);
            return c;
        }
    }
    return traits_type::eof();
}

Stringbuf::int_type Stringbuf::overflow(int_type c)
{
    if (!traits_type::eq_int_type(c, traits_type::eof()))
    {
        std::ptrdiff_t ninp = this->gptr() - this->eback();
        if (this->pptr() == this->epptr())
        {
            if ((_mode & std::ios::out) != std::ios::out)
                return traits_type::eof();
            try
            {
                std::ptrdiff_t nout = this->pptr() - this->pbase();
                std::ptrdiff_t hm = _hm - this->pbase();
                _strInOut.push_back(char_type());
                _strInOut.resize(_strInOut.capacity());
                char_type* p = const_cast<char_type*>(_strInOut.data());
                this->setp(p, p + _strInOut.size());
                this->pbump(static_cast<int>(nout));
                _hm = this->pbase() + hm;
            }
            catch (...)
            {
                return traits_type::eof();
            }
        }
        _hm = std::max(this->pptr() + 1, _hm);
        if ((_mode & std::ios::in) == std::ios::in)
        {
            char_type* p = nullptr;
            if ((_mode & std::ios::out) != std::ios::out)
                p = const_cast<char_type*>(_strIn.data());
            else
                p = const_cast<char_type*>(_strInOut.data());
            this->setg(p, p + ninp, _hm);
        }
        return this->sputc(c);
    }
    return traits_type::not_eof(c);
}

Stringbuf::pos_type Stringbuf::seekoff(off_type off, std::ios::seekdir way, std::ios::openmode wch)
{
    if (_hm < this->pptr())
        _hm = this->pptr();
    if ((wch & (std::ios::in | std::ios::out)) == 0)
        return pos_type(-1);
    if ((wch & (std::ios::in | std::ios::out)) == (std::ios::in | std::ios::out) && way == std::ios::cur)
        return pos_type(-1);
    off_type noff;
    switch (way)
    {
        case std::ios::beg:
            noff = 0;
            break;
        case std::ios::cur:
            if ((wch & std::ios::in) == std::ios::in)
                noff = this->gptr() - this->eback();
            else
                noff = this->pptr() - this->pbase();
            break;
        case std::ios::end:
            if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
                noff = _hm - _strIn.data();
            else
                noff = _hm - _strInOut.data();
            break;
    }
    noff += off;
    if ((_mode & std::ios::in) == std::ios::in && (_mode & std::ios::out) != std::ios::out)
    {
        if (noff < 0 || _hm - _strIn.data() < noff)
            return pos_type(-1);
    }
    else
    {
        if (noff < 0 || _hm - _strInOut.data() < noff)
            return pos_type(-1);
    }
    if (noff != 0)
    {
        if ((wch & std::ios::in) == std::ios::in && this->gptr() == 0)
            return pos_type(-1);
        if ((wch & std::ios::out) == std::ios::out && this->pptr() == 0)
            return pos_type(-1);
    }
    if ((wch & std::ios::in) == std::ios::in)
        this->setg(this->eback(), this->eback() + noff, _hm);
    if ((wch & std::ios::out) == std::ios::out)
    {
        this->setp(this->pbase(), this->epptr());
        this->pbump(static_cast<int>(noff));
    }
    return pos_type(noff);
}

Stringbuf::pos_type Stringbuf::seekpos(pos_type sp, std::ios::openmode wch)
{
    return seekoff(sp, std::ios::beg, wch);
}
