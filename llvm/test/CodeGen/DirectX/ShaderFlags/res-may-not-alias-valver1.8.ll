; RUN: opt -S --passes="print-dx-shader-flags" 2>&1 %s | FileCheck %s

; This test checks to ensure the behavior of the DXIL shader flag analysis for
; the flag ResMayNotAlias is correct when the DXIL validator version is >= 1.8.
; The ResMayNotAlias flag (0x20000000) should only be set when a function uses a
; UAV.

target triple = "dxil-pc-shadermodel6.7-library"

; CHECK:      Combined Shader Flags for Module
; CHECK-NEXT: Shader Flags Value: 0x200000010

; CHECK: Note: extra DXIL module flags:
; CHECK:       Raw and Structured buffers
; CHECK:       Any UAV may not alias any other UAV
;

; CHECK: Function loadUAV : 0x20000000
define float @loadUAV() #0 {
  %res = call target("dx.TypedBuffer", float, 1, 0, 0)
      @llvm.dx.resource.handlefrombinding(i32 0, i32 0, i32 1, i32 0, i1 false)
  %load = call {float, i1} @llvm.dx.resource.load.typedbuffer(
      target("dx.TypedBuffer", float, 1, 0, 0) %res, i32 0)
  %val = extractvalue {float, i1} %load, 0
  ret float %val
}

; CHECK: Function loadSRV : 0x00000010
define float @loadSRV() #0 {
  %res = tail call target("dx.RawBuffer", float, 0, 0)
      @llvm.dx.resource.handlefrombinding(i32 0, i32 0, i32 1, i32 0, i1 false)
  %load = call {float, i1} @llvm.dx.resource.load.rawbuffer(
      target("dx.RawBuffer", float, 0, 0) %res, i32 0, i32 0)
  %val = extractvalue { float, i1 } %load, 0
  ret float %val
}

!dx.valver = !{!1}
!1 = !{i32 1, i32 8}

attributes #0 = { convergent norecurse nounwind "hlsl.export"}
