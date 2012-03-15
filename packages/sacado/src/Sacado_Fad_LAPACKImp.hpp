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
// @HEADER

#include "Teuchos_Assert.hpp"

template <typename OrdinalType, typename FadType>
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
ArrayTraits(bool use_dynamic_, 
	    OrdinalType workspace_size_) : 
  use_dynamic(use_dynamic_),
  workspace_size(workspace_size_),
  workspace(NULL),
  workspace_pointer(NULL)
{
  if (workspace_size > 0) {
    workspace = new ValueType[workspace_size];
    workspace_pointer = workspace;
  }
}

template <typename OrdinalType, typename FadType>
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
ArrayTraits(const ArrayTraits& a) :
  use_dynamic(a.use_dynamic),
  workspace_size(a.workspace_size),
  workspace(NULL),
  workspace_pointer(NULL)
{
  if (workspace_size > 0) {
    workspace = new ValueType*[workspace_size];
    workspace_pointer = workspace;
  }
}
  

template <typename OrdinalType, typename FadType>
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
~ArrayTraits()
{
// #ifdef SACADO_DEBUG
//   TEUCHOS_TEST_FOR_EXCEPTION(workspace_pointer != workspace,
// 		     std::logic_error,
// 		     "ArrayTraits::~ArrayTraits(): " <<
// 		     "Destructor called with non-zero used workspace. " <<
// 		     "Currently used size is " << workspace_pointer-workspace <<
// 		     ".");
    
// #endif

  if (workspace_size > 0)
    delete [] workspace;
}

template <typename OrdinalType, typename FadType>
void
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
unpack() const
{
}

template <typename OrdinalType, typename FadType>
void
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
pack() const
{
}

template <typename OrdinalType, typename FadType>
void
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
free() const
{
}

template <typename OrdinalType, typename FadType>
typename Sacado::Fad::ArrayTraits<OrdinalType,FadType>::ValueType*
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
allocate_array(OrdinalType size) const
{
  if (use_dynamic)
    return new ValueType[size];

#ifdef SACADO_DEBUG
  TEUCHOS_TEST_FOR_EXCEPTION(workspace_pointer + size - workspace > workspace_size,
		     std::logic_error,
		     "ArrayTraits::allocate_array(): " <<
		     "Requested workspace memory beyond size allocated. " <<
		     "Workspace size is " << workspace_size << 
		     ", currently used is " << workspace_pointer-workspace << 
		     ", requested size is " << size << ".");
    
#endif

  ValueType *v = workspace_pointer;
  workspace_pointer += size;
  return v;
}

template <typename OrdinalType, typename FadType>
void
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
free_array(const ValueType* ptr, OrdinalType size) const
{
  if (use_dynamic && ptr != NULL)
    delete [] ptr;
  else
    workspace_pointer -= size;
}

template <typename OrdinalType, typename FadType>
bool
Sacado::Fad::ArrayTraits<OrdinalType,FadType>::
is_array_contiguous(const FadType* a, OrdinalType n, OrdinalType n_dot) const
{
  return (n > 0) && 
    (&(a[n-1].val())-&(a[0].val()) == n-1) && 
    (a[n-1].dx()-a[0].dx() == n-1);
}

template <typename OrdinalType, typename FadType>
Sacado::Fad::Fad_LAPACK<OrdinalType,FadType>::
Fad_LAPACK(bool use_default_impl_,
           bool use_dynamic_, 
           OrdinalType static_workspace_size_) : 
  LAPACKType(),
  arrayTraits(use_dynamic_, static_workspace_size_),
  lapack(),
  use_default_impl(use_default_impl_)
{
}

template <typename OrdinalType, typename FadType>
Sacado::Fad::Fad_LAPACK<OrdinalType,FadType>::
Fad_LAPACK(const Fad_LAPACK& x) : 
  LAPACKType(x),
  arrayTraits(x.arrayTraits),
  lapack(x.lapack),
  use_default_impl(x.use_default_impl) 
{
}

template <typename OrdinalType, typename FadType>
Sacado::Fad::Fad_LAPACK<OrdinalType,FadType>::
~Fad_LAPACK() 
{
}

template <typename OrdinalType, typename FadType>
void
Sacado::Fad::Fad_LAPACK<OrdinalType,FadType>::
GESV(const OrdinalType n, const OrdinalType nrhs, FadType* A, const OrdinalType lda,
     OrdinalType* IPIV, FadType* B, const OrdinalType ldb, OrdinalType* info) const {

  if (use_default_impl) {
    LAPACKType::GESV(n,nrhs,A,lda,IPIV,B,ldb,info);
    return;
  }

  // Unpack input values & derivatives
  arrayTraits.unpack();

  // Call differentiated routine
  Fad_GESV();
  
  // Pack values and derivatives for result
  arrayTraits.pack();
  
  // Free temporary arrays
  arrayTraits.free();
}

template <typename OrdinalType, typename FadType>
void
Sacado::Fad::Fad_LAPACK<OrdinalType,FadType>::
Fad_GESV() const
{
}
