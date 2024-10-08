; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

target datalayout = "e-m:e-i64:64-n8:16:32:64"

; Although i1 is not in the datalayout, we should treat it
; as a legal type because it is a fundamental type in IR.
; This means we should shrink the phi (sink the zexts).

define i64 @sink_i1_casts(i1 %cond1, i1 %cond2, i1 %cond) {
; CHECK-LABEL: define i64 @sink_i1_casts(
; CHECK-SAME: i1 [[COND1:%.*]], i1 [[COND2:%.*]], i1 [[COND:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    br i1 [[COND]], label %[[IF:.*]], label %[[END:.*]]
; CHECK:       [[IF]]:
; CHECK-NEXT:    br label %[[END]]
; CHECK:       [[END]]:
; CHECK-NEXT:    [[PHI_IN1:%.*]] = phi i1 [ [[COND1]], %[[ENTRY]] ], [ [[COND2]], %[[IF]] ]
; CHECK-NEXT:    [[PHI_IN:%.*]] = zext i1 [[PHI_IN1]] to i64
; CHECK-NEXT:    ret i64 [[PHI_IN]]
;
entry:
  %z1 = zext i1 %cond1 to i64
  br i1 %cond, label %if, label %end

if:
  %z2 = zext i1 %cond2 to i64
  br label %end

end:
  %phi = phi i64 [ %z1, %entry ], [ %z2, %if ]
  ret i64 %phi
}

