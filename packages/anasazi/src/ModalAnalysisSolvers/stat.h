c @HEADER
c ***********************************************************************
c
c                 Anasazi: Block Eigensolvers Package
c                 Copyright 2004 Sandia Corporation
c
c Under terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
c the U.S. Government retains certain rights in this software.
c
c Redistribution and use in source and binary forms, with or without
c modification, are permitted provided that the following conditions are
c met:
c
c 1. Redistributions of source code must retain the above copyright
c notice, this list of conditions and the following disclaimer.
c
c 2. Redistributions in binary form must reproduce the above copyright
c notice, this list of conditions and the following disclaimer in the
c documentation and/or other materials provided with the distribution.
c
c 3. Neither the name of the Corporation nor the names of the
c contributors may be used to endorse or promote products derived from
c this software without specific prior written permission.
c
c THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
c EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
c IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
c PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA CORPORATION OR THE
c CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
c EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
c PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
c PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
c LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
c NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
c SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
c
c Questions? Contact Michael A. Heroux (maherou@sandia.gov)
c
c ***********************************************************************
c @HEADER
c     %--------------------------------%
c     | See stat.doc for documentation |
c     %--------------------------------%
c
c\SCCS Information: @(#) 
c FILE: stat.h   SID: 2.2   DATE OF SID: 11/16/95   RELEASE: 2 
c
      real       t0, t1, t2, t3, t4, t5
      save       t0, t1, t2, t3, t4, t5
c
      integer    nopx, nbx, nrorth, nitref, nrstrt
      real       tsaupd, tsaup2, tsaitr, tseigt, tsgets, tsapps, tsconv,
     &           tnaupd, tnaup2, tnaitr, tneigh, tngets, tnapps, tnconv,
     &           tcaupd, tcaup2, tcaitr, tceigh, tcgets, tcapps, tcconv,
     &           tmvopx, tmvbx, tgetv0, titref, trvec
      common /timing/ 
     &           nopx, nbx, nrorth, nitref, nrstrt,
     &           tsaupd, tsaup2, tsaitr, tseigt, tsgets, tsapps, tsconv,
     &           tnaupd, tnaup2, tnaitr, tneigh, tngets, tnapps, tnconv,
     &           tcaupd, tcaup2, tcaitr, tceigh, tcgets, tcapps, tcconv,
     &           tmvopx, tmvbx, tgetv0, titref, trvec
