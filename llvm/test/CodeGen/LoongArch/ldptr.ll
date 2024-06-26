; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc --mtriple=loongarch32 -mattr=+d < %s | FileCheck %s --check-prefix=LA32
; RUN: llc --mtriple=loongarch64 -mattr=+d < %s | FileCheck %s --check-prefix=LA64

;; Check that ldptr.w is not emitted for small offsets.
define signext i32 @ldptr_w_too_small_offset(ptr %p) nounwind {
; LA32-LABEL: ldptr_w_too_small_offset:
; LA32:       # %bb.0: # %entry
; LA32-NEXT:    ld.w $a0, $a0, 2044
; LA32-NEXT:    ret
;
; LA64-LABEL: ldptr_w_too_small_offset:
; LA64:       # %bb.0: # %entry
; LA64-NEXT:    ld.w $a0, $a0, 2044
; LA64-NEXT:    ret
entry:
  %addr = getelementptr inbounds i32, ptr %p, i64 511
  %val = load i32, ptr %addr, align 4
  ret i32 %val
}

;; Check that ldptr.w is emitted for applicable offsets.
define signext i32 @ldptr_w(ptr %p) nounwind {
; LA32-LABEL: ldptr_w:
; LA32:       # %bb.0: # %entry
; LA32-NEXT:    addi.w $a0, $a0, 2047
; LA32-NEXT:    addi.w $a0, $a0, 1
; LA32-NEXT:    ld.w $a0, $a0, 0
; LA32-NEXT:    ret
;
; LA64-LABEL: ldptr_w:
; LA64:       # %bb.0: # %entry
; LA64-NEXT:    ldptr.w $a0, $a0, 2048
; LA64-NEXT:    ret
entry:
  %addr = getelementptr inbounds i32, ptr %p, i64 512
  %val = load i32, ptr %addr, align 4
  ret i32 %val
}

;; Check that ldptr.w is not emitted for out-of-range offsets.
define signext i32 @ldptr_w_too_big_offset(ptr %p) nounwind {
; LA32-LABEL: ldptr_w_too_big_offset:
; LA32:       # %bb.0: # %entry
; LA32-NEXT:    lu12i.w $a1, 8
; LA32-NEXT:    add.w $a0, $a0, $a1
; LA32-NEXT:    ld.w $a0, $a0, 0
; LA32-NEXT:    ret
;
; LA64-LABEL: ldptr_w_too_big_offset:
; LA64:       # %bb.0: # %entry
; LA64-NEXT:    lu12i.w $a1, 8
; LA64-NEXT:    ldx.w $a0, $a0, $a1
; LA64-NEXT:    ret
entry:
  %addr = getelementptr inbounds i32, ptr %p, i64 8192
  %val = load i32, ptr %addr, align 4
  ret i32 %val
}

;; Check that ldptr.d is not emitted for small offsets.
define i64 @ldptr_d_too_small_offset(ptr %p) nounwind {
; LA32-LABEL: ldptr_d_too_small_offset:
; LA32:       # %bb.0: # %entry
; LA32-NEXT:    ld.w $a2, $a0, 2040
; LA32-NEXT:    ld.w $a1, $a0, 2044
; LA32-NEXT:    move $a0, $a2
; LA32-NEXT:    ret
;
; LA64-LABEL: ldptr_d_too_small_offset:
; LA64:       # %bb.0: # %entry
; LA64-NEXT:    ld.d $a0, $a0, 2040
; LA64-NEXT:    ret
entry:
  %addr = getelementptr inbounds i64, ptr %p, i64 255
  %val = load i64, ptr %addr, align 8
  ret i64 %val
}

;; Check that ldptr.d is emitted for applicable offsets.
define i64 @ldptr_d(ptr %p) nounwind {
; LA32-LABEL: ldptr_d:
; LA32:       # %bb.0: # %entry
; LA32-NEXT:    addi.w $a0, $a0, 2047
; LA32-NEXT:    addi.w $a1, $a0, 1
; LA32-NEXT:    ld.w $a0, $a1, 0
; LA32-NEXT:    ld.w $a1, $a1, 4
; LA32-NEXT:    ret
;
; LA64-LABEL: ldptr_d:
; LA64:       # %bb.0: # %entry
; LA64-NEXT:    ldptr.d $a0, $a0, 2048
; LA64-NEXT:    ret
entry:
  %addr = getelementptr inbounds i64, ptr %p, i64 256
  %val = load i64, ptr %addr, align 8
  ret i64 %val
}

;; Check that ldptr.d is not emitted for out-of-range offsets.
define i64 @ldptr_d_too_big_offset(ptr %p) nounwind {
; LA32-LABEL: ldptr_d_too_big_offset:
; LA32:       # %bb.0: # %entry
; LA32-NEXT:    lu12i.w $a1, 8
; LA32-NEXT:    add.w $a1, $a0, $a1
; LA32-NEXT:    ld.w $a0, $a1, 0
; LA32-NEXT:    ld.w $a1, $a1, 4
; LA32-NEXT:    ret
;
; LA64-LABEL: ldptr_d_too_big_offset:
; LA64:       # %bb.0: # %entry
; LA64-NEXT:    lu12i.w $a1, 8
; LA64-NEXT:    ldx.d $a0, $a0, $a1
; LA64-NEXT:    ret
entry:
  %addr = getelementptr inbounds i64, ptr %p, i64 4096
  %val = load i64, ptr %addr, align 8
  ret i64 %val
}
