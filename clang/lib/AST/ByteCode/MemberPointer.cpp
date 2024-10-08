//===------------------------- MemberPointer.cpp ----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MemberPointer.h"
#include "Context.h"
#include "FunctionPointer.h"
#include "Program.h"
#include "Record.h"

namespace clang {
namespace interp {

std::optional<Pointer> MemberPointer::toPointer(const Context &Ctx) const {
  if (!Dcl || isa<FunctionDecl>(Dcl))
    return Base;
  assert((isa<FieldDecl, IndirectFieldDecl>(Dcl)));

  if (!Base.isBlockPointer())
    return std::nullopt;

  Pointer CastedBase =
      (PtrOffset < 0 ? Base.atField(-PtrOffset) : Base.atFieldSub(PtrOffset));

  const Record *BaseRecord = CastedBase.getRecord();
  if (!BaseRecord)
    return std::nullopt;

  unsigned Offset = 0;
  Offset += CastedBase.block()->getDescriptor()->getMetadataSize();

  if (const auto *FD = dyn_cast<FieldDecl>(Dcl)) {
    if (FD->getParent() == BaseRecord->getDecl())
      return CastedBase.atField(BaseRecord->getField(FD)->Offset);

    const RecordDecl *FieldParent = FD->getParent();
    const Record *FieldRecord = Ctx.getRecord(FieldParent);

    Offset += FieldRecord->getField(FD)->Offset;
    if (Offset > CastedBase.block()->getSize())
      return std::nullopt;

    if (const RecordDecl *BaseDecl = Base.getDeclPtr().getRecord()->getDecl();
        BaseDecl != FieldParent)
      Offset += Ctx.collectBaseOffset(FieldParent, BaseDecl);

  } else {
    const auto *IFD = cast<IndirectFieldDecl>(Dcl);

    for (const NamedDecl *ND : IFD->chain()) {
      const FieldDecl *F = cast<FieldDecl>(ND);
      const RecordDecl *FieldParent = F->getParent();
      const Record *FieldRecord = Ctx.getRecord(FieldParent);
      Offset += FieldRecord->getField(F)->Offset;
    }
  }

  assert(BaseRecord);
  if (Offset > CastedBase.block()->getSize())
    return std::nullopt;

  assert(Offset <= CastedBase.block()->getSize());
  return Pointer(const_cast<Block *>(Base.block()), Offset, Offset);
}

FunctionPointer MemberPointer::toFunctionPointer(const Context &Ctx) const {
  return FunctionPointer(Ctx.getProgram().getFunction(cast<FunctionDecl>(Dcl)));
}

APValue MemberPointer::toAPValue(const ASTContext &ASTCtx) const {
  if (isZero())
    return APValue(static_cast<ValueDecl *>(nullptr), /*IsDerivedMember=*/false,
                   /*Path=*/{});

  if (hasBase())
    return Base.toAPValue(ASTCtx);

  return APValue(getDecl(), /*IsDerivedMember=*/false,
                 /*Path=*/{});
}

} // namespace interp
} // namespace clang
