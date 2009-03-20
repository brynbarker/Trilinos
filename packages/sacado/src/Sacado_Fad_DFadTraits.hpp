// $Id$ 
// $Source$ 
// @HEADER
// ***********************************************************************
// 
//                           Sacado Package
//                 Copyright (2006) Sandia Corporation
// 
// Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
// the U.S. Government retains certain rights in this software.
// 
// This library is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 2.1 of the
// License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
// Questions? Contact David M. Gay (dmgay@sandia.gov) or Eric T. Phipps
// (etphipp@sandia.gov).
// 
// ***********************************************************************
//
// The forward-mode AD classes in Sacado are a derivative work of the
// expression template classes in the Fad package by Nicolas Di Cesare.  
// The following banner is included in the original Fad source code:
//
// ************ DO NOT REMOVE THIS BANNER ****************
//
//  Nicolas Di Cesare <Nicolas.Dicesare@ann.jussieu.fr>
//  http://www.ann.jussieu.fr/~dicesare
//
//            CEMRACS 98 : C++ courses, 
//         templates : new C++ techniques 
//            for scientific computing 
// 
//********************************************************
//
//  NumericalTraits class to illustrate TRAITS
//
//********************************************************
// @HEADER

#ifndef SACADO_FAD_DFADTRAITS_HPP
#define SACADO_FAD_DFADTRAITS_HPP

#include "Sacado_Traits.hpp"

// Forward declarations
namespace Sacado {
  namespace Fad {
    template <typename T1, typename T2> class DFad;
  }
}

namespace Sacado {

  //! Specialization of %Promote to DFad types
  template <typename ValueT, typename ScalarT>
  struct Promote< Fad::DFad<ValueT,ScalarT>, Fad::DFad<ValueT,ScalarT> > {
    typedef Fad::DFad<ValueT,ScalarT> type;
  };

  //! Specialization of %Promote to DFad types
  template <typename ValueT, typename ScalarT, typename R>
  struct Promote< Fad::DFad<ValueT,ScalarT>, R > {
    typedef typename ValueType< Fad::DFad<ValueT,ScalarT> >::type value_type_l;
    typedef typename ValueType<R>::type value_type_r;
    typedef typename Promote<value_type_l,value_type_r>::type value_type;

    typedef Fad::DFad<value_type,ScalarT> type;
  };

  //! Specialization of %Promote to DFad types
  template <typename L, typename ValueT, typename ScalarT>
  struct Promote< L, Fad::DFad<ValueT, ScalarT> > {
  public:

    typedef typename ValueType<L>::type value_type_l;
    typedef typename ValueType< Fad::DFad<ValueT,ScalarT> >::type value_type_r;
    typedef typename Promote<value_type_l,value_type_r>::type value_type;

    typedef Fad::DFad<value_type,ScalarT> type;
  };

  //! Specialization of %ScalarType to DFad types
  template <typename ValueT, typename ScalarT>
  struct ScalarType< Fad::DFad<ValueT,ScalarT> > {
    typedef ScalarT type;
  };

  //! Specialization of %ValueType to DFad types
  template <typename ValueT, typename ScalarT>
  struct ValueType< Fad::DFad<ValueT,ScalarT> > {
    typedef ValueT type;
  };

   //! Specialization of %ScalarValueType to DFad types
  template <typename ValueT, typename ScalarT>
  struct ScalarValueType< Fad::DFad<ValueT,ScalarT> > {
    typedef typename ScalarValueType< ValueT >::type type;
  };

  //! Specialization of %IsADType to DFad types
  template <typename ValueT, typename ScalarT>
  struct IsADType< Fad::DFad<ValueT,ScalarT> > {
    static const bool value = true;
  };

  //! Specialization of %IsADType to DFad types
  template <typename ValueT, typename ScalarT>
  struct IsScalarType< Fad::DFad<ValueT,ScalarT> > {
    static const bool value = false;
  };

  //! Specialization of %Value to DFad types
  template <typename ValueT, typename ScalarT>
  struct Value< Fad::DFad<ValueT,ScalarT> > {
    typedef typename ValueType< Fad::DFad<ValueT,ScalarT> >::type value_type;
    static const value_type& eval(const Fad::DFad<ValueT,ScalarT>& x) { 
      return x.val(); }
  };

} // namespace Sacado

// Define Teuchos traits classes
#ifdef HAVE_SACADO_TEUCHOS

#include "Teuchos_TestForException.hpp"

namespace Teuchos {

  //! Specialization of %Teuchos::PromotionTraits to DFad types
  template <typename ValueT, typename ScalarT>
  struct PromotionTraits< Sacado::Fad::DFad<ValueT,ScalarT>, 
			  Sacado::Fad::DFad<ValueT,ScalarT> > {
    typedef typename Sacado::Promote< Sacado::Fad::DFad<ValueT,ScalarT>,
				      Sacado::Fad::DFad<ValueT,ScalarT> >::type
    promote;
  };

  //! Specialization of %Teuchos::PromotionTraits to DFad types
  template <typename ValueT, typename ScalarT, typename R>
  struct PromotionTraits< Sacado::Fad::DFad<ValueT,ScalarT>, R > {
    typedef typename Sacado::Promote< Sacado::Fad::DFad<ValueT,ScalarT>,
				      R >::type 
    promote;
  };

  //! Specialization of %Teuchos::PromotionTraits to DFad types
  template <typename L, typename ValueT, typename ScalarT>
  struct PromotionTraits< L, Sacado::Fad::DFad<ValueT, ScalarT> > {
  public:
    typedef typename Sacado::Promote< L, 
				      Sacado::Fad::DFad<ValueT,ScalarT> >::type 
    promote;
  };

  //! Specializtion of Teuchos::ScalarTraits
  template <typename ValueT, typename ScalarT>
  struct ScalarTraits< Sacado::Fad::DFad<ValueT,ScalarT> > {
    typedef Sacado::Fad::DFad<ValueT,ScalarT> FadType;

    typedef Sacado::Fad::DFad<typename ScalarTraits<ValueT>::magnitudeType,
    			      typename ScalarTraits<ScalarT>::magnitudeType> magnitudeType;
    //typedef FadType magnitudeType;
    typedef Sacado::Fad::DFad<typename ScalarTraits<ValueT>::halfPrecision,
			      typename ScalarTraits<ScalarT>::halfPrecision> 
    halfPrecision;
    typedef Sacado::Fad::DFad<typename ScalarTraits<ValueT>::doublePrecision,
			      typename ScalarTraits<ScalarT>::doublePrecision> 
    doublePrecision;
    static const bool isComplex = ScalarTraits<ValueT>::isComplex;
    static const bool isOrdinal = ScalarTraits<ValueT>::isOrdinal;
    static const bool isComparable = ScalarTraits<ValueT>::isComparable;
    static const bool hasMachineParameters = 
      ScalarTraits<ValueT>::hasMachineParameters;
    static inline typename ScalarTraits<ValueT>::magnitudeType eps()   {
      return ScalarTraits<ValueT>::eps();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType sfmin() {
      return ScalarTraits<ValueT>::sfmin();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType base()  {
      return ScalarTraits<ValueT>::base();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType prec()  {
      return ScalarTraits<ValueT>::prec();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType t()     {
      return ScalarTraits<ValueT>::t();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType rnd()   {
      return ScalarTraits<ValueT>::rnd();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType emin()  {
      return ScalarTraits<ValueT>::emin();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType rmin()  {
      return ScalarTraits<ValueT>::rmin();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType emax()  {
      return ScalarTraits<ValueT>::emax();
    }
    static inline typename ScalarTraits<ValueT>::magnitudeType rmax()  {
      return ScalarTraits<ValueT>::rmax();
    }
    static inline magnitudeType magnitude(const FadType& a) {
#ifdef TEUCHOS_DEBUG
      TEUCHOS_SCALAR_TRAITS_NAN_INF_ERR(
        a, "Error, the input value to magnitude(...) a = " << a << 
	" can not be NaN!" );
#endif
      //return std::fabs(a); 
      magnitudeType b(a.size(), ScalarTraits<ValueT>::magnitude(a.val()));
      for (int i=0; i<a.size(); i++)
	b.fastAccessDx(i) = (ScalarTraits<ValueT>::real(a.val())*ScalarTraits<ValueT>::real(a.fastAccessDx(i)) + ScalarTraits<ValueT>::imag(a.val())*ScalarTraits<ValueT>::imag(a.fastAccessDx(i)))/b.val();
      return b;
    }
    static inline ValueT zero()  { 
      return ValueT(0.0); 
    }
    static inline ValueT one()   { 
      return ValueT(1.0); 
    }

    // Conjugate is only defined for real derivative components
    static inline FadType conjugate(const FadType& x) {
#ifdef TEUCHOS_DEBUG
      TEST_FOR_EXCEPTION(is_fad_real(x) == false, std::runtime_error,
			 "Complex conjugate is not a differentiable function "
			 << "of complex inputs.  All Fad derivative components "
			 << "must be real.");
	
#endif
      FadType y = x;
      y.val() = ScalarTraits<ValueT>::conjugate(x.val());
      return y; 
    }   

    // Real part is only defined for real derivative components
    static inline FadType real(const FadType& x) { 
#ifdef TEUCHOS_DEBUG
      TEST_FOR_EXCEPTION(is_fad_real(x) == false, std::runtime_error,
			 "Real component is not a differentiable function "
			 << "of complex inputs.  All Fad derivative components "
			 << "must be real.");
	
#endif
      FadType y = x;
      y.val() = ScalarTraits<ValueT>::real(x.val());
      return y; 
    }

    // Imaginary part is only defined for real derivative components
    static inline FadType imag(const FadType& x) { 
#ifdef TEUCHOS_DEBUG
      TEST_FOR_EXCEPTION(is_fad_real(x) == false, std::runtime_error,
			 "Imaginary component is not a differentiable function "
			 << "of complex inputs.  All Fad derivative components "
			 << "must be real.");
	
#endif
      return FadType(ScalarTraits<ValueT>::imag(x.val()));
    }

    static inline ValueT nan() {
      return ScalarTraits<ValueT>::nan(); 
    }
    static inline bool isnaninf(const FadType& x) { 
      if (ScalarTraits<ValueT>::isnaninf(x.val()))
	return true;
      for (int i=0; i<x.size(); i++)
	if (ScalarTraits<ValueT>::isnaninf(x.dx(i)))
	  return true;
      return false;
    }
    static inline void seedrandom(unsigned int s) { 
      ScalarTraits<ValueT>::seedrandom(s); 
    }
    static inline ValueT random() { 
      return ScalarTraits<ValueT>::random(); 
    }
    static inline std::string name() { 
      return "Sacado::Fad::DFad<" + 
	ScalarTraits<ValueT>::name() + "," + 
	ScalarTraits<ScalarT>::name() + ">"; 
    }
    static inline FadType squareroot(const FadType& x) {
#ifdef TEUCHOS_DEBUG
      TEUCHOS_SCALAR_TRAITS_NAN_INF_ERR(
        x, "Error, the input value to squareroot(...) a = " << x << 
	" can not be NaN!" );
#endif
      return std::sqrt(x); 
    }
    static inline FadType pow(const FadType& x, const FadType& y) { 
      return std::pow(x,y); 
    }

    // Helper function to determine whether a complex value is real
    static inline bool is_complex_real(const ValueT& x) {
      return 
	ScalarTraits<ValueT>::magnitude(x-ScalarTraits<ValueT>::real(x)) == 0;
    }

    // Helper function to determine whether a Fad type has real derivative 
    // components
    static inline bool is_fad_real(const FadType& x) {
      if (ScalarTraits<ValueT>::isComplex) {
	for (int i=0; i<x.size(); i++)
	  if (!is_complex_real(x.fastAccessDx(i)))
	    return false;
      }
      return true;
    }
  };
}
#endif // HAVE_SACADO_TEUCHOS

#endif // SACADO_FAD_DFADTRAITS_HPP
