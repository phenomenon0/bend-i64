# bend-i64: package entry for BendHub.
# Source: https://github.com/phenomenon0/bend-i64
#
# SIGNED 64-bit integers, two's complement over Word(64n). add_comm is checked
# at 64 by instantiating Base's generic lemma Word.add_comm(64n, ...), and it
# transfers to the signed reading exactly because addition ignores the sign.
# Signedness lives in: neg (0 - x), cmp (bias both operands by the sign bit),
# shr.s (arithmetic shift). Pure Bend: no FFI, no intrinsics, no unsafe.
import Base
import ./i64.bend as I64

def zero() -> I64.I64:
  I64.zero()

def one() -> I64.I64:
  I64.one()

def minus_one() -> I64.I64:
  I64.minus_one()

def min() -> I64.I64:
  I64.min()

def max() -> I64.I64:
  I64.max()

def add(a: I64.I64, b: I64.I64) -> I64.I64:
  I64.add(a, b)

def sub(a: I64.I64, b: I64.I64) -> I64.I64:
  I64.sub(a, b)

def mul(a: I64.I64, b: I64.I64) -> I64.I64:
  I64.mul(a, b)

def inc(a: I64.I64) -> I64.I64:
  I64.inc(a)

def neg(a: I64.I64) -> I64.I64:
  I64.neg(a)

def and(a: I64.I64, b: I64.I64) -> I64.I64:
  I64.and(a, b)

def or(a: I64.I64, b: I64.I64) -> I64.I64:
  I64.or(a, b)

def xor(a: I64.I64, b: I64.I64) -> I64.I64:
  I64.xor(a, b)

def not(a: I64.I64) -> I64.I64:
  I64.not(a)

def shl(a: I64.I64) -> I64.I64:
  I64.shl(a)

def shl_n(n: Nat, a: I64.I64) -> I64.I64:
  I64.shl.n(n, a)

def shr(a: I64.I64) -> I64.I64:
  I64.shr(a)

def shr_s(a: I64.I64) -> I64.I64:
  I64.shr.s(a)

def shr_s_n(n: Nat, a: I64.I64) -> I64.I64:
  I64.shr.s.n(n, a)

def cmp(a: I64.I64, b: I64.I64) -> Cmp:
  I64.cmp(a, b)

def is_eq(a: I64.I64, b: I64.I64) -> Bool:
  I64.is_eq(a, b)

def is_lt(a: I64.I64, b: I64.I64) -> Bool:
  I64.is_lt(a, b)

def is_gt(a: I64.I64, b: I64.I64) -> Bool:
  I64.is_gt(a, b)

def is_neg(a: I64.I64) -> Bool:
  I64.is_neg(a)

def to_nat(a: I64.I64) -> Nat:
  I64.to_nat(a)
