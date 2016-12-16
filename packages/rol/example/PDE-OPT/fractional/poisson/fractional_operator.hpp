// @HEADER
// ************************************************************************
//
//               Rapid Optimization Library (ROL) Package
//                 Copyright (2014) Sandia Corporation
//
// Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
// license for use of this work by or on behalf of the U.S. Government.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// 1. Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// 3. Neither the name of the Corporation nor the names of the
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA CORPORATION OR THE
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Questions? Contact lead developers:
//              Drew Kouri   (dpkouri@sandia.gov) and
//              Denis Ridzal (dridzal@sandia.gov)
//
// ************************************************************************
// @HEADER

#ifndef ROL_FRACTIONALOPERATOR_H
#define ROL_FRACTIONALOPERATOR_H

#include "ROL_LinearOperator.hpp"
#include "../../TOOLS/assembler.hpp"

template <class Real>
class FractionalOperator : public ROL::LinearOperator<Real> {
private:
  Teuchos::RCP<Tpetra::CrsMatrix<> > Klocal_, Mlocal_;
  Teuchos::RCP<Tpetra::CrsMatrix<> > Kcylinder_, Mcylinder_;

public:
  FractionalOperator(const Teuchos::RCP<PDE<Real> > &pde_local,
                     const Teuchos::RCP<MeshManager<Real> > &mesh_local,
                     const Teuchos::RCP<PDE<Real> > &pde_cylinder,
                     const Teuchos::RCP<MeshManager<Real> > &mesh_cylinder,
                     const Teuchos::RCP<const Teuchos::Comm<int> > &comm,
                     Teuchos::ParameterList &parlist,
                     std::ostream &outStream = std::cout) {
    Teuchos::RCP<Tpetra::MultiVector<> > uvec;
    Teuchos::RCP<Tpetra::MultiVector<> > zvec;
    // Assemble local components
    Teuchos::RCP<Assembler<Real> > assembler_local
      = Teuchos::rcp(new Assembler<Real>(pde_local->getFields(),mesh_local,comm,parlist,outStream));
    assembler_local->setCellNodes(*pde_local);
    uvec = assembler_local->createStateVector();
    zvec = assembler_local->createControlVector();
    assembler_local->assemblePDEJacobian1(Klocal_,pde_local,uvec,zvec);
    assembler_local->assemblePDERieszMap1(Mlocal_,pde_local);
    // Assemble cylinder components
    Teuchos::RCP<Assembler<Real> > assembler_cylinder
      = Teuchos::rcp(new Assembler<Real>(pde_cylinder->getFields(),mesh_cylinder,comm,parlist,outStream));
    assembler_cylinder->setCellNodes(*pde_cylinder);
    uvec = assembler_cylinder->createStateVector();
    zvec = assembler_cylinder->createControlVector();
    assembler_cylinder->assemblePDEJacobian1(Kcylinder_,pde_cylinder,uvec,zvec);
    assembler_cylinder->assemblePDERieszMap1(Mcylinder_,pde_cylinder);
  }

  FractionalOperator(const Teuchos::RCP<Tpetra::CrsMatrix<> > &Klocal,
                     const Teuchos::RCP<Tpetra::CrsMatrix<> > &Mlocal,
                     const Teuchos::RCP<Tpetra::CrsMatrix<> > &Kcylinder,
                     const Teuchos::RCP<Tpetra::CrsMatrix<> > &Mcylinder)
    : Klocal_(Klocal), Mlocal_(Mlocal), Kcylinder_(Kcylinder), Mcylinder_(Mcylinder) {}

  void apply( ROL::Vector<Real> &Hv, const ROL::Vector<Real> &v, Real &tol ) const {
    Teuchos::RCP<Tpetra::MultiVector<> >       Hvf = getField(Hv);
    Teuchos::RCP<const Tpetra::MultiVector<> >  vf = getConstField(v);

    size_t numRowEntries(0);
    Teuchos::Array<int> indices;
    Teuchos::Array<Real> values;
    for (size_t r = 0; r < Mcylinder_->getGlobalNumRows(); ++r) {
      numRowEntries = Mcylinder_->getNumEntriesInGlobalRow(r);
      indices.resize(numRowEntries); values.resize(numRowEntries);
      Mcylinder_->getGlobalRowCopy(r,indices(),values(),numRowEntries);
      for (int c = 0; c < indices.size(); ++c) {
        Klocal_->apply(*(vf->getVector(indices[c])),*(Hvf->getVectorNonConst(r)),Teuchos::NO_TRANS,values[c],static_cast<Real>(0));
      }
    }
    for (size_t r = 0; r < Kcylinder_->getGlobalNumRows(); ++r) {
      numRowEntries = Kcylinder_->getNumEntriesInGlobalRow(r);
      indices.resize(numRowEntries); values.resize(numRowEntries);
      Kcylinder_->getGlobalRowCopy(r,indices(),values(),numRowEntries);
      for (int c = 0; c < indices.size(); ++c) {
        Mlocal_->apply(*(vf->getVector(indices[c])),*(Hvf->getVectorNonConst(r)),Teuchos::NO_TRANS,values[c],static_cast<Real>(1));
      }
    }
  }

private: // Vector accessor functions

  Teuchos::RCP<const Tpetra::MultiVector<> > getConstField(const ROL::Vector<Real> &x) const {
    return Teuchos::dyn_cast<const ROL::TpetraMultiVector<Real> >(x).getVector();
  }

  Teuchos::RCP<Tpetra::MultiVector<> > getField(ROL::Vector<Real> &x) const {
    return Teuchos::dyn_cast<ROL::TpetraMultiVector<Real> >(x).getVector();
  }
};

template <class Real>
class FractionalPreconditioner : public ROL::LinearOperator<Real> {
private:
  Teuchos::RCP<Tpetra::CrsMatrix<> > Klocal_, Mlocal_;
  Teuchos::RCP<Tpetra::CrsMatrix<> > Kcylinder_, Mcylinder_;

public:
  FractionalPreconditioner(const Teuchos::RCP<PDE<Real> > &pde_local,
                           const Teuchos::RCP<MeshManager<Real> > &mesh_local,
                           const Teuchos::RCP<PDE<Real> > &pde_cylinder,
                           const Teuchos::RCP<MeshManager<Real> > &mesh_cylinder,
                           const Teuchos::RCP<const Teuchos::Comm<int> > &comm,
                           Teuchos::ParameterList &parlist,
                           std::ostream &outStream = std::cout) {
    Teuchos::RCP<Tpetra::MultiVector<> > uvec;
    Teuchos::RCP<Tpetra::MultiVector<> > zvec;
    // Assemble local components
    Teuchos::RCP<Assembler<Real> > assembler_local
      = Teuchos::rcp(new Assembler<Real>(pde_local->getFields(),mesh_local,comm,parlist,outStream));
    assembler_local->setCellNodes(*pde_local);
    uvec = assembler_local->createStateVector();
    zvec = assembler_local->createControlVector();
    assembler_local->assemblePDEJacobian1(Klocal_,pde_local,uvec,zvec);
    assembler_local->assemblePDERieszMap1(Mlocal_,pde_local);
    // Assemble cylinder components
    Teuchos::RCP<Assembler<Real> > assembler_cylinder
      = Teuchos::rcp(new Assembler<Real>(pde_cylinder->getFields(),mesh_cylinder,comm,parlist,outStream));
    assembler_cylinder->setCellNodes(*pde_cylinder);
    uvec = assembler_cylinder->createStateVector();
    zvec = assembler_cylinder->createControlVector();
    assembler_cylinder->assemblePDEJacobian1(Kcylinder_,pde_cylinder,uvec,zvec);
    assembler_cylinder->assemblePDERieszMap1(Mcylinder_,pde_cylinder);
  }

  FractionalPreconditioner(const Teuchos::RCP<Tpetra::CrsMatrix<> > &Klocal,
                           const Teuchos::RCP<Tpetra::CrsMatrix<> > &Mlocal,
                           const Teuchos::RCP<Tpetra::CrsMatrix<> > &Kcylinder,
                           const Teuchos::RCP<Tpetra::CrsMatrix<> > &Mcylinder)
    : Klocal_(Klocal), Mlocal_(Mlocal), Kcylinder_(Kcylinder), Mcylinder_(Mcylinder) {}

  void apply( ROL::Vector<Real> &Hv, const ROL::Vector<Real> &v, Real &tol ) const {
    Hv.set(v);
//    Teuchos::RCP<Tpetra::MultiVector<> >       Hvf = getField(v);
//    Teuchos::RCP<const Tpetra::MultiVector<> >  vf = getConstField(v);
//
//    Teuchos::Array<int> indices;
//    Teuchos::Array<Real> values;
//    for (size_t r = 0; r < Mcylinder_->getGlobalNumRows(); ++r) {
//      numRowEntries = Mcylinder_->getNumEntriesInGlobalRow(r);
//      indices.resize(numRowEntries); values.resize(numRowEntries);
//      Mcylinder_->getGlobalRowCopy(r,indices(),values(),numRowEntries);
//      for (int c = 0; c < indices.size(); ++c) {
//        Klocal_->apply(*(vf->getVector(indices[c])),*(Hvf->getVectorNonConst(r)),Teuchos::NO_TRANS,values[c],static_cast<Real>(0));
//      }
//    }
//    for (size_t r = 0; r < Kcylinder_->getGlobalNumRows(); ++r) {
//      numRowEntries = Kcylinder_->getNumEntriesInGlobalRow(r);
//      indices.resize(numRowEntries); values.resize(numRowEntries);
//      Kcylinder_->getGlobalRowView(r,indices(),values(),numRowEntries);
//      for (int c = 0; c < indices.size(); ++c) {
//        Mlocal_->apply(*(vf->getVector(indices[c])),*(Hvf->getVectorNonConst(r)),Teuchos::NO_TRANS,values[c],static_cast<Real>(1));
//      }
//    }
  }

private: // Vector accessor functions

  Teuchos::RCP<const Tpetra::MultiVector<> > getConstField(const ROL::Vector<Real> &x) const {
    return Teuchos::dyn_cast<const ROL::TpetraMultiVector<Real> >(x).getVector();
  }

  Teuchos::RCP<Tpetra::MultiVector<> > getField(ROL::Vector<Real> &x) const {
    return Teuchos::dyn_cast<ROL::TpetraMultiVector<Real> >(x).getVector();
  }
};

template <class Real>
class FractionalControlOperator : public ROL::LinearOperator<Real> {
private:
  const Teuchos::RCP<Tpetra::CrsMatrix<> > Blocal_;
  const int numCylinder_;

  bool transpose_;

public:
  FractionalControlOperator(const Teuchos::RCP<Tpetra::CrsMatrix<> > &Blocal,
                            const int numCylinder)
    : Blocal_(Blocal), numCylinder_(numCylinder), transpose_(false) {}

  void setTranspose(const bool trans = true) {
    transpose_ = trans;
  }

  void apply( ROL::Vector<Real> &Hv, const ROL::Vector<Real> &v, Real &tol ) const {
    Teuchos::RCP<Tpetra::MultiVector<> >       Hvf = getField(Hv);
    Teuchos::RCP<const Tpetra::MultiVector<> >  vf = getConstField(v);

    if ( !transpose_ ) {
      Hv.zero();
      Blocal_->apply(*vf, *(Hvf->getVectorNonConst(0)));
    }
    else {
      Blocal_->apply(*(vf->getVector(0)), *Hvf, Teuchos::TRANS);
    }
  }

private: // Vector accessor functions

  Teuchos::RCP<const Tpetra::MultiVector<> > getConstField(const ROL::Vector<Real> &x) const {
    return Teuchos::dyn_cast<const ROL::TpetraMultiVector<Real> >(x).getVector();
  }

  Teuchos::RCP<Tpetra::MultiVector<> > getField(ROL::Vector<Real> &x) const {
    return Teuchos::dyn_cast<ROL::TpetraMultiVector<Real> >(x).getVector();
  }
};

#endif
